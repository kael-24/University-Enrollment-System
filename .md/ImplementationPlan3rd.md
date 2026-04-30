# EnrollHub - Implementation Plan v3

---

## 1. Overview

This document records the third round of changes made to EnrollHub. The update expands the v2 role-based system by adding administrator access, limiting professor authority to assigned courses, converting student drops into professor-approved requests, and adding confirmation dialogs before professor approval/rejection actions.

All changes remain in-memory only. No database, persistence layer, or external storage was added.

---

## 2. New Requirements Implemented

| # | Requirement | Implementation |
|---|-------------|----------------|
| 1 | Professor account should only handle managed subjects | Added `professorId` ownership to `Course`; professor pages now scope courses, students, requests, and dashboard stats to the logged-in professor's managed courses |
| 2 | Student course dropping should only be a request approved by professor in charge | Added `EnrollmentStatus.dropPending`; student drop action now submits a drop request; professor/admin can approve or reject it |
| 3 | Add admin account with full overview, history, credential management, and full course authority | Added `admin` role, admin login, admin shell, overview dashboard, history page, account credentials page, and full access to course/student/enrollment management |
| 4 | Professor approval/rejection should show a confirmation dialog first | Added confirmation dialogs before approving/rejecting enrollment requests and drop requests on professor dashboard and enrollment pages |

---

## 3. Updated Architecture

### 3.1 Authentication Flow

```text
App Start -> Login Page
  |-- Student Login
  |   `-- Student Shell: Dashboard, Courses, Enrollments
  |-- Professor Login
  |   `-- Professor Shell: Dashboard, Managed Courses, Managed Students, Managed Requests
  `-- Admin Login
      `-- Admin Shell: Dashboard, Courses, Students, Requests, History, Accounts
```

### 3.2 Course Ownership

Courses now include a real owner field:

```dart
final String? professorId;
```

This is separate from the display-only `instructor` name. Professor access is based on `professorId`, not instructor text.

### 3.3 Drop Request Flow

```text
1. Student swipes an enrolled course to drop
2. Confirmation dialog explains this is only a request
3. Enrollment status changes from enrolled -> dropPending
4. Professor in charge sees the drop request
5. Professor approves -> status becomes dropped
6. Professor rejects -> status returns to enrolled
```

### 3.4 Enrollment Approval Flow

```text
1. Student requests enrollment
2. Enrollment status is pending
3. Professor in charge reviews request
4. Confirmation dialog appears before approve/reject
5. Approve -> enrolled
6. Reject -> pending enrollment is removed
```

---

## 4. Data Model Updates

### Course

Added:

```dart
final String? professorId;
```

Used for professor-specific course ownership and request filtering.

### EnrollmentStatus

Updated from:

```dart
enum EnrollmentStatus { pending, enrolled, dropped, completed }
```

To:

```dart
enum EnrollmentStatus { pending, enrolled, dropPending, dropped, completed }
```

`dropPending` means the student has requested to drop the course, but the professor has not approved it yet.

### UserRole

Updated from:

```dart
enum UserRole { student, professor }
```

To:

```dart
enum UserRole { student, professor, admin }
```

### AdminAccount

Added a simple in-memory admin account model:

```dart
class AdminAccount {
  final String username;
  final String password;
}
```

Seed credentials:

```text
Username: admin
Password: admin123
```

---

## 5. Provider Updates

### AuthProvider

Added:

- `loginAsAdmin(username, password)`
- `isAdmin`
- `adminAccount`
- `updateAdminCredentials(...)`

Student and professor login now validate against the live provider lists instead of static seed data, so admin credential changes take effect during the current app session.

### ProfessorProvider

Added a new provider for in-memory professor records:

- `professors`
- `getProfessorById(id)`
- `updateCredentials(currentId, newId, password)`

### CourseProvider

Added:

- `professorId` support in `addCourse(...)` and `updateCourse(...)`
- `getCoursesForProfessor(professorId)`
- `reassignProfessorId(oldId, newId)`

When an admin changes a professor ID, assigned courses are reassigned to the new ID.

### StudentProvider

Added:

- `updateCredentials(currentId, newId, password)`

When an admin changes a student ID, enrollments are reassigned to the new ID.

### EnrollmentProvider

Added:

- `dropRequests`
- `requestDropEnrollment(enrollmentId)`
- `approveDropRequest(enrollmentId)`
- `rejectDropRequest(enrollmentId)`
- `reassignStudentId(oldId, newId)`

Updated:

- `pendingEnrollments` now includes both enrollment requests and drop requests
- `getPendingEnrollmentsForStudent(...)` includes `pending` and `dropPending`
- `isStudentPendingInCourse(...)` treats `dropPending` as an active pending state

