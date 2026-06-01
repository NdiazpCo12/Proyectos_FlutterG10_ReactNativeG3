import {
  repairMojibake,
  normalizeDisplayText,
  normalizeDeepText,
} from './text';

// ── repairMojibake ──

describe('repairMojibake', () => {
  it('restores a mojibake UTF-8 string to its correct form', () => {
    const corrupted = 'DÃ©veloppement';
    const result = repairMojibake(corrupted);
    expect(result).toBe('Développement');
  });

  it('passes through clean text unchanged', () => {
    const clean = 'hello world';
    expect(repairMojibake(clean)).toBe(clean);
  });

  it('returns an empty string as-is', () => {
    expect(repairMojibake('')).toBe('');
  });

  it('passes through text without any mojibake patterns', () => {
    const text = 'café résumé façade';
    expect(repairMojibake(text)).toBe(text);
  });
});

// ── normalizeDisplayText ──

describe('normalizeDisplayText', () => {
  it('returns fallback for null', () => {
    expect(normalizeDisplayText(null)).toBe('');
  });

  it('returns fallback for undefined', () => {
    expect(normalizeDisplayText(undefined)).toBe('');
  });

  it('returns custom fallback when provided', () => {
    expect(normalizeDisplayText(null, 'N/A')).toBe('N/A');
  });

  it('converts a number to its string representation', () => {
    expect(normalizeDisplayText(42)).toBe('42');
  });

  it('repairs mojibake in string value', () => {
    const corrupted = 'MÃ¼nchen';
    expect(normalizeDisplayText(corrupted)).toBe('München');
  });
});

// ── normalizeDeepText ──

describe('normalizeDeepText', () => {
  it('repairs a plain string', () => {
    expect(normalizeDeepText('crÃ¨me')).toBe('crème');
  });

  it('recursively repairs strings inside an object', () => {
    const input = { name: 'DÃ©veloppement', code: 'ABC' };
    const result = normalizeDeepText(input);
    expect(result.name).toBe('Développement');
    expect(result.code).toBe('ABC');
  });

  it('repairs strings inside an array', () => {
    const input = ['hello', 'MÃ¼nchen'];
    const result = normalizeDeepText(input);
    expect(result[0]).toBe('hello');
    expect(result[1]).toBe('München');
  });

  it('repairs deeply nested strings', () => {
    const input = {
      items: [{ label: 'crÃ¨me brÃ»lÃ©e' }],
    };
    const result = normalizeDeepText(input);
    expect(result.items[0].label).toBe('crème brûlée');
  });

  it('passes through numbers unchanged', () => {
    expect(normalizeDeepText(42)).toBe(42);
  });

  it('passes through booleans unchanged', () => {
    expect(normalizeDeepText(true)).toBe(true);
    expect(normalizeDeepText(false)).toBe(false);
  });
});
