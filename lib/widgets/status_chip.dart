import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';

/// Color-coded chip displaying enrollment status.
class StatusChip extends StatelessWidget {
  final EnrollmentStatus status;

  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case EnrollmentStatus.enrolled:
        return AppColors.success;
      case EnrollmentStatus.dropped:
        return AppColors.error;
      case EnrollmentStatus.completed:
        return AppColors.secondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case EnrollmentStatus.enrolled:
        return Icons.check_circle_outline;
      case EnrollmentStatus.dropped:
        return Icons.cancel_outlined;
      case EnrollmentStatus.completed:
        return Icons.school_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
