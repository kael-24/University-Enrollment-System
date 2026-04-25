import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Grade input bottom sheet for completed enrollments.
Future<double?> showGradeInputSheet(BuildContext context,
    {double? currentGrade}) {
  double selectedGrade = currentGrade ?? 1.0;

  final grades = [1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 5.0];
  final gradeLabels = {
    1.0: 'Excellent',
    1.25: 'Excellent',
    1.5: 'Very Good',
    1.75: 'Very Good',
    2.0: 'Good',
    2.25: 'Good',
    2.5: 'Satisfactory',
    2.75: 'Satisfactory',
    3.0: 'Passing',
    5.0: 'Failing',
  };

  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
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
                Text('Input Grade', style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Text('Select a grade for this enrollment',
                    style: AppTextStyles.caption),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: grades.map((grade) {
                    final isSelected = selectedGrade == grade;
                    final isFailing = grade >= 5.0;
                    return GestureDetector(
                      onTap: () => setState(() => selectedGrade = grade),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isFailing ? AppColors.error : AppColors.primary)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isFailing
                                    ? AppColors.error
                                    : AppColors.primary)
                                : AppColors.divider,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              grade.toStringAsFixed(
                                  grade == 5.0 || grade == 1.0 || grade == 2.0 || grade == 3.0 ? 1 : 2),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              gradeLabels[grade]!,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, selectedGrade),
                    child: Text('Save Grade',
                        style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
