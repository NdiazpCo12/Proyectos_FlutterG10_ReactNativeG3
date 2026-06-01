import {
  mapCourse,
  mapStudent,
  mapAssessment,
  submissionToJson,
  peerReviewToJson,
} from './mappers';

import type {
  RobleAssessmentSubmission,
  RobleAssessmentPeerReview,
} from './models';

// ── mapCourse ──

describe('mapCourse', () => {
  it('maps all fields from a full API response', () => {
    const json = {
      _id: 'course-1',
      name: 'Intro to CS',
      code: 'CS101',
      teacher_email: 'prof@uni.edu',
      created_at: '2025-01-15T10:00:00Z',
      status: 'Active',
      student_count: 30,
      pending_evaluations: 5,
    };

    const result = mapCourse(json);
    expect(result.id).toBe('course-1');
    expect(result.name).toBe('Intro to CS');
    expect(result.code).toBe('CS101');
    expect(result.teacherEmail).toBe('prof@uni.edu');
    expect(result.createdAt).toBeInstanceOf(Date);
    expect(result.status).toBe('Active');
    expect(result.studentCount).toBe(30);
    expect(result.pendingEvaluations).toBe(5);
  });

  it('uses `id` field when `_id` is missing', () => {
    const json = {
      id: 'course-2',
      name: 'Algorithms',
      code: 'CS201',
    };
    const result = mapCourse(json);
    expect(result.id).toBe('course-2');
  });

  it('provides safe defaults when optional fields are missing', () => {
    const json = { _id: 'c1' };
    const result = mapCourse(json);
    expect(result.name).toBe('No Name');
    expect(result.code).toBe('No Code');
    expect(result.status).toBe('Active');
    expect(result.studentCount).toBe(25);
    expect(result.pendingEvaluations).toBe(3);
  });

  it('parses numeric strings into numbers', () => {
    const json = {
      _id: 'c3',
      student_count: '42',
      pending_evaluations: '7',
    };
    const result = mapCourse(json);
    expect(result.studentCount).toBe(42);
    expect(result.pendingEvaluations).toBe(7);
  });

  it('falls back to numeric defaults when parse fails', () => {
    const json = {
      _id: 'c4',
      student_count: 'not-a-number',
      pending_evaluations: '',
    };
    const result = mapCourse(json);
    expect(result.studentCount).toBe(25);
    expect(result.pendingEvaluations).toBe(3);
  });
});

// ── mapStudent ──

describe('mapStudent', () => {
  it('maps a complete student record', () => {
    const json = {
      _id: 's1',
      username: 'jdoe',
      org_defined_id: '2020001',
      first_name: 'John',
      last_name: 'Doe',
      email: 'jdoe@uni.edu',
    };

    const result = mapStudent(json);
    expect(result.id).toBe('s1');
    expect(result.username).toBe('jdoe');
    expect(result.orgDefinedId).toBe('2020001');
    expect(result.firstName).toBe('John');
    expect(result.lastName).toBe('Doe');
    expect(result.email).toBe('jdoe@uni.edu');
  });

  it('returns empty string for missing username', () => {
    const json = { _id: 's2' };
    const result = mapStudent(json);
    expect(result.username).toBe('');
  });
});

// ── mapAssessment ──

describe('mapAssessment', () => {
  it('maps a valid assessment with dates', () => {
    const json = {
      _id: 'a1',
      course_id: 'c1',
      category_id: 'cat1',
      name: 'Peer Review 1',
      visibility: 'public',
      status: 'published',
      starts_at: '2025-03-01T00:00:00Z',
      ends_at: '2025-03-08T00:00:00Z',
      created_by_email: 'prof@uni.edu',
      created_at: '2025-02-01T00:00:00Z',
    };

    const result = mapAssessment(json);
    expect(result.name).toBe('Peer Review 1');
    expect(result.visibility).toBe('public');
    expect(result.status).toBe('published');
    expect(result.startsAt).toBeInstanceOf(Date);
    expect(result.endsAt).toBeInstanceOf(Date);
    expect(result.createdAt).toBeInstanceOf(Date);
  });

  it('uses defaults when optional fields are missing', () => {
    const json = { _id: 'a2' };
    const result = mapAssessment(json);
    expect(result.name).toBe('Untitled assessment');
    expect(result.visibility).toBe('private');
    expect(result.status).toBe('draft');
  });
});

// ── submissionToJson ──

describe('submissionToJson', () => {
  it('serialises all fields correctly', () => {
    const createdAt = new Date('2025-03-10T12:00:00Z');
    const startedAt = new Date('2025-03-11T08:00:00Z');
    const submission: RobleAssessmentSubmission = {
      assessmentId: 'a1',
      courseId: 'c1',
      categoryId: 'cat1',
      groupId: 'g1',
      reviewerStudentId: 's1',
      status: 'submitted',
      generalComment: 'Good work',
      startedAt,
      submittedAt: undefined,
      createdAt,
    };

    const result = submissionToJson(submission);
    expect(result.assessment_id).toBe('a1');
    expect(result.course_id).toBe('c1');
    expect(result.status).toBe('submitted');
    expect(result.general_comment).toBe('Good work');
    expect(result.started_at).toBe(startedAt.toISOString());
    expect(result.submitted_at).toBe('');
    expect(result.created_at).toBe(createdAt.toISOString());
  });
});

// ── peerReviewToJson ──

describe('peerReviewToJson', () => {
  it('serialises peer review with Date fields', () => {
    const createdAt = new Date('2025-03-15T12:00:00Z');
    const review: RobleAssessmentPeerReview = {
      submissionId: 'sub1',
      assessmentId: 'a1',
      courseId: 'c1',
      categoryId: 'cat1',
      groupId: 'g1',
      reviewerStudentId: 's1',
      revieweeStudentId: 's2',
      generalComment: 'Excellent',
      createdAt,
    };

    const result = peerReviewToJson(review);
    expect(result.submission_id).toBe('sub1');
    expect(result.reviewer_student_id).toBe('s1');
    expect(result.reviewee_student_id).toBe('s2');
    expect(result.general_comment).toBe('Excellent');
    expect(result.created_at).toBe(createdAt.toISOString());
  });
});
