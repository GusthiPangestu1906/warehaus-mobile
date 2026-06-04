import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// ENUMS & MODELS
// ─────────────────────────────────────────────────────────────────

enum OrderType { inbound, outbound }

enum OrderStatus { queued, active, completed }

/// Tahap proses aktif.
/// Inbound  : qc, puttingAway
/// Outbound : pickingUp, packing
enum OrderProcessStage { qc, puttingAway, pickingUp, packing }

/// Data model untuk OrderCard.
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

  /// Inbound → "Carrier", Outbound → "Courier"
  final String carrierOrCourier;

  /// Hanya ada jika [status] == active
  final OrderProcessStage? processStage;
  final int processValue;
  final int processTotal;
  final String processUnit;
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.data, this.onTap});

  final OrderCardData data;
  final VoidCallback? onTap;

  // ── Colors ───────────────────────────────────────────────────
  static const _cardBg = WHColors.surface;
  static const _cardBorder = WHColors.grey3;
  static const _labelColor = WHColors.grey2;
  static const _valueColor = WHColors.textPrimary;
  static const _orderNumSize = 20.0;
  static const _labelSize = 10.0;
  static const _valueSize = 13.0;

  // ── Helpers ──────────────────────────────────────────────────
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
          bg: WHColors.grey5,
          text: WHColors.grey2,
          label: 'Queued',
        );
      case OrderStatus.active:
        return const _StatusStyle(
          bg: WHColors.warning1,
          text: WHColors.warning2,
          label: 'Active',
        );
      case OrderStatus.completed:
        return const _StatusStyle(
          bg: WHColors.success2,
          text: WHColors.success4,
          label: 'Completed',
        );
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
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: order type + badge ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _orderTypeLabel,
                  style: const TextStyle(
                    fontSize: _labelSize,
                    color: _labelColor,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _StatusBadge(
                  label: style.label,
                  bg: style.bg,
                  text: style.text,
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ── Row 2: order number ───────────────────────────
            Text(
              data.orderNumber,
              style: const TextStyle(
                fontSize: _orderNumSize,
                fontWeight: FontWeight.w700,
                color: _valueColor,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 10),

            // ── Row 3: Created At + Carrier/Courier ───────────
            Row(
              children: [
                _MetaColumn(label: 'Created At', value: data.createdAt),
                const SizedBox(width: 24),
                _MetaColumn(label: _carrierLabel, value: data.carrierOrCourier),
              ],
            ),

            // ── Row 4: Progress bar (only when active) ────────
            if (_isActive && data.processStage != null) ...[
              const SizedBox(height: 12),
              const Divider(color: _cardBorder, height: 1),
              const SizedBox(height: 10),
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

// ─────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
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
          style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8A)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: WHColors.textPrimary,
          ),
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

  static const _orange = Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
            ),
            Text(
              '$value / $total $unit',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: const Color(0xFF3A3A3A),
            valueColor: const AlwaysStoppedAnimation<Color>(_orange),
          ),
        ),
      ],
    );
  }
}
