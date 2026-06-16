import 'package:core_ui/core_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/models/pick_flow_item.dart';
import 'package:outbound/presentation/widgets/packing/packing_item_card.dart';

class PackingPage extends StatefulWidget {
  const PackingPage({
    super.key,
    required this.orderNumber,
    required this.items,
    this.orderId,
  });

  final String orderNumber;
  final List<PickItem> items;
  final int? orderId;

  @override
  State<PackingPage> createState() => _PackingPageState();
}

class _PackingPageState extends State<PackingPage> {
  late final List<bool> _verifiedItems;
  bool _isCompleting = false;

  SalesOrderApiDatasource get _api => GetIt.instance<SalesOrderApiDatasource>();

  @override
  void initState() {
    super.initState();
    _verifiedItems = List.generate(widget.items.length, (index) => false);
  }

  bool get _allVerified => _verifiedItems.every((verified) => verified);
  int get _verifiedCount => _verifiedItems.where((verified) => verified).length;

  Future<void> _scanItem(int index) async {
    if (_verifiedItems[index]) return;

    final scannedCode = await Navigator.of(context).push<String>(
      WHScannerPage.route(
        title: 'Verify Barcode Item',
        subtitle: 'Scan barcode ${widget.items[index].productName}',
      ),
    );

    if (!mounted || scannedCode == null || scannedCode.trim().isEmpty) return;

    final item = widget.items[index];
    debugPrint(
      '[PackingPage] scanned item="${scannedCode.trim()}" '
      'targetBarcode="${item.barcode}" targetSku="${item.sku}"',
    );

    if (!_matchesItemBarcode(scannedCode, item)) {
      WHSnackBar.showError(context, 'Barcode item tidak sesuai.');
      return;
    }

    setState(() => _verifiedItems[index] = true);
    WHSnackBar.showSuccess(context, 'Barcode verified successfully.');
  }

  bool _matchesItemBarcode(String raw, PickItem item) {
    final scanned = _normalize(raw);
    final candidates = [
      item.barcode,
      item.sku,
    ].map(_normalize).where((value) => value.isNotEmpty);

    return candidates.any(
      (candidate) => scanned == candidate || scanned.contains(candidate),
    );
  }

  String _normalize(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('_', '-');
  }

  Future<void> _complete() async {
    if (_isCompleting) return;

    if (!_allVerified) {
      WHSnackBar.showInfo(
        context,
        'Scan semua item packing sebelum complete dan print label.',
      );
      return;
    }

    final orderId = widget.orderId;
    if (orderId == null) {
      WHSnackBar.showError(context, 'Sales Order ID tidak ditemukan.');
      return;
    }

    if (widget.items.any((item) => item.salesOrderItemId == null)) {
      WHSnackBar.showError(context, 'Data item packing tidak lengkap.');
      return;
    }

    setState(() => _isCompleting = true);

    try {
      await _api.completePacking(
        orderId,
        verifiedItems: widget.items
            .map(
              (item) => {
                'salesOrderItemId': item.salesOrderItemId,
                'packedQty': item.expectedQty,
              },
            )
            .toList(),
      );
      if (!mounted) return;

      _showCompleteSuccess(orderId);
    } catch (e) {
      if (!mounted) return;
      debugPrint('[PackingPage] complete packing error: $e');

      final completed = await _isCompletedOnBackend(orderId);
      if (!mounted) return;

      if (completed) {
        _showCompleteSuccess(orderId);
        return;
      }

      setState(() => _isCompleting = false);
      WHSnackBar.showError(context, _friendlyError(e));
    }
  }

  Future<bool> _isCompletedOnBackend(int orderId) async {
    try {
      final order = await _api.getSalesOrderById(orderId);
      return order.isCompleted || order.status.toLowerCase() == 'completed';
    } catch (e) {
      debugPrint('[PackingPage] failed to refresh complete status: $e');
      return false;
    }
  }

  void _showCompleteSuccess(int orderId) {
    context.read<SalesOrderBloc>().add(
      UpdateSalesOrderLocalStatusEvent(
        id: orderId,
        status: 'Completed',
        totalPickedItems: _totalQuantity,
        totalVerifiedItems: _totalQuantity,
        isCompleted: true,
      ),
    );

    setState(() => _isCompleting = false);

    showWhPopUpDone(
      context: context,
      nextStepLabel: 'Label printed. Sales Order is ready for delivery.',
      onBackToFlow: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  int get _totalQuantity =>
      widget.items.fold<int>(0, (sum, item) => sum + item.expectedQty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: WHColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WHColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'PACKING',
          style: TextStyle(
            color: WHColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFD7E2F5)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          _PackingOrderCard(
            orderNumber: widget.orderNumber,
            verifiedCount: _verifiedCount,
            totalCount: widget.items.length,
          ),
          const SizedBox(height: 28),
          ...List.generate(widget.items.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: PackingItemCard(
                  key: ValueKey(
                    '${widget.items[index].sku}-${_verifiedItems[index]}',
                  ),
                  sku: widget.items[index].sku,
                  productName: widget.items[index].productName,
                  expectedQty: widget.items[index].expectedQty,
                  unitOfMeasure: widget.items[index].unitOfMeasure,
                  isVerified: _verifiedItems[index],
                  onScan: () => _scanItem(index),
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: const BoxDecoration(
          color: WHColors.surface,
          border: Border(top: BorderSide(color: WHColors.grey5)),
        ),
        child: WhPrimaryButton(
          text: _isCompleting ? 'Processing...' : 'Complete & Print Label',
          icon: Icons.print_outlined,
          onPressed: _isCompleting ? null : _complete,
        ),
      ),
    );
  }
}

String _friendlyError(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final responseText = error.response?.data?.toString() ?? '';
    debugPrint(
      '[PackingPage] complete packing response status=$statusCode body=$responseText',
    );

    if (statusCode == 409 || statusCode == 400) {
      return 'Backend menolak complete. Pastikan endpoint complete menerima verifiedItems.';
    }
    if (statusCode == 404) {
      return 'Endpoint packing complete belum ditemukan di backend.';
    }
    if (responseText.isNotEmpty) {
      return responseText;
    }
  }

  final message = error.toString();
  if (message.contains('409')) {
    return 'Backend menolak complete. Pastikan endpoint complete menerima verifiedItems.';
  }
  if (message.contains('404')) {
    return 'Endpoint packing complete belum ditemukan di backend.';
  }
  return 'Gagal complete packing. Coba lagi.';
}

class _PackingOrderCard extends StatelessWidget {
  const _PackingOrderCard({
    required this.orderNumber,
    required this.verifiedCount,
    required this.totalCount,
  });

  final String orderNumber;
  final int verifiedCount;
  final int totalCount;

  double get _progress =>
      totalCount == 0 ? 0 : (verifiedCount / totalCount).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER #',
                  style: WHTypography.bodyText.copyWith(
                    color: WHColors.textSecondary,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFE2E2E2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      WHColors.secondary4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                orderNumber,
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.primary1,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '$verifiedCount / $totalCount Items',
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.secondary3,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
