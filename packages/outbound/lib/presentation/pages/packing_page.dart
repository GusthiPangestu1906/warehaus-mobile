import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _verifiedItems = List.generate(widget.items.length, (index) => false);
    if (_verifiedItems.isNotEmpty) {
      _verifiedItems[_verifiedItems.length - 1] = true;
    }
  }

  bool get _allVerified => _verifiedItems.every((verified) => verified);
  int get _verifiedCount => _verifiedItems.where((verified) => verified).length;

  void _scanItem(int index) {
    setState(() => _verifiedItems[index] = true);
  }

  void _complete() {
    final orderId = widget.orderId;
    if (orderId != null) {
      context.read<SalesOrderBloc>().add(
        UpdateSalesOrderLocalStatusEvent(
          id: orderId,
          status: 'Completed',
          totalPickedItems: _totalQuantity,
          totalVerifiedItems: _totalQuantity,
          isCompleted: true,
        ),
      );
    }

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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: const BoxDecoration(
              color: WHColors.surface,
              border: Border(top: BorderSide(color: WHColors.grey5)),
            ),
            child: WhPrimaryButton(
              text: 'Complete & Print Label',
              icon: Icons.print_outlined,
              onPressed: _allVerified ? _complete : null,
            ),
          ),
          WHBottomNav(
            currentIndex: 2,
            onTap: (_) =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
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
