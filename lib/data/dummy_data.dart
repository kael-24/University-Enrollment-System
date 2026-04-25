import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/enums.dart';

/// Pre-seeded dummy data for the application.
class DummyData {
  DummyData._();

  // ─── Students ────────────────────────────────────────
  static List<Student> get students => [
        Student(
          id: 'STU-001',
          firstName: 'Juan',
          lastName: 'Dela Cruz',
          email: 'juan.delacruz@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 3,
          dateEnrolled: DateTime(2023, 6, 15),
        ),
        Student(
          id: 'STU-002',
          firstName: 'Maria',
          lastName: 'Santos',
          email: 'maria.santos@enrollhub.edu',
          program: 'BS Information Technology',
          yearLevel: 2,
          dateEnrolled: DateTime(2024, 6, 10),
        ),
        Student(
          id: 'STU-003',
          firstName: 'Carlos',
          lastName: 'Reyes',
          email: 'carlos.reyes@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 1,
          dateEnrolled: DateTime(2025, 6, 12),
        ),
        Student(
          id: 'STU-004',
          firstName: 'Ana',
          lastName: 'Garcia',
          email: 'ana.garcia@enrollhub.edu',
          program: 'BS Mathematics',
          yearLevel: 4,
          dateEnrolled: DateTime(2022, 6, 8),
        ),
        Student(
          id: 'STU-005',
          firstName: 'Pedro',
          lastName: 'Lim',
          email: 'pedro.lim@enrollhub.edu',
          program: 'BS Information Technology',
          yearLevel: 3,
          dateEnrolled: DateTime(2023, 6, 20),
        ),
        Student(
          id: 'STU-006',
          firstName: 'Sofia',
          lastName: 'Tan',
          email: 'sofia.tan@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 2,
          dateEnrolled: DateTime(2024, 6, 5),
        ),
        Student(
          id: 'STU-007',
          firstName: 'Miguel',
          lastName: 'Torres',
          email: 'miguel.torres@enrollhub.edu',
          program: 'BS Mathematics',
          yearLevel: 1,
          dateEnrolled: DateTime(2025, 6, 18),
        ),
        Student(
          id: 'STU-008',
          firstName: 'Isabella',
          lastName: 'Cruz',
          email: 'isabella.cruz@enrollhub.edu',
          program: 'BS Information Technology',
          yearLevel: 4,
          dateEnrolled: DateTime(2022, 6, 14),
        ),
        Student(
          id: 'STU-009',
          firstName: 'Rafael',
          lastName: 'Mendoza',
          email: 'rafael.mendoza@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 3,
          dateEnrolled: DateTime(2023, 6, 22),
        ),
        Student(
          id: 'STU-010',
          firstName: 'Camille',
          lastName: 'Flores',
          email: 'camille.flores@enrollhub.edu',
          program: 'BS Mathematics',
          yearLevel: 2,
          dateEnrolled: DateTime(2024, 6, 1),
        ),
      ];

