# 🎓 Course Enrollment Simulator — Master Prompt for Claude AI (Antigravity IDE) 1st Version

---

## PROJECT OVERVIEW

Build a **Course Enrollment Simulator** — a fully functional Flutter desktop/mobile application that manages students, courses, and enrollment processes using object-oriented programming principles. The app must be visually stunning with a sleek, modern, premium UI/UX design. **No database is required** — all data should be stored in-memory using dummy/seed data and will be lost on app refresh.

---

## TECHNOLOGY STACK

- **Language:** Dart
- **Framework:** Flutter (latest stable)
- **State Management:** Provider (or Riverpod if you prefer — pick one and be consistent)
- **Routing:** GoRouter (`go_router` package)
- **Storage:** In-memory only (no database, no SharedPreferences, no local storage). Pre-seed the app with realistic dummy data on startup. All data resets when the app restarts.
- **Icons:** Material Icons + Lucide Icons (`lucide_icons` package) or Iconsax (`iconsax` package)
- **Fonts:** Google Fonts — use `Inter` or `Poppins` as the primary font via the `google_fonts` package

---

## DESIGN SYSTEM & UI/UX REQUIREMENTS

### Color Palette (Dark Theme Primary)
Design a **dark-mode-first** interface with the following palette:
- **Background:** `#0F0F1A` (deep dark navy/charcoal)
- **Surface/Cards:** `#1A1A2E` with subtle glassmorphism (semi-transparent with blur)
- **Primary Accent:** `#6C63FF` (vibrant indigo/purple)
- **Secondary Accent:** `#00D9FF` (cyan/electric blue)
- **Success:** `#00E676` (bright green)
- **Warning:** `#FFB74D` (amber)
- **Error/Danger:** `#FF5252` (red)
- **Text Primary:** `#FFFFFF`
- **Text Secondary:** `#8E8EA0`
- **Dividers/Borders:** `#2A2A3E`

### Design Principles
1. **Glassmorphism** — Cards and panels should have frosted glass effects with `BackdropFilter`, subtle borders (`Colors.white.withOpacity(0.05)`), and soft shadows.
2. **Gradient Accents** — Use linear gradients (indigo → cyan) on primary action buttons, headers, and progress indicators.
3. **Rounded Corners** — Use `BorderRadius.circular(16)` for cards, `BorderRadius.circular(12)` for buttons, `BorderRadius.circular(24)` for chips/tags.
4. **Smooth Animations** — Page transitions (fade + slide), list item animations (staggered), button press feedback (scale animation), hero transitions for navigation.
5. **Micro-interactions** — Hover/tap ripple effects, animated counters, progress bar animations, success/error toast animations.
6. **Consistent Spacing** — Use 8px grid system. Padding: 16px or 24px for containers. Gap between cards: 12px or 16px.
7. **Typography Hierarchy:**
   - Headings: `Poppins` or `Inter`, bold, 24-28px
   - Subheadings: Semi-bold, 18-20px
   - Body: Regular, 14-16px
   - Captions: Regular, 12px, secondary text color
8. **Empty States** — Design beautiful empty state illustrations/icons with descriptive text when lists are empty.
9. **Bottom Navigation Bar** — Use a custom styled bottom nav with 4 tabs: Dashboard, Students, Courses, Enrollments. Active tab should have a gradient indicator.

---

## DATA MODELS (OOP Classes)

### 1. Student
```dart
class Student {
  final String id;            // Unique ID (e.g., "STU-001")
  final String firstName;
  final String lastName;
  final String email;
  final String program;       // e.g., "BS Computer Science"
  final int yearLevel;        // 1, 2, 3, 4
  final String avatarUrl;     // Placeholder avatar (use initials-based avatar or asset)
  final DateTime dateEnrolled;

  // Computed
  String get fullName => '$firstName $lastName';
  List<Enrollment> get enrollments => /* fetched from EnrollmentManager */;
  List<Course> get enrolledCourses => /* derived from enrollments */;
}
```

