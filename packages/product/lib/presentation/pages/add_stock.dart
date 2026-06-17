import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:product/domain/entities/product.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';
import 'package:zone/domain/entities/zone.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';

class AddStockPage extends StatefulWidget {
  final Product product;

  const AddStockPage({super.key, required this.product});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');

  List<Zone> _zones = const [];
  Zone? _selectedZoneDetail;
  int? _selectedZoneId;
  int? _selectedAisle;
  int? _selectedShelfId;
  bool _isSubmitting = false;
  int? _pendingAisle;
  int? _pendingShelfNumber;

  static const _primaryOrange = WHColors.secondary3;
  static const _borderColor = WHColors.grey;
  static const _hintColor = WHColors.grey;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ZoneBloc>().add(GetZonesEvent());
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // ── QR Scanner ────────────────────────────────────────────────────────────

  /// Buka halaman scanner, tunggu hasil zoneCode-nya.
  Future<void> _openQrScanner() async {
    final scannedCode = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerPage()));

    if (scannedCode == null || scannedCode.isEmpty) return;

    _applyZoneByCode(scannedCode.trim());
  }

  /// Cocokkan zoneCode hasil scan dengan daftar zona yang sudah di-load.
  void _applyZoneByCode(String raw) {
    final blocState = context.read<ZoneBloc>().state;
    final stateZones = blocState is ZoneLoaded ? blocState.zones : <Zone>[];
    final searchList = _zones.isNotEmpty ? _zones : stateZones;

    final parts = raw.trim().split('-');

    Zone? matched;
    int? parsedAisle;
    int? parsedShelf;

    // Coba cocokkan zone code dari kiri ke kanan
    // "KTS-1-1" → coba "KTS", lalu "KTS-1", lalu "KTS-1-1"
    for (int i = 1; i <= parts.length; i++) {
      final candidate = parts.sublist(0, i).join('-').toLowerCase();
      final remaining = parts.sublist(i);

      for (final z in searchList) {
        if (z.zoneCode.trim().toLowerCase() == candidate) {
          matched = z;
          if (remaining.isNotEmpty) parsedAisle = int.tryParse(remaining[0]);
          if (remaining.length >= 2) parsedShelf = int.tryParse(remaining[1]);
          break;
        }
      }
      if (matched != null) break;
    }

    if (matched == null) {
      WHSnackBar.showError(context, 'Zone "$raw" tidak ditemukan');
      return;
    }

    // Simpan pending aisle & shelf, akan dipakai setelah zone detail load
    _pendingAisle = parsedAisle;
    _pendingShelfNumber = parsedShelf;

    _onZoneSelected(matched.id); // trigger GetZoneDetailsEvent

    WHSnackBar.showInfo(context, 'Zone ${matched.zoneCode} dipilih dari QR');
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedShelfId == null) return;

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) return;

    setState(() => _isSubmitting = true);

    context.read<ProductBloc>().add(
      AddStockLocationEvent(
        productId: widget.product.id,
        shelfId: _selectedShelfId!,
        quantity: quantity,
      ),
    );
  }

  void _onZoneSelected(int? zoneId) {
    setState(() {
      _selectedZoneId = zoneId;
      _selectedZoneDetail = null;
      _selectedAisle = null;
      _selectedShelfId = null;
    });

    if (zoneId != null) {
      context.read<ZoneBloc>().add(GetZoneDetailsEvent(zoneId: zoneId));
    }
  }

  void _syncZoneState(ZoneState state) {
    if (state is ZoneLoaded) {
      if (state.zones.length > 1 || _selectedZoneId == null) {
        _zones = state.zones;
        return;
      }

      if (state.zones.length == 1 && state.zones.first.id == _selectedZoneId) {
        _selectedZoneDetail = state.zones.first;

        // Auto-select aisle & shelf dari QR jika ada
        if (_pendingAisle != null) {
          final aisles = _getAisles(_selectedZoneDetail!);
          if (aisles.contains(_pendingAisle)) {
            _selectedAisle = _pendingAisle;

            if (_pendingShelfNumber != null) {
              final shelves = _getShelvesByAisle(
                _selectedZoneDetail!,
                _pendingAisle!,
              );
              // Cocokkan by shelf number di akhir kode (misal "A-1" → angka 1)
              for (final s in shelves) {
                if (s.code.endsWith('-$_pendingShelfNumber') ||
                    s.code == '$_pendingShelfNumber') {
                  _selectedShelfId = s.id;
                  break;
                }
              }
            }
          }
          _pendingAisle = null;
          _pendingShelfNumber = null;
        }
      }
    }
  }

  Zone? _getSelectedZone(List<Zone> zones) {
    for (final zone in zones) {
      if (zone.id == _selectedZoneId) return zone;
    }
    return null;
  }

  List<int> _getAisles(Zone zone) {
    final aisleSet = <int>{};
    final shelves = zone.shelves ?? const [];
    for (final shelf in shelves) {
      aisleSet.add(shelf.aisle);
    }
    if (aisleSet.isEmpty) {
      final aisles = zone.aisles ?? const [];
      for (final aisle in aisles) {
        aisleSet.add(aisle.aisleNumber);
      }
    }
    return aisleSet.toList()..sort();
  }

  List<_ShelfOption> _getShelvesByAisle(Zone zone, int aisle) {
    final shelves = zone.shelves ?? const [];
    final options = <_ShelfOption>[];
    for (final shelf in shelves) {
      if (shelf.aisle != aisle) continue;
      final shelfId = int.tryParse(shelf.id);
      if (shelfId == null) continue;
      options.add(_ShelfOption(id: shelfId, code: shelf.shelfCode));
    }
    return options..sort((a, b) => a.code.compareTo(b.code));
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _hintColor, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    filled: true,
    fillColor: WHColors.surface,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: _borderColor, width: 1.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: _borderColor, width: 1.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: _hintColor, width: 1.5),
    ),
  );

  Widget _stepperButton(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: 36,
      height: 38,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: Color(0xFF555555)),
        ),
      ),
    ),
  );

  Widget _numericInput(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(child: _label(label)),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor, width: 1.5),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepperButton('−', () {
                final current = int.tryParse(controller.text) ?? 0;
                controller.text = (current - 1).clamp(1, 999999).toString();
              }),
              Container(
                width: 80,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: _borderColor),
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Quantity required';
                    final value = int.tryParse(v);
                    if (value == null) return 'Invalid number';
                    if (value <= 0) return 'Quantity must be greater than 0';
                    return null;
                  },
                ),
              ),
              _stepperButton('+', () {
                final current = int.tryParse(controller.text) ?? 0;
                controller.text = (current + 1).toString();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: WHColors.textPrimary,
      ),
    ),
  );

  Widget _readOnlyProductField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Product'),
        TextFormField(
          initialValue: '${widget.product.sku} - ${widget.product.productName}',
          readOnly: true,
          decoration: _inputDecoration('Product'),
        ),
      ],
    );
  }

  // ── Zone / Aisle / Shelf section — ditambah tombol QR ────────────────────

  Widget _zoneAisleShelfSection(ZoneState zoneState) {
    if (zoneState is ZoneLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (zoneState is ZoneError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Failed to load zones: ${zoneState.message}',
          style: WHTypography.bodyText,
        ),
      );
    }

    if (zoneState is! ZoneLoaded || zoneState.zones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No zone data available', style: WHTypography.bodyText),
      );
    }

    final zones = _zones.isNotEmpty ? _zones : zoneState.zones;
    final selectedZone =
        _selectedZoneDetail ??
        _getSelectedZone(zoneState.zones) ??
        _getSelectedZone(zones);
    final aisleOptions = selectedZone == null
        ? <int>[]
        : _getAisles(selectedZone);
    final shelfOptions = (selectedZone == null || _selectedAisle == null)
        ? <_ShelfOption>[]
        : _getShelvesByAisle(selectedZone, _selectedAisle!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label + tombol QR sejajar ──────────────────────────────────────
        Row(
          children: [
            Expanded(child: _label('Zone')),
            InkWell(
              onTap: _openQrScanner,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 18,
                      color: _primaryOrange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Scan QR',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Zone dropdown ──────────────────────────────────────────────────
        DropdownButtonFormField<int>(
          initialValue: _selectedZoneId,
          decoration: _inputDecoration('Select zone'),
          items: zones
              .map(
                (zone) => DropdownMenuItem<int>(
                  value: zone.id,
                  child: Text('${zone.zoneCode} - ${zone.zoneName}'),
                ),
              )
              .toList(),
          onChanged: _onZoneSelected,
          validator: (value) => value == null ? 'Zone required' : null,
        ),
        const SizedBox(height: 16),

        _label('Aisle'),
        DropdownButtonFormField<int>(
          initialValue: _selectedAisle,
          decoration: _inputDecoration('Select aisle'),
          items: aisleOptions
              .map(
                (aisle) => DropdownMenuItem<int>(
                  value: aisle,
                  child: Text('Aisle $aisle'),
                ),
              )
              .toList(),
          onChanged: selectedZone == null
              ? null
              : (value) {
                  setState(() {
                    _selectedAisle = value;
                    _selectedShelfId = null;
                  });
                },
          validator: (value) => value == null ? 'Aisle required' : null,
        ),
        const SizedBox(height: 16),

        _label('Shelf'),
        DropdownButtonFormField<int>(
          initialValue: _selectedShelfId,
          decoration: _inputDecoration('Select shelf'),
          items: shelfOptions
              .map(
                (shelf) => DropdownMenuItem<int>(
                  value: shelf.id,
                  child: Text(shelf.code),
                ),
              )
              .toList(),
          onChanged: _selectedAisle == null
              ? null
              : (value) => setState(() => _selectedShelfId = value),
          validator: (value) => value == null ? 'Shelf required' : null,
        ),
        if (_selectedAisle != null && shelfOptions.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'No shelves available in selected aisle',
              style: WHTypography.caption,
            ),
          ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZoneBloc, ZoneState>(
      listener: (context, state) {
        _syncZoneState(state);
        if (state is ZoneError) {
          setState(() => _selectedZoneDetail = null);
        }
      },
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (!_isSubmitting) return;

          if (state is ProductError) {
            setState(() => _isSubmitting = false);
            WHSnackBar.showError(context, state.message);
          }

          if (state is ProductDetailLoaded &&
              state.product.id == widget.product.id) {
            setState(() => _isSubmitting = false);
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: WHColors.background,
          appBar: WHAppbar(title: 'Add Stock'),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _readOnlyProductField(),
                        const SizedBox(height: 16),
                        BlocBuilder<ZoneBloc, ZoneState>(
                          builder: (context, zoneState) =>
                              _zoneAisleShelfSection(zoneState),
                        ),
                        const SizedBox(height: 16),
                        _numericInput('Quantity', _quantityController),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                            size: 17,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isSubmitting ? 'Saving...' : 'Save Stock',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
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
    Navigator.of(context).pop(value); // kembalikan zoneCode ke parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Zone QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay viewfinder
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

          // Hint text
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
                  'Arahkan kamera ke QR Code zona',
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

// Shelf option model

class _ShelfOption {
  final int id;
  final String code;

  const _ShelfOption({required this.id, required this.code});
}