  // ─── Courses ─────────────────────────────────────────
  static List<Course> get courses => [
        Course(
          id: 'CRS-001',
          courseCode: 'CS 101',
          title: 'Introduction to Computer Science',
          description:
              'Covers the fundamentals of computing, algorithms, and programming logic. An essential first step for all CS students.',
          capacity: 40,
          units: 3,
          schedule: 'MWF 9:00-10:00 AM',
          instructor: 'Dr. Ricardo Pascual',
          category: CourseCategory.cs,
        ),
        Course(
          id: 'CRS-002',
          courseCode: 'CS 201',
          title: 'Data Structures & Algorithms',
          description:
              'In-depth study of data organization, searching, sorting, trees, graphs, and algorithm complexity analysis.',
          capacity: 35,
          units: 3,
          schedule: 'TTh 10:30-12:00 PM',
          instructor: 'Dr. Elena Villanueva',
          prerequisiteCourseId: 'CRS-001',
          category: CourseCategory.cs,
        ),
        Course(
          id: 'CRS-003',
          courseCode: 'CS 301',
          title: 'Software Engineering',
          description:
              'Principles of software design, project management, agile methodologies, and collaborative development practices.',
          capacity: 30,
          units: 3,
          schedule: 'MWF 1:00-2:00 PM',
          instructor: 'Prof. Marco Aquino',
          prerequisiteCourseId: 'CRS-002',
          category: CourseCategory.cs,
        ),
        Course(
          id: 'CRS-004',
          courseCode: 'IT 101',
          title: 'Fundamentals of IT',
          description:
              'Introduction to information technology concepts, hardware, software, networking, and IT infrastructure.',
          capacity: 40,
          units: 3,
          schedule: 'TTh 9:00-10:30 AM',
          instructor: 'Prof. Liza Fernandez',
          category: CourseCategory.it,
        ),
        Course(
          id: 'CRS-005',
          courseCode: 'IT 201',
          title: 'Web Development',
          description:
              'Hands-on course covering HTML, CSS, JavaScript, responsive design, and modern web frameworks.',
          capacity: 35,
          units: 3,
          schedule: 'MWF 10:30-11:30 AM',
          instructor: 'Prof. Daniel Ramos',
          prerequisiteCourseId: 'CRS-004',
          category: CourseCategory.it,
        ),
        Course(
          id: 'CRS-006',
          courseCode: 'MATH 101',
          title: 'Calculus I',
          description:
              'Limits, derivatives, integrals, and their applications in science and engineering.',
          capacity: 45,
          units: 4,
          schedule: 'MWF 8:00-9:00 AM',
          instructor: 'Dr. Gloria Navarro',
          category: CourseCategory.math,
        ),
        Course(
          id: 'CRS-007',
          courseCode: 'MATH 201',
          title: 'Linear Algebra',
          description:
              'Vector spaces, matrices, linear transformations, eigenvalues, and applications.',
          capacity: 35,
          units: 3,
          schedule: 'TTh 1:00-2:30 PM',
          instructor: 'Dr. Antonio Bautista',
          prerequisiteCourseId: 'CRS-006',
          category: CourseCategory.math,
        ),
        Course(
          id: 'CRS-008',
          courseCode: 'GE 101',
          title: 'Purposive Communication',
          description:
              'Develops effective communication skills in various academic and professional contexts.',
          capacity: 50,
          units: 3,
          schedule: 'TTh 3:00-4:30 PM',
          instructor: 'Prof. Carmen Dizon',
          category: CourseCategory.genEd,
        ),
        Course(
          id: 'CRS-009',
          courseCode: 'GE 102',
          title: 'Mathematics in the Modern World',
          description:
              'Explores mathematical concepts and their real-world applications in nature, art, and technology.',
          capacity: 50,
          units: 3,
          schedule: 'MWF 2:00-3:00 PM',
          instructor: 'Prof. Jose Rivera',
          category: CourseCategory.genEd,
        ),
        Course(
          id: 'CRS-010',
          courseCode: 'SCI 101',
          title: 'General Physics I',
          description:
              'Mechanics, thermodynamics, wave motion, and fundamental physical laws with laboratory applications.',
          capacity: 40,
          units: 4,
          schedule: 'MWF 3:00-4:00 PM',
          instructor: 'Dr. Patricia Gomez',
          category: CourseCategory.science,
        ),
      ];

