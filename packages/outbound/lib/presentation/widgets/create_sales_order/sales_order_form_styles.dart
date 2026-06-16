import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

BoxDecoration salesOrderCardDecoration(double radius) {
  return BoxDecoration(
    color: WHColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: WHColors.grey5),
    boxShadow: const [
      BoxShadow(color: Color(0x16000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );
}

BoxDecoration salesOrderPlainCardDecoration(double radius) {
  return BoxDecoration(
    color: WHColors.surface,
    borderRadius: BorderRadius.circular(radius),
  );
}

BoxDecoration salesOrderFilledInputDecoration(double radius) {
  return BoxDecoration(
    color: WHColors.grey5,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: WHColors.grey3),
  );
}

InputDecoration salesOrderInputDecoration(String hint) {
  const borderColor = Color(0xFF6F6576);
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFE9E9E9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: borderColor, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: WHColors.error2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: WHColors.error2),
    ),
  );
}
