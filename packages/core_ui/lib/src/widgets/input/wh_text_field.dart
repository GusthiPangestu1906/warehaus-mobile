import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WHTextField extends StatefulWidget {
  const WHTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.isDisabled = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool isDisabled;
  final bool isPassword;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;

  @override
  State<WHTextField> createState() => _WHTextFieldState();
}

class _WHTextFieldState extends State<WHTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  // ── Design tokens (mapped dari WHColors) ──────────────────────
  // Background input: grey5 (bluish-gray muda, mirip gambar)
  static const _mainColorBackground = WHColors.surface; // 0xFFD8E5E6
  static const _mainBorderColor = WHColors.grey5; // 0xFFD8E5E6

  static const _colorBackground = WHColors.grey5; // 0xFFD8E5E6
  static const _colorBorderDefault = WHColors.textPrimary;
  static const _colorBorderFocused = WHColors.primary3; // 0xFF005BBF
  static const _colorBorderError = WHColors.error2; // 0xFFBA1A1A
  static const _colorBorderDisabled = WHColors.grey5;

  static const _colorLabelDefault = WHColors.textPrimary; // 0xFF43474C
  static const _colorLabelFocused = WHColors.primary3; // 0xFF005BBF
  static const _colorLabelError = WHColors.error2; // 0xFFBA1A1A
  static const _colorLabelDisabled = WHColors.grey4; // 0xFF879798

  static const _colorHint = WHColors.grey4; // 0xFF879798
  static const _colorText = WHColors.textPrimary; // 0xFF121E1F
  static const _colorIcon = WHColors.grey4; // 0xFF879798
  static const _colorIconFocused = WHColors.primary3; // 0xFF005BBF
  static const _colorIconError = WHColors.error2; // 0xFFBA1A1A
  static const _colorIconDisabled = WHColors.grey5; // 0xFFD8E5E6

  static const _colorHelperText = WHColors.grey3; // 0xFF546162
  static const _colorErrorText = WHColors.error2; // 0xFFBA1A1A
  static const _colorDisabledBg = WHColors.background; // 0xFFF5F5F5
  static const _colorDisabledText = WHColors.grey4; // 0xFF879798

  static const _borderRadius = 12.0;
  static const _labelFontSize = 13.0;
  static const _inputFontSize = 14.0;
  static const _helperFontSize = 12.0;

  // ── Helpers ────────────────────────────────────────────────────
  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

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

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
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

          // ── Input container ───────────────────────────────────────
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
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: !widget.isDisabled,
              obscureText: widget.isPassword && _obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.isPassword ? 1 : widget.maxLines,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: TextStyle(
                fontSize: _inputFontSize,
                fontWeight: FontWeight.w400,
                color: widget.isDisabled ? _colorDisabledText : _colorText,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: _inputFontSize,
                  color: _colorHint,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 4 : 14,
                  vertical: 13,
                ),
                border: InputBorder.none,
                counterText: '',

                // Prefix icon
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        child: Icon(
                          widget.prefixIcon,
                          size: 18,
                          color: _iconColor,
                        ),
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),

                // Suffix icon (password toggle atau custom)
                suffixIcon: _buildSuffixIcon(),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
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

  Widget? _buildSuffixIcon() {
    // Password toggle
    if (widget.isPassword) {
      return GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Padding(
          padding: const EdgeInsets.only(right: 12, left: 6),
          child: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: _iconColor,
          ),
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 12, left: 6),
          child: Icon(widget.suffixIcon, size: 18, color: _iconColor),
        ),
      );
    }

    return null;
  }
}
