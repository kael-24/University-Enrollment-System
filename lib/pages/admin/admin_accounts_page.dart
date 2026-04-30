import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/professor_provider.dart';
import '../../providers/student_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';

class AdminAccountsPage extends StatelessWidget {
  const AdminAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sp = context.watch<StudentProvider>();
    final pp = context.watch<ProfessorProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Credentials', style: AppTextStyles.heading),
                const SizedBox(height: 4),
                Text(
                  'Change usernames and passwords for all account types',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    tabs: const [
                      Tab(text: 'Students'),
                      Tab(text: 'Professors'),
                      Tab(text: 'Admin'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _studentsTab(context, sp),
                      _professorsTab(context, pp),
                      _adminTab(context, auth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentsTab(BuildContext context, StudentProvider sp) {
    if (sp.students.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No students found',
      );
    }
    return ListView.builder(
      itemCount: sp.students.length,
      itemBuilder: (ctx, i) {
        final s = sp.students[i];
        return GlassCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_rounded, color: AppColors.primary),
            title: Text(
              s.fullName,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(s.id, style: AppTextStyles.caption),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () =>
                  _editStudent(context, s.id, s.fullName, s.password),
            ),
          ),
        );
      },
    );
  }

  Widget _professorsTab(BuildContext context, ProfessorProvider pp) {
    if (pp.professors.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No professors found',
      );
    }
    return ListView.builder(
      itemCount: pp.professors.length,
      itemBuilder: (ctx, i) {
        final p = pp.professors[i];
        return GlassCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.school_rounded,
              color: AppColors.secondary,
            ),
            title: Text(
              p.fullName,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${p.id} - ${p.department}',
              style: AppTextStyles.caption,
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () =>
                  _editProfessor(context, p.id, p.fullName, p.password),
            ),
          ),
        );
      },
    );
  }

  Widget _adminTab(BuildContext context, AuthProvider auth) {
    return GlassCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.admin_panel_settings_rounded,
          color: AppColors.warning,
        ),
        title: Text(
          'System Administrator',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          auth.adminAccount.username,
          style: AppTextStyles.caption,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          onPressed: () => _editAdmin(
            context,
            auth.adminAccount.username,
            auth.adminAccount.password,
          ),
        ),
      ),
    );
  }

  void _editStudent(
    BuildContext context,
    String id,
    String name,
    String password,
  ) async {
    final result = await _showCredentialsSheet(
      context,
      title: name,
      username: id,
      password: password,
    );
    if (result == null || !context.mounted) return;
    final ok = context.read<StudentProvider>().updateCredentials(
      id,
      newId: result.username,
      password: result.password,
    );
    if (!ok) {
      showAppSnackbar(
        context,
        message: 'Could not update student credentials. ID may already exist.',
        type: SnackbarType.error,
      );
      return;
    }
    if (result.username != id) {
      context.read<EnrollmentProvider>().reassignStudentId(id, result.username);
    }
    showAppSnackbar(
      context,
      message: 'Student credentials updated',
      type: SnackbarType.success,
    );
  }

  void _editProfessor(
    BuildContext context,
    String id,
    String name,
    String password,
  ) async {
    final result = await _showCredentialsSheet(
      context,
      title: name,
      username: id,
      password: password,
    );
    if (result == null || !context.mounted) return;
    final ok = context.read<ProfessorProvider>().updateCredentials(
      id,
      newId: result.username,
      password: result.password,
    );
    if (!ok) {
      showAppSnackbar(
        context,
        message:
            'Could not update professor credentials. ID may already exist.',
        type: SnackbarType.error,
      );
      return;
    }
    if (result.username != id) {
      context.read<CourseProvider>().reassignProfessorId(id, result.username);
    }
    showAppSnackbar(
      context,
      message: 'Professor credentials updated',
      type: SnackbarType.success,
    );
  }

  void _editAdmin(
    BuildContext context,
    String username,
    String password,
  ) async {
    final result = await _showCredentialsSheet(
      context,
      title: 'System Administrator',
      username: username,
      password: password,
    );
    if (result == null || !context.mounted) return;
    context.read<AuthProvider>().updateAdminCredentials(
      username: result.username,
      password: result.password,
    );
    showAppSnackbar(
      context,
      message: 'Admin credentials updated',
      type: SnackbarType.success,
    );
  }

  Future<_Credentials?> _showCredentialsSheet(
    BuildContext context, {
    required String title,
    required String username,
    required String password,
  }) {
    final userCtrl = TextEditingController(text: username);
    final passCtrl = TextEditingController(text: password);
    return showModalBottomSheet<_Credentials>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit $title', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(
                labelText: 'Username / ID',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  ctx,
                  _Credentials(userCtrl.text.trim(), passCtrl.text.trim()),
                ),
                child: const Text('Save Credentials'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Credentials {
  final String username;
  final String password;
  const _Credentials(this.username, this.password);
}
