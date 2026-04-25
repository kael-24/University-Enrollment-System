import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular avatar showing student initials with a unique gradient background.
class StudentAvatar extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double size;

  const StudentAvatar({
    super.key,
    required this.initials,
    this.colorIndex = 0,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.avatarGradient(colorIndex),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.36,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
