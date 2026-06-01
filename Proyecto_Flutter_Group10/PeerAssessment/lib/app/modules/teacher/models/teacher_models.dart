class TeacherCourse {
  const TeacherCourse({
    required this.id,
    required this.name,
    required this.code,
    required this.term,
    required this.status,
    required this.studentCount,
    required this.groupCount,
    required this.pendingEvaluations,
  });

  final String id;
  final String name;
  final String code;
  final String term;
  final String status;
  final int studentCount;
  final int groupCount;
  final int pendingEvaluations;
}

class TeacherGroup {
  const TeacherGroup({
    required this.id,
    required this.courseId,
    required this.name,
    required this.category,
    required this.averageScore,
    required this.members,
  });

  final String id;
  final String courseId;
  final String name;
  final String category;
  final double averageScore;
  final List<GroupMember> members;
}

class GroupMember {
  const GroupMember({
    required this.name,
    required this.email,
    required this.averageScore,
    required this.criteriaScores,
  });

  final String name;
  final String email;
  final double averageScore;
  final Map<String, double> criteriaScores;
}

class TeacherEvaluation {
  const TeacherEvaluation({
    required this.id,
    required this.courseId,
    required this.title,
    required this.groupCategory,
    required this.visibility,
    required this.dateRange,
    required this.status,
    required this.responses,
  });

  final String id;
  final String courseId;
  final String title;
  final String groupCategory;
  final String visibility;
  final String dateRange;
  final String status;
  final int responses;
}
