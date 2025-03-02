import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle displayLarge(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.05,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.04,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    );
  }

  static TextStyle displaySmall(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.035,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.03,
      color: AppColors.secondaryText,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.025,
      color: AppColors.secondaryText,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.02,
      color: AppColors.secondaryText,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.035,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.03,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width * 0.025,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryText,
    );
  }

  // Helper methods for common text style modifications
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  static TextStyle hintStyle(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return TextStyle(
      fontSize: isSmallScreen ? 16 : 18,
      fontWeight: FontWeight.w400,
      color: AppColors.primary.withOpacity(0.6),
      letterSpacing: 0.2,
    );
  }
}