### 2. Course
```dart
class Course {
  final String id;            // Unique ID (e.g., "CRS-001")
  final String courseCode;    // e.g., "CS 101"
  final String title;         // e.g., "Introduction to Computer Science"
  final String description;   // Brief course description
  final int capacity;         // Maximum students allowed
  final int units;            // Credit units (e.g., 3)
  final String schedule;      // e.g., "MWF 9:00-10:00 AM"
  final String instructor;    // Instructor name
  final String? prerequisiteCourseId; // Optional prerequisite course ID
  final CourseCategory category; // enum: CS, IT, MATH, GEN_ED, SCIENCE

  // Computed
  int get enrolledCount => /* fetched from EnrollmentManager */;
  int get availableSlots => capacity - enrolledCount;
  bool get isFull => enrolledCount >= capacity;
}
```

### 3. Enrollment
```dart
class Enrollment {
  final String id;            // Unique ID (e.g., "ENR-001")
  final String studentId;
  final String courseId;
  final DateTime enrollmentDate;
  EnrollmentStatus status;    // enum: ENROLLED, DROPPED, COMPLETED
  double? grade;              // Optional grade (1.0 - 5.0 scale, or letter grade)

  // Computed
  Student get student => /* fetched from StudentManager */;
  Course get course => /* fetched from CourseManager */;
}
```

### 4. Enums
```dart
enum EnrollmentStatus { enrolled, dropped, completed }
enum CourseCategory { cs, it, math, genEd, science }
```

---

## DUMMY/SEED DATA

Pre-populate the app with the following on startup:

### Students (at least 8-10)
| ID | Name | Program | Year |
|----|------|---------|------|
| STU-001 | Juan Dela Cruz | BS Computer Science | 3 |
| STU-002 | Maria Santos | BS Information Technology | 2 |
| STU-003 | Carlos Reyes | BS Computer Science | 1 |
| STU-004 | Ana Garcia | BS Mathematics | 4 |
| STU-005 | Pedro Lim | BS Information Technology | 3 |
| STU-006 | Sofia Tan | BS Computer Science | 2 |
| STU-007 | Miguel Torres | BS Mathematics | 1 |
| STU-008 | Isabella Cruz | BS Information Technology | 4 |
| STU-009 | Rafael Mendoza | BS Computer Science | 3 |
| STU-010 | Camille Flores | BS Mathematics | 2 |

### Courses (at least 8-10)
| Code | Title | Capacity | Units | Category | Prerequisite |
|------|-------|----------|-------|----------|--------------|
| CS 101 | Introduction to Computer Science | 40 | 3 | CS | None |
| CS 201 | Data Structures & Algorithms | 35 | 3 | CS | CS 101 |
| CS 301 | Software Engineering | 30 | 3 | CS | CS 201 |
| IT 101 | Fundamentals of IT | 40 | 3 | IT | None |
| IT 201 | Web Development | 35 | 3 | IT | IT 101 |
| MATH 101 | Calculus I | 45 | 4 | Math | None |
| MATH 201 | Linear Algebra | 35 | 3 | Math | MATH 101 |
| GE 101 | Purposive Communication | 50 | 3 | Gen Ed | None |
| GE 102 | Mathematics in the Modern World | 50 | 3 | Gen Ed | None |
| SCI 101 | General Physics I | 40 | 4 | Science | None |

### Pre-existing Enrollments (at least 10-15)
Create realistic enrollment records linking students to courses. Some students should have multiple enrollments, some courses should be near capacity, and a few enrollments should have `dropped` or `completed` status with grades.

---

## APPLICATION STRUCTURE & PAGES

### 1. 📊 Dashboard Page (Home)
The first page users see. Display:
- **Welcome header** with current date and greeting
- **Summary Stats Cards** (animated counters):
  - Total Students
  - Total Courses
  - Active Enrollments
  - Average Enrollment Rate (%)
- **Quick Actions** row: "Enroll Student" button, "Add Student" button, "View All Courses" button
- **Recent Enrollments** list — show the 5 most recent enrollments with student name, course, and status badge
- **Course Capacity Overview** — horizontal bar chart or progress bars showing enrollment vs. capacity for each course (use colorful progress indicators: green for <70%, yellow for 70-90%, red for >90%)

### 2. 👥 Students Page
- **Search bar** at the top with real-time filtering by name, ID, or program
- **Filter chips** for program and year level
- **Student cards** displayed in a `ListView` or grid:
  - Avatar (initials-based, with gradient background unique per student)
  - Full name, ID, program, year level
  - Number of enrolled courses badge
  - Tap to view student detail