---

## 6. Routing Updates

Added admin routes:

```text
/admin/dashboard      -> AdminDashboardPage
/admin/courses        -> ProfessorCoursesPage with admin-wide scope
/admin/students       -> ProfessorStudentsPage with admin-wide scope
/admin/enrollments    -> ProfessorEnrollmentsPage with admin-wide scope
/admin/history        -> AdminHistoryPage
/admin/accounts       -> AdminAccountsPage
```

Redirect rules now include:

- Student users cannot access professor/admin routes
- Professor users cannot access student/admin routes
- Admin users cannot access student routes
- Login redirects to the correct dashboard for the authenticated role

---

## 7. Page Updates

### Login Page

Updated from two tabs to three tabs:

```text
Student | Professor | Admin
```

Admin demo credentials were added to the credential hint panel.

### Professor Dashboard

Now scoped to the logged-in professor:

- Managed course count only
- Students enrolled in managed courses only
- Pending enrollment/drop requests for managed courses only
- Active enrollments for managed courses only

Approve/reject buttons now show confirmation dialogs.

### Professor Courses

Professor view:

- Shows only courses where `course.professorId == currentUserId`
- New courses created by a professor are automatically assigned to that professor

Admin view:

- Shows and manages all courses

### Professor Students

Professor view:

- Shows only students connected to the professor's managed courses
- Expanded enrollment lists are filtered to managed courses

Admin view:

- Shows all students
- Keeps add-student authority

### Professor Enrollments

Professor view:

- Shows only enrollment/drop requests for managed courses

Admin view:

- Shows all enrollment/drop requests

Pending tab now handles both:

- enrollment approval/rejection
- drop approval/rejection

### Student Enrollments

Drop action changed:

- Before: directly changed status to `dropped`
- Now: changes status to `dropPending`

The confirmation copy now clearly says the drop is a request for professor approval.

### Admin Dashboard

Added new overview page with:

- student count
- course count
- pending request count
- history count
- quick links to admin actions

### Admin History

Added history page showing enrollment records, including active, completed, and dropped records.

### Admin Accounts

Added credential management for:

- students
- professors
- admin account

Credential edits are in-memory and reset when the app restarts, matching the project storage rules.

---

## 8. Business Rules Updated

1. Professors only manage courses assigned through `course.professorId`.
2. Admin has global access to courses, students, enrollments, history, and credentials.
3. Student enrollment requests still require professor approval.
4. Student drop actions now require professor approval.
5. A drop request changes status to `dropPending`, not `dropped`.
6. Approving a drop request changes `dropPending -> dropped`.
7. Rejecting a drop request changes `dropPending -> enrolled`.
8. Approving an enrollment request changes `pending -> enrolled`.
9. Rejecting an enrollment request removes the pending enrollment.
10. Professor approve/reject actions must be confirmed through a dialog first.

---

## 9. Files Added

```text
lib/models/admin_account.dart
lib/providers/professor_provider.dart
lib/pages/admin/admin_dashboard_page.dart
lib/pages/admin/admin_history_page.dart
lib/pages/admin/admin_accounts_page.dart
```

---

## 10. Key Files Modified

```text
lib/app.dart
lib/main.dart
lib/data/dummy_data.dart
lib/models/course.dart
lib/models/enums.dart
lib/models/professor.dart
lib/providers/auth_provider.dart
lib/providers/course_provider.dart
lib/providers/enrollment_provider.dart
lib/providers/student_provider.dart
lib/widgets/status_chip.dart
lib/pages/auth/login_page.dart
lib/pages/student/student_enrollments_page.dart
lib/pages/professor/professor_dashboard_page.dart
lib/pages/professor/professor_courses_page.dart
lib/pages/professor/professor_students_page.dart
lib/pages/professor/professor_enrollments_page.dart
```

---

## 11. Verification

Commands run:

```text
dart format lib
flutter analyze --no-fatal-infos
flutter test
```

Results:

- `dart format lib` completed successfully.
- `flutter analyze --no-fatal-infos` completed successfully with no errors or warnings.
- Analyzer still reports existing info-level lint messages when fatal infos are enabled.
- `flutter test` could not run because the project does not currently contain a `test` directory.

---

## 12. Notes and Limitations

- All credentials and data changes remain in memory only.
- Admin credential edits, professor ID edits, and student ID edits reset after app restart.
- The admin course management view reuses professor course management UI with global scope.
- The admin student and request views reuse professor pages with global scope.
- The current history view is based on enrollment records and statuses, not a separate immutable audit-log model.
