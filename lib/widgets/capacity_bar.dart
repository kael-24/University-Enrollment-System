import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Animated capacity progress bar showing enrollment vs. capacity.
class CapacityBar extends StatelessWidget {
  final int enrolled;
  final int capacity;
  final bool showLabel;
  final double height;

  const CapacityBar({
    super.key,
    required this.enrolled,
    required this.capacity,
    this.showLabel = true,
    this.height = 8,
  });

  double get _ratio => capacity > 0 ? (enrolled / capacity).clamp(0.0, 1.0) : 0;

  Color get _barColor {
    if (_ratio > 0.9) return AppColors.error;
    if (_ratio > 0.7) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$enrolled / $capacity students',
                    style: AppTextStyles.caption),
                Text('${(_ratio * 100).toInt()}%',
                    style: AppTextStyles.caption.copyWith(
                      color: _barColor,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _ratio),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: _barColor,
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: _barColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
