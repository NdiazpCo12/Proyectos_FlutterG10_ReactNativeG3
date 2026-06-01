import { normalizeDisplayText } from './text';

export const formatDate = (date: Date) => {
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  return `${day}/${month}/${date.getFullYear()}`;
};

export const average = (values: number[]) => {
  if (values.length === 0) return 0;
  return values.reduce((sum, value) => sum + value, 0) / values.length;
};

export const userMessage = (error: unknown, fallback: string) => {
  if (error instanceof Error && error.message.trim()) {
    return normalizeDisplayText(error.message.replace(/^Exception:\s*/i, ''));
  }
  return normalizeDisplayText(fallback);
};
