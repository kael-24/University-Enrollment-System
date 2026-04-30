import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/professor.dart';
import '../models/enums.dart';

/// Pre-seeded dummy data for the application.
class DummyData {
  DummyData._();

  // ─── Professors ─────────────────────────────────────
  static List<Professor> get professors => [
        Professor(
          id: 'PROF-001',
          firstName: 'Ricardo',
          lastName: 'Pascual',
          email: 'r.pascual@enrollhub.edu',
          department: 'Computer Science',
          password: 'prof001',
        ),
        Professor(
          id: 'PROF-002',
          firstName: 'Elena',
          lastName: 'Villanueva',
          email: 'e.villanueva@enrollhub.edu',
          department: 'Computer Science',
          password: 'prof002',
        ),
        Professor(
          id: 'PROF-003',
          firstName: 'Liza',
          lastName: 'Fernandez',
          email: 'l.fernandez@enrollhub.edu',
          department: 'Information Technology',
          password: 'prof003',
        ),
        Professor(
          id: 'PROF-004',
          firstName: 'Gloria',
          lastName: 'Navarro',
          email: 'g.navarro@enrollhub.edu',
          department: 'Mathematics',
          password: 'prof004',
        ),
      ];

  // ─── Students ────────────────────────────────────────
  // IDs follow YYYY-CODE-LETTER format as per instructions
  static List<Student> get students => [
        Student(
          id: '2023-2735-A',
          firstName: 'Juan',
          lastName: 'Dela Cruz',
          email: 'juan.delacruz@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 3,
          dateEnrolled: DateTime(2023, 6, 15),
          password: '2023-2735-A',
        ),
        Student(
          id: '2024-1482-B',
          firstName: 'Maria',
          lastName: 'Santos',
          email: 'maria.santos@enrollhub.edu',
          program: 'BS Information Technology',
          yearLevel: 2,
          dateEnrolled: DateTime(2024, 6, 10),
          password: '2024-1482-B',
        ),
        Student(
          id: '2025-3091-C',
          firstName: 'Carlos',
          lastName: 'Reyes',
          email: 'carlos.reyes@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 1,
          dateEnrolled: DateTime(2025, 6, 12),
          password: '2025-3091-C',
        ),
        Student(
          id: '2022-4517-A',
          firstName: 'Ana',
          lastName: 'Garcia',
          email: 'ana.garcia@enrollhub.edu',
          program: 'BS Mathematics',
          yearLevel: 4,
          dateEnrolled: DateTime(2022, 6, 8),
          password: '2022-4517-A',
        ),
        Student(
          id: '2023-5623-B',
          firstName: 'Pedro',
          lastName: 'Lim',
          email: 'pedro.lim@enrollhub.edu',
          program: 'BS Information Technology',
          yearLevel: 3,
          dateEnrolled: DateTime(2023, 6, 20),
          password: '2023-5623-B',
        ),
        Student(
          id: '2024-6178-C',
          firstName: 'Sofia',
          lastName: 'Tan',
          email: 'sofia.tan@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 2,
          dateEnrolled: DateTime(2024, 6, 5),
          password: '2024-6178-C',
        ),
        Student(
          id: '2025-7204-A',
          firstName: 'Miguel',
          lastName: 'Torres',
          email: 'miguel.torres@enrollhub.edu',
          program: 'BS Mathematics',
          yearLevel: 1,
          dateEnrolled: DateTime(2025, 6, 18),
          password: '2025-7204-A',
        ),
        Student(
          id: '2022-8356-B',
          firstName: 'Isabella',
          lastName: 'Cruz',
          email: 'isabella.cruz@enrollhub.edu',
          program: 'BS Information Technology',
          yearLevel: 4,
          dateEnrolled: DateTime(2022, 6, 14),
          password: '2022-8356-B',
        ),
        Student(
          id: '2023-9412-C',
          firstName: 'Rafael',
          lastName: 'Mendoza',
          email: 'rafael.mendoza@enrollhub.edu',
          program: 'BS Computer Science',
          yearLevel: 3,
          dateEnrolled: DateTime(2023, 6, 22),
          password: '2023-9412-C',
        ),
        Student(
          id: '2024-1067-A',
          firstName: 'Camille',
          lastName: 'Flores',
          email: 'camille.flores@enrollhub.edu',
          program: 'BS Mathematics',
          yearLevel: 2,
          dateEnrolled: DateTime(2024, 6, 1),
          password: '2024-1067-A',
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
        // Juan Dela Cruz (2023-2735-A) – completed CS 101, completed CS 201, enrolled CS 301
        Enrollment(
          id: 'ENR-001',
          studentId: '2023-2735-A',
          courseId: 'CRS-001',
          enrollmentDate: DateTime(2023, 8, 15),
          status: EnrollmentStatus.completed,
          grade: 1.5,
        ),
        Enrollment(
          id: 'ENR-002',
          studentId: '2023-2735-A',
          courseId: 'CRS-002',
          enrollmentDate: DateTime(2024, 1, 10),
          status: EnrollmentStatus.completed,
          grade: 1.75,
        ),
        Enrollment(
          id: 'ENR-003',
          studentId: '2023-2735-A',
          courseId: 'CRS-003',
          enrollmentDate: DateTime(2025, 8, 5),
          status: EnrollmentStatus.enrolled,
        ),
        // Maria Santos (2024-1482-B) – enrolled IT 101, enrolled GE 101
        Enrollment(
          id: 'ENR-004',
          studentId: '2024-1482-B',
          courseId: 'CRS-004',
          enrollmentDate: DateTime(2025, 8, 10),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-005',
          studentId: '2024-1482-B',
          courseId: 'CRS-008',
          enrollmentDate: DateTime(2025, 8, 10),
          status: EnrollmentStatus.enrolled,
        ),
        // Carlos Reyes (2025-3091-C) – enrolled CS 101, enrolled GE 102
        Enrollment(
          id: 'ENR-006',
          studentId: '2025-3091-C',
          courseId: 'CRS-001',
          enrollmentDate: DateTime(2025, 8, 12),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-007',
          studentId: '2025-3091-C',
          courseId: 'CRS-009',
          enrollmentDate: DateTime(2025, 8, 12),
          status: EnrollmentStatus.enrolled,
        ),
        // Ana Garcia (2022-4517-A) – completed MATH 101, completed MATH 201, dropped GE 101
        Enrollment(
          id: 'ENR-008',
          studentId: '2022-4517-A',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2022, 8, 8),
          status: EnrollmentStatus.completed,
          grade: 1.25,
        ),
        Enrollment(
          id: 'ENR-009',
          studentId: '2022-4517-A',
          courseId: 'CRS-007',
          enrollmentDate: DateTime(2023, 1, 12),
          status: EnrollmentStatus.completed,
          grade: 1.5,
        ),
        Enrollment(
          id: 'ENR-010',
          studentId: '2022-4517-A',
          courseId: 'CRS-008',
          enrollmentDate: DateTime(2024, 8, 5),
          status: EnrollmentStatus.dropped,
        ),
        // Pedro Lim (2023-5623-B) – completed IT 101, enrolled IT 201
        Enrollment(
          id: 'ENR-011',
          studentId: '2023-5623-B',
          courseId: 'CRS-004',
          enrollmentDate: DateTime(2023, 8, 20),
          status: EnrollmentStatus.completed,
          grade: 2.0,
        ),
        Enrollment(
          id: 'ENR-012',
          studentId: '2023-5623-B',
          courseId: 'CRS-005',
          enrollmentDate: DateTime(2025, 8, 8),
          status: EnrollmentStatus.enrolled,
        ),
        // Sofia Tan (2024-6178-C) – enrolled CS 101, enrolled MATH 101
        Enrollment(
          id: 'ENR-013',
          studentId: '2024-6178-C',
          courseId: 'CRS-001',
          enrollmentDate: DateTime(2025, 8, 5),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-014',
          studentId: '2024-6178-C',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2025, 8, 5),
          status: EnrollmentStatus.enrolled,
        ),
        // Miguel Torres (2025-7204-A) – enrolled MATH 101, pending GE 102
        Enrollment(
          id: 'ENR-015',
          studentId: '2025-7204-A',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2025, 8, 18),
          status: EnrollmentStatus.enrolled,
        ),
        Enrollment(
          id: 'ENR-016',
          studentId: '2025-7204-A',
          courseId: 'CRS-009',
          enrollmentDate: DateTime(2025, 8, 18),
          status: EnrollmentStatus.pending, // Pending professor approval
        ),
        // Isabella Cruz (2022-8356-B) – completed IT 101, completed IT 201, enrolled GE 101
        Enrollment(
          id: 'ENR-017',
          studentId: '2022-8356-B',
          courseId: 'CRS-004',
          enrollmentDate: DateTime(2022, 8, 14),
          status: EnrollmentStatus.completed,
          grade: 1.75,
        ),
        Enrollment(
          id: 'ENR-018',
          studentId: '2022-8356-B',
          courseId: 'CRS-005',
          enrollmentDate: DateTime(2023, 1, 8),
          status: EnrollmentStatus.completed,
          grade: 2.25,
        ),
        Enrollment(
          id: 'ENR-019',
          studentId: '2022-8356-B',
          courseId: 'CRS-008',
          enrollmentDate: DateTime(2025, 8, 6),
          status: EnrollmentStatus.enrolled,
        ),
        // Rafael Mendoza (2023-9412-C) – pending SCI 101
        Enrollment(
          id: 'ENR-020',
          studentId: '2023-9412-C',
          courseId: 'CRS-010',
          enrollmentDate: DateTime(2025, 8, 22),
          status: EnrollmentStatus.pending, // Pending professor approval
        ),
        // Camille Flores (2024-1067-A) – pending MATH 101
        Enrollment(
          id: 'ENR-021',
          studentId: '2024-1067-A',
          courseId: 'CRS-006',
          enrollmentDate: DateTime(2025, 8, 25),
          status: EnrollmentStatus.pending, // Pending professor approval
        ),
      ];
}
