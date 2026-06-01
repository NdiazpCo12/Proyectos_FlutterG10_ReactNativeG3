import 'dart:developer';

import 'package:dio/dio.dart';

import '../../storage/session_storage_service.dart';
import '../models/roble_models.dart';
import '../roble_config.dart';

/// Handles all HTTP requests to the ROBLE database API.
/// Uses the access token persisted by [SessionStorageService] after login.
class RobleApiService {
  RobleApiService({SessionStorageService? storage})
    : _storage = storage ?? SessionStorageService();

  final SessionStorageService _storage;
  static const Duration _readCacheTtl = Duration(seconds: 20);

  Dio? _dio;
  int? _preferredUpdatePayloadIndex;
  final Map<String, _ReadCacheEntry> _readCache = <String, _ReadCacheEntry>{};
  final Map<String, Future<List<Map<String, dynamic>>>> _pendingReads =
      <String, Future<List<Map<String, dynamic>>>>{};

  Future<Dio> _client() async {
    final token = await _storage.getAccessToken();
    _dio ??= Dio(
      BaseOptions(
        baseUrl: RobleConfig.dbBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );
    _dio!.options.headers['Authorization'] = 'Bearer ${token ?? ''}';
    return _dio!;
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value == null) {
        sanitized[entry.key] = '';
      } else if (entry.value is String &&
          (entry.value as String).trim().isEmpty) {
        sanitized[entry.key] = '';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  Future<List<Map<String, dynamic>>> read(
    String table, {
    Map<String, dynamic> filters = const {},
  }) async {
    final cacheKey = _buildReadCacheKey(table, filters);
    final cachedEntry = _readCache[cacheKey];
    final now = DateTime.now();
    if (cachedEntry != null && cachedEntry.expiresAt.isAfter(now)) {
      return cachedEntry.rows
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);
    }

    final pending = _pendingReads[cacheKey];
    if (pending != null) {
      final rows = await pending;
      return rows.map((row) => Map<String, dynamic>.from(row)).toList();
    }

    final future = _performRead(table, filters: filters);
    _pendingReads[cacheKey] = future;
    try {
      final rows = await future;
      _readCache[cacheKey] = _ReadCacheEntry(
        rows: rows.map((row) => Map<String, dynamic>.from(row)).toList(),
        expiresAt: now.add(_readCacheTtl),
      );
      return rows.map((row) => Map<String, dynamic>.from(row)).toList();
    } finally {
      _pendingReads.remove(cacheKey);
    }
  }

  Future<List<Map<String, dynamic>>> _performRead(
    String table, {
    Map<String, dynamic> filters = const {},
  }) async {
    final client = await _client();
    final queryParameters = <String, dynamic>{'tableName': table};

    for (final entry in filters.entries) {
      if (entry.value == null) continue;
      final value = entry.value.toString().trim();
      if (value.isEmpty) continue;
      queryParameters[entry.key] = value;
    }

    try {
      final response = await client.get(
        '/read',
        queryParameters: queryParameters,
      );
      final body = response.data;

      if (body is List) {
        return body
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      }

      throw Exception('No fue posible leer la informacion solicitada.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('No se pudo cargar la informacion: $msg');
    }
  }

  /// Inserts [data] into [table] and returns the auto-generated `_id`.
  Future<String> insert(String table, Map<String, dynamic> data) async {
    final client = await _client();
    final sanitizedData = _sanitizePayload(data);
    final payload = {
      'tableName': table,
      'records': [sanitizedData],
    };

    try {
      final response = await client.post('/insert', data: payload);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final skipped = body['skipped'];
        if (skipped is List && skipped.isNotEmpty) {
          final firstSkip = skipped.first as Map<String, dynamic>;
          final reason = firstSkip['reason'] ?? 'Motivo desconocido';
          throw Exception('Registro omitido (skipped). Motivo: $reason');
        }

        final inserted = body['inserted'];
        if (inserted is List && inserted.isNotEmpty) {
          final firstRecord = inserted.first as Map<String, dynamic>;
          final id = firstRecord['_id'] ?? firstRecord['id'];

          if (id != null) {
            log(
              'ID capturado con exito: $id',
              name: 'RobleApiService',
            );
            _invalidateReadCache();
            return id.toString();
          }
        }
      }

      throw Exception('No fue posible guardar la informacion.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('No se pudo guardar la informacion: $msg');
    } catch (e) {
      throw Exception('Ocurrio un problema al procesar la solicitud: $e');
    }
  }

  /// Updates a record in [table] using [idColumn] and [idValue].
  Future<void> update(
    String table, {
    required String idColumn,
    required String idValue,
    required Map<String, dynamic> data,
  }) async {
    final trimmedId = idValue.trim();
    if (trimmedId.isEmpty) {
      return;
    }

    final client = await _client();
    final sanitizedData = _sanitizePayload(data);
    final payloadCandidates = _buildUpdatePayloadCandidates(
      table: table,
      idColumn: idColumn,
      idValue: trimmedId,
      data: sanitizedData,
    );

    Object? lastError;
    for (final entry in payloadCandidates) {
      try {
        await client.put('/update', data: entry.payload);
        _preferredUpdatePayloadIndex = entry.index;
        _invalidateReadCache();
        return;
      } on DioException catch (e) {
        lastError = e;
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
          throw Exception('No se pudo actualizar la informacion: $msg');
        }
      }
    }

    if (lastError is DioException) {
      final msg =
          lastError.response?.data?.toString() ??
          lastError.message ??
          lastError.toString();
      throw Exception('No se pudo actualizar la informacion: $msg');
    }

    throw Exception('No fue posible actualizar la informacion.');
  }

  /// Deletes a record from [table] using [idColumn] and [idValue].
  Future<void> delete(
    String table, {
    required String idColumn,
    required String idValue,
  }) async {
    final trimmedId = idValue.trim();
    if (trimmedId.isEmpty) {
      return;
    }

    final client = await _client();
    final payload = {
      'tableName': table,
      'idColumn': idColumn,
      'idValue': trimmedId,
    };

    try {
      await client.delete('/delete', data: payload);
      _invalidateReadCache();
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('No se pudo eliminar la informacion: $msg');
    }
  }

  Future<void> deleteById(String table, String idValue) {
    return delete(table, idColumn: '_id', idValue: idValue);
  }

  /// Fetches courses for the given teacher email from ROBLE `courses` table.
  Future<List<RobleCourseHome>> getCourses(String teacherEmail) async {
    try {
      final mapped = await _getTeacherCoursesBase(teacherEmail);
      if (mapped.isEmpty) {
        return [];
      }

      final statsByCourseId = await _getCourseStatsMap(mapped);
      return mapped.map((course) {
        final stats =
            statsByCourseId[course.id] ??
            const _CourseStats(studentCount: 0, activeAssessmentCount: 0);
        return course.copyWith(
          studentCount: stats.studentCount,
          pendingEvaluations: stats.activeAssessmentCount,
        );
      }).toList();
    } catch (e) {
      throw Exception('No se pudieron cargar los cursos.');
    }
  }

  Future<List<StudentCourseEnrollment>> getStudentEnrollments(
    String studentEmail,
  ) async {
    final trimmedEmail = studentEmail.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return [];
    }

    final studentRows = await read(
      'students',
      filters: {'email': trimmedEmail},
    );
    if (studentRows.isEmpty) {
      return [];
    }

    final students = studentRows.map(RobleStudentRecord.fromJson).toList();
    final studentIds = students.map((student) => student.id).toSet();
    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('group_members'),
      read('course_groups'),
      read('group_categories'),
      read('courses'),
    ]);

    final memberships = tables[0]
        .map(RobleGroupMemberRecord.fromJson)
        .where((membership) => studentIds.contains(membership.studentId))
        .toList();

    if (memberships.isEmpty) {
      return [];
    }

    final groupsById = {
      for (final group in tables[1].map(RobleCourseGroupRecord.fromJson))
        if (group.id.isNotEmpty) group.id: group,
    };
    final categoriesById = {
      for (final category in tables[2].map(RobleGroupCategoryRecord.fromJson))
        if (category.id.isNotEmpty) category.id: category,
    };
    final coursesById = {
      for (final course in tables[3].map(RobleCourseHome.fromJson))
        if (course.id.isNotEmpty) course.id: course,
    };
    final enrollments = <StudentCourseEnrollment>[];
    final seenEnrollmentKeys = <String>{};

    for (final membership in memberships) {
      final group = groupsById[membership.groupId];
      if (group == null) continue;

      final course = coursesById[group.courseId];
      if (course == null) continue;

      final enrollmentKey = '${course.id}:${group.id}:${membership.studentId}';
      if (!seenEnrollmentKeys.add(enrollmentKey)) {
        continue;
      }

      final category = categoriesById[group.categoryId];

      enrollments.add(
        StudentCourseEnrollment(
          course: course,
          groupName: group.groupName,
          groupCode: group.groupCode,
          groupCategoryName: category?.name ?? 'Sin categoria',
          enrollmentDate: membership.enrollmentDate,
        ),
      );
    }

    enrollments.sort(
      (a, b) => b.course.createdAt.compareTo(a.course.createdAt),
    );
    return enrollments;
  }

  Future<List<RobleStudentAssessmentAssignment>> getStudentAssessments(
    String studentEmail,
  ) async {
    final trimmedEmail = studentEmail.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return [];
    }

    final studentRows = await read(
      'students',
      filters: {'email': trimmedEmail},
    );
    if (studentRows.isEmpty) {
      return [];
    }

    final students = studentRows.map(RobleStudentRecord.fromJson).toList();
    final studentIds = students.map((student) => student.id).toSet();
    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('group_members'),
      read('course_groups'),
      read('group_categories'),
      read('courses'),
      read('assessments'),
      read('assessment_criteria'),
      read('assessment_criterion_levels'),
      read('assessment_submissions'),
      read('assessment_peer_reviews'),
      read('assessment_scores'),
      read('students'),
    ]);

    final memberships = tables[0]
        .map(RobleGroupMemberRecord.fromJson)
        .where((membership) => studentIds.contains(membership.studentId))
        .where((membership) => membership.id.isNotEmpty)
        .toList();
    if (memberships.isEmpty) {
      return [];
    }

    final allGroups = tables[1].map(RobleCourseGroupRecord.fromJson).toList();
    final groupsById = {
      for (final group in allGroups)
        if (group.id.isNotEmpty) group.id: group,
    };
    final categoriesById = {
      for (final category in tables[2].map(RobleGroupCategoryRecord.fromJson))
        if (category.id.isNotEmpty) category.id: category,
    };
    final coursesById = {
      for (final course in tables[3].map(RobleCourseHome.fromJson))
        if (course.id.isNotEmpty) course.id: course,
    };
    final assessments = await _syncExpiredAssessments(
      tables[4].map(RobleAssessment.fromJson),
    );
    final assessmentsByCategoryId = <String, List<RobleAssessment>>{};
    for (final assessment in assessments) {
      assessmentsByCategoryId
          .putIfAbsent(assessment.categoryId, () => <RobleAssessment>[])
          .add(assessment);
    }

    final criteriaByAssessmentId = <String, List<RobleAssessmentCriterion>>{};
    for (final criterion in tables[5].map(RobleAssessmentCriterion.fromJson)) {
      if ((criterion.id ?? '').isEmpty) {
        continue;
      }
      criteriaByAssessmentId
          .putIfAbsent(
            criterion.assessmentId,
            () => <RobleAssessmentCriterion>[],
          )
          .add(criterion);
    }
    for (final criteria in criteriaByAssessmentId.values) {
      criteria.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }
    final levelsByCriterionId = <String, List<RobleAssessmentCriterionLevel>>{};
    for (final level in tables[6].map(RobleAssessmentCriterionLevel.fromJson)) {
      if (level.criterionId.isEmpty || level.scoreValue <= 0) {
        continue;
      }
      levelsByCriterionId
          .putIfAbsent(
            level.criterionId,
            () => <RobleAssessmentCriterionLevel>[],
          )
          .add(level);
    }
    for (final levels in levelsByCriterionId.values) {
      levels.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }

    final submissionsByAssessmentReviewer =
        <String, List<RobleAssessmentSubmission>>{};
    for (final submission in tables[7].map(
      RobleAssessmentSubmission.fromJson,
    )) {
      final key =
          '${submission.assessmentId.trim()}:${submission.reviewerStudentId.trim()}';
      submissionsByAssessmentReviewer
          .putIfAbsent(key, () => <RobleAssessmentSubmission>[])
          .add(submission);
    }
    final latestSubmissionByAssessmentReviewer =
        <String, RobleAssessmentSubmission>{};
    for (final entry in submissionsByAssessmentReviewer.entries) {
      final submissions = entry.value
        ..sort((a, b) {
          if (a.isSubmitted != b.isSubmitted) {
            return a.isSubmitted ? -1 : 1;
          }
          final aDate = a.submittedAt ?? a.startedAt ?? a.createdAt;
          final bDate = b.submittedAt ?? b.startedAt ?? b.createdAt;
          return bDate.compareTo(aDate);
        });
      latestSubmissionByAssessmentReviewer[entry.key] = submissions.first;
    }

    final peerReviewsBySubmissionId =
        <String, List<RobleAssessmentPeerReview>>{};
    for (final peerReview in tables[8].map(
      RobleAssessmentPeerReview.fromJson,
    )) {
      final submissionId = peerReview.submissionId.trim();
      if (submissionId.isEmpty) {
        continue;
      }
      peerReviewsBySubmissionId
          .putIfAbsent(submissionId, () => <RobleAssessmentPeerReview>[])
          .add(peerReview);
    }
    final scoresByPeerReviewId = <String, List<RobleAssessmentScore>>{};
    for (final score in tables[9].map(RobleAssessmentScore.fromJson)) {
      final peerReviewId = score.peerReviewId.trim();
      if (peerReviewId.isEmpty || score.criterionId.isEmpty) {
        continue;
      }
      scoresByPeerReviewId
          .putIfAbsent(peerReviewId, () => <RobleAssessmentScore>[])
          .add(score);
    }
    final studentById = {
      for (final student in tables[10].map(RobleStudentRecord.fromJson))
        if (student.id.isNotEmpty) student.id: student,
    };
    final membershipsByGroupId = <String, List<RobleGroupMemberRecord>>{};
    for (final membership in tables[0].map(RobleGroupMemberRecord.fromJson)) {
      membershipsByGroupId
          .putIfAbsent(membership.groupId, () => <RobleGroupMemberRecord>[])
          .add(membership);
    }

    final assignments = <RobleStudentAssessmentAssignment>[];
    final seenAssignmentKeys = <String>{};
    for (final student in students) {
      final studentMemberships = memberships
          .where((membership) => membership.studentId == student.id)
          .toList();

      for (final membership in studentMemberships) {
        final group = groupsById[membership.groupId];
        if (group == null) {
          continue;
        }
        final course = coursesById[group.courseId];
        if (course == null) {
          continue;
        }
        final category = categoriesById[group.categoryId];
        final categoryAssessments =
            assessmentsByCategoryId[group.categoryId] ??
            const <RobleAssessment>[];

        for (final assessment in categoryAssessments) {
          if (assessment.courseId.isNotEmpty &&
              assessment.courseId != course.id) {
            continue;
          }

          final assignmentKey = '${assessment.id}:${student.id}:${group.id}';
          if (!seenAssignmentKeys.add(assignmentKey)) {
            continue;
          }

          final criteria =
              (criteriaByAssessmentId[assessment.id ?? ''] ??
                      const <RobleAssessmentCriterion>[])
                  .map(
                    (criterion) => RobleAssessmentCriterionDetail(
                      criterion: criterion,
                      levels: List<RobleAssessmentCriterionLevel>.from(
                        levelsByCriterionId[criterion.id ?? ''] ?? const [],
                      ),
                    ),
                  )
                  .toList();

          final teammates =
              (membershipsByGroupId[group.id] ??
                      const <RobleGroupMemberRecord>[])
                  .where((entry) => entry.studentId.isNotEmpty)
                  .where((entry) => entry.studentId != student.id)
                  .fold<
                    List<RobleStudentAssessmentTeammate>
                  >(<RobleStudentAssessmentTeammate>[], (list, entry) {
                    if (list.any((item) => item.studentId == entry.studentId)) {
                      return list;
                    }
                    final teammate = studentById[entry.studentId];
                    if (teammate == null) {
                      return list;
                    }
                    final name =
                        '${teammate.firstName.trim()} ${teammate.lastName.trim()}'
                            .trim();
                    list.add(
                      RobleStudentAssessmentTeammate(
                        studentId: teammate.id,
                        name: name.isEmpty ? teammate.username : name,
                        email: teammate.email,
                      ),
                    );
                    return list;
                  })
                ..sort((a, b) => a.name.compareTo(b.name));

          final submissionKey = '${assessment.id ?? ''}:${student.id}';
          final submission =
              latestSubmissionByAssessmentReviewer[submissionKey];
          final savedScores = <String, Map<String, int>>{};
          if (submission != null && (submission.id ?? '').trim().isNotEmpty) {
            for (final peerReview
                in peerReviewsBySubmissionId[submission.id!.trim()] ??
                    const <RobleAssessmentPeerReview>[]) {
              final criterionScores = <String, int>{};
              for (final score
                  in scoresByPeerReviewId[peerReview.id?.trim() ?? ''] ??
                      const <RobleAssessmentScore>[]) {
                criterionScores[score.criterionId] = score.scoreValue;
              }
              savedScores[peerReview.revieweeStudentId] = criterionScores;
            }
          }

          assignments.add(
            RobleStudentAssessmentAssignment(
              assessment: assessment,
              course: course,
              category: category,
              group: group,
              reviewer: student,
              teammates: teammates,
              criteria: criteria,
              isSubmitted: submission?.isSubmitted ?? false,
              submissionId: submission?.id,
              submissionStatus: submission?.status,
              submittedAt: submission?.submittedAt,
              savedScoresByReviewee: savedScores,
            ),
          );
        }
      }
    }

    assignments.sort((a, b) {
      final aRank = _studentAssessmentSortRank(a);
      final bRank = _studentAssessmentSortRank(b);
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.assessment.endsAt.compareTo(b.assessment.endsAt);
    });
    return assignments;
  }

  Future<RobleStudentResultsSummary> getStudentResults(
    String studentEmail,
  ) async {
    final trimmedEmail = studentEmail.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return RobleStudentResultsSummary.empty;
    }

    final studentRows = await read(
      'students',
      filters: {'email': trimmedEmail},
    );
    if (studentRows.isEmpty) {
      return RobleStudentResultsSummary.empty;
    }

    final students = studentRows.map(RobleStudentRecord.fromJson).toList();
    final studentIds = students.map((student) => student.id).toSet();
    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('assessment_scores'),
      read('assessments'),
      read('assessment_criteria'),
      read('courses'),
    ]);
    final scores = tables[0]
        .map(RobleAssessmentScore.fromJson)
        .where(
          (score) =>
              studentIds.contains(score.revieweeStudentId) &&
              score.scoreValue > 0,
        )
        .toList();
    if (scores.isEmpty) {
      return RobleStudentResultsSummary.empty;
    }

    final assessments = await _syncExpiredAssessments(
      tables[1].map(RobleAssessment.fromJson),
    );
    final assessmentById = {
      for (final assessment in assessments)
        if ((assessment.id ?? '').trim().isNotEmpty)
          assessment.id!.trim(): assessment,
    };
    final criterionById = {
      for (final criterion in tables[2].map(RobleAssessmentCriterion.fromJson))
        if ((criterion.id ?? '').trim().isNotEmpty)
          criterion.id!.trim(): criterion,
    };
    final courseById = {
      for (final course in tables[3].map(RobleCourseHome.fromJson))
        if (course.id.isNotEmpty) course.id: course,
    };
    final criterionAggregates = <String, _StudentResultCriterionAccumulator>{};
    final assessmentAggregates =
        <String, _StudentResultAssessmentAccumulator>{};
    final courseAggregates = <String, _StudentResultCourseAccumulator>{};
    final reviewIds = <String>{};

    var totalScore = 0;
    var totalScoreCount = 0;

    for (final score in scores) {
      final assessment = assessmentById[score.assessmentId.trim()];
      if (assessment == null || !_isPublicAssessment(assessment)) {
        continue;
      }

      final criterion = criterionById[score.criterionId.trim()];
      if (criterion == null) {
        continue;
      }

      final assessmentId = (assessment.id?.trim().isNotEmpty ?? false)
          ? assessment.id!.trim()
          : score.assessmentId.trim();
      if (assessmentId.isEmpty) {
        continue;
      }
      final courseId = assessment.courseId.trim();
      if (courseId.isEmpty) {
        continue;
      }
      final course = courseById[courseId];

      final criterionLabel = criterion.name.trim().isEmpty
          ? 'Criterion'
          : criterion.name.trim();
      final criterionOrder = criterion.displayOrder <= 0
          ? 999
          : criterion.displayOrder;

      totalScore += score.scoreValue;
      totalScoreCount++;

      reviewIds.add(score.peerReviewId);

      final criterionAggregate = criterionAggregates.putIfAbsent(
        criterionLabel,
        () => _StudentResultCriterionAccumulator(
          label: criterionLabel,
          displayOrder: criterionOrder,
        ),
      );
      criterionAggregate.totalScore += score.scoreValue;
      criterionAggregate.scoreCount++;
      if (criterionOrder < criterionAggregate.displayOrder) {
        criterionAggregate.displayOrder = criterionOrder;
      }

      final assessmentAggregate = assessmentAggregates.putIfAbsent(
        assessmentId,
        () => _StudentResultAssessmentAccumulator(
          assessmentId: assessmentId,
          title: assessment.name,
          date: assessment.endsAt,
        ),
      );
      assessmentAggregate.totalScore += score.scoreValue;
      assessmentAggregate.scoreCount++;
      if (score.peerReviewId.trim().isNotEmpty) {
        assessmentAggregate.peerReviewIds.add(score.peerReviewId.trim());
      }
      final assessmentCriterionAggregate = assessmentAggregate.criteria
          .putIfAbsent(
            criterionLabel,
            () => _StudentResultCriterionAccumulator(
              label: criterionLabel,
              displayOrder: criterionOrder,
            ),
          );
      assessmentCriterionAggregate.totalScore += score.scoreValue;
      assessmentCriterionAggregate.scoreCount++;
      if (criterionOrder < assessmentCriterionAggregate.displayOrder) {
        assessmentCriterionAggregate.displayOrder = criterionOrder;
      }

      final courseAggregate = courseAggregates.putIfAbsent(
        courseId,
        () => _StudentResultCourseAccumulator(
          courseId: courseId,
          courseName: course?.name ?? 'Curso',
          courseCode: course?.code ?? '',
        ),
      );
      courseAggregate.totalScore += score.scoreValue;
      courseAggregate.scoreCount++;
      if (score.peerReviewId.trim().isNotEmpty) {
        courseAggregate.reviewIds.add(score.peerReviewId.trim());
      }

      final courseCriterionAggregate = courseAggregate.criteria.putIfAbsent(
        criterionLabel,
        () => _StudentResultCriterionAccumulator(
          label: criterionLabel,
          displayOrder: criterionOrder,
        ),
      );
      courseCriterionAggregate.totalScore += score.scoreValue;
      courseCriterionAggregate.scoreCount++;
      if (criterionOrder < courseCriterionAggregate.displayOrder) {
        courseCriterionAggregate.displayOrder = criterionOrder;
      }

      final courseAssessmentAggregate = courseAggregate.assessments.putIfAbsent(
        assessmentId,
        () => _StudentResultAssessmentAccumulator(
          assessmentId: assessmentId,
          title: assessment.name,
          date: assessment.endsAt,
        ),
      );
      courseAssessmentAggregate.totalScore += score.scoreValue;
      courseAssessmentAggregate.scoreCount++;
      if (score.peerReviewId.trim().isNotEmpty) {
        courseAssessmentAggregate.peerReviewIds.add(score.peerReviewId.trim());
      }
      final courseAssessmentCriterionAggregate = courseAssessmentAggregate
          .criteria
          .putIfAbsent(
            criterionLabel,
            () => _StudentResultCriterionAccumulator(
              label: criterionLabel,
              displayOrder: criterionOrder,
            ),
          );
      courseAssessmentCriterionAggregate.totalScore += score.scoreValue;
      courseAssessmentCriterionAggregate.scoreCount++;
      if (criterionOrder < courseAssessmentCriterionAggregate.displayOrder) {
        courseAssessmentCriterionAggregate.displayOrder = criterionOrder;
      }
    }

    final criteria =
        criterionAggregates.values
            .where((aggregate) => aggregate.scoreCount > 0)
            .map(
              (aggregate) => RobleStudentResultCriterionScore(
                label: aggregate.label,
                score: aggregate.totalScore / aggregate.scoreCount,
                responseCount: aggregate.scoreCount,
                displayOrder: aggregate.displayOrder,
              ),
            )
            .toList()
          ..sort((a, b) {
            final orderCompare = a.displayOrder.compareTo(b.displayOrder);
            if (orderCompare != 0) {
              return orderCompare;
            }
            return a.label.toLowerCase().compareTo(b.label.toLowerCase());
          });

    final history =
        assessmentAggregates.values
            .where((aggregate) => aggregate.scoreCount > 0)
            .map(
              (aggregate) => RobleStudentAssessmentHistoryItem(
                assessmentId: aggregate.assessmentId,
                title: aggregate.title,
                date: aggregate.date,
                score: aggregate.totalScore / aggregate.scoreCount,
                reviewCount: aggregate.peerReviewIds.length,
                criteria:
                    aggregate.criteria.values
                        .where((criterion) => criterion.scoreCount > 0)
                        .map(
                          (criterion) => RobleStudentResultCriterionScore(
                            label: criterion.label,
                            score: criterion.totalScore / criterion.scoreCount,
                            responseCount: criterion.scoreCount,
                            displayOrder: criterion.displayOrder,
                          ),
                        )
                        .toList()
                      ..sort((a, b) {
                        final orderCompare = a.displayOrder.compareTo(
                          b.displayOrder,
                        );
                        if (orderCompare != 0) {
                          return orderCompare;
                        }
                        return a.label.toLowerCase().compareTo(
                          b.label.toLowerCase(),
                        );
                      }),
              ),
            )
            .toList()
          ..sort((a, b) {
            final dateCompare = b.date.compareTo(a.date);
            if (dateCompare != 0) {
              return dateCompare;
            }
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          });

    final courseResults =
        courseAggregates.values
            .where((aggregate) => aggregate.scoreCount > 0)
            .map(
              (aggregate) => RobleStudentCourseResults(
                courseId: aggregate.courseId,
                courseName: aggregate.courseName,
                courseCode: aggregate.courseCode,
                overallScore: aggregate.totalScore / aggregate.scoreCount,
                assessmentCount: aggregate.assessments.length,
                reviewCount: aggregate.reviewIds.length,
                criteria:
                    aggregate.criteria.values
                        .where((criterion) => criterion.scoreCount > 0)
                        .map(
                          (criterion) => RobleStudentResultCriterionScore(
                            label: criterion.label,
                            score: criterion.totalScore / criterion.scoreCount,
                            responseCount: criterion.scoreCount,
                            displayOrder: criterion.displayOrder,
                          ),
                        )
                        .toList()
                      ..sort((a, b) {
                        final orderCompare = a.displayOrder.compareTo(
                          b.displayOrder,
                        );
                        if (orderCompare != 0) {
                          return orderCompare;
                        }
                        return a.label.toLowerCase().compareTo(
                          b.label.toLowerCase(),
                        );
                      }),
                history:
                    aggregate.assessments.values
                        .where((assessment) => assessment.scoreCount > 0)
                        .map(
                          (assessment) => RobleStudentAssessmentHistoryItem(
                            assessmentId: assessment.assessmentId,
                            title: assessment.title,
                            date: assessment.date,
                            score:
                                assessment.totalScore / assessment.scoreCount,
                            reviewCount: assessment.peerReviewIds.length,
                            criteria:
                                assessment.criteria.values
                                    .where(
                                      (criterion) => criterion.scoreCount > 0,
                                    )
                                    .map(
                                      (criterion) =>
                                          RobleStudentResultCriterionScore(
                                            label: criterion.label,
                                            score:
                                                criterion.totalScore /
                                                criterion.scoreCount,
                                            responseCount: criterion.scoreCount,
                                            displayOrder:
                                                criterion.displayOrder,
                                          ),
                                    )
                                    .toList()
                                  ..sort((a, b) {
                                    final orderCompare = a.displayOrder
                                        .compareTo(b.displayOrder);
                                    if (orderCompare != 0) {
                                      return orderCompare;
                                    }
                                    return a.label.toLowerCase().compareTo(
                                      b.label.toLowerCase(),
                                    );
                                  }),
                          ),
                        )
                        .toList()
                      ..sort((a, b) {
                        final dateCompare = b.date.compareTo(a.date);
                        if (dateCompare != 0) {
                          return dateCompare;
                        }
                        return a.title.toLowerCase().compareTo(
                          b.title.toLowerCase(),
                        );
                      }),
              ),
            )
            .toList()
          ..sort(
            (a, b) => a.displayLabel.toLowerCase().compareTo(
              b.displayLabel.toLowerCase(),
            ),
          );

    return RobleStudentResultsSummary(
      overallScore: totalScoreCount == 0 ? 0 : totalScore / totalScoreCount,
      assessmentCount: history.length,
      reviewCount: reviewIds.length,
      criteria: criteria,
      history: history,
      courseResults: courseResults,
    );
  }

  Future<void> submitStudentAssessment({
    required RobleStudentAssessmentAssignment assignment,
    required Map<String, Map<String, int>> scoresByReviewee,
  }) async {
    final assessmentId = assignment.assessment.id?.trim() ?? '';
    final reviewerStudentId = assignment.reviewer.id.trim();
    final groupId = assignment.group.id.trim();
    final courseId = assignment.course.id.trim();
    final categoryId = assignment.assessment.categoryId.trim();

    if (assessmentId.isEmpty ||
        reviewerStudentId.isEmpty ||
        groupId.isEmpty ||
        courseId.isEmpty ||
        categoryId.isEmpty) {
      throw Exception('No fue posible identificar esta evaluacion.');
    }

    if (scoresByReviewee.isEmpty) {
      throw Exception('Debes calificar a tus companeros antes de enviar.');
    }

    final existingSubmission = await _getStudentSubmission(
      assessmentId: assessmentId,
      reviewerStudentId: reviewerStudentId,
    );
    if (existingSubmission != null && existingSubmission.isSubmitted) {
      throw Exception('Esta evaluacion ya fue enviada.');
    }
    if (existingSubmission != null &&
        (existingSubmission.id ?? '').isNotEmpty) {
      await _deleteSubmissionCascade(existingSubmission.id!);
    }

    final now = DateTime.now();
    String? createdSubmissionId;
    try {
      final submission = RobleAssessmentSubmission(
        assessmentId: assessmentId,
        courseId: courseId,
        categoryId: categoryId,
        groupId: groupId,
        reviewerStudentId: reviewerStudentId,
        status: 'submitted',
        generalComment: '',
        startedAt: now,
        submittedAt: now,
        createdAt: now,
      );
      createdSubmissionId = await insert(
        'assessment_submissions',
        submission.toJson(),
      );

      for (final teammateEntry in scoresByReviewee.entries) {
        final revieweeStudentId = teammateEntry.key.trim();
        final criterionScores = teammateEntry.value;
        if (revieweeStudentId.isEmpty ||
            revieweeStudentId == reviewerStudentId ||
            criterionScores.isEmpty) {
          continue;
        }

        final peerReview = RobleAssessmentPeerReview(
          submissionId: createdSubmissionId,
          assessmentId: assessmentId,
          courseId: courseId,
          categoryId: categoryId,
          groupId: groupId,
          reviewerStudentId: reviewerStudentId,
          revieweeStudentId: revieweeStudentId,
          generalComment: '',
          createdAt: now,
        );
        final peerReviewId = await insert(
          'assessment_peer_reviews',
          peerReview.toJson(),
        );

        for (final scoreEntry in criterionScores.entries) {
          final criterionId = scoreEntry.key.trim();
          final scoreValue = scoreEntry.value;
          if (criterionId.isEmpty) {
            continue;
          }

          final score = RobleAssessmentScore(
            peerReviewId: peerReviewId,
            assessmentId: assessmentId,
            courseId: courseId,
            categoryId: categoryId,
            groupId: groupId,
            reviewerStudentId: reviewerStudentId,
            revieweeStudentId: revieweeStudentId,
            criterionId: criterionId,
            scoreValue: scoreValue,
            createdAt: now,
            updatedAt: now,
          );
          await insert('assessment_scores', score.toJson());
        }
      }
    } catch (error) {
      if (createdSubmissionId != null) {
        try {
          await _deleteSubmissionCascade(createdSubmissionId);
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<RobleGroupCategoryRecord>> getCourseCategories(
    String courseId,
  ) async {
    if (courseId.trim().isEmpty) {
      return [];
    }

    final rows = await read(
      'group_categories',
      filters: {'course_id': courseId},
    );
    final categories =
        rows
            .map(RobleGroupCategoryRecord.fromJson)
            .where((category) => category.id.isNotEmpty)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<List<RobleAssessmentOverview>> getTeacherAssessments(
    String teacherEmail,
  ) async {
    final courses = await _getTeacherCoursesBase(teacherEmail);
    if (courses.isEmpty) {
      return [];
    }

    final courseIds = courses.map((course) => course.id).toSet();
    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('group_categories'),
      read('assessments'),
      read('course_groups'),
      read('group_members'),
      read('assessment_submissions'),
    ]);
    final categories = tables[0]
        .map(RobleGroupCategoryRecord.fromJson)
        .where((category) => courseIds.contains(category.courseId))
        .toList();
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final groups = tables[2]
        .map(RobleCourseGroupRecord.fromJson)
        .where((group) => courseIds.contains(group.courseId))
        .toList();
    final groupIdsByCategoryId = <String, Set<String>>{};
    for (final group in groups) {
      groupIdsByCategoryId
          .putIfAbsent(group.categoryId, () => <String>{})
          .add(group.id);
    }
    final membershipRows = tables[3].map(RobleGroupMemberRecord.fromJson);
    final studentIdsByCategoryId = <String, Set<String>>{};
    final categoryIdByGroupId = {
      for (final group in groups) group.id: group.categoryId,
    };
    for (final membership in membershipRows) {
      final categoryId = categoryIdByGroupId[membership.groupId];
      if (categoryId == null || membership.studentId.isEmpty) {
        continue;
      }
      studentIdsByCategoryId
          .putIfAbsent(categoryId, () => <String>{})
          .add(membership.studentId);
    }
    final submittedResponsesByAssessmentId = <String, int>{};
    for (final row in tables[4]) {
      final status = row['status']?.toString().toLowerCase() ?? '';
      final submittedAt = row['submitted_at']?.toString().trim() ?? '';
      if (status != 'submitted' && submittedAt.isEmpty) {
        continue;
      }
      final assessmentId = row['assessment_id']?.toString().trim() ?? '';
      if (assessmentId.isEmpty) {
        continue;
      }
      submittedResponsesByAssessmentId[assessmentId] =
          (submittedResponsesByAssessmentId[assessmentId] ?? 0) + 1;
    }

    final syncedAssessments = await _syncExpiredAssessments(
      tables[1]
          .map(RobleAssessment.fromJson)
          .where((assessment) => courseIds.contains(assessment.courseId)),
    );
    final courseById = {for (final course in courses) course.id: course};
    final assessments = <RobleAssessmentOverview>[];

    for (final assessment in syncedAssessments) {
      final course = courseById[assessment.courseId];
      if (course == null) {
        continue;
      }
      assessments.add(
        RobleAssessmentOverview(
          assessment: assessment,
          course: course,
          categoryName:
              categoriesById[assessment.categoryId]?.name ?? 'Sin categoria',
          responsesSubmitted:
              submittedResponsesByAssessmentId[assessment.id?.trim() ?? ''] ??
              0,
          totalReviewers:
              studentIdsByCategoryId[assessment.categoryId]?.length ?? 0,
        ),
      );
    }

    assessments.sort(
      (a, b) => b.assessment.startsAt.compareTo(a.assessment.startsAt),
    );
    return assessments;
  }

  Future<RobleAssessmentDetailData?> getAssessmentDetail(
    String assessmentId,
  ) async {
    final trimmedId = assessmentId.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final rows = await read('assessments', filters: {'_id': trimmedId});
    if (rows.isEmpty) {
      return null;
    }

    final assessment = await _syncExpiredAssessmentStatus(
      RobleAssessment.fromJson(rows.first),
    );
    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('courses'),
      read('group_categories'),
      read('assessment_criteria'),
      read('assessment_criterion_levels'),
      read('assessment_submissions'),
      read('course_groups'),
      read('group_members'),
    ]);
    final course = tables[0]
        .map(RobleCourseHome.fromJson)
        .where((course) => course.id == assessment.courseId)
        .cast<RobleCourseHome?>()
        .firstWhere((course) => course != null, orElse: () => null);
    if (course == null) {
      return null;
    }
    final category = tables[1]
        .map(RobleGroupCategoryRecord.fromJson)
        .where((category) => category.id == assessment.categoryId)
        .cast<RobleGroupCategoryRecord?>()
        .firstWhere((category) => category != null, orElse: () => null);
    final responsesSubmitted = tables[4].where((row) {
      final status = row['status']?.toString().toLowerCase() ?? '';
      final submittedAt = row['submitted_at']?.toString().trim() ?? '';
      return (row['assessment_id']?.toString().trim() ?? '') == trimmedId &&
          (status == 'submitted' || submittedAt.isNotEmpty);
    }).length;
    final groups = tables[5]
        .map(RobleCourseGroupRecord.fromJson)
        .where(
          (group) =>
              group.courseId == assessment.courseId &&
              group.categoryId == assessment.categoryId,
        )
        .toList();
    final groupIds = groups.map((group) => group.id).toSet();
    final totalReviewers = tables[6]
        .map(RobleGroupMemberRecord.fromJson)
        .where((membership) => groupIds.contains(membership.groupId))
        .map((membership) => membership.studentId)
        .where((studentId) => studentId.isNotEmpty)
        .toSet()
        .length;

    final criteria =
        tables[2]
            .map(RobleAssessmentCriterion.fromJson)
            .where((criterion) => criterion.assessmentId == trimmedId)
            .where((criterion) => (criterion.id ?? '').isNotEmpty)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final levelsByCriterionId = <String, List<RobleAssessmentCriterionLevel>>{};
    for (final level in tables[3].map(RobleAssessmentCriterionLevel.fromJson)) {
      if (level.criterionId.isEmpty) {
        continue;
      }
      levelsByCriterionId
          .putIfAbsent(
            level.criterionId,
            () => <RobleAssessmentCriterionLevel>[],
          )
          .add(level);
    }

    final criterionDetails = <RobleAssessmentCriterionDetail>[];
    for (final criterion in criteria) {
      final levels = List<RobleAssessmentCriterionLevel>.from(
        levelsByCriterionId[criterion.id ?? ''] ?? const [],
      )..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      criterionDetails.add(
        RobleAssessmentCriterionDetail(criterion: criterion, levels: levels),
      );
    }

    return RobleAssessmentDetailData(
      overview: RobleAssessmentOverview(
        assessment: assessment,
        course: course,
        categoryName: category?.name ?? 'Sin categoria',
        responsesSubmitted: responsesSubmitted,
        totalReviewers: totalReviewers,
      ),
      category: category,
      criteria: criterionDetails,
    );
  }

  Future<RobleTeacherAssessmentAnalytics?> getTeacherAssessmentAnalytics(
    String assessmentId,
  ) async {
    final trimmedId = assessmentId.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final detail = await getAssessmentDetail(trimmedId);
    if (detail == null) {
      return null;
    }

    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('assessment_scores'),
      read('course_groups'),
      read('group_members'),
      read('students'),
    ]);
    final scores = tables[0]
        .map(RobleAssessmentScore.fromJson)
        .where(
          (score) => score.assessmentId == trimmedId && score.scoreValue > 0,
        )
        .toList();

    final criteriaAverages = <RobleTeacherAssessmentCriterionAverage>[];
    for (final criterionDetail in detail.criteria) {
      final criterionId = criterionDetail.criterion.id?.trim() ?? '';
      final criterionScores = scores
          .where((score) => score.criterionId == criterionId)
          .map((score) => score.scoreValue)
          .toList();

      criteriaAverages.add(
        RobleTeacherAssessmentCriterionAverage(
          criterionId: criterionId,
          label: criterionDetail.criterion.name,
          averageScore: _averageFromInts(criterionScores),
          responseCount: criterionScores.length,
        ),
      );
    }

    final groups =
        tables[1]
            .map(RobleCourseGroupRecord.fromJson)
            .where(
              (group) =>
                  group.id.isNotEmpty &&
                  group.courseId == detail.overview.course.id &&
                  group.categoryId == detail.overview.assessment.categoryId,
            )
            .toList()
          ..sort((a, b) => _compareNaturalLabels(a.groupName, b.groupName));
    final membershipsByGroupId = <String, List<RobleGroupMemberRecord>>{};
    for (final membership in tables[2].map(RobleGroupMemberRecord.fromJson)) {
      membershipsByGroupId
          .putIfAbsent(membership.groupId, () => <RobleGroupMemberRecord>[])
          .add(membership);
    }
    final studentsById = {
      for (final student in tables[3].map(RobleStudentRecord.fromJson))
        if (student.id.isNotEmpty) student.id: student,
    };
    final groupAnalytics = <RobleTeacherAssessmentGroupAnalytics>[];

    for (final group in groups) {
      final memberships =
          membershipsByGroupId[group.id] ?? const <RobleGroupMemberRecord>[];

      final seenStudentIds = <String>{};
      final students = <RobleTeacherAssessmentStudentAnalytics>[];

      for (final membership in memberships) {
        if (!seenStudentIds.add(membership.studentId)) {
          continue;
        }

        final student = studentsById[membership.studentId];
        if (student == null) {
          continue;
        }

        final studentScores = scores
            .where(
              (score) =>
                  score.groupId == group.id &&
                  score.revieweeStudentId == student.id,
            )
            .toList();

        final criteriaScores = <String, double>{};
        for (final criterionDetail in detail.criteria) {
          final criterionId = criterionDetail.criterion.id?.trim() ?? '';
          final criterionScores = studentScores
              .where((score) => score.criterionId == criterionId)
              .map((score) => score.scoreValue)
              .toList();
          criteriaScores[criterionDetail.criterion.name] = _averageFromInts(
            criterionScores,
          );
        }

        final fullName =
            '${student.firstName.trim()} ${student.lastName.trim()}'.trim();
        students.add(
          RobleTeacherAssessmentStudentAnalytics(
            studentId: student.id,
            name: fullName.isEmpty ? student.username : fullName,
            email: student.email,
            averageScore: _averageFromInts(
              studentScores.map((score) => score.scoreValue),
            ),
            criteriaScores: criteriaScores,
          ),
        );
      }

      students.sort((a, b) => a.name.compareTo(b.name));
      final groupScores = scores
          .where((score) => score.groupId == group.id)
          .map((score) => score.scoreValue);

      groupAnalytics.add(
        RobleTeacherAssessmentGroupAnalytics(
          groupId: group.id,
          groupName: group.groupName,
          averageScore: _averageFromInts(groupScores),
          studentCount: students.length,
          students: students,
        ),
      );
    }

    return RobleTeacherAssessmentAnalytics(
      detail: detail,
      engagementRate: detail.overview.completionProgress.clamp(0.0, 1.0),
      averageScore: _averageFromInts(scores.map((score) => score.scoreValue)),
      criteriaAverages: criteriaAverages,
      groups: groupAnalytics,
    );
  }

  Future<RobleCourseManagementData> getCourseManagementData(
    RobleCourseHome course,
  ) async {
    final tables = await Future.wait<List<Map<String, dynamic>>>([
      read('group_categories'),
      read('course_groups'),
      read('group_members'),
      read('students'),
    ]);
    final categories =
        tables[0]
            .map(RobleGroupCategoryRecord.fromJson)
            .where(
              (category) =>
                  category.id.isNotEmpty && category.courseId == course.id,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    final groups =
        tables[1]
            .map(RobleCourseGroupRecord.fromJson)
            .where(
              (group) => group.id.isNotEmpty && group.courseId == course.id,
            )
            .toList()
          ..sort((a, b) => _compareNaturalLabels(a.groupName, b.groupName));

    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final membershipsByGroupId = <String, List<RobleGroupMemberRecord>>{};
    for (final membership in tables[2].map(RobleGroupMemberRecord.fromJson)) {
      membershipsByGroupId
          .putIfAbsent(membership.groupId, () => <RobleGroupMemberRecord>[])
          .add(membership);
    }
    final studentById = {
      for (final student in tables[3].map(RobleStudentRecord.fromJson))
        if (student.id.isNotEmpty) student.id: student,
    };
    final roster = <RobleCourseRosterEntry>[];

    for (final group in groups) {
      final memberships =
          (membershipsByGroupId[group.id] ?? const <RobleGroupMemberRecord>[])
              .where((membership) => membership.id.isNotEmpty)
              .toList();

      for (final membership in memberships) {
        final student = studentById[membership.studentId];
        if (student == null) {
          continue;
        }

        final category = categoryById[group.categoryId];
        roster.add(
          RobleCourseRosterEntry(
            studentId: student.id,
            username: student.username,
            orgDefinedId: student.orgDefinedId,
            firstName: student.firstName,
            lastName: student.lastName,
            email: student.email,
            groupId: group.id,
            groupName: group.groupName,
            groupCode: group.groupCode,
            categoryId: group.categoryId,
            categoryName: category?.name ?? 'Sin categoria',
            enrollmentDate: membership.enrollmentDate,
          ),
        );
      }
    }

    roster.sort((a, b) {
      final categoryCompare = a.categoryName.compareTo(b.categoryName);
      if (categoryCompare != 0) {
        return categoryCompare;
      }

      final groupCompare = _compareNaturalLabels(a.groupName, b.groupName);
      if (groupCompare != 0) {
        return groupCompare;
      }

      return a.fullName.compareTo(b.fullName);
    });

    return RobleCourseManagementData(
      course: course.copyWith(
        studentCount: roster.map((entry) => entry.studentId).toSet().length,
      ),
      categories: categories,
      roster: roster,
    );
  }

  Future<void> deleteCourseCascade(String courseId) async {
    if (courseId.trim().isEmpty) {
      return;
    }

    final categoryRows = await read(
      'group_categories',
      filters: {'course_id': courseId},
    );
    final categories = categoryRows
        .map(RobleGroupCategoryRecord.fromJson)
        .where((category) => category.id.isNotEmpty)
        .toList();

    final groupRows = await read(
      'course_groups',
      filters: {'course_id': courseId},
    );
    final groups = groupRows
        .map(RobleCourseGroupRecord.fromJson)
        .where((group) => group.id.isNotEmpty)
        .toList();

    final membershipIds = <String>{};
    final affectedStudentIds = <String>{};

    for (final group in groups) {
      final membershipRows = await read(
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
      await deleteById('group_members', membershipId);
    }

    for (final group in groups) {
      await deleteById('course_groups', group.id);
    }

    for (final category in categories) {
      await deleteById('group_categories', category.id);
    }

    await _deleteStudentsIfOrphaned(affectedStudentIds);
    await deleteById('courses', courseId);
  }

  Future<RobleAssessmentSubmission?> _getStudentSubmission({
    required String assessmentId,
    required String reviewerStudentId,
  }) async {
    final trimmedAssessmentId = assessmentId.trim();
    final trimmedReviewerId = reviewerStudentId.trim();
    if (trimmedAssessmentId.isEmpty || trimmedReviewerId.isEmpty) {
      return null;
    }

    final rows = await read(
      'assessment_submissions',
      filters: {
        'assessment_id': trimmedAssessmentId,
        'reviewer_student_id': trimmedReviewerId,
      },
    );
    if (rows.isEmpty) {
      return null;
    }

    final submissions = rows.map(RobleAssessmentSubmission.fromJson).toList()
      ..sort((a, b) {
        if (a.isSubmitted != b.isSubmitted) {
          return a.isSubmitted ? -1 : 1;
        }
        final aDate = a.submittedAt ?? a.startedAt ?? a.createdAt;
        final bDate = b.submittedAt ?? b.startedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

    return submissions.first;
  }

  Future<void> _deleteSubmissionCascade(String submissionId) async {
    final trimmedSubmissionId = submissionId.trim();
    if (trimmedSubmissionId.isEmpty) {
      return;
    }

    final peerReviewRows = await read(
      'assessment_peer_reviews',
      filters: {'submission_id': trimmedSubmissionId},
    );
    final peerReviews = peerReviewRows
        .map(RobleAssessmentPeerReview.fromJson)
        .where((peerReview) => (peerReview.id ?? '').isNotEmpty)
        .toList();

    for (final peerReview in peerReviews) {
      final scoreRows = await read(
        'assessment_scores',
        filters: {'peer_review_id': peerReview.id},
      );
      final scores = scoreRows
          .map(RobleAssessmentScore.fromJson)
          .where((score) => (score.id ?? '').isNotEmpty)
          .toList();

      for (final score in scores) {
        await deleteById('assessment_scores', score.id!);
      }

      await deleteById('assessment_peer_reviews', peerReview.id!);
    }

    await deleteById('assessment_submissions', trimmedSubmissionId);
  }

  int _studentAssessmentSortRank(RobleStudentAssessmentAssignment assignment) {
    switch (assignment.statusLabel) {
      case 'Active':
        return 0;
      case 'Scheduled':
        return 1;
      case 'Completed':
        return 2;
      case 'Closed':
        return 3;
      default:
        return 4;
    }
  }

  Future<List<RobleCourseHome>> _getTeacherCoursesBase(
    String teacherEmail,
  ) async {
    final normalizedEmail = teacherEmail.trim().toLowerCase();
    final rows = await read('courses');

    final courses =
        rows
            .map(RobleCourseHome.fromJson)
            .where(
              (course) =>
                  normalizedEmail.isEmpty ||
                  course.teacherEmail.toLowerCase() == normalizedEmail,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return courses;
  }

  Future<Map<String, _CourseStats>> _getCourseStatsMap(
    List<RobleCourseHome> courses,
  ) async {
    final courseIds = courses
        .map((course) => course.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    if (courseIds.isEmpty) {
      return const <String, _CourseStats>{};
    }

    final studentIdsByCourse = <String, Set<String>>{
      for (final courseId in courseIds) courseId: <String>{},
    };
    final activeAssessmentsByCourse = <String, int>{
      for (final courseId in courseIds) courseId: 0,
    };
    final groupIdToCourseId = <String, String>{};

    final groupRows = await read('course_groups');
    for (final row in groupRows) {
      final group = RobleCourseGroupRecord.fromJson(row);
      if (group.id.isEmpty || !courseIds.contains(group.courseId)) {
        continue;
      }
      groupIdToCourseId[group.id] = group.courseId;
    }

    if (groupIdToCourseId.isNotEmpty) {
      final membershipRows = await read('group_members');
      for (final row in membershipRows) {
        final membership = RobleGroupMemberRecord.fromJson(row);
        final courseId = groupIdToCourseId[membership.groupId];
        if (courseId == null || membership.studentId.isEmpty) {
          continue;
        }
        studentIdsByCourse[courseId]!.add(membership.studentId);
      }
    }

    final assessmentRows = await read('assessments');
    for (final row in assessmentRows) {
      final assessment = await _syncExpiredAssessmentStatus(
        RobleAssessment.fromJson(row),
      );
      if (!courseIds.contains(assessment.courseId)) {
        continue;
      }
      if (_isCourseAssessmentActive(assessment)) {
        activeAssessmentsByCourse[assessment.courseId] =
            (activeAssessmentsByCourse[assessment.courseId] ?? 0) + 1;
      }
    }

    return {
      for (final courseId in courseIds)
        courseId: _CourseStats(
          studentCount: studentIdsByCourse[courseId]?.length ?? 0,
          activeAssessmentCount: activeAssessmentsByCourse[courseId] ?? 0,
        ),
    };
  }

  /// Inserts multiple rows into [table] sequentially, in chunks of [chunkSize].
  /// Returns the list of generated IDs in the same order as [rows].
  Future<List<String>> insertBatch(
    String table,
    List<Map<String, dynamic>> rows, {
    int chunkSize = 10,
    void Function(int done, int total)? onProgress,
  }) async {
    final ids = <String>[];
    for (var i = 0; i < rows.length; i += chunkSize) {
      final chunk = rows.skip(i).take(chunkSize);
      for (final row in chunk) {
        ids.add(await insert(table, row));
      }
      onProgress?.call((i + chunkSize).clamp(0, rows.length), rows.length);
    }
    return ids;
  }

  /// Resets the cached Dio instance so the next request picks up a fresh token.
  void resetClient() {
    _dio = null;
    _invalidateReadCache();
  }

  String _buildReadCacheKey(String table, Map<String, dynamic> filters) {
    final normalizedEntries =
        filters.entries
            .where((entry) => entry.value != null)
            .map((entry) {
              final value = entry.value.toString().trim();
              return MapEntry(entry.key, value);
            })
            .where((entry) => entry.value.isNotEmpty)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final normalizedFilters = normalizedEntries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    return normalizedFilters.isEmpty ? table : '$table?$normalizedFilters';
  }

  void _invalidateReadCache() {
    _readCache.clear();
    _pendingReads.clear();
  }

  List<_UpdatePayloadCandidate> _buildUpdatePayloadCandidates({
    required String table,
    required String idColumn,
    required String idValue,
    required Map<String, dynamic> data,
  }) {
    final builders = <Map<String, dynamic>>[
      {
        'tableName': table,
        'idColumn': idColumn,
        'idValue': idValue,
        'record': data,
      },
      {
        'tableName': table,
        'idColumn': idColumn,
        'idValue': idValue,
        'data': data,
      },
      {
        'tableName': table,
        'idColumn': idColumn,
        'idValue': idValue,
        'updates': data,
      },
      {
        'tableName': table,
        'idColumn': idColumn,
        'idValue': idValue,
        'newData': data,
      },
    ];

    final orderedIndexes = <int>[];
    if (_preferredUpdatePayloadIndex != null &&
        _preferredUpdatePayloadIndex! >= 0 &&
        _preferredUpdatePayloadIndex! < builders.length) {
      orderedIndexes.add(_preferredUpdatePayloadIndex!);
    }
    orderedIndexes.addAll(
      List<int>.generate(
        builders.length,
        (index) => index,
      ).where((index) => index != _preferredUpdatePayloadIndex),
    );

    return orderedIndexes
        .map(
          (index) =>
              _UpdatePayloadCandidate(index: index, payload: builders[index]),
        )
        .toList();
  }

  Future<RobleAssessment> _syncExpiredAssessmentStatus(
    RobleAssessment assessment,
  ) async {
    final assessmentId = assessment.id?.trim() ?? '';
    final normalizedStatus = assessment.status.trim().toLowerCase();

    if (assessmentId.isEmpty ||
        normalizedStatus == 'closed' ||
        !DateTime.now().isAfter(assessment.endsAt)) {
      return assessment;
    }

    try {
      await update(
        'assessments',
        idColumn: '_id',
        idValue: assessmentId,
        data: {'status': 'closed'},
      );
      return assessment.copyWith(status: 'closed');
    } catch (e) {
      log(
        'No se pudo sincronizar el cierre del assessment $assessmentId: $e',
        name: 'RobleApiService',
      );
      return assessment;
    }
  }

  Future<List<RobleAssessment>> _syncExpiredAssessments(
    Iterable<RobleAssessment> assessments,
  ) async {
    final list = assessments.toList(growable: false);
    if (list.isEmpty) {
      return const [];
    }

    return Future.wait(
      list.map(_syncExpiredAssessmentStatus),
      eagerError: false,
    );
  }

  Future<void> _deleteStudentsIfOrphaned(Iterable<String> studentIds) async {
    for (final studentId in studentIds) {
      final trimmedStudentId = studentId.trim();
      if (trimmedStudentId.isEmpty) {
        continue;
      }

      final remainingMemberships = await read(
        'group_members',
        filters: {'student_id': trimmedStudentId},
      );
      if (remainingMemberships.isEmpty) {
        await deleteById('students', trimmedStudentId);
      }
    }
  }

  bool _isCourseAssessmentActive(RobleAssessment assessment) {
    final normalizedStatus = assessment.status.trim().toLowerCase();
    final now = DateTime.now();

    if (normalizedStatus == 'closed' || normalizedStatus == 'draft') {
      return false;
    }
    if (now.isBefore(assessment.startsAt)) {
      return false;
    }
    if (now.isAfter(assessment.endsAt)) {
      return false;
    }
    return true;
  }

  bool _isPublicAssessment(RobleAssessment assessment) {
    return assessment.visibility.trim().toLowerCase() == 'public';
  }

  int _compareNaturalLabels(String a, String b) {
    final aParts = RegExp(
      r'\d+|\D+',
    ).allMatches(a).map((match) => match.group(0) ?? '').toList();
    final bParts = RegExp(
      r'\d+|\D+',
    ).allMatches(b).map((match) => match.group(0) ?? '').toList();

    final minLength = aParts.length < bParts.length
        ? aParts.length
        : bParts.length;

    for (var index = 0; index < minLength; index++) {
      final aPart = aParts[index];
      final bPart = bParts[index];
      final aNumber = int.tryParse(aPart);
      final bNumber = int.tryParse(bPart);

      if (aNumber != null && bNumber != null) {
        final compare = aNumber.compareTo(bNumber);
        if (compare != 0) {
          return compare;
        }
        continue;
      }

      final compare = aPart.toLowerCase().compareTo(bPart.toLowerCase());
      if (compare != 0) {
        return compare;
      }
    }

    return aParts.length.compareTo(bParts.length);
  }

  double _averageFromInts(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) {
      return 0;
    }
    final total = list.fold<int>(0, (sum, value) => sum + value);
    return total / list.length;
  }
}

class _CourseStats {
  const _CourseStats({
    required this.studentCount,
    required this.activeAssessmentCount,
  });

  final int studentCount;
  final int activeAssessmentCount;
}

class _ReadCacheEntry {
  const _ReadCacheEntry({required this.rows, required this.expiresAt});

  final List<Map<String, dynamic>> rows;
  final DateTime expiresAt;
}

class _UpdatePayloadCandidate {
  const _UpdatePayloadCandidate({required this.index, required this.payload});

  final int index;
  final Map<String, dynamic> payload;
}

class _StudentResultCriterionAccumulator {
  _StudentResultCriterionAccumulator({
    required this.label,
    required this.displayOrder,
  });

  final String label;
  int displayOrder;
  int totalScore = 0;
  int scoreCount = 0;
}

class _StudentResultAssessmentAccumulator {
  _StudentResultAssessmentAccumulator({
    required this.assessmentId,
    required this.title,
    required this.date,
  });

  final String assessmentId;
  final String title;
  final DateTime date;
  final Set<String> peerReviewIds = <String>{};
  final Map<String, _StudentResultCriterionAccumulator> criteria =
      <String, _StudentResultCriterionAccumulator>{};
  int totalScore = 0;
  int scoreCount = 0;
}

class _StudentResultCourseAccumulator {
  _StudentResultCourseAccumulator({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
  });

  final String courseId;
  final String courseName;
  final String courseCode;
  final Set<String> reviewIds = <String>{};
  final Map<String, _StudentResultCriterionAccumulator> criteria =
      <String, _StudentResultCriterionAccumulator>{};
  final Map<String, _StudentResultAssessmentAccumulator> assessments =
      <String, _StudentResultAssessmentAccumulator>{};
  int totalScore = 0;
  int scoreCount = 0;
}
