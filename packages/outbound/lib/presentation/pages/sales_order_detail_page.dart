import 'package:auth/domain/entities/app_permissions.dart';
import 'package:auth/presentation/bloc/auth_bloc.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:outbound/data/datasources/region_api_datasource.dart';
import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/models/pick_flow_item.dart';
import 'package:outbound/presentation/models/sales_order_status_view.dart';
import 'package:outbound/presentation/pages/create_sales_order_page.dart';
import 'package:outbound/presentation/pages/picking_page.dart';
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
  String? _provinceName;
  String? _cityName;
  bool _startedFromTracking = false;
  bool _isPrintingLabel = false;
  RegionApiDatasource get _regionApi => GetIt.instance<RegionApiDatasource>();
  SalesOrderApiDatasource get _salesOrderApi =>
      GetIt.instance<SalesOrderApiDatasource>();

  @override
  void initState() {
    super.initState();
    _trackingNumber = _clean(widget.order.trackingNumber);
    _trackingController.text = _trackingNumber ?? '';
    _resolveRegionLabels();
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  String get _status {
    if (salesOrderViewStatus(widget.order) == OrderStatus.completed) {
      return 'Completed';
    }
    if (_trackingNumber != null || _startedFromTracking) {
      return 'Active';
    }
    return salesOrderStatusLabel(salesOrderViewStatus(widget.order));
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
    context.read<SalesOrderBloc>().add(
      UpdateSalesOrderTrackingEvent(id: widget.order.id, trackingNumber: value),
    );
  }

  Future<void> _editSalesOrder() async {
    final bloc = context.read<SalesOrderBloc>();
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CreateSalesOrderPage(initialOrder: widget.order),
        ),
      ),
    );

    if (!mounted || updated != true) return;
    Navigator.of(context).pop();
  }

  Future<void> _confirmDeleteSalesOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _DeleteSalesOrderDialog(soNumber: widget.order.soNumber),
    );

    if (confirmed != true || !mounted) return;

    context.read<SalesOrderBloc>().add(DeleteSalesOrderEvent(widget.order.id));
    Navigator.of(context).pop();
  }

  Future<void> _printLabel() async {
    if (_isPrintingLabel) return;

    setState(() => _isPrintingLabel = true);
    try {
      final path = await _salesOrderApi.downloadLabelPdf(
        widget.order.id,
        soNumber: widget.order.soNumber,
      );
      if (!mounted) return;
      WHSnackBar.showSuccess(context, 'Label berhasil diunduh: $path');
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SalesOrderDetailPage] failed to download label PDF: $e');
      WHSnackBar.showError(context, 'Gagal print label Sales Order.');
    } finally {
      if (mounted) setState(() => _isPrintingLabel = false);
    }
  }

  Future<void> _resolveRegionLabels() async {
    final provinceCode = _clean(widget.order.provinceCode);
    final cityCode = _clean(widget.order.cityCode);

    try {
      String? provinceName;
      String? cityName;

      if (provinceCode != null) {
        final provinces = await _regionApi.getProvinces();
        provinceName = _findRegionName(provinces, provinceCode);
      }

      if (provinceCode != null && cityCode != null) {
        final cities = await _regionApi.getCities(provinceCode);
        cityName = _findRegionName(cities, cityCode);
      }

      if (!mounted) return;
      setState(() {
        _provinceName = provinceName;
        _cityName = cityName;
      });
    } catch (e) {
      debugPrint('[SalesOrderDetailPage] failed to resolve region labels: $e');
    }
  }

  String? _findRegionName(List<Map<String, dynamic>> rows, String code) {
    final target = code.trim().toLowerCase();
    for (final row in rows) {
      final rowCode = _valueFrom(row, const [
        'code',
        'Code',
        'provinceCode',
        'cityCode',
        'districtCode',
        'id',
        'Id',
      ])?.trim().toLowerCase();

      if (rowCode == target) {
        final name =
            _valueFrom(row, const [
              'name',
              'Name',
              'provinceName',
              'cityName',
              'districtName',
            ]) ??
            code;
        return _cleanRegionName(name);
      }
    }
    return null;
  }

  String? _valueFrom(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) return value.toString();
    }
    return null;
  }

  String _cleanRegionName(String value) {
    return value
        .replaceFirst(RegExp(r'^Kabupaten\s+', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^Kota\s+', caseSensitive: false), '')
        .trim();
  }

  String? _backendRegionLabel(String? value) {
    final cleanValue = _clean(value);
    if (cleanValue == null) return null;
    return _cleanRegionName(cleanValue);
  }

  @override
  Widget build(BuildContext context) {
    // Permission check – ikuti pola product_list_page
    final AuthState = context.read<AuthBloc>().state;
    final session =
        AuthState is AuthenticatedState ? AuthState.session : null;

    final canEdit     = session?.hasPermission(AppPermissions.soEdit)      ?? false;
    final canDelete   = session?.hasPermission(AppPermissions.soDelete)    ?? false;
    final canTracking = session?.hasPermission(AppPermissions.soInvoice)   ?? false;
    final canPick     = session?.hasPermission(AppPermissions.pickExecute) ?? false;

    final bottomAction = _bottomAction(canPick: canPick);

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
            soNumber: widget.order.soNumber,
            createdAt: _formatDate(widget.order.orderDate),
            status: _status,
            showActions: _isQueued && !_isEditingTracking && !_hasTracking,
            canEdit: canEdit,
            canDelete: canDelete,
            onDelete: _confirmDeleteSalesOrder,
            onEdit: _editSalesOrder,
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
            province:
                _backendRegionLabel(widget.order.provinceName) ??
                _provinceName ??
                _provinceLabel(widget.order),
            city:
                _backendRegionLabel(widget.order.cityName) ??
                _cityName ??
                _cityLabel(widget.order),
            postalCode: widget.order.postalCode ?? '-',
          ),
          const SizedBox(height: 8),
          _NoteCard(note: widget.order.note),
          if (!_hasTracking && canTracking) ...[
            const SizedBox(height: 6),
            SoTrackingInputCard(
              controller: _trackingController,
              isEditing: _isEditingTracking,
              onStart: () => setState(() => _isEditingTracking = true),
              onSave: _confirmTracking,
            ),
          ],
          if (_isCompleted) ...[
            const SizedBox(height: 24),
            _PrintLabelButton(
              isLoading: _isPrintingLabel,
              onPressed: _printLabel,
            ),
          ],
          const SizedBox(height: 24),
          SoProductListSection(products: widget.order.items),
        ],
      ),
      bottomNavigationBar: bottomAction,
    );
  }

  Widget? _bottomAction({bool canPick = true}) {
    if (_isActive && canPick) {
      return _StickyActionButton(
        label: 'Start Picking',
        icon: Icons.check_circle_outline,
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => PickingPage(
                orderId: widget.order.id,
                soNumber: widget.order.soNumber,
                items: _pickItems(widget.order),
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      );
    }
    return null;
  }
}

