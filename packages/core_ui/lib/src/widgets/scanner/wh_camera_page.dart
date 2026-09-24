// lib/features/shared/presentation/pages/wh_camera_page.dart

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core_ui/core_ui.dart';

// ─────────────────────────────────────────────────────────────────
// RESULT MODEL
// ─────────────────────────────────────────────────────────────────

/// Hasil dari halaman kamera.
class WhCaptureResult {
  const WhCaptureResult({required this.files, this.notes});

  /// Daftar file foto yang diambil
  final List<File> files;

  /// Catatan opsional yang diisi user setelah foto
  final String? notes;
}

// ─────────────────────────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────────────────────────

/// Halaman kamera reusable untuk memfoto kondisi barang.
///
/// Mengembalikan [WhCaptureResult] via Navigator.pop.
/// Jika user cancel tanpa foto, mengembalikan null.
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<WhCaptureResult>(
///   context,
///   WhCameraPage.route(
///     title: 'Capture Condition',
///     maxPhotos: 5,
///   ),
/// );
/// if (result != null) {
///   print(result.files.length); // jumlah foto
///   print(result.notes);        // catatan opsional
/// }
/// ```
class WhCameraPage extends StatefulWidget {
  const WhCameraPage({
    super.key,
    this.title = 'Capture Condition',
    this.subtitle,
    this.maxPhotos = 5,
    this.withNotesField = true,
  });

  final String title;
  final String? subtitle;

  /// Maksimal foto yang boleh diambil. Default: 5
  final int maxPhotos;

  /// Tampilkan field catatan di halaman review. Default: true
  final bool withNotesField;

  static Route<WhCaptureResult> route({
    String title = 'Capture Condition',
    String? subtitle,
    int maxPhotos = 5,
    bool withNotesField = true,
  }) {
    return MaterialPageRoute<WhCaptureResult>(
      builder: (_) => WhCameraPage(
        title: title,
        subtitle: subtitle,
        maxPhotos: maxPhotos,
        withNotesField: withNotesField,
      ),
    );
  }

  @override
  State<WhCameraPage> createState() => _WhCameraPageState();
}

class _WhCameraPageState extends State<WhCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isFrontCamera = false;
  bool _isTorchOn = false;
  bool _showReview = false;
  bool _isSwitching = false;
  String? _cameraError;

  final List<File> _capturedFiles = [];
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera({bool useFront = false}) async {
    _isSwitching = true;
    setState(() {
      _isInitialized = false;
      _cameraError = null;
    });

    try {
      // 1. Dispose controller lama sebelum inisialisasi controller baru
      // untuk melepas lock hardware kamera pada platform Android/iOS
      final oldController = _controller;
      _controller = null;
      if (oldController != null) {
        await oldController.dispose();
      }

      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameraError = 'No camera available on this device.';
          _isSwitching = false;
        });
        return;
      }

      CameraDescription targetCamera;
      if (useFront) {
        final frontCameras = _cameras
            .where((c) => c.lensDirection == CameraLensDirection.front)
            .toList();
        if (frontCameras.isNotEmpty) {
          targetCamera = frontCameras.first;
          _isFrontCamera = true;
        } else {
          targetCamera = _cameras.first;
          _isFrontCamera = targetCamera.lensDirection == CameraLensDirection.front;
        }
      } else {
        final backCameras = _cameras
            .where((c) => c.lensDirection == CameraLensDirection.back)
            .toList();
        if (backCameras.isNotEmpty) {
          targetCamera = backCameras.first;
          _isFrontCamera = false;
        } else {
          targetCamera = _cameras.first;
          _isFrontCamera = targetCamera.lensDirection == CameraLensDirection.front;
        }
      }

      // Jangan paksakan imageFormatGroup: ImageFormatGroup.jpeg pada preview
      // karena pada beberapa sensor depan Android ini menyebabkan preview blank/hitam
      final controller = CameraController(
        targetCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      try {
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (e) {
        debugPrint('Camera orientation lock not supported: $e');
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
        _isTorchOn = false;
        _cameraError = null;
        _isSwitching = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _cameraError = _cameraErrorMessage(e);
        _isSwitching = false;
      });
      debugPrint('Camera init error: ${e.code} ${e.description}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _cameraError = 'Unable to start camera. Please try again.';
        _isSwitching = false;
      });
      debugPrint('Camera init error: $e');
    }
  }

  String _cameraErrorMessage(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
        return 'Camera permission is required to capture item condition.';
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return 'Camera permission was denied. Enable it from app settings.';
      default:
        return e.description?.isNotEmpty == true
            ? e.description!
            : 'Unable to start camera. Please try again.';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      setState(() {
        _controller = null;
        _isInitialized = false;
      });
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(useFront: _isFrontCamera);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Ambil foto ────────────────────────────────────────────────
  Future<void> _capture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _isCapturing) return;
    if (_capturedFiles.length >= widget.maxPhotos) return;

    setState(() => _isCapturing = true);

    try {
      // Flash animasi
      HapticFeedback.mediumImpact();

      final xFile = await ctrl.takePicture();
      final file = File(xFile.path);

      setState(() {
        _capturedFiles.add(file);
        _isCapturing = false;
      });

      // Auto masuk ke review jika sudah mencapai maxPhotos
      if (_capturedFiles.length >= widget.maxPhotos) {
        _openReview();
      }
    } catch (e) {
      setState(() => _isCapturing = false);
      debugPrint('Capture error: $e');
    }
  }

  // ── Toggle torch ──────────────────────────────────────────────
  Future<void> _toggleTorch() async {
    final ctrl = _controller;
    if (ctrl == null || _isFrontCamera) return;
    final next = _isTorchOn ? FlashMode.off : FlashMode.torch;
    await ctrl.setFlashMode(next);
    setState(() => _isTorchOn = !_isTorchOn);
  }

  // ── Switch camera ─────────────────────────────────────────────
  Future<void> _switchCamera() async {
    if (_isSwitching || _cameras.length <= 1) return;
    final nextUseFront = !_isFrontCamera;
    await _initCamera(useFront: nextUseFront);
  }

  // ── Hapus foto terakhir ───────────────────────────────────────
  void _removePhoto(int index) {
    setState(() => _capturedFiles.removeAt(index));
  }

  // ── Buka review ───────────────────────────────────────────────
  void _openReview() {
    if (_capturedFiles.isEmpty) return;
    setState(() => _showReview = true);
  }

  // ── Submit result ─────────────────────────────────────────────
  void _submit() {
    Navigator.of(context).pop(
      WhCaptureResult(
        files: List.unmodifiable(_capturedFiles),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _showReview
          ? _ReviewView(
              files: _capturedFiles,
              notesCtrl: _notesCtrl,
              withNotesField: widget.withNotesField,
              maxPhotos: widget.maxPhotos,
              onRemove: _removePhoto,
              onAddMore: () => setState(() => _showReview = false),
              onSubmit: _submit,
              onBack: () => setState(() => _showReview = false),
            )
          : _CameraView(
              controller: _controller,
              isInitialized: _isInitialized,
              isCapturing: _isCapturing,
              isTorchOn: _isTorchOn,
              isFrontCamera: _isFrontCamera,
              capturedCount: _capturedFiles.length,
              maxPhotos: widget.maxPhotos,
              title: widget.title,
              subtitle: widget.subtitle,
              lastCapture: _capturedFiles.isNotEmpty
                  ? _capturedFiles.last
                  : null,
              errorMessage: _cameraError,
              onCapture: _capture,
              onToggleTorch: _toggleTorch,
              onSwitchCamera: _switchCamera,
              onReview: _openReview,
              onRetry: () => _initCamera(useFront: _isFrontCamera),
              onBack: () => Navigator.of(context).pop(),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CAMERA VIEW
// ─────────────────────────────────────────────────────────────────
class _CameraView extends StatelessWidget {
  const _CameraView({
    required this.controller,
    required this.isInitialized,
    required this.isCapturing,
    required this.isTorchOn,
    required this.isFrontCamera,
    required this.capturedCount,
    required this.maxPhotos,
    required this.title,
    required this.subtitle,
    required this.lastCapture,
    required this.errorMessage,
    required this.onCapture,
    required this.onToggleTorch,
    required this.onSwitchCamera,
    required this.onReview,
    required this.onRetry,
    required this.onBack,
  });

  final CameraController? controller;
  final bool isInitialized;
  final bool isCapturing;
  final bool isTorchOn;
  final bool isFrontCamera;
  final int capturedCount;
  final int maxPhotos;
  final String title;
  final String? subtitle;
  final File? lastCapture;
  final String? errorMessage;
  final VoidCallback onCapture;
  final VoidCallback onToggleTorch;
  final VoidCallback onSwitchCamera;
  final VoidCallback onReview;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  bool get _isMaxReached => capturedCount >= maxPhotos;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Camera preview ───────────────────────────────────
        if (errorMessage != null)
          _CameraErrorView(
            message: errorMessage!,
            onRetry: onRetry,
            onBack: onBack,
          )
        else if (isInitialized &&
            controller != null &&
            controller!.value.isInitialized)
          Center(
            child: CameraPreview(
              controller!,
              key: ValueKey(
                'camera_preview_${controller!.description.name}_${controller!.cameraId}_${controller!.description.lensDirection}',
              ),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: WHColors.secondary3),
          ),

        // ── Top bar ──────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _IconBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
                  const Spacer(),
                  Flexible(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WHTypography.heading2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WHTypography.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isFrontCamera)
                    _IconBtn(
                      icon: isTorchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      activeColor: isTorchOn ? WHColors.secondary3 : null,
                      onTap: onToggleTorch,
                    )
                  else
                    const SizedBox(width: 44, height: 44),
                ],
              ),
            ),
          ),
        ),

        // ── Max reached banner ────────────────────────────────
        if (_isMaxReached)
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: WHColors.warning2.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Maksimal $maxPhotos foto tercapai',
                textAlign: TextAlign.center,
                style: WHTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // ── Bottom controls ───────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thumbnail preview foto terakhir + counter
                  _ThumbnailPreview(
                    file: lastCapture,
                    count: capturedCount,
                    onTap: capturedCount > 0 ? onReview : null,
                  ),

                  // Shutter button
                  _ShutterButton(
                    isCapturing: isCapturing,
                    isDisabled: _isMaxReached,
                    onTap: onCapture,
                  ),

                  // Flip camera
                  _IconBtn(
                    icon: Icons.flip_camera_ios_rounded,
                    onTap: onSwitchCamera,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: WHColors.surface,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: WHTypography.bodyText.copyWith(color: WHColors.surface),
            ),
            const SizedBox(height: 20),
            WHButton(
              label: 'Try Again',
              icon: Icons.refresh,
              backgroundColor: WHColors.secondary3,
              onPressed: onRetry,
            ),
            const SizedBox(height: 10),
            WHOutlinedButton(
              label: 'Back',
              icon: Icons.arrow_back,
              borderColor: WHColors.surface,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// REVIEW VIEW
// ─────────────────────────────────────────────────────────────────
class _ReviewView extends StatelessWidget {
  const _ReviewView({
    required this.files,
    required this.notesCtrl,
    required this.withNotesField,
    required this.maxPhotos,
    required this.onRemove,
    required this.onAddMore,
    required this.onSubmit,
    required this.onBack,
  });

  final List<File> files;
  final TextEditingController notesCtrl;
  final bool withNotesField;
  final int maxPhotos;
  final ValueChanged<int> onRemove;
  final VoidCallback onAddMore;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHColors.background,
      appBar: AppBar(
        backgroundColor: WHColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: WHColors.textPrimary,
          ),
          onPressed: onBack,
        ),
        title: Text(
          'Review Foto (${files.length}/$maxPhotos)',
          style: WHTypography.heading2,
        ),
        shape: const Border(
          bottom: BorderSide(color: WHColors.grey5, width: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo grid ─────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: files.length < maxPhotos
                  ? files.length +
                        1 // +1 untuk tombol tambah
                  : files.length,
              itemBuilder: (_, i) {
                if (i == files.length && files.length < maxPhotos) {
                  return _AddMoreTile(onTap: onAddMore);
                }
                return _PhotoTile(
                  file: files[i],
                  index: i,
                  onRemove: () => onRemove(i),
                );
              },
            ),

            // ── Notes field ─────────────────────────────────────
            if (withNotesField) ...[
              const SizedBox(height: 20),
              Text(
                'Catatan Kondisi',
                style: WHTypography.caption.copyWith(
                  color: WHColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WHColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WHColors.grey5),
                ),
                child: TextField(
                  controller: notesCtrl,
                  maxLines: 4,
                  maxLength: 200,
                  style: WHTypography.bodyText.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan kondisi barang (opsional)…',
                    hintStyle: WHTypography.caption.copyWith(
                      color: WHColors.grey4,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    counterStyle: WHTypography.caption.copyWith(
                      color: WHColors.grey4,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Submit button ───────────────────────────────────
            WHButton(
              label: 'Simpan Foto',
              icon: Icons.check_rounded,
              backgroundColor: WHColors.secondary3,
              onPressed: files.isNotEmpty ? onSubmit : null,
            ),

            const SizedBox(height: 8),

            // ── Add more button ─────────────────────────────────
            if (files.length < maxPhotos)
              WHOutlinedButton(
                label: 'Tambah Foto Lagi',
                icon: Icons.add_a_photo_outlined,
                onPressed: onAddMore,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.activeColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: activeColor != null
              ? activeColor!.withValues(alpha: 0.85)
              : Colors.black45,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({
    required this.isCapturing,
    required this.isDisabled,
    required this.onTap,
  });

  final bool isCapturing;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.white30 : Colors.white,
            width: 3,
          ),
        ),
        padding: const EdgeInsets.all(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCapturing
                ? WHColors.secondary3.withValues(alpha: 0.7)
                : isDisabled
                ? Colors.white24
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  const _ThumbnailPreview({
    required this.file,
    required this.count,
    required this.onTap,
  });

  final File? file;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: file != null ? Colors.white : Colors.white30,
                width: 1.5,
              ),
              color: Colors.black45,
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file!, fit: BoxFit.cover),
                  )
                : const Icon(
                    Icons.photo_outlined,
                    color: Colors.white38,
                    size: 24,
                  ),
          ),
          if (count > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: WHColors.secondary3,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  final File file;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: WHColors.error2,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 6,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddMoreTile extends StatelessWidget {
  const _AddMoreTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: WHColors.grey5.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WHColors.grey5, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: WHColors.grey4, size: 24),
            SizedBox(height: 4),
            Text(
              'Tambah',
              style: TextStyle(
                fontSize: 10,
                color: WHColors.grey4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
