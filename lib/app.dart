import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/students/students_page.dart';
import 'pages/students/student_detail_page.dart';
import 'pages/courses/courses_page.dart';
import 'pages/courses/course_detail_page.dart';
import 'pages/enrollments/enrollments_page.dart';

/// Root application widget with routing and theme.
class EnrollHubApp extends StatelessWidget {
  const EnrollHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EnrollHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

// ─── Navigation Shell ──────────────────────────────────
final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(child: DashboardPage()),
        ),
        GoRoute(
          path: '/students',
          pageBuilder: (context, state) => const NoTransitionPage(child: StudentsPage()),
        ),
        GoRoute(
          path: '/courses',
          pageBuilder: (context, state) => const NoTransitionPage(child: CoursesPage()),
        ),
        GoRoute(
          path: '/enrollments',
          pageBuilder: (context, state) => const NoTransitionPage(child: EnrollmentsPage()),
        ),
      ],
    ),
    // Detail pages outside shell (no bottom nav)
    GoRoute(
      path: '/students/:id',
      parentNavigatorKey: _rootNavKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(child: StudentDetailPage(studentId: id));
      },
    ),
    GoRoute(
      path: '/courses/:id',
      parentNavigatorKey: _rootNavKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(child: CourseDetailPage(courseId: id));
      },
    ),
  ],
);

/// Shell wrapper providing bottom navigation.
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  static const _tabs = ['/dashboard', '/students', '/courses', '/enrollments'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t));
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) => _NavItem(
                icon: _icons[i],
                label: _labels[i],
                isActive: idx == i,
                onTap: () => context.go(_tabs[i]),
              )),
            ),
          ),
        ),
      ),
    );
  }

  static const _icons = [
    Icons.dashboard_rounded,
    Icons.people_rounded,
    Icons.menu_book_rounded,
    Icons.assignment_rounded,
  ];

  static const _labels = ['Dashboard', 'Students', 'Courses', 'Enrollments'];
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 32 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
