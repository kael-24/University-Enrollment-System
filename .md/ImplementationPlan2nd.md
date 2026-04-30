# 🎓 EnrollHub — Implementation Plan v2 (Role-Based Refactor)

---

## 1. OVERVIEW

This document outlines the **complete refactored implementation** of EnrollHub, addressing discrepancies between the original `ImplementationPlan1st.md` and the updated `ProjectInstructions.md`. The key change is transitioning from an admin-centric model to a **student-initiated, professor-approved** enrollment flow with proper role-based authentication.

---

## 2. DISCREPANCIES IDENTIFIED

| # | Issue | Original (v1) | Required (Instructions) |
|---|-------|---------------|------------------------|
| 1 | **Enrollment Flow** | Admin/professor enrolls students directly | **Students** initiate enrollment → professor confirms |
| 2 | **Drop Course** | No drop feature for students | Students must be able to **drop courses** themselves |
| 3 | **Authentication** | No login; single-role access | Two accounts: **Student** and **Professor** with login |
| 4 | **Student ID Format** | `STU-001` format | `YYYY-CODE-LETTER` format (e.g., `2023-2735-A`) |
| 5 | **Professor Role** | Not implemented | Add/remove/update courses, confirm/reject enrollments, grade students |
| 6 | **Student Role** | Mixed with admin | Enroll, drop, view courses independently |
| 7 | **Enrollment Status** | `enrolled`, `dropped`, `completed` only | Added `pending` status for professor approval workflow |
| 8 | **Prerequisite Checks** | Existed but in admin context | Must work in student self-enrollment context |
| 9 | **Grade Input** | Professor-only action (correct) | Professor grades completed courses (confirmed correct) |
| 10 | **Navigation** | Single bottom nav for all users | Role-based navigation shells (student vs. professor) |

---

## 3. ARCHITECTURE

### 3.1 Authentication Flow
```
App Start → Login Page
  ├── Student Login (ID: YYYY-CODE-LETTER, Password)
  │   └── Student Shell (Dashboard, Courses, Enrollments)
  └── Professor Login (ID: PROF-XXX, Password)
      └── Professor Shell (Dashboard, Courses, Students, Enrollments)
```

### 3.2 Enrollment Flow (Student-Initiated)
```
1. Student browses courses → sees availability, prerequisites
2. Student taps "Enroll" → System checks capacity + prerequisites
3. Enrollment created with status = PENDING
4. Professor sees pending requests in their dashboard
5. Professor approves → status changes to ENROLLED
   OR Professor rejects → enrollment removed
6. Student can DROP enrolled courses (status → DROPPED)
7. Professor marks enrolled courses as COMPLETED
8. Professor assigns grade to completed enrollments
```

### 3.3 Data Models

#### Student
```dart
class Student {
  final String id;            // YYYY-CODE-LETTER format
  final String firstName;
  final String lastName;
  final String email;
  final String program;
  final int yearLevel;
  final DateTime dateEnrolled;
  final String password;       // Simple in-memory password
}
```

#### Professor
```dart
class Professor {
  final String id;            // PROF-XXX format
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final String password;
}
```

#### Course
```dart
class Course {
  final String id;
  final String courseCode;
  final String title;
  final String description;
  final int capacity;
  final int units;
  final String schedule;
  final String instructor;
  final String? prerequisiteCourseId;
  final CourseCategory category;
}
```

#### Enrollment
```dart
class Enrollment {
  final String id;
  final String studentId;
  final String courseId;
  final DateTime enrollmentDate;
  EnrollmentStatus status;    // pending → enrolled → completed/dropped
  double? grade;
}
```

#### Enums
```dart
enum EnrollmentStatus { pending, enrolled, dropped, completed }
enum CourseCategory { cs, it, math, genEd, science }
enum UserRole { student, professor }
```

---

## 4. PROVIDERS (STATE MANAGEMENT)

### 4.1 AuthProvider
- `loginAsStudent(id, password)` → validates against seed data
- `loginAsProfessor(id, password)` → validates against seed data
- `logout()` → clears session
- Exposes: `currentRole`, `currentUserId`, `isLoggedIn`, `isStudent`, `isProfessor`

### 4.2 StudentProvider
- In-memory `List<Student>` initialized with seed data
- `getStudentById(id)`, `search(query)`, `filter(program, yearLevel)`
- `addStudent(...)` — professor can add students

