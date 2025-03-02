import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF34495E); // Dark Blue
  static const Color secondary = Color(0xFF3498DB); // Medium Blue
  static const Color tertiary = Color(0xFF27AE60); // Emerald Green
  static const Color error = Color(0xFFE67E22); // Carrot Orange
  static const Color background = Color(0xFFF8F9FA); // Off White
  static const Color surface = Colors.white;

  // Metric Card Colors
  static const Color monthlyMetric = primary; // Dark Blue
  static const Color completedMetric = tertiary; // Emerald Green
  static const Color activeMetric = error; // Carrot Orange

  // Text Colors
  static const Color primaryText = primary;
  static const Color secondaryText = secondary;
  static const Color disabledText = Color(0xFF9E9E9E);

  // Icon Colors
  static const Color primaryIcon = primary;
  static const Color secondaryIcon = secondary;

  // Opacity values for various states
  static const double activeStateOpacity = 1.0;
  static const double inactiveStateOpacity = 0.6;
  static const double disabledStateOpacity = 0.38;
  static const double hoverStateOpacity = 0.8;
  static const double focusStateOpacity = 0.7;
  static const double pressedStateOpacity = 0.5;

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
