import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

enum QcCondition { good, damaged, less }

class QcFormData {
  QcFormData({
    this.condition = QcCondition.good,
    this.conditionNotes = '',
    this.isUnreadableBarcode = false,
    this.receivedQty = 0,
    this.expiryDate,
  });

  final QcCondition condition;
  final String conditionNotes;
  final bool isUnreadableBarcode;
  final int receivedQty;
  final DateTime? expiryDate;

  QcFormData copyWith({
    QcCondition? condition,
    String? conditionNotes,
    bool? isUnreadableBarcode,
    int? receivedQty,
    DateTime? expiryDate,
  }) {
    return QcFormData(
      condition: condition ?? this.condition,
      conditionNotes: conditionNotes ?? this.conditionNotes,
      isUnreadableBarcode: isUnreadableBarcode ?? this.isUnreadableBarcode,
      receivedQty: receivedQty ?? this.receivedQty,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

class QcFormCard extends StatefulWidget {
  const QcFormCard({
    super.key,
    this.data,
    this.onChanged,
    this.onCapture,
    this.hasCapturedPhoto = false,
  });

  final QcFormData? data;
  final ValueChanged<QcFormData>? onChanged;
  final VoidCallback? onCapture;
  final bool hasCapturedPhoto;

  @override
  State<QcFormCard> createState() => _QcFormCardState();
}

class _QcFormCardState extends State<QcFormCard> {
  late QcFormData _data;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _data = widget.data ?? QcFormData();
    _notesController = TextEditingController(text: _data.conditionNotes);
  }

  @override
  void didUpdateWidget(covariant QcFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data && widget.data != null) {
      _data = widget.data!;
      if (_notesController.text != _data.conditionNotes) {
        _notesController.text = _data.conditionNotes;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _emit(QcFormData updated) {
    setState(() => _data = updated);
    widget.onChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return _QcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('QC CONDITION'),
          const SizedBox(height: 12),
          _ConditionSegmentedControl(
            selected: _data.condition,
            onSelected: (condition) {
              _emit(_data.copyWith(condition: condition));
            },
          ),
          if (_data.condition == QcCondition.damaged) ...[
            const SizedBox(height: 12),
            _ConditionNotesField(
              controller: _notesController,
              valueLength: _data.conditionNotes.length,
              onChanged: (value) {
                _emit(_data.copyWith(conditionNotes: value));
              },
            ),
            const SizedBox(height: 12),
            _UnreadableBarcodeCheck(
              value: _data.isUnreadableBarcode,
              onChanged: (value) {
                _emit(_data.copyWith(isUnreadableBarcode: value));
              },
            ),
          ],
          if (_data.condition == QcCondition.less) ...[
            const SizedBox(height: 16),
            _ReceivedQtyField(
              value: _data.receivedQty,
              onChanged: (value) {
                _emit(_data.copyWith(receivedQty: value));
              },
            ),
          ],
          const SizedBox(height: 12),
          WHButton(
            backgroundColor: widget.hasCapturedPhoto
                ? WHColors.success1
                : WHColors.primary1,
            label: widget.hasCapturedPhoto
                ? 'Condition Captured'
                : 'Capture Condition',
            icon: widget.hasCapturedPhoto
                ? Icons.check_circle_outline
                : Icons.camera_alt_outlined,
            onPressed: widget.onCapture,
          ),
          const SizedBox(height: 14),
          const _SectionLabel('EXPIRY DATE'),
          const SizedBox(height: 8),
          WHDateField(
            label: 'Expiry Date',
            flat: true,
            isPast: false,
            selectedDate: _data.expiryDate,
            onDateSelected: (date) {
              _emit(_data.copyWith(expiryDate: date));
            },
          ),
        ],
      ),
    );
  }
}

class QcBarcodeCard extends StatelessWidget {
  const QcBarcodeCard({super.key, this.onScan, this.isVerified = false});

