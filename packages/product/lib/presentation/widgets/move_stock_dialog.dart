import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:zone/domain/entities/zone.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';

class MoveStockResult {
  const MoveStockResult({required this.toShelfId});

  final int toShelfId;
}

Future<MoveStockResult?> showMoveStockDialog(
  BuildContext context, {
  required int fromShelfId,
  required String fromShelfCode,
  required int currentQuantity,
  required String productId,
}) async {
  return showDialog<MoveStockResult>(
    context: context,
    builder: (ctx) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProductBloc>()),
        BlocProvider.value(value: context.read<ZoneBloc>()),
      ],
      child: _MoveStockDialog(
        fromShelfId: fromShelfId,
        fromShelfCode: fromShelfCode,
        currentQuantity: currentQuantity,
        productId: productId,
      ),
    ),
  );
}

class _MoveStockDialog extends StatefulWidget {
  const _MoveStockDialog({
    required this.fromShelfId,
    required this.fromShelfCode,
    required this.currentQuantity,
    required this.productId,
  });

  final int fromShelfId;
  final String fromShelfCode;
  final int currentQuantity;
  final String productId;

  @override
  State<_MoveStockDialog> createState() => _MoveStockDialogState();
}

class _MoveStockDialogState extends State<_MoveStockDialog> {
  Zone? _selectedZone;
  String? _selectedShelfCode;
  int? _pendingToShelfId;

  static const _primaryOrange = WHColors.secondary3;
  static const _borderColor = WHColors.grey;

  @override
  void initState() {
    super.initState();
    context.read<ZoneBloc>().add(GetZonesEvent());
  }

  Future<void> _openQrScanner() async {
    final scannedCode = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerPage()));

    if (scannedCode == null || scannedCode.isEmpty) return;

    _applyZoneByCode(scannedCode.trim());
  }

  void _applyZoneByCode(String raw) {
    final blocState = context.read<ZoneBloc>().state;
    final zones = blocState is ZoneLoaded ? blocState.zones : <Zone>[];

    final rawLower = raw.trim().toLowerCase();

    // First, try to match as complete shelf code
    for (final zone in zones) {
      final zoneShelves = zone.shelves ?? [];
      for (final shelf in zoneShelves) {
        if (shelf.shelfCode.toLowerCase() == rawLower) {
          // Found direct shelf match
          setState(() {
            _selectedZone = zone;
            _selectedShelfCode = shelf.shelfCode;
            _pendingToShelfId = int.tryParse(shelf.id);
          });
          return;
        }
      }
    }

    // Try matching zone code prefix pattern (e.g., "KTS-1-1")
    final parts = raw.trim().split('-');
    if (parts.length >= 2) {
      for (final zone in zones) {
        if (zone.zoneCode.trim().toLowerCase() == parts[0].toLowerCase()) {
          // Found zone match - load details
          context.read<ZoneBloc>().add(GetZoneDetailsEvent(zoneId: zone.id));

          // Store pending info
          _pendingZoneCode = zone.zoneCode;
          _pendingZoneId = zone.id;
          if (parts.length >= 2) {
            _pendingAisle = int.tryParse(parts[1]);
          }
          if (parts.length >= 3) {
            _pendingShelfNumber = int.tryParse(parts[2]);
          }

          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shelf "$raw" tidak ditemukan'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String? _pendingZoneCode;
  int? _pendingZoneId;
  int? _pendingAisle;
  int? _pendingShelfNumber;

  void _findShelfInZone(Zone zone) {
    if (_pendingAisle == null && _pendingShelfNumber == null) return;

    final shelves = zone.shelves ?? [];
    for (final shelf in shelves) {
      bool matches = false;

      if (_pendingAisle != null && _pendingShelfNumber != null) {
        // Full pattern: zone-aisle-shelfNumber
        matches =
            shelf.aisle == _pendingAisle &&
            shelf.shelfCode.endsWith('-$_pendingShelfNumber');
      } else if (_pendingShelfNumber != null) {
        // Just shelf number: e.g., "A-1"
        matches =
            shelf.shelfCode.endsWith('-$_pendingShelfNumber') ||
            shelf.shelfCode == '$_pendingShelfNumber';
      }

      if (matches) {
        setState(() {
          _selectedZone = zone;
          _selectedShelfCode = shelf.shelfCode;
          _pendingToShelfId = int.tryParse(shelf.id);
        });
        return;
      }
    }

    // If we found the zone but not shelf, still show zone and let user know
    setState(() {
      _selectedZone = zone;
      _selectedShelfCode = null;
      _pendingToShelfId = null;
    });
  }

  void _submitMove() {
    if (_pendingToShelfId == null) return;

    context.read<ProductBloc>().add(
      MoveStockLocationEvent(
        productId: widget.productId,
        fromShelfId: widget.fromShelfId,
        toShelfId: _pendingToShelfId!,
        quantity: widget.currentQuantity,
      ),
    );

    Navigator.of(context).pop(MoveStockResult(toShelfId: _pendingToShelfId!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZoneBloc, ZoneState>(
      listener: (context, state) {
        if (state is ZoneLoaded && state.zones.isNotEmpty) {
          // Check if this is from GetZoneDetailsEvent
          if (_pendingZoneId != null) {
            for (final zone in state.zones) {
              if (zone.id == _pendingZoneId) {
                _findShelfInZone(zone);
                return;
              }
            }
          }
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  const Icon(Icons.swap_horiz, color: _primaryOrange, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Move Stock',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: WHColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(null),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: WHColors.grey),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                'From: ${widget.fromShelfCode} (${widget.currentQuantity} items)',
                style: const TextStyle(fontSize: 12, color: WHColors.grey),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 16),

              // ── Selected Target Info ──
              if (_selectedZone != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WHColors.primary5.withValues(alpha: 0.1),
                    border: Border.all(color: WHColors.primary4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: WHColors.primary3,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Target Selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WHColors.primary3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Zone: ${_selectedZone!.zoneCode} - ${_selectedZone!.zoneName}',
                        style: WHTypography.bodyText,
                      ),
                      if (_selectedShelfCode != null)
                        Text(
                          'Shelf: $_selectedShelfCode',
                          style: WHTypography.bodyText,
                        ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WHColors.surface,
                    border: Border.all(color: WHColors.grey5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: WHColors.grey2,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Scan target shelf QR code to move all stock.',
                          style: WHTypography.caption.copyWith(
                            color: WHColors.grey2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Actions ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: _borderColor, width: 1.5),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: WHColors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openQrScanner,
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        _selectedZone == null ? 'Scan Target' : 'Rescan',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),

              if (_pendingToShelfId != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitMove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Move All (${widget.currentQuantity})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── QR Scanner Page ──────────────────────────────────────────────────────────

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;
    if (value == null || value.isEmpty) return;

    _hasScanned = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Target Shelf QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: WHColors.secondary3, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Scan QR Code shelf tujuan',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
