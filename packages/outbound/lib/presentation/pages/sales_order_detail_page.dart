import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/presentation/widgets/sales_order_detail/so_detail_header.dart';
import 'package:outbound/presentation/widgets/sales_order_detail/so_info_cards.dart';
import 'package:outbound/presentation/widgets/sales_order_detail/so_product_list_section.dart';
import 'package:outbound/presentation/widgets/sales_order_detail/so_tracking_input_card.dart';

class SalesOrderDetailPage extends StatefulWidget {
  const SalesOrderDetailPage({super.key, required this.order});

  final SalesOrder order;

  @override
  State<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
}

class _SalesOrderDetailPageState extends State<SalesOrderDetailPage> {
  final TextEditingController _trackingController = TextEditingController();
  bool _isEditingTracking = false;
  String? _trackingNumber;
  bool _startedFromTracking = false;

  @override
  void initState() {
    super.initState();
    _trackingNumber = _clean(widget.order.trackingNumber);
    _trackingController.text = _trackingNumber ?? '';
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  String get _status {
    if (_trackingNumber != null || _startedFromTracking) return 'Active';
    if (widget.order.isCompleted) return 'Completed';

    switch (widget.order.status.trim().toLowerCase()) {
      case 'completed':
      case 'complete':
      case 'success':
      case 'done':
        return 'Completed';
      case 'active':
      case 'processing':
      case 'picking':
      case 'picking up':
      case 'packing':
      case 'in progress':
        return 'Active';
      default:
        return 'Queued';
    }
  }

  bool get _isQueued => _status == 'Queued';
  bool get _isActive => _status == 'Active';
  bool get _isCompleted => _status == 'Completed';
  bool get _hasTracking => _trackingNumber != null;

  Future<void> _confirmTracking() async {
    final value = _trackingController.text.trim();
    if (value.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TrackingConfirmationDialog(trackingNumber: value),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _trackingNumber = value;
      _isEditingTracking = false;
      _startedFromTracking = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomAction = _bottomAction();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: WHColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WHColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'DETAIL SO',
          style: TextStyle(
            color: WHColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFD7E2F5)),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          bottomAction == null ? 24 : 96,
        ),
        children: [
          SoDetailHeader(
            soNumber: _formatSalesOrderNumber(widget.order),
            createdAt: _formatDate(widget.order.orderDate),
            status: _status,
            showActions: _isQueued && !_isEditingTracking && !_hasTracking,
            onDelete: () {},
            onEdit: () {},
          ),
          const SizedBox(height: 6),
          SoInfoCards(
            slaLabel: _formatDate(widget.order.requiredDeliveryDate),
            trackingNumber: _trackingNumber,
            customerName:
                widget.order.contactPerson ?? widget.order.customerName,
            companyName: widget.order.companyName ?? '-',
            courier: widget.order.courierName ?? '-',
            address: _address(widget.order),
            province: _provinceLabel(widget.order),
            city: _cityLabel(widget.order),
            postalCode: widget.order.postalCode ?? '-',
          ),
          const SizedBox(height: 8),
          const _NoteCard(),
          if (!_hasTracking) ...[
            const SizedBox(height: 6),
            SoTrackingInputCard(
              controller: _trackingController,
              isEditing: _isEditingTracking,
              onStart: () => setState(() => _isEditingTracking = true),
              onSave: _confirmTracking,
            ),
          ],
          const SizedBox(height: 24),
          SoProductListSection(products: widget.order.items),
        ],
      ),
      bottomNavigationBar: bottomAction,
    );
  }

  Widget? _bottomAction() {
    if (_isActive) {
      return _StickyActionButton(
        label: 'Start Picking',
        icon: Icons.check_circle_outline,
        onPressed: () {},
      );
    }

    if (_isCompleted) {
      return _StickyActionButton(
        label: 'Completed',
        icon: Icons.check_circle,
        onPressed: () {},
      );
    }

    return null;
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Note', style: WHTypography.caption),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            style: WHTypography.bodyText.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _TrackingConfirmationDialog extends StatelessWidget {
  const _TrackingConfirmationDialog({required this.trackingNumber});

  final String trackingNumber;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF8F8F8),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 86,
              color: Color(0xFFC91E1E),
            ),
            const SizedBox(height: 22),
            const Text(
              'Are you sure the entered Tracking\nNumber is correct?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 6),
            Text(
              trackingNumber,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0865C9),
                  foregroundColor: WHColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                child: const Text(
                  'Yes, Save It.',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyActionButton extends StatelessWidget {
  const _StickyActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: WHColors.surface,
        border: Border(top: BorderSide(color: WHColors.grey5)),
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 22),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: WHColors.secondary3,
            foregroundColor: WHColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.black),
            ),
            textStyle: WHTypography.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return '-';
  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

String _formatSalesOrderNumber(SalesOrder order) {
  final parsed = DateTime.tryParse(order.orderDate);
  if (parsed == null) return order.soNumber;

  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final sequence = order.id.toString().padLeft(2, '0');

  return 'SO-$day$month${local.year}-$sequence';
}

String _address(SalesOrder order) {
  final value = order.shippingAddress.trim();
  if (value.isEmpty) {
    return 'Jl. Raya ITS, Gedung D4, Keputih, Sukolilo, Surabaya, East Java 36812';
  }
  return value;
}

String _provinceLabel(SalesOrder order) {
  final code = order.provinceCode?.trim();
  if (code == null || code.isEmpty) return 'East Java';
  if (code == '51') return 'Bali';
  return code;
}

String _cityLabel(SalesOrder order) {
  final code = order.cityCode?.trim();
  if (code == null || code.isEmpty) return 'Surabaya';
  if (code == '51.03') return 'Badung';
  return code;
}

String? _clean(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}
