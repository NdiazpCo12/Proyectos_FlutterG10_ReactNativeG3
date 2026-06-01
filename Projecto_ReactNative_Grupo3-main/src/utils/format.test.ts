import { formatDate, average, userMessage } from './format';

// ── formatDate ──

describe('formatDate', () => {
  it('formats a valid date as dd/mm/yyyy', () => {
    const date = new Date(2025, 2, 11); // 11 Mar 2025
    expect(formatDate(date)).toBe('11/03/2025');
  });

  it('formats the last day of a month', () => {
    const date = new Date(2025, 0, 31); // 31 Jan 2025
    expect(formatDate(date)).toBe('31/01/2025');
  });

  it('pads single-digit days and months with leading zero', () => {
    const date = new Date(2025, 0, 5); // 5 Jan 2025
    expect(formatDate(date)).toBe('05/01/2025');
  });

  it('formats a date in December', () => {
    const date = new Date(2025, 11, 25); // 25 Dec 2025
    expect(formatDate(date)).toBe('25/12/2025');
  });
});

// ── average ──

describe('average', () => {
  it('returns 0 for an empty array', () => {
    expect(average([])).toBe(0);
  });

  it('returns the single element for a one-element array', () => {
    expect(average([5])).toBe(5);
  });

  it('computes the arithmetic mean for multiple values', () => {
    expect(average([2, 4, 6])).toBe(4);
  });

  it('handles an array of all zeros', () => {
    expect(average([0, 0, 0])).toBe(0);
  });

  it('handles decimal results', () => {
    expect(average([1, 2])).toBe(1.5);
  });
});

// ── userMessage ──

describe('userMessage', () => {
  it('extracts the message from an Error instance', () => {
    const error = new Error('Something went wrong');
    expect(userMessage(error, 'default')).toBe('Something went wrong');
  });

  it('strips the "Exception:" prefix from error messages', () => {
    const error = new Error('Exception: Invalid input');
    expect(userMessage(error, 'default')).toBe('Invalid input');
  });

  it('returns fallback when error message is empty', () => {
    const error = new Error('');
    expect(userMessage(error, 'No details')).toBe('No details');
  });

  it('returns fallback for a non-Error value', () => {
    expect(userMessage('just a string', 'default message')).toBe(
      'default message',
    );
  });

  it('returns fallback for null error', () => {
    expect(userMessage(null, 'fallback')).toBe('fallback');
  });
});