### 4.3 CourseProvider
- In-memory `List<Course>` initialized with seed data
- `getCourseById(id)`, `getCourseByCode(code)`, `search(query)`, `filterByCategory(cat)`
- `addCourse(...)`, `updateCourse(...)`, `removeCourse(...)` — professor CRUD

### 4.4 EnrollmentProvider
- In-memory `List<Enrollment>` initialized with seed data
- **Student actions:**
  - `requestEnrollment(studentId, courseId, capacity, prereq)` → creates PENDING enrollment
  - `dropEnrollment(enrollmentId)` → changes status to DROPPED
- **Professor actions:**
  - `approveEnrollment(enrollmentId)` → changes PENDING to ENROLLED
  - `rejectEnrollment(enrollmentId)` → removes the pending enrollment
  - `markCompleted(enrollmentId)` → changes ENROLLED to COMPLETED
  - `updateGrade(enrollmentId, grade)` → sets grade on COMPLETED enrollment
- **Query methods:**
  - `getEnrollmentsForStudent(id)`, `getActiveEnrollmentsForStudent(id)`
  - `getPendingEnrollmentsForStudent(id)`, `getCompletedEnrollmentsForStudent(id)`
  - `getHistoryForStudent(id)` (dropped + completed)
  - `getEnrollmentsForCourse(id)`, `getActiveEnrollmentsForCourse(id)`
  - `getEnrolledCount(courseId)`, `isStudentEnrolledInCourse(s, c)`
  - `isStudentPendingInCourse(s, c)`, `hasStudentCompletedCourse(s, c)`
  - `getRecentEnrollments(limit)`, `filterByStatus(status)`

---

## 5. PAGES & NAVIGATION

### 5.1 Login Page (`/login`)
- Tab-based: Student | Professor
- Student: enters YYYY-CODE-LETTER ID + password
- Professor: enters PROF-XXX ID + password
- Demo credentials shown as a hint
- Redirects to appropriate shell on success

### 5.2 Student Shell (Bottom Nav: Dashboard, Courses, Enrollments)

#### Student Dashboard (`/student/dashboard`)
- Welcome header with student name, ID, program
- Stats: Active courses, Pending requests, Completed, Available courses
- Quick actions: Browse Courses, My Enrollments
- Active courses list, Pending requests list

#### Student Courses (`/student/courses`)
- Browse all courses with search + category filter
- Shows capacity, prerequisites, enrollment status per course
- "Enroll in Course" button → creates PENDING enrollment
- Validates: capacity, duplicates, prerequisites, already completed

#### Student Enrollments (`/student/enrollments`)
- Tabs: Active | Pending | History
- Active tab: swipe-to-drop with confirmation dialog
- Pending tab: shows awaiting approval status
- History tab: dropped + completed courses with grades

### 5.3 Professor Shell (Bottom Nav: Dashboard, Courses, Students, Enrollments)

#### Professor Dashboard (`/professor/dashboard`)
- Welcome header with professor name, department
- Stats: Total students, Total courses, Pending, Active enrollments
- Quick actions: Review Pending, Manage Courses
- Pending enrollments with Approve/Reject buttons

#### Professor Courses (`/professor/courses`)
- Full CRUD: Add, Edit, Delete courses
- Search + category filter
- Capacity bars for each course
- FAB to add new course

#### Professor Students (`/professor/students`)
- View all students with search
- Expandable cards showing student's enrollments
- Mark enrolled → completed action
- Grade input for completed enrollments
- FAB to add new student

#### Professor Enrollments (`/professor/enrollments`)
- Tabs: Pending | Active | Done | All
- Pending tab: Approve/Reject buttons
- Search by student or course
- Grade display for completed enrollments

---

## 6. ROUTING CONFIGURATION

```
/login                          → LoginPage (initial)
/student/dashboard              → StudentDashboardPage (student shell)
/student/courses                → StudentCoursesPage (student shell)
/student/enrollments            → StudentEnrollmentsPage (student shell)
/professor/dashboard            → ProfessorDashboardPage (professor shell)
/professor/courses              → ProfessorCoursesPage (professor shell)
/professor/students             → ProfessorStudentsPage (professor shell)
/professor/enrollments          → ProfessorEnrollmentsPage (professor shell)
```

Redirect logic:
- If not logged in → redirect to `/login`
- If student tries professor routes → redirect to student dashboard
- If professor tries student routes → redirect to professor dashboard

---

## 7. BUSINESS RULES

