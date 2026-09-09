import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/presentation/bloc/inbound/inbound_bloc.dart';
import 'package:inbound/presentation/bloc/inbound/inbound_event.dart';
import 'package:inbound/presentation/bloc/inbound/inbound_state.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/pa_scan_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_header.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_product_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/upcoming_product_card.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    context.read<InboundBloc>().add(GetPaNextItemEvent(widget.purchaseOrderId));
  }

  bool _isAllShelvesScanned(PaNextItem item) {
    return item.recommendedShelves.every(
      (shelf) => _completedShelfIds.contains(shelf.shelfId),
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

    if (!_isAllShelvesScanned(item)) {
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
    context.read<InboundBloc>().add(SubmitPaEvent(params, item.receivingLogId));
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
        formats: const [BarcodeFormat.qrCode],
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
    return BlocListener<InboundBloc, InboundState>(
      listener: (context, state) {
        if (state is SubmitPaSuccess) {
          setState(() => _isSubmitting = false);
          _handleSubmitSuccess();
        }

        if (state is InboundError) {
          setState(() => _isSubmitting = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: const WHAppbar(title: 'Put Away'),
        bottomNavigationBar: BlocBuilder<InboundBloc, InboundState>(
          builder: (context, state) {
            // CEK CACHE AGAR TOMBOL TIDAK HILANG SAAT LOADING SUBMIT
            final PaNextItem? displayItem = (state is PaNextItemLoaded)
                ? state.item
                : (_isSubmitting ? _lastLoadedItem : null);

            if (displayItem == null) return const SizedBox.shrink();

            return SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: WHButton(
                backgroundColor: WHColors.secondary3,
                icon: displayItem.upcoming == null
                    ? Icons.check_circle_outline_outlined
                    : null,
                label: displayItem.upcoming == null ? 'Done' : 'Next Item',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting
                    ? null
                    : () => _submitPutAway(displayItem),
              ),
            );
          },
        ),
        body: BlocBuilder<InboundBloc, InboundState>(
          builder: (context, state) {
            // HANYA MUNCUL LOADING PENUH JIKA BUKAN PROSES SUBMIT
            if (state is InboundLoading && !_isSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InboundError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: WHError(message: state.message),
                ),
              );
            }

            final PaNextItem? displayItem = (state is PaNextItemLoaded)
                ? state.item
                : (_isSubmitting ? _lastLoadedItem : null);

            if (displayItem != null) {
              return _PutAwayContent(
                purchaseOrderNumber: widget.purchaseOrderNumber,
                item: displayItem,
                completedShelfIds: _completedShelfIds,
                onScanQrCode: _scanQrCode,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _PutAwayContent extends StatelessWidget {
  const _PutAwayContent({
    required this.purchaseOrderNumber,
    required this.item,
    required this.completedShelfIds,
    required this.onScanQrCode,
  });

  final String purchaseOrderNumber;
  final PaNextItem item;
  final Set<int> completedShelfIds;
  final ValueChanged<RecommendedShelf> onScanQrCode;

  @override
  Widget build(BuildContext context) {
    final upcomingProduct = item.upcoming == null
        ? null
        : UpcomingProduct(
            sku: item.upcoming!.sku,
            productName: item.upcoming!.productName,
            expectedQty: item.upcoming!.qtyExpected,
            unit: item.upcoming!.unitOfMeasure,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        QcHeader(
          typeLabel: 'Purchase Order',
          orderNumber: purchaseOrderNumber,
          currentItem: item.currentItemNumber,
          totalItems: item.totalItems,
        ),
        const SizedBox(height: 16),
        QcProductCard(
          sku: item.sku,
          productName: item.productName,
          expectedQty: item.qtyExpected,
          unitOfMeasure: item.unitOfMeasure,
        ),
        const SizedBox(height: 16),
        item.recommendedShelves.isEmpty
            ? Text(
                'No recommended shelves available. Please contact your supervisor.',
                style: WHTypography.caption.copyWith(color: WHColors.error1),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommended Shelves', style: WHTypography.caption),
                  const SizedBox(height: 8),
                  ...item.recommendedShelves.map((shelf) {
                    return PaScanCard(
                      shelf: shelf,
                      unitOfMeasure: item.unitOfMeasure,
                      isCompleted: completedShelfIds.contains(shelf.shelfId),
                      onScan: () => onScanQrCode(shelf),
                    );
                  }),
                ],
              ),
        if (item.isLastItem == false && upcomingProduct != null) ...[
          const SizedBox(height: 16),
          Text('Upcoming', style: WHTypography.bodyText.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          UpcomingProductCard(product: upcomingProduct),
        ],
      ],
    );
  }
}
