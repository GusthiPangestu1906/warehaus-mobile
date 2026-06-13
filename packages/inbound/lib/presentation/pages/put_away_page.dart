import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/pa_scan_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_header.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_product_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/upcoming_product_card.dart';

class PutAwayPage extends StatefulWidget {
  const PutAwayPage({
    super.key,
    required this.purchaseOrderId,
    required this.purchaseOrderNumber,
  });

  final int purchaseOrderId;
  final String purchaseOrderNumber;

  @override
  State<PutAwayPage> createState() => _PutAwayPageState();
}

class _PutAwayPageState extends State<PutAwayPage> {
  final Set<int> _completedShelfIds = {};
  PaNextItem? _lastLoadedItem;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchNextPaItem();
  }

  void _fetchNextPaItem() {
    context.read<PurchaseOrderBloc>().add(
      GetPaNextItemEvent(widget.purchaseOrderId),
    );
  }

  void _submitPutAway(PaNextItem item) {
    if (item.recommendedShelves.isEmpty) {
      WHSnackBar.showError(
        context,
        'No recommended shelves available. Please contact your supervisor.',
      );
      return;
    }

    final unscannedShelves = item.recommendedShelves.where(
      (shelf) => !_completedShelfIds.contains(shelf.shelfId),
    );

    if (unscannedShelves.isNotEmpty) {
      WHSnackBar.showError(
        context,
        'Please scan all recommended shelf QR codes before submitting.',
      );
      return;
    }

    final params = SubmitPaParams(
      itemId: item.poItemId,
      shelves: item.recommendedShelves
          .map(
            (shelf) => ShelfPutAway(
              shelfId: shelf.shelfId,
              quantity: shelf.qtyRequired,
            ),
          )
          .toList(),
    );

    _lastLoadedItem = item;
    setState(() => _isSubmitting = true);
    context.read<PurchaseOrderBloc>().add(
      SubmitPaEvent(params, item.receivingLogId),
    );
  }

  void _handleSubmitSuccess() {
    final submittedItem = _lastLoadedItem;
    if (submittedItem == null) {
      _fetchNextPaItem();
      return;
    }

    _completedShelfIds.clear();

    if (submittedItem.upcoming == null) {
      WHSnackBar.showSuccess(context, 'Put away completed.');
      Navigator.of(context).pop();
      return;
    }

    WHSnackBar.showSuccess(context, 'Put away item saved.');
    _fetchNextPaItem();
  }

  Future<void> _scanQrCode(RecommendedShelf item) async {
    final scannedCode = await Navigator.of(context).push<String>(
      WHScannerPage.route(
        title: 'Scan ${item.shelfCode}',
        subtitle: 'Scan the QR code on the shelf to confirm put away location',
      ),
    );

    if (!mounted || scannedCode == null) return;

    if (scannedCode.trim() != item.shelfCode.trim()) {
      WHSnackBar.showError(
        context,
        'Scanned code does not match the expected shelf code. Please try again. {Expected: ${item.shelfCode}, Scanned: $scannedCode}',
      );
      return;
    }

    setState(() => _completedShelfIds.add(item.shelfId));
    WHSnackBar.showSuccess(context, 'QRCode verified successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseOrderBloc, PurchaseOrderState>(
      listener: (context, state) {
        if (state is SubmitPaSuccess) {
          setState(() => _isSubmitting = false);
          _handleSubmitSuccess();
        }

        if (state is PurchaseOrderError) {
          setState(() => _isSubmitting = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: const WHAppbar(title: 'Put Away'),
        bottomNavigationBar: BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
          builder: (context, state) {
            if (state is! PaNextItemLoaded) return const SizedBox.shrink();

            return SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: WHButton(
                backgroundColor: WHColors.secondary3,
                icon: state.item.upcoming == null
                    ? Icons.check_circle_outline_outlined
                    : null,
                label: state.item.upcoming == null ? 'Done' : 'Next Item',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting
                    ? null
                    : () => _submitPutAway(state.item),
              ),
            );
          },
        ),
        body: BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
          builder: (context, state) {
            if (state is PurchaseOrderLoading && !_isSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PurchaseOrderError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: WHError(message: state.message),
                ),
              );
            }

            if (state is PaNextItemLoaded) {
              final upcomingProduct = state.item.upcoming == null
                  ? null
                  : UpcomingProduct(
                      sku: state.item.upcoming!.sku,
                      productName: state.item.upcoming!.productName,
                      expectedQty: state.item.upcoming!.qtyExpected,
                      unit: state.item.upcoming!.unitOfMeasure,
                    );

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  QcHeader(
                    typeLabel: 'Purchase Order',
                    orderNumber: widget.purchaseOrderNumber,
                    currentItem: state.item.currentItemNumber,
                    totalItems: state.item.totalItems,
                  ),
                  const SizedBox(height: 16),
                  QcProductCard(
                    sku: state.item.sku,
                    productName: state.item.productName,
                    expectedQty: state.item.qtyExpected,
                    unitOfMeasure: state.item.unitOfMeasure,
                  ),
                  const SizedBox(height: 16),
                  state.item.recommendedShelves.isEmpty
                      ? Text(
                          'No recommended shelves available. Please contact your supervisor.',
                          style: WHTypography.caption.copyWith(
                            color: WHColors.error1,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended Shelves',
                              style: WHTypography.caption,
                            ),
                            const SizedBox(height: 8),
                            ...state.item.recommendedShelves.map((shelf) {
                              return PaScanCard(
                                shelf: shelf,
                                unitOfMeasure: state.item.unitOfMeasure,
                                isCompleted: _completedShelfIds.contains(
                                  shelf.shelfId,
                                ),
                                onScan: () => _scanQrCode(shelf),
                              );
                            }),
                          ],
                        ),
                  if (state.item.isLastItem == false &&
                      upcomingProduct != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Upcoming',
                      style: WHTypography.bodyText.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    UpcomingProductCard(product: upcomingProduct),
                  ],
                ],
              );
            }

            if (_isSubmitting && _lastLoadedItem != null) {
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
