import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WHDescriptionField extends StatefulWidget {
  const WHDescriptionField({
    super.key,
    required this.label,
    this.hintText = 'Add description here ....',
    this.controller,
    this.errorText,
    this.helperText,
    this.isDisabled = false,
    this.isOptional = true,
    this.onChanged,
    this.maxLines = 4,
    this.maxLength = 150,
    this.focusNode,
    this.flat = false,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final bool isDisabled;
  final bool isOptional;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int maxLength;
  final FocusNode? focusNode;
  final bool flat;

  @override
  State<WHDescriptionField> createState() => _WHDescriptionFieldState();
}

class _WHDescriptionFieldState extends State<WHDescriptionField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  int _charCount = 0;

  // Design tokens (Konsisten dengan WHTextField)
  static const _mainColorBackground = WHColors.surface;
  static const _mainBorderColor = WHColors.grey5;
  static const _colorBackground = WHColors.grey5;
  static const _colorBorderDefault = WHColors.textPrimary;
  static const _colorBorderFocused = WHColors.primary3;
  static const _colorBorderError = WHColors.error2;
  static const _colorBorderDisabled = WHColors.grey5;
  static const _colorLabelDefault = WHColors.textPrimary;
  static const _colorLabelFocused = WHColors.primary3;
  static const _colorLabelError = WHColors.error2;
  static const _colorLabelDisabled = WHColors.grey4;
  static const _colorHint = WHColors.grey4;
  static const _colorText = WHColors.textPrimary;
  static const _colorCounter = WHColors.grey4;
  static const _colorHelperText = WHColors.grey3;
  static const _colorErrorText = WHColors.error2;
  static const _colorDisabledBg = WHColors.background;
  static const _colorDisabledText = WHColors.grey4;

  static const _borderRadius = 12.0;
  static const _labelFontSize = 13.0;
  static const _inputFontSize = 14.0;
  static const _helperFontSize = 12.0;
  static const _optionalFontSize = 11.0;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _charCount = widget.controller?.text.length ?? 0;
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

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

  @override
  Widget build(BuildContext context) {
    final inputContainer = AnimatedContainer(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: !widget.isDisabled,
            keyboardType: TextInputType.multiline,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: (value) {
              setState(() => _charCount = value.length);
              widget.onChanged?.call(value);
            },
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
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              counterText: '', // Sembunyikan counter default
            ),
          ),

          // Character Counter
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 8),
            child: Text(
              '$_charCount/${widget.maxLength}',
              style: const TextStyle(
                fontSize: 10,
                color: _colorCounter,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.flat) {
      if (!_hasError && widget.helperText == null) {
        return inputContainer;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          inputContainer,
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
      );
    }

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
          // Label & Optional Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: _labelFontSize,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                  letterSpacing: 0.1,
                ),
              ),
              if (widget.isOptional)
                Text(
                  '(Optional)',
                  style: const TextStyle(
                    fontSize: _optionalFontSize,
                    color: WHColors.grey4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Input Container
          inputContainer,

          // Helper / Error text
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