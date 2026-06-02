import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WHStepperField extends StatefulWidget {
  const WHStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.unit,
    this.step = 1,
    this.minValue = 0,
    this.maxValue,
    this.errorText,
    this.helperText,
    this.isDisabled = false,
    this.allowManualInput = true,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  /// Satuan tampil di sebelah kanan angka. Contoh: 'Box', 'pcs', 'ml', 'kg'
  final String? unit;

  /// Jumlah penambahan/pengurangan tiap tap. Default: 1
  final int step;

  /// Nilai minimum. Default: 0
  final int minValue;

  /// Nilai maksimum. Default: tidak terbatas
  final int? maxValue;

  final String? errorText;
  final String? helperText;
  final bool isDisabled;

  /// Izinkan user mengetik angka langsung. Default: true
  final bool allowManualInput;

  @override
  State<WHStepperField> createState() => _WHStepperFieldState();
}

class _WHStepperFieldState extends State<WHStepperField> {
  late TextEditingController _ctrl;
  bool _isEditing = false;

  static const _colorRowBg = WHColors.surface;
  static const _colorRowBorder = WHColors.grey5;

  static const _colorLabelDefault = WHColors.textSecondary;
  static const _colorLabelError = WHColors.error2;
  static const _colorLabelDisabled = WHColors.grey4;

  static const _colorHelperText = WHColors.grey3;
  static const _colorErrorText = WHColors.error2;

  static const _borderRadius = 12.0;
  static const _labelFontSize = 13.0;
  static const _helperFontSize = 12.0;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;
  bool get _canDecrease => !widget.isDisabled && widget.value > widget.minValue;
  bool get _canIncrease =>
      !widget.isDisabled &&
      (widget.maxValue == null || widget.value < widget.maxValue!);

  Color get _labelColor {
    if (widget.isDisabled) return _colorLabelDisabled;
    if (_hasError) return _colorLabelError;
    return _colorLabelDefault;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(WHStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.value != widget.value) {
      _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _decrease() {
    if (!_canDecrease) return;
    final next = widget.value - widget.step;
    widget.onChanged(next < widget.minValue ? widget.minValue : next);
  }

  void _increase() {
    if (!_canIncrease) return;
    final next = widget.value + widget.step;
    if (widget.maxValue != null && next > widget.maxValue!) {
      widget.onChanged(widget.maxValue!);
    } else {
      widget.onChanged(next);
    }
  }

  void _onManualSubmit(String raw) {
    setState(() => _isEditing = false);
    final parsed = int.tryParse(raw);
    if (parsed == null) {
      _ctrl.text = widget.value.toString();
      return;
    }
    int clamped = parsed;
    if (clamped < widget.minValue) clamped = widget.minValue;
    if (widget.maxValue != null && clamped > widget.maxValue!) {
      clamped = widget.maxValue!;
    }
    _ctrl.text = clamped.toString();
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _colorRowBg,
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(
              color: _hasError ? _colorErrorText : _colorRowBorder,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: _labelFontSize,
                    fontWeight: FontWeight.w500,
                    color: _labelColor,
                  ),
                ),
              ),

              _StepperControl(
                value: widget.value,
                unit: widget.unit,
                controller: _ctrl,
                canDecrease: _canDecrease,
                canIncrease: _canIncrease,
                isDisabled: widget.isDisabled,
                allowManualInput: widget.allowManualInput,
                onDecrease: _decrease,
                onIncrease: _increase,
                onEditingStart: () => setState(() => _isEditing = true),
                onEditingDone: _onManualSubmit,
              ),
            ],
          ),
        ),

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
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Internal stepper control widget ───────────────────────────────
class _StepperControl extends StatelessWidget {
  const _StepperControl({
    required this.value,
    required this.unit,
    required this.controller,
    required this.canDecrease,
    required this.canIncrease,
    required this.isDisabled,
    required this.allowManualInput,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEditingStart,
    required this.onEditingDone,
  });

  final int value;
  final String? unit;
  final TextEditingController controller;
  final bool canDecrease;
  final bool canIncrease;
  final bool isDisabled;
  final bool allowManualInput;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEditingStart;
  final ValueChanged<String> onEditingDone;

  static const _stepperBg = WHColors.grey5;
  static const _dividerColor = WHColors.textPrimary;
  static const _stepperRadius = 10.0;
  static const _stepperHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _stepperHeight,
      decoration: BoxDecoration(
        color: _stepperBg,
        borderRadius: BorderRadius.circular(_stepperRadius),
        border: Border.all(color: WHColors.textPrimary),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              enabled: canDecrease,
              isLeft: true,
              onTap: onDecrease,
            ),

            Container(
              width: 72,
              height: _stepperHeight,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: WHColors.surface,
                border: Border.symmetric(
                  vertical: BorderSide(color: _dividerColor),
                ),
              ),
              child: allowManualInput && !isDisabled
                  ? TextField(
                      controller: controller,
                      onTap: onEditingStart,
                      onSubmitted: onEditingDone,
                      onEditingComplete: () => onEditingDone(controller.text),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WHColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? WHColors.grey4
                            : WHColors.textPrimary,
                      ),
                    ),
            ),

            _StepButton(
              icon: Icons.add_rounded,
              enabled: canIncrease,
              isLeft: false,
              onTap: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tombol + / - ──────────────────────────────────────────────────
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.isLeft,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(12) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(12),
        ),
        splashColor: WHColors.textPrimary.withValues(alpha: 0.08),
        highlightColor: WHColors.textPrimary.withValues(alpha: 0.04),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? WHColors.textPrimary : WHColors.grey4,
          ),
        ),
      ),
    );
  }
}
