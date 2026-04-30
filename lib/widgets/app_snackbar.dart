import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows a custom themed snackbar with icon.
void showAppSnackbar(
  BuildContext context, {
  required String message,
  SnackbarType type = SnackbarType.info,
}) {
  Color bgColor;
  IconData icon;
  switch (type) {
    case SnackbarType.success:
      bgColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      break;
    case SnackbarType.error:
      bgColor = AppColors.error;
      icon = Icons.error_rounded;
      break;
    case SnackbarType.warning:
      bgColor = AppColors.warning;
      icon = Icons.warning_rounded;
      break;
    case SnackbarType.info:
      bgColor = AppColors.primary;
      icon = Icons.info_rounded;
      break;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}

enum SnackbarType { success, error, warning, info }
