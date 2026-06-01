import '../models/teacher_models.dart';

class TeacherMockData {
  TeacherMockData._();

  static const courses = <TeacherCourse>[
    TeacherCourse(
      id: 'mobile',
      name: 'Mobile Development',
      code: 'MDV-401',
      term: '2026-1',
      status: 'Active',
      studentCount: 24,
      groupCount: 6,
      pendingEvaluations: 2,
    ),
    TeacherCourse(
      id: 'ux',
      name: 'UX Engineering',
      code: 'UXE-310',
      term: '2026-1',
      status: 'Active',
      studentCount: 18,
      groupCount: 4,
      pendingEvaluations: 1,
    ),
    TeacherCourse(
      id: 'software',
      name: 'Software Architecture',
      code: 'SAR-420',
      term: '2025-2',
      status: 'Closed',
      studentCount: 30,
      groupCount: 5,
      pendingEvaluations: 0,
    ),
  ];

  static const evaluations = <TeacherEvaluation>[
    TeacherEvaluation(
      id: 'eval-1',
      courseId: 'mobile',
      title: 'Sprint 1 Peer Review',
      groupCategory: 'Project Teams',
      visibility: 'Private',
      dateRange: 'Mar 17 - Mar 24',
      status: 'Active',
      responses: 14,
    ),
    TeacherEvaluation(
      id: 'eval-2',
      courseId: 'mobile',
      title: 'Prototype Delivery',
      groupCategory: 'Project Teams',
      visibility: 'Public',
      dateRange: 'Apr 02 - Apr 09',
      status: 'Scheduled',
      responses: 0,
    ),
    TeacherEvaluation(
      id: 'eval-3',
      courseId: 'ux',
      title: 'Research Collaboration',
      groupCategory: 'Lab Groups',
      visibility: 'Private',
      dateRange: 'Mar 20 - Mar 27',
      status: 'Active',
      responses: 8,
    ),
  ];

  static const groups = <TeacherGroup>[
    TeacherGroup(
      id: 'g1',
      courseId: 'mobile',
      name: 'Group A',
      category: 'Project Teams',
      averageScore: 4.6,
      members: [
        GroupMember(
          name: 'Laura Gomez',
          email: 'laura.gomez@uni.edu',
          averageScore: 4.8,
          criteriaScores: {
            'Punctuality': 4.9,
            'Contribution': 4.8,
            'Commitment': 4.7,
            'Attitude': 4.9,
          },
        ),
        GroupMember(
          name: 'Mateo Ruiz',
          email: 'mateo.ruiz@uni.edu',
          averageScore: 4.5,
          criteriaScores: {
            'Punctuality': 4.4,
            'Contribution': 4.6,
            'Commitment': 4.5,
            'Attitude': 4.5,
          },
        ),
        GroupMember(
          name: 'Sara Diaz',
          email: 'sara.diaz@uni.edu',
          averageScore: 4.4,
          criteriaScores: {
            'Punctuality': 4.5,
            'Contribution': 4.2,
            'Commitment': 4.4,
            'Attitude': 4.5,
          },
        ),
      ],
    ),
    TeacherGroup(
      id: 'g2',
      courseId: 'mobile',
      name: 'Group B',
      category: 'Project Teams',
      averageScore: 4.2,
      members: [
        GroupMember(
          name: 'Nicolas Perez',
          email: 'nicolas.perez@uni.edu',
          averageScore: 4.1,
          criteriaScores: {
            'Punctuality': 4.0,
            'Contribution': 4.1,
            'Commitment': 4.2,
            'Attitude': 4.1,
          },
        ),
        GroupMember(
          name: 'Valentina Mora',
          email: 'valentina.mora@uni.edu',
          averageScore: 4.3,
          criteriaScores: {
            'Punctuality': 4.2,
            'Contribution': 4.4,
            'Commitment': 4.3,
            'Attitude': 4.3,
          },
        ),
        GroupMember(
          name: 'Juan Torres',
          email: 'juan.torres@uni.edu',
          averageScore: 4.2,
          criteriaScores: {
            'Punctuality': 4.1,
            'Contribution': 4.3,
            'Commitment': 4.1,
            'Attitude': 4.3,
          },
        ),
      ],
    ),
    TeacherGroup(
      id: 'g3',
      courseId: 'ux',
      name: 'Lab 1',
      category: 'Lab Groups',
      averageScore: 4.7,
      members: [
        GroupMember(
          name: 'Camila Soto',
          email: 'camila.soto@uni.edu',
          averageScore: 4.8,
          criteriaScores: {
            'Punctuality': 4.8,
            'Contribution': 4.9,
            'Commitment': 4.7,
            'Attitude': 4.8,
          },
        ),
        GroupMember(
          name: 'Felipe Ramos',
          email: 'felipe.ramos@uni.edu',
          averageScore: 4.6,
          criteriaScores: {
            'Punctuality': 4.7,
            'Contribution': 4.6,
            'Commitment': 4.5,
            'Attitude': 4.7,
          },
        ),
      ],
    ),
  ];
}
