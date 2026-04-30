import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/capacity_bar.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});
  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  CourseCategory? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CourseProvider>();
    final ep = context.watch<EnrollmentProvider>();
    var list = _query.isNotEmpty ? cp.search(_query) : cp.courses;
    if (_category != null)
      list = list.where((c) => c.category == _category).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Courses', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                '${cp.courses.length} available courses',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              CustomSearchBar(
                controller: _searchCtrl,
                hintText: 'Search by code, title, or instructor...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              // Category tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _catChip('All', null),
                    ...CourseCategory.values.map(
                      (c) => _catChip(c.shortLabel, c),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'No courses found',
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final c = list[i];
                          final enrolled = ep.getEnrolledCount(c.id);
                          final isFull = enrolled >= c.capacity;
                          return GlassCard(
                            onTap: () => context.go('/courses/${c.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c.courseCode,
                                      style: AppTextStyles.subheading.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isFull)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.error.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'FULL',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (!isFull)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${c.capacity - enrolled} slots',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(c.title, style: AppTextStyles.bodyLarge),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      c.instructor,
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      c.schedule,
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${c.units} units',
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                CapacityBar(
                                  enrolled: enrolled,
                                  capacity: c.capacity,
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
    );
  }

  Widget _catChip(String label, CourseCategory? cat) {
    final sel = _category == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) => setState(() => _category = cat),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        side: BorderSide(color: sel ? AppColors.primary : AppColors.divider),
        labelStyle: TextStyle(
          color: sel ? AppColors.primary : AppColors.textSecondary,
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
