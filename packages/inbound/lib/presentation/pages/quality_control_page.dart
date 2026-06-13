import 'dart:convert';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/entities/qc_next_item.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_form_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_header.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_product_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/upcoming_product_card.dart';

class QualityControlPage extends StatefulWidget {
  const QualityControlPage({
    super.key,
    required this.purchaseOrderId,
    required this.purchaseOrderNumber,
  });

  final int purchaseOrderId;
  final String purchaseOrderNumber;

  @override
  State<QualityControlPage> createState() => _QualityControlPageState();
}

class _QualityControlPageState extends State<QualityControlPage> {
  final Map<int, QcFormData> _formDataByItemId = {};
  final Map<int, String> _photoByItemId = {};
  final Set<int> _verifiedBarcodeItemIds = {};

  QcNextItem? _lastLoadedItem;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchNextQcItem();
  }

  void _fetchNextQcItem() {
    context.read<PurchaseOrderBloc>().add(
      GetQcNextItemEvent(widget.purchaseOrderId),
    );
  }

  QcFormData _formDataFor(QcNextItem item) {
    return _formDataByItemId.putIfAbsent(
      item.id,
      () => QcFormData(
        receivedQty: item.qtyReceived,
        expiryDate: DateTime(2025, 12, 31),
      ),
    );
  }

  void _updateFormData(int itemId, QcFormData data) {
    setState(() => _formDataByItemId[itemId] = data);
  }

  Future<void> _captureCondition(QcNextItem item) async {
    final result = await Navigator.push<WhCaptureResult>(
      context,
      WhCameraPage.route(
        title: 'Capture Condition',
        subtitle: 'Foto kondisi barang yang diterima',
        maxPhotos: 1,
        withNotesField: false,
      ),
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final bytes = await result.files.first.readAsBytes();
    setState(() {
      _photoByItemId[item.id] = base64Encode(bytes);
    });
  }

  Future<void> _scanBarcode(QcNextItem item) async {
    final scannedCode = await Navigator.of(context).push<String>(
      WHScannerPage.route(
        title: 'Verify Barcode Item',
        subtitle: 'Scan barcode ${item.productDetail.sku}',
      ),
    );

    if (!mounted || scannedCode == null) return;

    if (scannedCode.trim() != item.productDetail.barcode.trim()) {
      WHSnackBar.showError(context, 'Barcode does not match this item.');
      return;
    }

    setState(() => _verifiedBarcodeItemIds.add(item.id));
    WHSnackBar.showSuccess(context, 'Barcode verified successfully.');
  }

  void _submitCurrentItem(QcNextItem item) {
    final formData = _formDataFor(item);
    final photo = _photoByItemId[item.id];
    final mustVerifyBarcode = !formData.isUnreadableBarcode;

    if (mustVerifyBarcode && !_verifiedBarcodeItemIds.contains(item.id)) {
      WHSnackBar.showError(context, 'Please verify item barcode first.');
      return;
    }

    if (photo == null || photo.isEmpty) {
      WHSnackBar.showError(context, 'Please capture item condition first.');
      return;
    }

    final params = SubmitQcParams(
      poItemId: item.id,
      qtyReceived: _qtyReceivedFor(item, formData),
      condition: _conditionLabel(formData.condition),
      conditionNotes: _conditionNotesFor(formData),
      unreadableBarcode: formData.isUnreadableBarcode,
      expiryDate: formData.expiryDate ?? DateTime.now(),
      photo: photo,
    );

    _lastLoadedItem = item;
    setState(() => _isSubmitting = true);
    context.read<PurchaseOrderBloc>().add(SubmitQcEvent(params));
  }

  void _handleSubmitSuccess() {
    final submittedItem = _lastLoadedItem;
    if (submittedItem == null) {
      _fetchNextQcItem();
      return;
    }

    _formDataByItemId.remove(submittedItem.id);
    _photoByItemId.remove(submittedItem.id);
    _verifiedBarcodeItemIds.remove(submittedItem.id);

    if (submittedItem.nextItem == null) {
      WHSnackBar.showSuccess(context, 'Quality control completed.');
      Navigator.of(context).pop();
      return;
    }

    WHSnackBar.showSuccess(context, 'QC item saved.');
    _fetchNextQcItem();
  }

  int _qtyReceivedFor(QcNextItem item, QcFormData formData) {
    switch (formData.condition) {
      case QcCondition.good:
        return item.qtyExpected;
      case QcCondition.less:
        return formData.receivedQty;
      case QcCondition.damaged:
        return item.qtyExpected;
    }
  }

  String _conditionLabel(QcCondition condition) {
    switch (condition) {
      case QcCondition.good:
        return 'Good';
      case QcCondition.damaged:
        return 'Damaged';
      case QcCondition.less:
        return 'Less';
    }
  }

  String _conditionNotesFor(QcFormData formData) {
    if (formData.condition == QcCondition.good ||
        formData.condition == QcCondition.less) {
      return '-';
    }

    final notes = formData.conditionNotes.trim();
    return notes.isEmpty ? '-' : notes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseOrderBloc, PurchaseOrderState>(
      listener: (context, state) {
        if (state is SubmitQcSuccess) {
          setState(() => _isSubmitting = false);
          _handleSubmitSuccess();
          return;
        }

        if (state is PurchaseOrderError) {
          setState(() => _isSubmitting = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: const WHAppbar(title: 'UNLOADING & QC'),
        bottomNavigationBar: BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
          builder: (context, state) {
            if (state is! QcNextItemLoaded) {
              return const SizedBox.shrink();
            }

            return SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: WHButton(
                label: state.item.nextItem == null ? 'Finish QC' : 'Next Item',
                backgroundColor: WHColors.secondary3,
                icon: state.item.nextItem == null
                    ? Icons.check_circle_outline_outlined
                    : null,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting
                    ? null
                    : () => _submitCurrentItem(state.item),
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

            if (state is QcNextItemLoaded) {
              return _QualityControlContent(
                purchaseOrderNumber: widget.purchaseOrderNumber,
                item: state.item,
                formData: _formDataFor(state.item),
                isBarcodeVerified: _verifiedBarcodeItemIds.contains(
                  state.item.id,
                ),
                hasPhoto: _photoByItemId.containsKey(state.item.id),
                onFormChanged: (data) => _updateFormData(state.item.id, data),
                onBarcodeScan: () => _scanBarcode(state.item),
                onCapture: () => _captureCondition(state.item),
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

class _QualityControlContent extends StatelessWidget {
  const _QualityControlContent({
    required this.purchaseOrderNumber,
    required this.item,
    required this.formData,
    required this.isBarcodeVerified,
    required this.hasPhoto,
    required this.onFormChanged,
    required this.onBarcodeScan,
    required this.onCapture,
  });

  final String purchaseOrderNumber;
  final QcNextItem item;
  final QcFormData formData;
  final bool isBarcodeVerified;
  final bool hasPhoto;
  final ValueChanged<QcFormData> onFormChanged;
  final VoidCallback onBarcodeScan;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final upcomingProduct = item.nextItem == null
        ? null
        : UpcomingProduct(
            sku: item.nextItem!.sku,
            productName: item.nextItem!.productName,
            expectedQty: item.nextItem!.qtyExpected,
            unit: item.nextItem!.unitOfMeasure,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        QcHeader(
          typeLabel: 'PURCHASE ORDER',
          orderNumber: purchaseOrderNumber,
          currentItem: item.currentItemNumber,
          totalItems: item.totalItems,
        ),
        const SizedBox(height: 16),
        QcProductCard(
          sku: item.sku,
          productName: item.productName,
          expectedQty: item.qtyExpected,
          unitOfMeasure: item.productDetail.unitOfMeasure,
        ),
        const SizedBox(height: 16),
        QcFormCard(
          data: formData,
          onChanged: onFormChanged,
          onCapture: onCapture,
          hasCapturedPhoto: hasPhoto,
        ),
        const SizedBox(height: 10),
        QcBarcodeCard(isVerified: isBarcodeVerified, onScan: onBarcodeScan),
        if (upcomingProduct != null) ...[
          const SizedBox(height: 16),
          Text('Upcoming', style: WHTypography.bodyText.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          UpcomingProductCard(product: upcomingProduct),
        ],
      ],
    );
  }
}