- **Floating Action Button** to add a new student (opens a modal bottom sheet form)

### 3. 👤 Student Detail Page
- **Hero header** with student avatar, name, ID, program, year
- **Enrolled Courses Tab:**
  - List of all active enrollments with course code, title, schedule, and status chip
  - Swipe-to-drop action (swipe left to reveal "Drop" button with confirmation dialog)
  - "Enroll in Course" button at the bottom
- **Dropped/Completed Tab:**
  - History of dropped and completed courses with grades (if available)
- **Grade Input:** Tap on a completed enrollment to input/edit grade via a sleek bottom sheet

### 4. 📚 Courses Page
- **Search bar** with real-time filtering by course code, title, or instructor
- **Category filter tabs** at the top (All, CS, IT, Math, Gen Ed, Science)
- **Course cards** in a list:
  - Course code (large, bold) + Title
  - Instructor name, schedule, units
  - Capacity progress bar (enrolled/capacity) with color coding
  - "Full" badge if at capacity
  - Tap to view course detail

### 5. 📖 Course Detail Page
- **Hero header** with course code, title, category chip, and capacity indicator
- **Course Info Section:** Description, instructor, schedule, units, prerequisite (if any, show as a linked chip)
- **Enrolled Students List:**
  - Show all students currently enrolled in this course
  - Each student row: avatar, name, program, enrollment date
  - Empty state if no students enrolled
- **Enroll Student Button** — Opens a bottom sheet to select from available students (only shows students not already enrolled, validates prerequisites and capacity)

### 6. 📋 Enrollments Page
- **Tabs:** All | Active | Dropped | Completed
- **Enrollment cards:**
  - Student name + avatar
  - Course code + title
  - Enrollment date
  - Status chip (color-coded: green for enrolled, red for dropped, blue for completed)
  - Grade display (for completed enrollments)
- **Search/filter** by student or course
- **Floating Action Button** to create a new enrollment (opens the enrollment flow)

### 7. ➕ Enrollment Flow (Modal/Bottom Sheet)
A multi-step bottom sheet or dialog:
1. **Step 1 — Select Student:** Searchable list of students
2. **Step 2 — Select Course:** Show available courses with capacity indicators. Gray out full courses. Show prerequisite warnings.
3. **Step 3 — Confirmation:** Show summary (student name, course, schedule) with "Confirm Enrollment" button
4. **Success Animation:** Show a checkmark animation with confetti or a Lottie-style animation on successful enrollment

---

## BUSINESS LOGIC & VALIDATION RULES

Implement these rules strictly:

1. **Capacity Check:** Before enrollment, verify `course.enrolledCount < course.capacity`. If full, show an error snackbar: "This course is already at full capacity."
2. **Duplicate Enrollment Check:** A student cannot enroll in the same course twice (if currently enrolled). Show error: "Student is already enrolled in this course."
3. **Prerequisite Check:** If a course has a prerequisite, verify the student has completed (status = `completed`) the prerequisite course. If not, show warning: "Prerequisite [CourseCode] has not been completed."
4. **Drop Course:** When dropping, change enrollment status to `dropped`. Show a confirmation dialog first: "Are you sure you want to drop [CourseCode]? This action cannot be undone."
5. **Grade Input:** Only allow grade input on enrollments with status `completed`. Grades should be on a 1.0-5.0 scale (1.0 = highest, 5.0 = failing) or use a dropdown.
6. **Students can enroll in multiple courses.**
7. **Courses can have multiple students** (up to capacity).
8. **Each enrollment links exactly one student to one course.**

---

## STATE MANAGEMENT

Use **Provider** (or Riverpod) with the following structure:

```
providers/
├── student_provider.dart    // StudentManager - CRUD operations for students
├── course_provider.dart     // CourseManager - CRUD operations for courses
├── enrollment_provider.dart // EnrollmentManager - enrollment/drop/grade logic
```

Each provider should:
- Hold an in-memory `List<Model>` initialized with dummy data
- Expose methods for CRUD operations
- Call `notifyListeners()` on every mutation
- Include helper/query methods (e.g., `getEnrollmentsForStudent(studentId)`, `getStudentsInCourse(courseId)`, `isStudentEnrolledInCourse(studentId, courseId)`)

