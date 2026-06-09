import 'package:flutter/material.dart';

/// Shared styles for the app UI. Put common colors/radii here so packages
/// can reuse a single source of truth.
class WHStyles {
  // Primary brand orange used across screens
  static const Color primary = Color(0xFFD94F1E);

  // A faded version used for disabled/pressed states
  // Keep as getter to avoid using withOpacity at file-scope (lint-safe)
  static Color get primaryFaded => const Color(0xFFD94F1E).withOpacity(0.6);

  // Borders and input fills
  static const Color border = Color(0xFFDDDDDD);
  static const Color inputFill = Color(0xFFEFF6F6);
  static const Color stepperText = Color(0xFF555555);

  // Hint color
  static const Color hint = Color(0xFF9AA3A3);

  // Rounded radii
  static const double inputRadius = 12.0;
  static const double buttonRadius = 28.0;
}

