import Papa from 'papaparse';

import { TeacherCsvImportRow } from '../../domain/entities/teacherModels';

export type TeacherCsvPreview = {
  rows: TeacherCsvImportRow[];
  categoryName: string;
  errors: string[];
};

const cell = (row: unknown[], index: number) => String(row[index] ?? '').trim();

export const parseTeacherCsvText = (csvText: string): TeacherCsvPreview => {
  const parsed = Papa.parse<unknown[]>(csvText, {
    skipEmptyLines: 'greedy',
  });

  const sourceRows = parsed.data.filter(
    (row): row is unknown[] => Array.isArray(row),
  );
  if (sourceRows.length === 0) {
    return {
      rows: [],
      categoryName: '',
      errors: ['El archivo CSV está vacío o no tiene filas válidas.'],
    };
  }

  const hasHeader = sourceRows[0].some((value: unknown) =>
    String(value).toLowerCase().includes('group category'),
  );
  const dataRows = (hasHeader ? sourceRows.slice(1) : sourceRows).filter((row) =>
    row.some((value: unknown) => String(value ?? '').trim()),
  );

  const rows: TeacherCsvImportRow[] = dataRows.map((row) => ({
    groupCategoryName: cell(row, 0),
    groupName: cell(row, 1),
    groupCode: cell(row, 2),
    username: cell(row, 3),
    orgDefinedId: cell(row, 4),
    firstName: cell(row, 5),
    lastName: cell(row, 6),
    email: cell(row, 7).toLowerCase(),
    enrollmentDate: cell(row, 8),
  }));

  const errors: string[] = [];
  const categoryNames = new Set(
    rows.map((row) => row.groupCategoryName).filter(Boolean),
  );
  if (categoryNames.size > 1) {
    errors.push('El CSV debe contener una sola categoría por carga.');
  }

  if (rows.some((row) => !row.email)) {
    errors.push('Todas las filas deben incluir el correo del estudiante.');
  }

  if (rows.some((row) => !row.groupName && !row.groupCode)) {
    errors.push('Todas las filas deben incluir un nombre o código de grupo.');
  }

  return {
    rows,
    categoryName: [...categoryNames][0] ?? 'Categoria General',
    errors,
  };
};