---

## PROJECT STRUCTURE

```
lib/
├── main.dart
├── app.dart                      // MaterialApp with theme, routes
├── theme/
│   ├── app_theme.dart            // ThemeData, dark theme config
│   ├── app_colors.dart           // Color constants
│   └── app_text_styles.dart      // Text style presets
├── models/
│   ├── student.dart
│   ├── course.dart
│   ├── enrollment.dart
│   └── enums.dart
├── providers/
│   ├── student_provider.dart
│   ├── course_provider.dart
│   └── enrollment_provider.dart
├── data/
│   └── dummy_data.dart           // All seed data
├── pages/
│   ├── dashboard/
│   │   └── dashboard_page.dart
│   ├── students/
│   │   ├── students_page.dart
│   │   └── student_detail_page.dart
│   ├── courses/
│   │   ├── courses_page.dart
│   │   └── course_detail_page.dart
│   └── enrollments/
│       └── enrollments_page.dart
├── widgets/
│   ├── glass_card.dart           // Reusable glassmorphism card
│   ├── stat_card.dart            // Dashboard stat card with animation
│   ├── capacity_bar.dart         // Course capacity progress bar
│   ├── status_chip.dart          // Enrollment status badge
│   ├── student_avatar.dart       // Initials-based avatar with gradient
│   ├── search_bar.dart           // Custom styled search bar
│   ├── enrollment_dialog.dart    // Multi-step enrollment flow
│   ├── grade_input_sheet.dart    // Grade input bottom sheet
│   ├── confirm_dialog.dart       // Confirmation dialog
│   ├── empty_state.dart          // Empty state widget
│   └── bottom_nav_bar.dart       // Custom bottom navigation
└── utils/
    ├── id_generator.dart         // Utility to generate unique IDs
    └── formatters.dart           // Date formatters, grade formatters
```

---

## ANIMATIONS & TRANSITIONS

1. **Page Transitions:** Use `GoRouter` with custom `fadeTransition` or `slideTransition` for page navigation
2. **List Animations:** Stagger list items using `AnimationController` + `SlideTransition` when the page loads
3. **Counter Animation:** Dashboard stat numbers should animate from 0 to their value using `TweenAnimationBuilder`
4. **Button Feedback:** Scale down on press using `AnimatedScale` or `Transform.scale`
5. **Success Feedback:** After successful enrollment, show an animated checkmark or success icon
6. **Snackbar/Toast:** Use custom styled snackbars with icons for success (green), error (red), and warning (amber)

---

## ADDITIONAL REQUIREMENTS

1. **Responsive Layout:** The app should look great on both mobile (360-414px width) and tablet (768px+). Use `LayoutBuilder` or `MediaQuery` to adapt layouts.
2. **Error Handling:** All operations should have proper error handling with user-friendly messages.
3. **Code Quality:**
   - Clean, well-organized, properly commented code
   - Follow Dart/Flutter best practices and naming conventions
   - Separate concerns properly (models, providers, UI)
4. **Accessibility:** Proper semantics labels on interactive elements
5. **No External API Calls:** Everything runs locally in-memory
6. **App Icon & Title:** Set the app title to "EnrollHub" with a graduation cap icon

---

## IMPORTANT REMINDERS

- **DO NOT** implement any database, SQLite, Hive, or persistent storage. ALL DATA IS IN-MEMORY ONLY.
- **DO NOT** use placeholder/lorem ipsum text. Use realistic Filipino student names and actual course titles.
- **DO NOT** create a basic/plain UI. The design MUST be premium, modern, and visually impressive with glassmorphism, gradients, and animations.
- **DO** implement ALL pages and features described above — this should be a complete, functional application.
- **DO** ensure the enrollment flow with all validations (capacity, duplicates, prerequisites) works correctly.
- **DO** make sure the bottom navigation works and all pages are accessible.
- **DO** test that adding students, enrolling, dropping, and grade input all function properly.

---

## SUMMARY

Build **EnrollHub** — a premium, dark-themed Flutter application for course enrollment simulation. It should have 6+ polished pages, glassmorphism cards, gradient accents, smooth animations, and full CRUD functionality for students, courses, and enrollments. All data is in-memory with pre-seeded dummy data. The app must be beautiful, functional, and complete.
