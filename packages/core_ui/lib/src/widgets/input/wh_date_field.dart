import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WHDateField extends StatefulWidget {
  const WHDateField({
    super.key,
    required this.label,
    this.selectedDate,
    this.onDateSelected,
    this.errorText,
    this.helperText,
    this.hintText = 'dd/mm/yyyy',
    this.isDisabled = false,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
  });

  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final String? errorText;
  final String? helperText;
  final String hintText;
  final bool isDisabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Custom formatter. Default: dd/MM/yyyy
  /// Contoh: (date) => '${date.day} ${_monthName(date.month)} ${date.year}'
  final String Function(DateTime)? dateFormat;

  @override
  State<WHDateField> createState() => _WHDateFieldState();
}

class _WHDateFieldState extends State<WHDateField> {
  bool _isFocused = false;

  // ── Design tokens (WHColors) ──────────────────────────────────
  static const _mainColorBackground = WHColors.surface; // 0xFFD8E5E6
  static const _mainBorderColor = WHColors.grey5;

  static const _colorBackground = WHColors.grey5;
  static const _colorBorderDefault = WHColors.textPrimary;
  static const _colorBorderFocused = WHColors.primary3;
  static const _colorBorderError = WHColors.error2;
  static const _colorBorderDisabled = WHColors.grey5;

  static const _colorLabelDefault = WHColors.textSecondary;
  static const _colorLabelFocused = WHColors.primary3;
  static const _colorLabelError = WHColors.error2;
  static const _colorLabelDisabled = WHColors.grey4;

  static const _colorText = WHColors.textPrimary;
  static const _colorHint = WHColors.grey4;
  static const _colorIcon = WHColors.grey4;
  static const _colorIconFocused = WHColors.primary3;
  static const _colorIconError = WHColors.error2;
  static const _colorIconDisabled = WHColors.grey5;

  static const _colorHelperText = WHColors.grey3;
  static const _colorErrorText = WHColors.error2;
  static const _colorDisabledBg = WHColors.background;
  static const _colorDisabledText = WHColors.grey4;

  static const _borderRadius = 12.0;
  static const _labelFontSize = 13.0;
  static const _inputFontSize = 14.0;
  static const _helperFontSize = 12.0;

  // ── Helpers ────────────────────────────────────────────────────
  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;
  bool get _hasValue => widget.selectedDate != null;

  Color get _borderColor {
    if (widget.isDisabled) return _colorBorderDisabled;
    if (_hasError) return _colorBorderError;
    if (_isFocused) return _colorBorderFocused;
    return _colorBorderDefault;
  }

  Color get _labelColor {
    if (widget.isDisabled) return _colorLabelDisabled;
    if (_hasError) return _colorLabelError;
    if (_isFocused) return _colorLabelFocused;
    return _colorLabelDefault;
  }

  Color get _iconColor {
    if (widget.isDisabled) return _colorIconDisabled;
    if (_hasError) return _colorIconError;
    if (_isFocused) return _colorIconFocused;
    return _colorIcon;
  }

  String _formatDate(DateTime date) {
    if (widget.dateFormat != null) return widget.dateFormat!(date);
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _pickDate() async {
    if (widget.isDisabled) return;

    setState(() => _isFocused = true);

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? now,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WHColors.primary3,
              onPrimary: WHColors.surface,
              onSurface: WHColors.textPrimary,
              surface: WHColors.surface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: WHColors.primary3),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    setState(() => _isFocused = false);

    if (picked != null) {
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _mainColorBackground,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: _mainBorderColor,
          width: _isFocused || _hasError ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ─────────────────────────────────────────────────
          Text(
            widget.label,
            style: TextStyle(
              fontSize: _labelFontSize,
              fontWeight: FontWeight.w500,
              color: _labelColor,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),

          // ── Date field button ─────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.isDisabled ? _colorDisabledBg : _colorBackground,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: _borderColor,
                width: _isFocused || _hasError ? 1.5 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isDisabled ? null : _pickDate,
                borderRadius: BorderRadius.circular(_borderRadius),
                splashColor: WHColors.primary6.withOpacity(0.3),
                highlightColor: WHColors.primary6.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      // Calendar icon
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: _iconColor,
                      ),
                      const SizedBox(width: 10),

                      // Date text / placeholder
                      Expanded(
                        child: Text(
                          _hasValue
                              ? _formatDate(widget.selectedDate!)
                              : widget.hintText,
                          style: TextStyle(
                            fontSize: _inputFontSize,
                            fontWeight: FontWeight.w400,
                            color: widget.isDisabled
                                ? _colorDisabledText
                                : _hasValue
                                ? _colorText
                                : _colorHint,
                            height: 1.4,
                          ),
                        ),
                      ),

                      // Clear button (tampil hanya jika ada value & tidak disabled)
                      if (_hasValue && !widget.isDisabled)
                        GestureDetector(
                          onTap: () {
                            // Kirim callback dengan tanggal null tidak bisa
                            // karena ValueChanged<DateTime> — gunakan onClear jika perlu.
                            // Untuk clear, implementasi di parent dengan set selectedDate = null.
                          },
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: _colorHint,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Helper / Error text ───────────────────────────────────
          if (_hasError || widget.helperText != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                if (_hasError)
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 13,
                    color: _colorErrorText,
                  ),
                if (_hasError) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _hasError ? widget.errorText! : widget.helperText!,
                    style: TextStyle(
                      fontSize: _helperFontSize,
                      color: _hasError ? _colorErrorText : _colorHelperText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
