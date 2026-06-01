import { parseTeacherCsvText } from './csvImport';
import type { TeacherCsvPreview } from './csvImport';

// ── parseTeacherCsvText ──

describe('parseTeacherCsvText', () => {
  it('parses a valid CSV with header row', () => {
    const csv =
      'Group Category,Group Name,Group Code,Username,Org ID,First Name,Last Name,Email,Enrollment Date\n' +
      'Categoria A,Grupo 1,G001,user1,1001,Juan,Perez,juan@test.com,2025-01-01';

    const result = parseTeacherCsvText(csv);
    expect(result.rows).toHaveLength(1);
    expect(result.rows[0].groupCategoryName).toBe('Categoria A');
    expect(result.rows[0].groupName).toBe('Grupo 1');
    expect(result.rows[0].email).toBe('juan@test.com');
    expect(result.categoryName).toBe('Categoria A');
    expect(result.errors).toHaveLength(0);
  });

  it('parses CSV without a header row', () => {
    const csv = 'MyCategory,MyGroup,MG01,userx,1002,Ana,Lopez,ana@test.com,2025-02-01';

    const result = parseTeacherCsvText(csv);
    expect(result.rows).toHaveLength(1);
    expect(result.rows[0].groupCategoryName).toBe('MyCategory');
    expect(result.categoryName).toBe('MyCategory');
  });

  it('returns an error for empty CSV input', () => {
    const result = parseTeacherCsvText('');
    expect(result.rows).toHaveLength(0);
    expect(result.errors).toContain(
      'El archivo CSV está vacío o no tiene filas válidas.',
    );
  });

  it('validates multiple categories as an error', () => {
    const csv =
      'Group Category,Group Name,Group Code,Username,Org ID,First Name,Last Name,Email,Enrollment Date\n' +
      'Cat A,G1,GC1,u1,1,A,B,a@t.com,\n' +
      'Cat B,G2,GC2,u2,2,C,D,b@t.com,';
    const result = parseTeacherCsvText(csv);
    expect(result.errors).toContain(
      'El CSV debe contener una sola categoría por carga.',
    );
  });

  it('validates missing email as an error', () => {
    const csv =
      'Group Category,Group Name,Group Code,Username,Org ID,First Name,Last Name,Email,Enrollment Date\n' +
      'Cat A,G1,GC1,u1,1,A,B,,';
    const result = parseTeacherCsvText(csv);
    expect(result.errors).toContain(
      'Todas las filas deben incluir el correo del estudiante.',
    );
  });

  it('parses multiple rows correctly', () => {
    const csv =
      'Group Category,Group Name,Group Code,Username,Org ID,First Name,Last Name,Email,Enrollment Date\n' +
      'Cat A,G1,GC1,u1,1,A,B,a@t.com,\n' +
      'Cat A,G2,GC2,u2,2,C,D,b@t.com,';
    const result = parseTeacherCsvText(csv);
    expect(result.rows).toHaveLength(2);
    expect(result.errors).toHaveLength(0);
  });
});