class _PrintLabelButton extends StatelessWidget {
  const _PrintLabelButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WhPrimaryButton(
      text: isLoading ? 'Downloading Label...' : 'Print Label Sales Order',
      icon: Icons.print_outlined,
      onPressed: isLoading ? null : onPressed,
    );
  }
}

class _DeleteSalesOrderDialog extends StatelessWidget {
  const _DeleteSalesOrderDialog({required this.soNumber});

  final String soNumber;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF3F3F3),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 102,
              color: Color(0xFFC71920),
            ),
            const SizedBox(height: 22),
            const Text(
              'Are you sure want to delete this\nSales Order?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                height: 1.16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              soNumber,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 26,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFC0C4),
                  foregroundColor: const Color(0xFFC71920),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Colors.black),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final displayNote = note?.trim();

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
            displayNote == null || displayNote.isEmpty ? '-' : displayNote,
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
        height: 56,
        child: WhPrimaryButton(text: label, icon: icon, onPressed: onPressed),
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

String _address(SalesOrder order) {
  final value = order.shippingAddress.trim();
  if (value.isEmpty) {
    return 'Jl. Raya ITS, Gedung D4, Keputih, Sukolilo, Surabaya, East Java 36812';
  }
  return value;
}

String _provinceLabel(SalesOrder order) {
  final code = order.provinceCode?.trim();
  if (code == null || code.isEmpty) return 'Jawa Timur';
  if (code == '32') return 'Jawa Barat';
  if (code == '35') return 'Jawa Timur';
  if (code == '51') return 'Bali';
  return code;
}

String _cityLabel(SalesOrder order) {
  final code = order.cityCode?.trim();
  if (code == null || code.isEmpty) return 'Surabaya';
  if (code == '32.15') return 'Karawang';
  if (code == '35.78') return 'Surabaya';
  if (code == '51.03') return 'Badung';
  return code;
}

String? _clean(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

List<PickItem> _pickItems(SalesOrder order) {
  if (order.items.isEmpty) return const [];

  return order.items.asMap().entries.map((entry) {
    final item = entry.value;
    final qty = item.qtyOrdered;
    final suggestedLocations = item.suggestedLocations;

    return PickItem(
      sku: _clean(item.sku) ?? item.productId.toString(),
      productName: _clean(item.productName) ?? 'Product ${item.productId}',
      expectedQty: qty,
      salesOrderItemId: item.id,
      barcode: _clean(item.barcode),
      unitOfMeasure: _clean(item.unitOfMeasure) ?? 'Box',
      locations: suggestedLocations
          .map(
            (location) => PickLocation(
              zone: location.zoneCode,
              aisle: 'Aisle ${location.aisle}',
              shelf: location.shelfCode,
              shelfId: location.shelfId,
              requiredQty: qty.clamp(1, location.availableQuantity).toInt(),
              unit: _clean(item.unitOfMeasure) ?? 'Box',
            ),
          )
          .toList(),
    );
  }).toList();
}
