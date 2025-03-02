import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'text_styles.dart';

class TabBarStyles {
  static ButtonStyle getTabButtonStyle({
    required BuildContext context,
    required bool isSelected,
    bool isLeftButton = true,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
      foregroundColor: isSelected ? Colors.white : AppColors.primaryText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: isLeftButton ? const Radius.circular(12) : Radius.zero,
          right: !isLeftButton ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  static TextStyle getTabTextStyle({
    required BuildContext context,
    required bool isSelected,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return AppTextStyles.titleMedium(context).copyWith(
      color: isSelected ? Colors.white : AppColors.primaryText,
      fontSize: isSmallScreen ? 14 : 16,
      fontWeight: FontWeight.w500,
    );
  }
}