1. **Capacity Check:** `course.enrolledCount < course.capacity` before enrollment
2. **Duplicate Check:** Student cannot have an active or pending enrollment in the same course
3. **Prerequisite Check:** Student must have `completed` the prerequisite course
4. **Drop:** Student can drop `enrolled` courses → status changes to `dropped`
5. **Grade:** Only professor can grade `completed` enrollments (1.0-5.0 scale)
6. **Mark Complete:** Only professor can change `enrolled` → `completed`
7. **Approve/Reject:** Only professor handles pending enrollments

---

## 8. SEED DATA

### Professors (4)
| ID | Name | Department | Password |
|----|------|-----------|----------|
| PROF-001 | Ricardo Pascual | Computer Science | prof001 |
| PROF-002 | Elena Villanueva | Computer Science | prof002 |
| PROF-003 | Liza Fernandez | Information Technology | prof003 |
| PROF-004 | Gloria Navarro | Mathematics | prof004 |

### Students (10) — YYYY-CODE-LETTER format
| ID | Name | Program | Year | Password |
|----|------|---------|------|----------|
| 2023-2735-A | Juan Dela Cruz | BS Computer Science | 3 | 2023-2735-A |
| 2024-1482-B | Maria Santos | BS Information Technology | 2 | 2024-1482-B |
| 2025-3091-C | Carlos Reyes | BS Computer Science | 1 | 2025-3091-C |
| 2022-4517-A | Ana Garcia | BS Mathematics | 4 | 2022-4517-A |
| 2023-5623-B | Pedro Lim | BS Information Technology | 3 | 2023-5623-B |
| 2024-6178-C | Sofia Tan | BS Computer Science | 2 | 2024-6178-C |
| 2025-7204-A | Miguel Torres | BS Mathematics | 1 | 2025-7204-A |
| 2022-8356-B | Isabella Cruz | BS Information Technology | 4 | 2022-8356-B |
| 2023-9412-C | Rafael Mendoza | BS Computer Science | 3 | 2023-9412-C |
| 2024-1067-A | Camille Flores | BS Mathematics | 2 | 2024-1067-A |

### Courses (10) with prerequisites and categories
### Enrollments (21) — mix of enrolled, pending, completed, dropped

---

## 9. UI/UX DESIGN

- **Dark theme** with glassmorphism cards
- **Color palette:** Background `#0F0F1A`, Surface `#1A1A2E`, Primary `#6C63FF`, Secondary `#00D9FF`
- **Typography:** Poppins for headings, Inter for body text via Google Fonts
- **Animations:** Counter animations, page transitions, button feedback, success checkmarks
- **Bottom navigation** with gradient active indicators
- **Responsive** layout for mobile and tablet

---

## 10. CHANGES MADE IN THIS REFACTOR

### Files Modified:
1. **`main.dart`** — Added `AuthProvider` to the MultiProvider
2. **`app.dart`** — Complete rewrite: auth-aware routing with `StudentShell` and `ProfessorShell`, redirect logic, role-based bottom navigation
3. **`enrollment_dialog.dart`** — Fixed broken `enrollStudent()` call → uses `requestEnrollment()` method

### Files Already Correct (from previous work):
- `models/student.dart` — YYYY-CODE-LETTER ID format ✓
- `models/professor.dart` — Professor model ✓
- `models/enrollment.dart` — Enrollment with pending status ✓
- `models/enums.dart` — EnrollmentStatus.pending, UserRole enum ✓
- `providers/auth_provider.dart` — Login/logout logic ✓
- `providers/enrollment_provider.dart` — requestEnrollment, approve/reject, drop, grade ✓
- `providers/course_provider.dart` — Full CRUD ✓
- `providers/student_provider.dart` — Student management ✓
- `data/dummy_data.dart` — Proper seed data with all roles ✓
- `pages/auth/login_page.dart` — Dual-tab login ✓
- `pages/student/*` — Student dashboard, courses, enrollments ✓
- `pages/professor/*` — Professor dashboard, courses, students, enrollments ✓
- All widgets — Glass cards, status chips, grade sheets, etc. ✓

### Legacy Files Removed from Routing:
- `pages/dashboard/dashboard_page.dart` — Old non-auth dashboard (kept for reference, no longer routed)
- `pages/students/students_page.dart` — Old non-auth students page
- `pages/students/student_detail_page.dart` — Old non-auth student detail
- `pages/courses/courses_page.dart` — Old non-auth courses page
- `pages/courses/course_detail_page.dart` — Old non-auth course detail
- `pages/enrollments/enrollments_page.dart` — Old non-auth enrollments page
