import 'package:core_services/api/api_client.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product/product.dart';
import 'package:zone/domain/entities/shelf_detail.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';
import 'package:zone/presentation/widgets/download_qr.dart';
import 'package:zone/presentation/widgets/filled_status_banner.dart';
import 'package:zone/presentation/widgets/format_dialog_qr.dart';
import 'package:zone/presentation/widgets/location_identity_card.dart';

class ShelfDetailPage extends StatefulWidget {
  const ShelfDetailPage({super.key, required this.shelfId});

  final int shelfId;

  @override
  State<ShelfDetailPage> createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> {
  bool _loading = false;

  void _loadShelfData() {
    context.read<ZoneBloc>().add(
      GetShelfDetailsEvent(shelfId: widget.shelfId),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadShelfData();
    });
  }

  Future<void> _downloadQr(ShelfDetail shelfDetail) async {
    final qrUrl = _resolveQrUrl(shelfDetail.qrCodePath);
    if (qrUrl.isEmpty) {
      WHSnackBar.showError(context, 'QR code path tidak tersedia');
      return;
    }

    try {
      await QRDownloader().downloadAndSave(qrUrl);
      if (!mounted) return;
      WHSnackBar.showSuccess(context, 'Berhasil diunduh');
    } catch (e) {
      if (!mounted) return;
      WHSnackBar.showError(context, 'Gagal mengunduh: $e');
    }
  }

  String _resolveQrUrl(String qrCodePath) {
    if (qrCodePath.isEmpty) return '';
    if (qrCodePath.startsWith('http')) return qrCodePath;

    final baseUrl = ApiClient().dio.options.baseUrl;
    if (baseUrl.isEmpty) return qrCodePath;

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$normalizedBase${qrCodePath.startsWith('/') ? '' : '/'}$qrCodePath';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZoneBloc, ZoneState>(
      builder: (context, state) {
        final shelfDetail =
            state is ShelfDetailLoaded && state.shelfId == widget.shelfId
            ? state.shelfDetail
            : null;

        return Scaffold(
          appBar: WHAppbar(title: 'Shelf Detail'),
          backgroundColor: WHColors.background,
          body: _buildBody(state, shelfDetail),
        );
      },
    );
  }

  Widget _buildBody(ZoneState state, ShelfDetail? shelfDetail) {
    debugPrint(
      '[ShelfDetailPage] state: $state, shelfDetail: $shelfDetail, shelfId: ${widget.shelfId}',
    );

    if (state is ZoneLoading && shelfDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ZoneError && shelfDetail == null) {
      return Center(child: Text('Failed to load shelf: ${state.message}'));
    }

    if (shelfDetail == null) {
      return const Center(child: Text('No shelf data available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (shelfDetail.currentVolume > 0) ...[
          FilledStatusBanner(isFilled: true),
          const SizedBox(height: 12),
        ],
        LocationIdentityCard(
          parentZone: shelfDetail.shelfCode.split('-').first,
          parentAisle: 'Aisle ${shelfDetail.aisle}',
          rackId: shelfDetail.shelfCode,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _loading
              ? null
              : () async {
                  final option = await FormatDialogQr.show(context);
                  if (option == null) return;

                  setState(() => _loading = true);
                  try {
                    final savedPath = await QRDownloader().downloadShelf(
                      shelfId: widget.shelfId,
                      format: option,
                      code: shelfDetail.shelfCode,
                    );
                    if (!mounted) return;
                    WHSnackBar.showSuccess(context, 'Berhasil diunduh: $savedPath');
                  } catch (e) {
                    if (!mounted) return;
                    WHSnackBar.showError(context, 'Gagal mengunduh: $e');
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
          icon: const Icon(Icons.download, size: 16, color: WHColors.surface),
          label: Text(
            'Download QR',
            style: WHTypography.bodyText.copyWith(color: WHColors.surface),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: WHColors.secondary3,
          ),
        ),
        const SizedBox(height: 16),
        Text('Product List', style: WHTypography.heading1),
        const SizedBox(height: 16),
        if (shelfDetail.stocks.isEmpty)
          const Text('No products found on this shelf')
        else
          ...shelfDetail.stocks.map(
            (stock) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(
                product: Product(
                  id: stock.product.id.toString(),
                  productName: stock.product.productName,
                  sku: stock.product.sku,
                  barcode: stock.product.barcode,
                  unitOfMeasure: stock.product.unitOfMeasure,
                ),
                shelfStock: stock.quantity,
                onView: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        productId: stock.product.id.toString(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}