  final VoidCallback? onScan;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return _QcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Barcode Item',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (isVerified)
            const _VerifiedBarcodeBanner()
          else
            WHButton(
              backgroundColor: WHColors.primary1,
              label: 'Scan',
              icon: Icons.qr_code_scanner_rounded,
              onPressed: onScan,
            ),
        ],
      ),
    );
  }
}

class _VerifiedBarcodeBanner extends StatelessWidget {
  const _VerifiedBarcodeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: WHColors.success4,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: WHColors.success3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: WHColors.success1, size: 20),
          const SizedBox(width: 8),
          Text(
            'Barcode Verified',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.success1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QcCard extends StatelessWidget {
  const _QcCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: WHColors.grey2),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: WHTypography.bodyText.copyWith(
        color: WHColors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _ConditionSegmentedControl extends StatelessWidget {
  const _ConditionSegmentedControl({
    required this.selected,
    required this.onSelected,
  });

  final QcCondition selected;
  final ValueChanged<QcCondition> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: QcCondition.values.map((condition) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: condition == QcCondition.less ? 0 : 8,
            ),
            child: _ConditionButton(
              condition: condition,
              isSelected: selected == condition,
              onTap: () => onSelected(condition),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ConditionButton extends StatelessWidget {
  const _ConditionButton({
    required this.condition,
    required this.isSelected,
    required this.onTap,
  });

  final QcCondition condition;
  final bool isSelected;
  final VoidCallback onTap;

  String get _label {
    switch (condition) {
      case QcCondition.good:
        return 'GOOD';
      case QcCondition.damaged:
        return 'DAMAGED';
      case QcCondition.less:
        return 'LESS';
    }
  }

  Color get _selectedBackground {
    switch (condition) {
      case QcCondition.good:
        return WHColors.primary6;
      case QcCondition.damaged:
        return WHColors.warning3;
      case QcCondition.less:
        return WHColors.error3;
    }
  }

  Color get _selectedBorder {
    switch (condition) {
      case QcCondition.good:
        return WHColors.primary3;
      case QcCondition.damaged:
        return WHColors.warning2;
      case QcCondition.less:
        return WHColors.error2;
    }
  }

  IconData get _selectedIcon {
    switch (condition) {
      case QcCondition.good:
        return Icons.check_circle;
      case QcCondition.damaged:
      case QcCondition.less:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? _selectedBorder : WHColors.grey4;
    final background = isSelected ? _selectedBackground : WHColors.surface;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: background,
          foregroundColor: WHColors.primary1,
          side: BorderSide(color: borderColor, width: isSelected ? 1.2 : 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(_selectedIcon, size: 15, color: WHColors.primary1),
                const SizedBox(width: 3),
              ],
              Text(
                _label,
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.primary1,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConditionNotesField extends StatelessWidget {
  const _ConditionNotesField({
    required this.controller,
    required this.valueLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int valueLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition Notes',
          style: WHTypography.bodyText.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: WHColors.grey4),
          ),
          child: TextField(
            controller: controller,
            maxLength: 150,
            maxLines: 5,
            onChanged: onChanged,
            style: WHTypography.bodyText,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Describe any visible damage...',
              hintStyle: WHTypography.bodyText.copyWith(
                color: const Color(0xFFCFCFCF),
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$valueLength/150',
            style: WHTypography.caption.copyWith(color: WHColors.grey2),
          ),
        ),
      ],
    );
  }
}

class _UnreadableBarcodeCheck extends StatelessWidget {
  const _UnreadableBarcodeCheck({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
              activeColor: WHColors.primary3,
              checkColor: WHColors.surface,
              side: const BorderSide(color: WHColors.primary1, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Unreadable Barcode',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.primary1,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedQtyField extends StatelessWidget {
  const _ReceivedQtyField({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return WHStepperField(
      label: 'Received Qty',
      value: value,
      onChanged: onChanged,
      minValue: 0,
      allowManualInput: true,
    );
  }
}