  // ─── Enrollments ─────────────────────────────────────
  static List<Enrollment> get enrollments => [
        // Juan Dela Cruz – completed CS 101, completed CS 201, enrolled CS 301
        Enrollment(
          id: 'ENR-001',
          studentId: 'STU-001',
          courseId: 'CRS-001',
          enrollmentDate: DateTime(2023, 8, 15),
          status: EnrollmentStatus.completed,
          grade: 1.5,
        ),
        Enrollment(
          id: 'ENR-002',
          studentId: 'STU-001',
          courseId: 'CRS-002',
          enrollmentDate: DateTime(2024, 1, 10),
          status: EnrollmentStatus.completed,
          grade: 1.75,
        ),
        Enrollment(
          id: 'ENR-003',
          studentId: 'STU-001',
          courseId: 'CRS-003',
          enrollmentDate: DateTime(2025, 8, 5),
          status: EnrollmentStatus.enrolled,
        ),
        // Maria Santos – enrolled IT 101, enrolled GE 101
        Enrollment(
          id: 'ENR-004',
          studentId: 'STU-002',
          courseId: 'CRS-004',
          enrollmentDate: DateTime(2025, 8, 10),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-005',
          studentId: 'STU-002',
          courseId: 'CRS-008',
          enrollmentDate: DateTime(2025, 8, 10),
          status: EnrollmentStatus.enrolled,
        ),
        // Carlos Reyes – enrolled CS 101, enrolled GE 102
        Enrollment(
          id: 'ENR-006',
          studentId: 'STU-003',
          courseId: 'CRS-001',
          enrollmentDate: DateTime(2025, 8, 12),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-007',
          studentId: 'STU-003',
          courseId: 'CRS-009',
          enrollmentDate: DateTime(2025, 8, 12),
          status: EnrollmentStatus.enrolled,
        ),
        // Ana Garcia – completed MATH 101, completed MATH 201, dropped GE 101
        Enrollment(
          id: 'ENR-008',
          studentId: 'STU-004',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2022, 8, 8),
          status: EnrollmentStatus.completed,
          grade: 1.25,
        ),
        Enrollment(
          id: 'ENR-009',
          studentId: 'STU-004',
          courseId: 'CRS-007',
          enrollmentDate: DateTime(2023, 1, 12),
          status: EnrollmentStatus.completed,
          grade: 1.5,
        ),
        Enrollment(
          id: 'ENR-010',
          studentId: 'STU-004',
          courseId: 'CRS-008',
          enrollmentDate: DateTime(2024, 8, 5),
          status: EnrollmentStatus.dropped,
        ),
        // Pedro Lim – completed IT 101, enrolled IT 201
        Enrollment(
          id: 'ENR-011',
          studentId: 'STU-005',
          courseId: 'CRS-004',
          enrollmentDate: DateTime(2023, 8, 20),
          status: EnrollmentStatus.completed,
          grade: 2.0,
        ),
        Enrollment(
          id: 'ENR-012',
          studentId: 'STU-005',
          courseId: 'CRS-005',
          enrollmentDate: DateTime(2025, 8, 8),
          status: EnrollmentStatus.enrolled,
        ),
        // Sofia Tan – enrolled CS 101, enrolled MATH 101
        Enrollment(
          id: 'ENR-013',
          studentId: 'STU-006',
          courseId: 'CRS-001',
          enrollmentDate: DateTime(2025, 8, 5),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-014',
          studentId: 'STU-006',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2025, 8, 5),
          status: EnrollmentStatus.enrolled,
        ),
        // Miguel Torres – enrolled MATH 101, enrolled GE 102
        Enrollment(
          id: 'ENR-015',
          studentId: 'STU-007',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2025, 8, 18),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-016',
          studentId: 'STU-007',
          courseId: 'CRS-009',
          enrollmentDate: DateTime(2025, 8, 18),
          status: EnrollmentStatus.enrolled,
        ),
        // Isabella Cruz – completed IT 101, completed IT 201, enrolled GE 101
        Enrollment(
          id: 'ENR-017',
          studentId: 'STU-008',
          courseId: 'CRS-004',
          enrollmentDate: DateTime(2022, 8, 14),
          status: EnrollmentStatus.completed,
          grade: 1.75,
        ),
        Enrollment(
          id: 'ENR-018',
          studentId: 'STU-008',
          courseId: 'CRS-005',
          enrollmentDate: DateTime(2023, 1, 8),
          status: EnrollmentStatus.completed,
          grade: 2.25,
        ),
        Enrollment(
          id: 'ENR-019',
          studentId: 'STU-008',
          courseId: 'CRS-008',
          enrollmentDate: DateTime(2025, 8, 6),
          status: EnrollmentStatus.enrolled,
        ),
        // Rafael Mendoza – enrolled SCI 101
        Enrollment(
          id: 'ENR-020',
          studentId: 'STU-009',
          courseId: 'CRS-010',
          enrollmentDate: DateTime(2025, 8, 22),
          status: EnrollmentStatus.enrolled,
        ),
      ];
}
