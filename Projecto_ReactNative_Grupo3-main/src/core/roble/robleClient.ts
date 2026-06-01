import axios, { AxiosInstance } from 'axios';

import { robleConfig } from '../../config/robleConfig';
import { sessionStorage } from '../local/LocalPreferencesAsyncStorage';
import { normalizeDeepText, normalizeDisplayText } from '../../utils/text';
import { JsonRecord } from './models';

type CacheEntry = {
  rows: JsonRecord[];
  expiresAt: number;
};

const readCache = new Map<string, CacheEntry>();
const ttlMs = 20_000;

const sanitizePayload = (data: JsonRecord) =>
  Object.fromEntries(
    Object.entries(data).map(([key, value]) => [
      key,
      value === null || value === undefined ? '' : value,
    ]),
  );

const cacheKeyFor = (table: string, filters: JsonRecord) => {
  const query = Object.entries(filters)
    .filter(([, value]) => value !== undefined && value !== null)
    .map(([key, value]) => [key, String(value).trim()])
    .filter(([, value]) => value)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}=${value}`)
    .join('&');
  return query ? `${table}?${query}` : table;
};

class RobleClient {
  private client?: AxiosInstance;

  private async http() {
    const token = await sessionStorage.getAccessToken();
    this.client ??= axios.create({
      baseURL: robleConfig.dbBaseUrl,
      timeout: 15000,
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    });
    this.client.defaults.headers.common.Authorization = `Bearer ${token ?? ''}`;
    return this.client;
  }

  private invalidate() {
    readCache.clear();
  }

  async read(table: string, filters: JsonRecord = {}) {
    const cacheKey = cacheKeyFor(table, filters);
    const cached = readCache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) {
      return cached.rows.map((row) => ({ ...row }));
    }

    const client = await this.http();
    const query: JsonRecord = { tableName: table };
    Object.entries(filters).forEach(([key, value]) => {
      const normalized = value?.toString().trim() ?? '';
      if (normalized) query[key] = normalized;
    });

    try {
      const response = await client.get('/read', { params: query });
      if (!Array.isArray(response.data)) {
        throw new Error('No fue posible leer la información solicitada.');
      }
      const rows = response.data
        .filter((row): row is JsonRecord => row && typeof row === 'object')
        .map((row) => normalizeDeepText(row));
      readCache.set(cacheKey, { rows, expiresAt: Date.now() + ttlMs });
      return rows.map((row) => ({ ...row }));
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const detail = normalizeDisplayText(
          error.response?.data?.message ?? error.message,
        );
        throw new Error(
          `No se pudo cargar la información: ${detail}`,
        );
      }
      throw error;
    }
  }

  async insert(table: string, data: JsonRecord) {
    const client = await this.http();
    try {
      const response = await client.post('/insert', {
        tableName: table,
        records: [sanitizePayload(data)],
      });
      const skipped = response.data?.skipped;
      if (Array.isArray(skipped) && skipped.length > 0) {
        throw new Error(`Registro omitido: ${skipped[0]?.reason ?? ''}`);
      }
      const inserted = response.data?.inserted;
      const firstRecord = Array.isArray(inserted) ? inserted[0] : undefined;
      const id = firstRecord?._id ?? firstRecord?.id;
      if (!id) throw new Error('No fue posible guardar la información.');
      this.invalidate();
      return id.toString();
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const detail = normalizeDisplayText(
          error.response?.data?.message ?? error.message,
        );
        throw new Error(
          `No se pudo guardar la información: ${detail}`,
        );
      }
      throw error;
    }
  }

  async update(
    table: string,
    idColumn: string,
    idValue: string,
    data: JsonRecord,
  ) {
    if (!idValue.trim()) return;
    const client = await this.http();
    const record = sanitizePayload(data);
    const payloads = ['record', 'data', 'updates', 'newData'].map((key) => ({
      tableName: table,
      idColumn,
      idValue,
      [key]: record,
    }));

    let lastError: unknown;
    for (const payload of payloads) {
      try {
        await client.put('/update', payload);
        this.invalidate();
        return;
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError instanceof Error
      ? lastError
      : new Error('No fue posible actualizar la información.');
  }

  async delete(table: string, idColumn: string, idValue: string) {
    if (!idValue.trim()) return;
    const client = await this.http();
    await client.delete('/delete', {
      data: { tableName: table, idColumn, idValue },
    });
    this.invalidate();
  }

  deleteById(table: string, idValue: string) {
    return this.delete(table, '_id', idValue);
  }
}

export const robleClient = new RobleClient();
