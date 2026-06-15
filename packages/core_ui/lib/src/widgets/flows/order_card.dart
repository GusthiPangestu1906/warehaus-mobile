import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

enum OrderType { inbound, outbound }

enum OrderStatus { queued, active, completed }

enum OrderProcessStage { qc, puttingAway, pickingUp, packing }

class OrderCardData {
  const OrderCardData({
    required this.orderNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.carrierOrCourier,
    this.processStage,
    this.processValue = 0,
    this.processTotal = 0,
    this.processUnit = 'Pallets',
  });

  final String orderNumber;
  final OrderType type;
  final OrderStatus status;
  final String createdAt;
  final String carrierOrCourier;
  final OrderProcessStage? processStage;
  final int processValue;
  final int processTotal;
  final String processUnit;
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.data, this.onTap});

  final OrderCardData data;
  final VoidCallback? onTap;

  static const _labelColor = WHColors.grey2;
  static const _valueColor = WHColors.textPrimary;

  bool get _isInbound => data.type == OrderType.inbound;
  bool get _isActive => data.status == OrderStatus.active;

  String get _orderTypeLabel => _isInbound ? 'PURCHASE ORDER' : 'SALES ORDER';

  String get _carrierLabel => _isInbound ? 'Carrier' : 'Courier';

  String get _processLabel {
    switch (data.processStage) {
      case OrderProcessStage.qc:
        return 'Quality Control Progress';
      case OrderProcessStage.puttingAway:
        return 'Putting Away Progress';
      case OrderProcessStage.pickingUp:
        return 'Picking Up Progress';
      case OrderProcessStage.packing:
        return 'Packing Progress';
      default:
        return '';
    }
  }

  _StatusStyle get _statusStyle {
    switch (data.status) {
      case OrderStatus.queued:
        return const _StatusStyle(
          bg: Color(0xFFEDEDED),
          text: WHColors.grey2,
          label: 'Queued',
        );
      case OrderStatus.active:
        return const _StatusStyle(
          bg: WHColors.warning2,
          text: WHColors.warning1,
          label: 'Active',
        );
      case OrderStatus.completed:
        return const _StatusStyle(
          bg: WHColors.success2,
          text: WHColors.surface,
          label: 'Completed',
        );
    }
  }

  Color get _borderColor {
    switch (data.status) {
      case OrderStatus.queued:
        return WHColors.grey3;
      case OrderStatus.active:
        return WHColors.secondary4;
      case OrderStatus.completed:
        return WHColors.success2;
    }
  }

  double get _progressPercent {
    if (data.processTotal <= 0) return 0;
    return (data.processValue / data.processTotal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: WHColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _orderTypeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _StatusBadge(
                  label: style.label,
                  bg: style.bg,
                  text: style.text,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              data.orderNumber,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (_isActive)
              _MetaColumn(label: _carrierLabel, value: data.carrierOrCourier)
            else
              Row(
                children: [
                  Expanded(
                    child: _MetaColumn(
                      label: 'Created At',
                      value: data.createdAt,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _MetaColumn(
                      label: _carrierLabel,
                      value: data.carrierOrCourier,
                    ),
                  ),
                ],
              ),
            if (_isActive && data.processStage != null) ...[
              const SizedBox(height: 12),
              const Divider(color: WHColors.grey3, height: 1),
              const SizedBox(height: 8),
              _ProgressRow(
                label: _processLabel,
                value: data.processValue,
                total: data.processTotal,
                unit: data.processUnit,
                percent: _progressPercent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.bg,
    required this.text,
    required this.label,
  });

  final Color bg;
  final Color text;
  final String label;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.bg,
    required this.text,
  });

  final String label;
  final Color bg;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    switch (label) {
      case 'Completed':
        return Icons.check_circle;
      case 'Active':
        return Icons.more_horiz;
      default:
        return Icons.access_time;
    }
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: WHColors.grey2),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: WHColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.unit,
    required this.percent,
  });

  final String label;
  final int value;
  final int total;
  final String unit;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: WHColors.grey2),
              ),
            ),
            Text(
              '$value / $total $unit',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: WHColors.secondary4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 7,
            backgroundColor: const Color(0xFFE8E8E8),
            valueColor: const AlwaysStoppedAnimation<Color>(
              WHColors.secondary4,
            ),
          ),
        ),
      ],
    );
  }
}
