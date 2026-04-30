import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/student_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/student_avatar.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});
  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _program;
  int? _year;
  final _programs = [
    'BS Computer Science',
    'BS Information Technology',
    'BS Mathematics',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final ep = context.watch<EnrollmentProvider>();
    var list = _query.isNotEmpty ? sp.search(_query) : sp.students;
    if (_program != null)
      list = list.where((s) => s.program == _program).toList();
    if (_year != null) list = list.where((s) => s.yearLevel == _year).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Students', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                '${sp.students.length} registered students',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              CustomSearchBar(
                controller: _searchCtrl,
                hintText: 'Search by name, ID, or program...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._programs.map((p) {
                      final sel = _program == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(p.replaceAll('BS ', '')),
                          selected: sel,
                          onSelected: (s) =>
                              setState(() => _program = s ? p : null),
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppColors.primary,
                          side: BorderSide(
                            color: sel ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                      );
                    }),
                    Container(width: 1, height: 24, color: AppColors.divider),
                    const SizedBox(width: 12),
                    ...List.generate(4, (i) {
                      final y = i + 1;
                      final sel = _year == y;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('Year $y'),
                          selected: sel,
                          onSelected: (s) =>
                              setState(() => _year = s ? y : null),
                          selectedColor: AppColors.secondary.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppColors.secondary,
                          side: BorderSide(
                            color: sel
                                ? AppColors.secondary
                                : AppColors.divider,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No students found',
                        subtitle: 'Try adjusting your search or filters',
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final s = list[i];
                          final cnt = ep
                              .getActiveEnrollmentsForStudent(s.id)
                              .length;
                          final gi = sp.students.indexOf(s);
                          return GlassCard(
                            onTap: () => context.go('/students/${s.id}'),
                            child: Row(
                              children: [
                                StudentAvatar(
                                  initials: s.initials,
                                  colorIndex: gi,
                                  size: 48,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.fullName,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${s.id} • ${s.program}',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        'Year ${s.yearLevel}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$cnt ${cnt == 1 ? 'course' : 'courses'}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdd(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final fn = TextEditingController(),
        ln = TextEditingController(),
        em = TextEditingController();
    String prog = _programs[0];
    int yr = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add New Student', style: AppTextStyles.headingSmall),
              const SizedBox(height: 20),
              TextField(
                controller: fn,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ln,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: em,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: prog,
                items: _programs
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => ss(() => prog = v!),
                decoration: const InputDecoration(
                  labelText: 'Program',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                dropdownColor: AppColors.surface,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: yr,
                items: [1, 2, 3, 4]
                    .map(
                      (y) => DropdownMenuItem(value: y, child: Text('Year $y')),
                    )
                    .toList(),
                onChanged: (v) => ss(() => yr = v!),
                decoration: const InputDecoration(
                  labelText: 'Year Level',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                dropdownColor: AppColors.surface,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (fn.text.isNotEmpty && ln.text.isNotEmpty) {
                        context.read<StudentProvider>().addStudent(
                          firstName: fn.text.trim(),
                          lastName: ln.text.trim(),
                          email: em.text.trim().isNotEmpty
                              ? em.text.trim()
                              : '${fn.text.toLowerCase()}.${ln.text.toLowerCase()}@enrollhub.edu',
                          program: prog,
                          yearLevel: yr,
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text('Add Student', style: AppTextStyles.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
