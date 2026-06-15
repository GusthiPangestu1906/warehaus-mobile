// lib/features/shared/presentation/pages/wh_scanner_page.dart

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Halaman scan QR / Barcode yang reusable.
///
/// Mengembalikan [String] hasil scan via [Navigator.pop].
/// Jika user menekan back tanpa scan, mengembalikan `null`.
///
/// ──────────────────────────────────────────────────────────────
/// Cara pakai — 1: push & tunggu result
/// ```dart
/// final result = await Navigator.push<String>(
///   context,
///   WhScannerPage.route(
///     title: 'Verify Barcode Item',
///     subtitle: 'Arahkan kamera ke barcode produk',
///   ),
/// );
/// if (result != null) {
///   // gunakan result
/// }
/// ```
///
/// Cara pakai — 2: pakai callback langsung
/// ```dart
/// Navigator.push(
///   context,
///   WhScannerPage.route(
///     title: 'Scan PO Barcode',
///     onDetected: (code) {
///       bloc.add(PoScanned(code));
///       Navigator.pop(context);
///     },
///   ),
/// );
/// ```
/// ──────────────────────────────────────────────────────────────
class WHScannerPage extends StatefulWidget {
  const WHScannerPage({
    super.key,
    this.title = 'Scan Barcode',
    this.subtitle,
    this.formats = const [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.dataMatrix,
    ],
    this.onDetected,
    this.allowMultiple = false,
  });

  /// Judul AppBar
  final String title;

  /// Hint teks di bawah viewfinder (opsional)
  final String? subtitle;

  /// Format barcode yang diterima. Default: QR + barcode umum.
  final List<BarcodeFormat> formats;

  /// Callback saat kode terdeteksi.
  /// Jika null, otomatis pop dengan result string.
  final ValueChanged<String>? onDetected;

  /// Izinkan scan berkali-kali tanpa auto-pop. Default: false.
  final bool allowMultiple;

  static Route<String> route({
    String title = 'Scan Barcode',
    String? subtitle,
    List<BarcodeFormat> formats = const [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.dataMatrix,
    ],
    ValueChanged<String>? onDetected,
    bool allowMultiple = false,
  }) {
    return MaterialPageRoute<String>(
      builder: (_) => WHScannerPage(
        title: title,
        subtitle: subtitle,
        formats: formats,
        onDetected: onDetected,
        allowMultiple: allowMultiple,
      ),
    );
  }

  @override
  State<WHScannerPage> createState() => _WHScannerPageState();
}

class _WHScannerPageState extends State<WHScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;

  bool _isProcessing = false; // guard supaya tidak double-detect
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      formats: widget.formats,
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // ── Handle deteksi ───────────────────────────────────────────
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing && !widget.allowMultiple) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    if (widget.onDetected != null) {
      widget.onDetected!(rawValue);
      if (!widget.allowMultiple) Navigator.of(context).pop(rawValue);
    } else {
      Navigator.of(context).pop(rawValue);
    }
  }

  // ── Toggle torch ──────────────────────────────────────────────
  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  // ── Switch camera ─────────────────────────────────────────────
  void _switchCamera() {
    _controller.switchCamera();
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _ScannerAppBar(
        title: widget.title,
        isTorchOn: _isTorchOn,
        onTorchToggle: _toggleTorch,
        onSwitchCamera: _switchCamera,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera feed ──────────────────────────────────────
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // ── Overlay dengan viewfinder ─────────────────────────
          _ScannerOverlay(subtitle: widget.subtitle),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AppBar transparan di atas kamera
// ─────────────────────────────────────────────────────────────────
class _ScannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ScannerAppBar({
    required this.title,
    required this.isTorchOn,
    required this.onTorchToggle,
    required this.onSwitchCamera,
  });

  final String title;
  final bool isTorchOn;
  final VoidCallback onTorchToggle;
  final VoidCallback onSwitchCamera;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: WHTypography.heading2.copyWith(color: Colors.white),
      ),
      actions: [
        // Torch toggle
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isTorchOn
                  ? WHColors.secondary3.withOpacity(0.9)
                  : Colors.black45,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: onTorchToggle,
        ),
        // Flip camera
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.flip_camera_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: onSwitchCamera,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Overlay viewfinder
// ─────────────────────────────────────────────────────────────────
class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({this.subtitle});
  final String? subtitle;

  static const double _cutoutSize = 260.0;
  static const double _cornerLength = 28.0;
  static const double _cornerThickness = 4.0;
  static const double _cornerRadius = 6.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dimmed area atas (termasuk di balik AppBar)
        Expanded(flex: 2, child: Container(color: Colors.black54)),

        // Baris tengah: dim | cutout bening | dim
        Row(
          children: [
            // Dim kiri
            Container(
              width: (MediaQuery.of(context).size.width - _cutoutSize) / 2,
              color: Colors.black54,
            ),

            // Area cutout — transparan
            SizedBox(
              width: _cutoutSize,
              height: _cutoutSize,
              child: CustomPaint(
                painter: _CornerPainter(
                  color: WHColors.secondary3,
                  cornerLength: _cornerLength,
                  cornerThickness: _cornerThickness,
                  cornerRadius: _cornerRadius,
                ),
              ),
            ),

            // Dim kanan
            Expanded(child: Container(color: Colors.black54)),
          ],
        ),

        // Dimmed area bawah + label
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Scan line animation
                const _ScanLineHint(),
                const SizedBox(height: 20),
                // Subtitle
                Text(
                  subtitle ?? 'Arahkan kamera ke barcode atau QR Code',
                  textAlign: TextAlign.center,
                  style: WHTypography.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sudut-sudut viewfinder (custom painter)
// ─────────────────────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.color,
    required this.cornerLength,
    required this.cornerThickness,
    required this.cornerRadius,
  });

  final Color color;
  final double cornerLength;
  final double cornerThickness;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThickness
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final cl = cornerLength;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, cl)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(cl, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - cl, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, cl),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w, h - cl)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(w - cl, h),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(cl, h)
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, h - cl),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) =>
      old.color != color ||
      old.cornerLength != cornerLength ||
      old.cornerThickness != cornerThickness;
}

// ─────────────────────────────────────────────────────────────────
// Scan line animasi (opsional, visual hint)
// ─────────────────────────────────────────────────────────────────
class _ScanLineHint extends StatefulWidget {
  const _ScanLineHint();

  @override
  State<_ScanLineHint> createState() => _ScanLineHintState();
}

class _ScanLineHintState extends State<_ScanLineHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: WHColors.secondary3,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Mencari kode…',
            style: WHTypography.caption.copyWith(
              color: WHColors.secondary3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
