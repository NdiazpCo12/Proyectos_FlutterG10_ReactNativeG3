const mojibakePattern =
  /(?:Ã.|Â.|â€|â€™|â€œ|â€�|â€“|â€”|â€¢|â€¦|ï¿½|�)/;

const suspiciousChars = /[ÃÂâ]|ï¿½|�/g;

const countSuspicious = (value: string) =>
  value.match(suspiciousChars)?.length ?? 0;

const decodeLatin1Bytes = (value: string) => {
  let encoded = '';

  for (let index = 0; index < value.length; index += 1) {
    const code = value.charCodeAt(index);
    if (code > 0xff) return value;
    encoded += `%${code.toString(16).padStart(2, '0')}`;
  }

  try {
    return decodeURIComponent(encoded);
  } catch {
    return value;
  }
};

export const repairMojibake = (value: string) => {
  if (!value || !mojibakePattern.test(value)) return value;

  const repaired = decodeLatin1Bytes(value);
  return countSuspicious(repaired) < countSuspicious(value) ? repaired : value;
};

export const normalizeDisplayText = (value: unknown, fallback = '') =>
  repairMojibake(value?.toString() ?? fallback);

export const normalizeDeepText = <T>(value: T): T => {
  if (typeof value === 'string') {
    return normalizeDisplayText(value) as T;
  }

  if (Array.isArray(value)) {
    return value.map((item) => normalizeDeepText(item)) as T;
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, normalizeDeepText(item)]),
    ) as T;
  }

  return value;
};
