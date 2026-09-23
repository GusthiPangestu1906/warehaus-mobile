import 'package:auth/domain/entities/app_permissions.dart';
import 'package:auth/presentation/bloc/auth_bloc.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/entities/po_item.dart';
import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/pages/create_purchase_order_page.dart';
import 'package:inbound/presentation/pages/put_away_page.dart';
import 'package:inbound/presentation/pages/quality_control_page.dart';
import 'package:inbound/presentation/widgets/purchase_order_detail/po_detail_header.dart';
import 'package:inbound/presentation/widgets/purchase_order_detail/po_info_cards.dart';
import 'package:inbound/presentation/widgets/purchase_order_detail/po_invoice_input_card.dart';
import 'package:inbound/presentation/widgets/purchase_order_detail/po_product_list_section.dart';
import 'package:intl/intl.dart';

enum PurchaseOrderDetailResult { deleted, invoiceUpdated }

class PurchaseOrderDetailPage extends StatefulWidget {
  const PurchaseOrderDetailPage({super.key, required this.purchaseOrderId});

  final int purchaseOrderId;

  @override
  State<PurchaseOrderDetailPage> createState() =>
      _PurchaseOrderDetailPageState();
}

class _PurchaseOrderDetailPageState extends State<PurchaseOrderDetailPage> {
  final TextEditingController _invoiceController = TextEditingController();
  bool _isInvoiceInputVisible = false;
  bool _isDownloadingPdf = false;
  String? _invoiceNumber;
  String? _localStatus;
  List<PoItem>? _localItems;
  PurchaseOrder? _lastPurchaseOrder;

  @override
  void initState() {
    super.initState();
    context.read<PurchaseOrderBloc>().add(
      GetPurchaseOrderDetailEvent(widget.purchaseOrderId),
    );
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    super.dispose();
  }

  void _showInvoiceInput() {
    setState(() => _isInvoiceInputVisible = true);
  }

  Future<void> _saveInvoice() async {
    final invoiceNumber = _invoiceController.text.trim();
    final confirmed = await WHInfoDialog.show(
      context: context,
      title: 'Are you sure want the entered invoice number is correct?',
      identifier: invoiceNumber,
      confirmLabel: 'Save',
      cancelLabel: 'Cancel',
    );

    if (!mounted || confirmed != true) return;

    context.read<PurchaseOrderBloc>().add(
      UpdateInvoiceEvent(widget.purchaseOrderId, invoiceNumber),
    );
  }

  Future<void> _showDeleteModal(PurchaseOrder purchaseOrder) async {
    final confirmed = await WHDeleteDialog.show(
      context: context,
      title: 'Are you sure want to delete this Purchase Order?',
      identifier: purchaseOrder.poNumber,
      barrierDismissible: false,
    );

    if (!mounted || confirmed != true) return;

    context.read<PurchaseOrderBloc>().add(
      DeletePurchaseOrderEvent(purchaseOrder.id),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditForm(PurchaseOrder purchaseOrder) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CreatePurchaseOrderPage(initialPurchaseOrder: purchaseOrder),
      ),
    );

    if (!mounted || updated != true) return;

