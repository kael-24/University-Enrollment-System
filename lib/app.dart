import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

import 'pages/auth/login_page.dart';
import 'pages/student/student_dashboard_page.dart';
import 'pages/student/student_courses_page.dart';
import 'pages/student/student_enrollments_page.dart';
import 'pages/professor/professor_dashboard_page.dart';
import 'pages/professor/professor_courses_page.dart';
import 'pages/professor/professor_students_page.dart';
import 'pages/professor/professor_enrollments_page.dart';
import 'pages/admin/admin_dashboard_page.dart';
import 'pages/admin/admin_accounts_page.dart';
import 'pages/admin/admin_history_page.dart';

/// Root application widget with auth-aware routing and theme.
class EnrollHubApp extends StatelessWidget {
  const EnrollHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild router when auth state changes
    final auth = context.watch<AuthProvider>();

    return MaterialApp.router(
      title: 'EnrollHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _buildRouter(auth),
    );
  }
}

// ─── Router Builder ────────────────────────────────────────
GoRouter _buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = auth.isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/login';

      // Not logged in — force to login
      if (!isLoggedIn && !isLoginRoute) return '/login';

      // Logged in but on login page — redirect to appropriate dashboard
      if (isLoggedIn && isLoginRoute) {
        if (auth.isStudent) return '/student/dashboard';
        if (auth.isAdmin) return '/admin/dashboard';
        return '/professor/dashboard';
      }

      // Student trying to access professor routes
      if (isLoggedIn &&
          auth.isStudent &&
          state.matchedLocation.startsWith('/professor')) {
        return '/student/dashboard';
      }

      // Professor trying to access student routes
      if (isLoggedIn &&
          auth.isProfessor &&
          state.matchedLocation.startsWith('/student')) {
        return '/professor/dashboard';
      }

      if (isLoggedIn &&
          auth.isProfessor &&
          state.matchedLocation.startsWith('/admin')) {
        return '/professor/dashboard';
      }

      if (isLoggedIn &&
          auth.isAdmin &&
          state.matchedLocation.startsWith('/student')) {
        return '/admin/dashboard';
      }

      return null; // No redirect
    },
    routes: [
      // ─── Login ───────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),

      // ─── Student Shell ───────────────────────
      ShellRoute(
        builder: (context, state, child) => _StudentShell(child: child),
        routes: [
          GoRoute(
            path: '/student/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentDashboardPage()),
          ),
          GoRoute(
            path: '/student/courses',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentCoursesPage()),
          ),
          GoRoute(
            path: '/student/enrollments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentEnrollmentsPage()),
          ),
        ],
      ),

      // ─── Professor Shell ─────────────────────
      ShellRoute(
        builder: (context, state, child) => _ProfessorShell(child: child),
        routes: [
          GoRoute(
            path: '/professor/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorDashboardPage()),
          ),
          GoRoute(
            path: '/professor/courses',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorCoursesPage()),
          ),
          GoRoute(
            path: '/professor/students',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorStudentsPage()),
          ),
          GoRoute(
            path: '/professor/enrollments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorEnrollmentsPage()),
          ),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) => _AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AdminDashboardPage()),
          ),
          GoRoute(
            path: '/admin/courses',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorCoursesPage()),
          ),
          GoRoute(
            path: '/admin/students',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorStudentsPage()),
          ),
          GoRoute(
            path: '/admin/enrollments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfessorEnrollmentsPage()),
          ),
          GoRoute(
            path: '/admin/history',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AdminHistoryPage()),
          ),
          GoRoute(
            path: '/admin/accounts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AdminAccountsPage()),
          ),
        ],
      ),
    ],
  );
}

// ─── Student Navigation Shell ──────────────────────────────
class _StudentShell extends StatelessWidget {
  final Widget child;
  const _StudentShell({required this.child});

  static const _tabs = [
    '/student/dashboard',
    '/student/courses',
    '/student/enrollments',
  ];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.menu_book_rounded,
    Icons.assignment_rounded,
  ];
  static const _labels = ['Dashboard', 'Courses', 'Enrollments'];

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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Nav items
                ...List.generate(
                  3,
                  (i) => _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isActive: idx == i,
                    onTap: () => context.go(_tabs[i]),
                  ),
                ),
                // Logout button
                _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isActive: false,
                  isLogout: true,
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Professor Navigation Shell ────────────────────────────
class _ProfessorShell extends StatelessWidget {
  final Widget child;
  const _ProfessorShell({required this.child});

  static const _tabs = [
    '/professor/dashboard',
    '/professor/courses',
    '/professor/students',
    '/professor/enrollments',
  ];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.menu_book_rounded,
    Icons.people_rounded,
    Icons.assignment_rounded,
  ];
  static const _labels = ['Dashboard', 'Courses', 'Students', 'Enrollments'];

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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Nav items
                ...List.generate(
                  4,
                  (i) => _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isActive: idx == i,
                    onTap: () => context.go(_tabs[i]),
                  ),
                ),
                // Logout button
                _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isActive: false,
                  isLogout: true,
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminShell extends StatelessWidget {
  final Widget child;
  const _AdminShell({required this.child});

  static const _tabs = [
    '/admin/dashboard',
    '/admin/courses',
    '/admin/students',
    '/admin/enrollments',
    '/admin/history',
    '/admin/accounts',
  ];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.menu_book_rounded,
    Icons.people_rounded,
    Icons.assignment_rounded,
    Icons.history_rounded,
    Icons.manage_accounts_rounded,
  ];
  static const _labels = [
    'Dashboard',
    'Courses',
    'Students',
    'Requests',
    'History',
    'Accounts',
  ];

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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...List.generate(
                  _tabs.length,
                  (i) => _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isActive: idx == i,
                    onTap: () => context.go(_tabs[i]),
                  ),
                ),
                _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isActive: false,
                  isLogout: true,
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Nav Item Widget ────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
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
              color: isLogout
                  ? AppColors.error.withValues(alpha: 0.7)
                  : isActive
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isLogout
                    ? AppColors.error.withValues(alpha: 0.7)
                    : isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
