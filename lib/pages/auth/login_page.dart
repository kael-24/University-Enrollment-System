import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_snackbar.dart';

/// Login page — users choose Student or Professor role and enter credentials.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _studentIdCtrl = TextEditingController();
  final _studentPwCtrl = TextEditingController();
  final _profIdCtrl = TextEditingController();
  final _profPwCtrl = TextEditingController();
  bool _obscureStudentPw = true;
  bool _obscureProfPw = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _studentIdCtrl.dispose();
    _studentPwCtrl.dispose();
    _profIdCtrl.dispose();
    _profPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo & branding
                _buildLogo(),
                const SizedBox(height: 40),
                // Login card
                _buildLoginCard(),
                const SizedBox(height: 24),
                // Demo credentials hint
                _buildDemoHint(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text('EnrollHub', style: AppTextStyles.heading.copyWith(fontSize: 32, color: Colors.white)),
        ),
        const SizedBox(height: 6),
        Text('Course Enrollment Simulator', style: AppTextStyles.caption.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelStyle: AppTextStyles.button,
              tabs: const [
                Tab(text: '🎓 Student'),
                Tab(text: '👨‍🏫 Professor'),
              ],
            ),
          ),
          // Tab content
          SizedBox(
            height: 280,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildStudentLogin(),
                _buildProfessorLogin(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentLogin() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student ID', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _studentIdCtrl,
            decoration: InputDecoration(
              hintText: 'e.g., 2023-2735-A',
              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Text('Password', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _studentPwCtrl,
            obscureText: _obscureStudentPw,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureStudentPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscureStudentPw = !_obscureStudentPw),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _loginStudent,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Sign In as Student', style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessorLogin() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professor ID', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _profIdCtrl,
            decoration: InputDecoration(
              hintText: 'e.g., PROF-001',
              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Text('Password', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _profPwCtrl,
            obscureText: _obscureProfPw,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureProfPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscureProfPw = !_obscureProfPw),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _loginProfessor,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Sign In as Professor', style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('Demo Credentials', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Student: ID = 2023-2735-A, Password = 2023-2735-A', style: AppTextStyles.caption.copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text('Professor: ID = PROF-001, Password = prof001', style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  void _loginStudent() {
    if (_studentIdCtrl.text.trim().isEmpty || _studentPwCtrl.text.trim().isEmpty) {
      showAppSnackbar(context, message: 'Please enter your Student ID and password.', type: SnackbarType.warning);
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      final auth = context.read<AuthProvider>();
      final result = auth.loginAsStudent(_studentIdCtrl.text.trim(), _studentPwCtrl.text.trim());
      setState(() => _isLoading = false);
      if (result != null) {
        showAppSnackbar(context, message: result, type: SnackbarType.error);
      } else {
        context.go('/student/dashboard');
      }
    });
  }

  void _loginProfessor() {
    if (_profIdCtrl.text.trim().isEmpty || _profPwCtrl.text.trim().isEmpty) {
      showAppSnackbar(context, message: 'Please enter your Professor ID and password.', type: SnackbarType.warning);
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      final auth = context.read<AuthProvider>();
      final result = auth.loginAsProfessor(_profIdCtrl.text.trim(), _profPwCtrl.text.trim());
      setState(() => _isLoading = false);
      if (result != null) {
        showAppSnackbar(context, message: result, type: SnackbarType.error);
      } else {
        context.go('/professor/dashboard');
      }
    });
  }
}
