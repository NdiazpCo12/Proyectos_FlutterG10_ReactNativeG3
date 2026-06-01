import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/auth_exception.dart';
import '../../../core/errors/error_message_formatter.dart';
import '../../../core/roble/roble.dart';
import '../../login/services/auth_service.dart';
import '../controllers/teacher_home_controller.dart';
import '../models/csv_row.dart';

class CreateCourseController extends GetxController {
  CreateCourseController({RobleApiService? apiService})
    : _api = apiService ?? RobleApiService();

  final RobleApiService _api;

  final isLoading = false.obs;
  final statusMessage = ''.obs;
  final progress = 0.0.obs;

  Future<void> pickAndUpload(String courseName) async {
    final trimmedCourseName = courseName.trim();
    if (trimmedCourseName.isEmpty) {
      Get.snackbar(
        'Campo requerido',
        'Por favor ingresa el nombre del curso.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    isLoading.value = true;
    progress.value = 0;

    var replacedExistingCategory = false;
    var categoryName = '';

    try {
      _setStatus('Leyendo archivo CSV...');
      final rows = await _parseCsv(result.files.first);

      if (rows.isEmpty) {
        throw Exception('El archivo CSV esta vacio o no tiene filas validas.');
      }

      categoryName = _resolveCategoryName(rows);

      final authService = Get.find<AuthService>();
      final user = await authService.getStoredUser();
      final teacherEmail = user?.email ?? 'profesor@uninorte.edu.co';

      _setStatus('Registrando cuentas de estudiantes...');
      await _ensureStudentAccounts(rows, authService);

      final courseId = await _resolveCourseId(
        courseName: trimmedCourseName,
        teacherEmail: teacherEmail,
        rows: rows,
      );

      final categoryResult = await _prepareCategoryForUpload(
        courseId: courseId,
        categoryName: categoryName,
      );
      replacedExistingCategory = categoryResult.replacedExistingData;

      _setStatus('Creando grupos...');
      final groupIds = await _insertUniqueGroups(
        rows,
        courseId,
        categoryResult.categoryId,
      );

      _setStatus('Procesando estudiantes...');
      final studentIds = await _resolveStudentIds(rows);

      _setStatus('Vinculando estudiantes a grupos...');
      await _insertGroupMembers(rows, studentIds, groupIds);

      _setStatus('Importacion completada.');
      final actionLabel = replacedExistingCategory ? 'actualizo' : 'cargo';
      Get.snackbar(
        'Exito',
        'La categoria "$categoryName" se $actionLabel en "$trimmedCourseName" con ${studentIds.length} estudiantes.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      Get.find<TeacherHomeController>().fetchCourses();
    } catch (e) {
      final message = formatUserErrorMessage(
        e,
        fallback: 'No se pudo completar la importacion del archivo.',
      );
      _setStatus('Error: $message');
      Get.snackbar(
        'Error al importar CSV',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CsvRow>> _parseCsv(PlatformFile file) async {
    String content;
    if (file.bytes != null) {
      content = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      throw Exception('No se pudo leer el archivo seleccionado.');
    }

    final rawRows = const CsvToListConverter(eol: '\n').convert(content);

    final startIndex =
        (rawRows.isNotEmpty &&
            rawRows.first.first.toString().contains('Group Category'))
        ? 1
        : 0;

    return rawRows
        .skip(startIndex)
        .where(
          (row) =>
              row.isNotEmpty &&
              row.any((cell) => cell.toString().trim().isNotEmpty),
        )
        .map(CsvRow.fromList)
        .toList();
  }

  String _resolveCategoryName(List<CsvRow> rows) {
    final categoryNames = rows
        .map((row) => row.groupCategoryName.trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    if (categoryNames.length > 1) {
      throw Exception(
        'El CSV debe contener una sola categoria por carga. Categorias encontradas: ${categoryNames.join(', ')}',
      );
    }

    return categoryNames.isEmpty ? 'Categoria General' : categoryNames.first;
  }

  Future<String> _resolveCourseId({
    required String courseName,
    required String teacherEmail,
    required List<CsvRow> rows,
  }) async {
    final existingCourse = await _findExistingCourse(
      courseName: courseName,
      teacherEmail: teacherEmail,
    );

    if (existingCourse != null) {
      _setStatus('Reutilizando curso "$courseName"...');
      return existingCourse.id;
    }

    _setStatus('Creando curso "$courseName"...');
    final courseCode = rows.first.groupCode.isNotEmpty
        ? rows.first.groupCode
        : courseName.replaceAll(' ', '_').toUpperCase();

    final courseObj = RobleCourse(
      name: courseName,
      code: courseCode,
      description: rows.first.groupCategoryName.isNotEmpty
          ? rows.first.groupCategoryName
          : 'Curso importado desde CSV',
      teacherEmail: teacherEmail,
    );
    log(
      '=== Enviando payload a courses ===\n${courseObj.toJson()}',
      name: 'CreateCourseController',
    );

    return _api.insert('courses', courseObj.toJson());
  }

  Future<RobleCourseHome?> _findExistingCourse({
    required String courseName,
    required String teacherEmail,
  }) async {
    final rows = await _api.read(
      'courses',
      filters: {'name': courseName, 'teacher_email': teacherEmail},
    );
    if (rows.isEmpty) {
      return null;
    }

    final courses = rows
        .map(RobleCourseHome.fromJson)
        .where((course) => course.id.isNotEmpty)
        .toList();
    if (courses.isEmpty) {
      return null;
    }

    courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return courses.first;
  }

  Future<_CategoryPreparationResult> _prepareCategoryForUpload({
    required String courseId,
    required String categoryName,
  }) async {
    final existingRows = await _api.read(
      'group_categories',
      filters: {'course_id': courseId, 'name': categoryName},
    );
    final existingCategories = existingRows
        .map(RobleGroupCategoryRecord.fromJson)
        .where((category) => category.id.isNotEmpty)
        .toList();

    var replacedExistingData = false;
    if (existingCategories.isNotEmpty) {
      replacedExistingData = true;
      _setStatus(
        'La categoria "$categoryName" ya existe. Eliminando datos anteriores...',
      );

      for (final category in existingCategories) {
        await _deleteCategoryData(category);
      }
    }

    _setStatus('Creando categoria "$categoryName"...');
    final categoryObj = RobleGroupCategory(
      name: categoryName,
      courseId: courseId,
    );
    log(
      '=== Enviando payload a group_categories ===\n${categoryObj.toJson()}',
      name: 'CreateCourseController',
    );

    final categoryId = await _api.insert(
      'group_categories',
      categoryObj.toJson(),
    );
    return _CategoryPreparationResult(
      categoryId: categoryId,
      replacedExistingData: replacedExistingData,
    );
  }

  Future<void> _deleteCategoryData(RobleGroupCategoryRecord category) async {
    _setStatus('Eliminando grupos y membresias de "${category.name}"...');

    final groupRows = await _api.read(
      'course_groups',
      filters: {'category_id': category.id},
    );
    final groups = groupRows
        .map(RobleCourseGroupRecord.fromJson)
        .where((group) => group.id.isNotEmpty)
        .toList();

    final membershipIds = <String>{};
    final affectedStudentIds = <String>{};

    for (final group in groups) {
      final membershipRows = await _api.read(
        'group_members',
        filters: {'group_id': group.id},
      );
      final memberships = membershipRows
          .map(RobleGroupMemberRecord.fromJson)
          .where((membership) => membership.id.isNotEmpty)
          .toList();

      for (final membership in memberships) {
        membershipIds.add(membership.id);
        if (membership.studentId.isNotEmpty) {
          affectedStudentIds.add(membership.studentId);
        }
      }
    }

    for (final membershipId in membershipIds) {
      await _api.deleteById('group_members', membershipId);
    }

    for (final group in groups) {
      await _api.deleteById('course_groups', group.id);
    }

    await _api.deleteById('group_categories', category.id);

    for (final studentId in affectedStudentIds) {
      final remainingMemberships = await _api.read(
        'group_members',
        filters: {'student_id': studentId},
      );

      if (remainingMemberships.isEmpty) {
        await _api.deleteById('students', studentId);
      }
    }
  }

  Future<Map<String, String>> _insertUniqueGroups(
    List<CsvRow> rows,
    String courseId,
    String categoryId,
  ) async {
    final seen = <String, String>{};
    var done = 0;

    for (final row in rows) {
      if (seen.containsKey(row.groupCode)) {
        continue;
      }

      final groupObj = RobleCourseGroup(
        name: row.groupName.isNotEmpty ? row.groupName : 'Grupo sin nombre',
        code: row.groupCode.isNotEmpty ? row.groupCode : 'GC',
        categoryId: categoryId,
        courseId: courseId,
      );

      log(
        '=== Enviando payload a course_groups ===\n${groupObj.toJson()}',
        name: 'CreateCourseController',
      );
      final id = await _api.insert('course_groups', groupObj.toJson());

      seen[row.groupCode] = id;
      done++;
      _setStatus('Grupos: $done insertados...');
    }

    return seen;
  }

  Future<void> _ensureStudentAccounts(
    List<CsvRow> rows,
    AuthService authService,
  ) async {
    final studentsByEmail = <String, CsvRow>{};

    for (final row in rows) {
      final normalizedEmail = _normalizeEmail(row.email);
      if (normalizedEmail.isEmpty) {
        continue;
      }
      studentsByEmail.putIfAbsent(normalizedEmail, () => row);
    }

    final total = studentsByEmail.length;
    var done = 0;

    for (final entry in studentsByEmail.entries) {
      final email = entry.key;
      final row = entry.value;

      try {
        await authService.signUpDirect(
          email: email,
          password: AuthService.defaultUserPassword,
          name: _buildStudentName(row),
        );
      } on AuthException catch (error) {
        if (!_isExistingAccountError(error)) {
          rethrow;
        }
      }

      done++;
      progress.value = total == 0 ? 0 : done / total;
      _setStatus('Cuentas de estudiantes: $done procesadas...');
    }
  }

  Future<Map<String, String>> _resolveStudentIds(List<CsvRow> rows) async {
    final seen = <String, String>{};
    final uniqueEmails = rows
        .map((row) => _normalizeEmail(row.email))
        .where((email) => email.isNotEmpty)
        .toSet();
    final total = uniqueEmails.length;
    var done = 0;

    for (final row in rows) {
      final normalizedEmail = _normalizeEmail(row.email);
      if (normalizedEmail.isEmpty || seen.containsKey(normalizedEmail)) {
        continue;
      }

      final existingRows = await _api.read(
        'students',
        filters: {'email': normalizedEmail},
      );
      if (existingRows.isNotEmpty) {
        final existingStudent = RobleStudentRecord.fromJson(existingRows.first);
        if (existingStudent.id.isNotEmpty) {
          seen[normalizedEmail] = existingStudent.id;
          done++;
          progress.value = total == 0 ? 0 : done / total;
          _setStatus('Estudiantes: $done procesados...');
          continue;
        }
      }

      final studentObj = RobleStudent(
        username: row.username.isNotEmpty
            ? row.username
            : normalizedEmail.split('@').first,
        orgId: row.orgDefinedId.isNotEmpty ? row.orgDefinedId : '00000',
        firstName: row.firstName.isNotEmpty ? row.firstName : 'Sin nombre',
        lastName: row.lastName.isNotEmpty ? row.lastName : 'Sin apellido',
        email: normalizedEmail.isNotEmpty
            ? normalizedEmail
            : 'correo@invalido.com',
      );

      log(
        '=== Enviando payload a students ===\n${studentObj.toJson()}',
        name: 'CreateCourseController',
      );
      final id = await _api.insert('students', studentObj.toJson());

      seen[normalizedEmail] = id;
      done++;
      progress.value = total == 0 ? 0 : done / total;
      _setStatus('Estudiantes: $done procesados...');
    }

    return seen;
  }

  Future<void> _insertGroupMembers(
    List<CsvRow> rows,
    Map<String, String> studentIds,
    Map<String, String> groupIds,
  ) async {
    var done = 0;

    for (final row in rows) {
      final studentId = studentIds[_normalizeEmail(row.email)];
      final groupId = groupIds[row.groupCode];

      if (studentId == null || groupId == null) {
        continue;
      }

      final originalDate = row.enrollmentDate;
      final formattedDate = _formatSpanishDate(originalDate);
      log(
        'Fecha convertida: $originalDate -> $formattedDate',
        name: 'CreateCourseController',
      );

      final memberObj = RobleGroupMember(
        studentId: studentId,
        groupId: groupId,
        enrollmentDate: formattedDate,
      );

      log(
        '=== Enviando payload a group_members ===\n${memberObj.toJson()}',
        name: 'CreateCourseController',
      );
      await _api.insert('group_members', memberObj.toJson());

      done++;
      _setStatus('Membresias: $done/${rows.length}...');
    }
  }

  void _setStatus(String msg) => statusMessage.value = msg;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _buildStudentName(CsvRow row) {
    final fullName = '${row.firstName.trim()} ${row.lastName.trim()}'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (row.username.trim().isNotEmpty) {
      return row.username.trim();
    }

    final email = _normalizeEmail(row.email);
    return email.isNotEmpty ? email.split('@').first : 'Estudiante';
  }

  bool _isExistingAccountError(AuthException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == 409 ||
        message.contains('already') ||
        message.contains('exists') ||
        message.contains('exist') ||
        message.contains('duplicate') ||
        message.contains('duplicado') ||
        message.contains('ya existe') ||
        message.contains('registrado');
  }

  String _formatSpanishDate(String date) {
    if (date.isEmpty) {
      return DateTime.now().toIso8601String();
    }

    final months = {
      'enero': '01',
      'febrero': '02',
      'marzo': '03',
      'abril': '04',
      'mayo': '05',
      'junio': '06',
      'julio': '07',
      'agosto': '08',
      'septiembre': '09',
      'octubre': '10',
      'noviembre': '11',
      'diciembre': '12',
    };

    try {
      final parts = date.toLowerCase().split(' ');
      if (parts.length >= 6) {
        final day = parts[0].padLeft(2, '0');
        final monthStr = months[parts[2]] ?? '01';
        final year = parts[4];
        final time = parts[5];
        return '$year-$monthStr-$day $time:00';
      }
    } catch (_) {}

    return DateTime.now().toIso8601String();
  }
}

class _CategoryPreparationResult {
  const _CategoryPreparationResult({
    required this.categoryId,
    required this.replacedExistingData,
  });

  final String categoryId;
  final bool replacedExistingData;
}