    context.read<PurchaseOrderBloc>().add(
      GetPurchaseOrderDetailEvent(purchaseOrder.id),
    );
  }

  void _downloadPurchaseOrderPdf(PurchaseOrder purchaseOrder) {
    if (_isDownloadingPdf) return;

    setState(() => _isDownloadingPdf = true);
    context.read<PurchaseOrderBloc>().add(
      DownloadPurchaseOrderPdfEvent(purchaseOrder.id, purchaseOrder.poNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Permission check – ikuti pola product_list_page
    final authState = context.read<AuthBloc>().state;
    final session =
        authState is AuthenticatedState ? authState.session : null;

    final canEdit    = session?.hasPermission(AppPermissions.poEdit)    ?? false;
    final canDelete  = session?.hasPermission(AppPermissions.poDelete)  ?? false;
    final canInvoice = session?.hasPermission(AppPermissions.poEdit)    ?? false;
    final canQc      = session?.hasPermission(AppPermissions.qcExecute) ?? false;
    final canPutAway = session?.hasPermission(AppPermissions.putExecute) ?? false;

    return BlocListener<PurchaseOrderBloc, PurchaseOrderState>(
      listener: (context, state) {
        if (state is DeletePurchaseOrderSuccess) {
          Navigator.of(context).pop(PurchaseOrderDetailResult.deleted);
        }

        if (state is UpdateInvoiceSuccess) {
          Navigator.of(context).pop(PurchaseOrderDetailResult.invoiceUpdated);
        }

        if (state is DownloadPurchaseOrderPdfSuccess) {
          setState(() => _isDownloadingPdf = false);
          WHSnackBar.showSuccess(context, 'PDF downloaded: ${state.filePath}');
        }

        if (state is PurchaseOrderActionError) {
          setState(() => _isDownloadingPdf = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: const WHAppbar(title: 'Detail Purchase Order'),
        body: SafeArea(
          child: BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
            builder: (context, state) {
              if (state is PurchaseOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PurchaseOrderError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: WHError(message: state.message),
                  ),
                );
              }

              if (state is PurchaseOrderDetailLoaded) {
                final purchaseOrder = state.purchaseOrder;
                _lastPurchaseOrder = purchaseOrder;
                return _buildDetailContent(
                  purchaseOrder,
                  canEdit: canEdit,
                  canDelete: canDelete,
                );
              }

              if (_lastPurchaseOrder != null) {
                return _buildDetailContent(
                  _lastPurchaseOrder!,
                  canEdit: canEdit,
                  canDelete: canDelete,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
          builder: (context, state) {
            if (state is! PurchaseOrderDetailLoaded) {
              return const SizedBox.shrink();
            }
            return _buildBottomAction(
              state.purchaseOrder,
              canInvoice: canInvoice,
              canQc: canQc,
              canPutAway: canPutAway,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailContent(
    PurchaseOrder purchaseOrder, {
    bool canEdit = true,
    bool canDelete = true,
  }) {
    final status = _effectiveStatus(purchaseOrder);
    final isQueued = _isQueued(status);
    final isCompleted = _isCompleted(status);
    final items = _localItems ?? purchaseOrder.items;
    final invoiceNumber = _invoiceNumber ?? purchaseOrder.invoiceNumber;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PoDetailHeader(
          poNumber: purchaseOrder.poNumber,
          status: status,
          supplierName: purchaseOrder.supplierName,
          carrier: purchaseOrder.carrier,
          showActions: isQueued && !_isInvoiceInputVisible,
          canEdit: canEdit,
          canDelete: canDelete,
          onDelete: () => _showDeleteModal(purchaseOrder),
          onEdit: () => _openEditForm(purchaseOrder),
          createdAt: purchaseOrder.createdAt,
        ),
        const SizedBox(height: 12),
        if (_isInvoiceInputVisible) ...[
          PoInvoiceInputCard(
            controller: _invoiceController,
            onSave: _saveInvoice,
          ),
          const SizedBox(height: 12),
        ] else ...[
          PoInfoCards(
            etaLabel: _formatDate(purchaseOrder.eta),
            supplierName: purchaseOrder.supplierName,
            carrier: purchaseOrder.carrier,
            invoiceNumber: invoiceNumber,
          ),
          const SizedBox(height: 16),
        ],
        if (isCompleted) ...[
          WHButton(
            label: 'Print Label Purchase Order',
            icon: Icons.print_outlined,
            backgroundColor: WHColors.primary3,
            isLoading: _isDownloadingPdf,
            onPressed: _isDownloadingPdf
                ? null
                : () => _downloadPurchaseOrderPdf(purchaseOrder),
          ),
          const SizedBox(height: 12),
        ],
        PoProductListSection(
          products: items,
          isCompleted: isCompleted,
          onProductTap: _showQcResult,
        ),
      ],
    );
  }

  Widget _buildBottomAction(
    PurchaseOrder purchaseOrder, {
    bool canInvoice = true,
    bool canQc = true,
    bool canPutAway = true,
  }) {
    final status = _effectiveStatus(purchaseOrder);

    if (_isQueued(status) && !_isInvoiceInputVisible && canInvoice) {
      return _BottomAction(
        child: WHButton(
          label: 'Arrived',
          icon: Icons.check_circle_outlined,
          backgroundColor: WHColors.secondary3,
          onPressed: _showInvoiceInput,
        ),
      );
    }

    if (_isActive(status)) {
      if (!purchaseOrder.isQcCompleted && canQc) {
        return _BottomAction(
          child: WHButton(
            label: 'Start Quality Control',
            icon: Icons.fact_check_outlined,
            backgroundColor: WHColors.secondary3,
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => QualityControlPage(
                        purchaseOrderId: purchaseOrder.id,
                        purchaseOrderNumber: purchaseOrder.poNumber,
                      ),
                    ),
                  )
                  .then((_) {
                    if (!mounted) return;
                    context.read<PurchaseOrderBloc>().add(
                      GetPurchaseOrderDetailEvent(purchaseOrder.id),
                    );
                  });
            },
          ),
        );
      } else if (purchaseOrder.isQcCompleted && canPutAway) {
        return _BottomAction(
          child: WHButton(
            label: 'Start Put Away',
            icon: Icons.local_shipping_outlined,
            backgroundColor: WHColors.secondary3,
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => PutAwayPage(
                        purchaseOrderId: purchaseOrder.id,
                        purchaseOrderNumber: purchaseOrder.poNumber,
                      ),
                    ),
                  )
                  .then((_) {
                    if (!mounted) return;
                    context.read<PurchaseOrderBloc>().add(
                      GetPurchaseOrderDetailEvent(purchaseOrder.id),
                    );
                  });
            },
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  void _showQcResult(PoItem item) {
    if (item.qcStatus == null) return;

    final productCode =
        item.productCode ?? 'PRD-${item.productId.toString().padLeft(4, '0')}';
    _showSnackBar('$productCode: ${_qcStatusLabel(item.qcStatus!)}');
  }

  String _effectiveStatus(PurchaseOrder purchaseOrder) {
    return _localStatus ?? purchaseOrder.status;
  }

  bool _isQueued(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'pending' || normalized == 'queued';
  }

  bool _isActive(String status) {
    return status.trim().toLowerCase() == 'active';
  }

  bool _isCompleted(String status) {
    return status.trim().toLowerCase() == 'completed' ||
        status.trim().toLowerCase() == 'success';
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd MMM yyyy').format(value);
  }

  String _qcStatusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'damage':
        return 'Damage';
      case 'less':
        return 'Less';
      case 'good':
      default:
        return 'Good';
    }
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: child,
    );
  }
}
