import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/presentation/models/pick_flow_item.dart';
import 'package:outbound/presentation/pages/packing_page.dart';

class PickingPage extends StatefulWidget {
  const PickingPage({
    super.key,
    required this.soNumber,
    required this.items,
    this.orderId,
  });

  final String soNumber;
  final List<PickItem> items;
  final int? orderId;

  @override
  State<PickingPage> createState() => _PickingPageState();
}

class _PickingPageState extends State<PickingPage> {
  final ScrollController _scrollController = ScrollController();
  final SalesOrderApiDatasource _api =
      GetIt.instance<SalesOrderApiDatasource>();

  _PickingTask? _task;
  _PickingTask? _lastVerifiedTask;
  _PickingTask? _pendingNextTask;
  _PickingProgress? _progress;
  bool _isLoading = true;
  bool _isCompleting = false;
  bool _isTaskVerified = false;
  bool _isStageCompleted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNextTask();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNextTask() async {
    final orderId = widget.orderId;
    if (orderId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sales Order ID tidak tersedia.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final json = await _api.getPickingNextTask(orderId);
      if (!mounted) return;
      setState(() {
        _applyTaskResponse(json);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _scanLocation() async {
    final task = _task;
    if (task == null || _isCompleting) return;

    final scannedCode = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const _QrScannerPage()));

    if (!mounted || scannedCode == null || scannedCode.trim().isEmpty) return;

    if (!_matchesShelfScan(scannedCode, task)) {
      WHSnackBar.showError(
        context,
        'QR shelf tidak sesuai dengan task picking ini.',
      );
      return;
    }

    await _completeTask(task);
  }

  Future<void> _completeTask(_PickingTask task) async {
    final orderId = widget.orderId;
    if (orderId == null) return;

    setState(() => _isCompleting = true);

    try {
      final json = await _api.completePickingTask(
        salesOrderId: orderId,
        salesOrderItemId: task.salesOrderItemId,
        shelfId: task.shelfId,
        pickedQty: task.requiredQty,
      );
      if (!mounted) return;
      setState(() {
        _lastVerifiedTask = task;
        _isTaskVerified = true;
        _applyCompleteResponse(json);
        _isCompleting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCompleting = false);
      WHSnackBar.showError(context, _friendlyError(e));
    }
  }

  void _applyTaskResponse(Map<String, dynamic> json) {
    _progress = _PickingProgress.fromJson(
      json['progress'] as Map<String, dynamic>?,
    );

    final taskJson = json['task'] as Map<String, dynamic>?;
    _task = taskJson == null ? null : _PickingTask.fromJson(taskJson);
    if (_task != null) _lastVerifiedTask = null;
    _pendingNextTask = null;
    _isStageCompleted =
        json['isStageCompleted'] == true ||
        (json['stage'] as String? ?? '').toLowerCase() == 'packing';
    _isTaskVerified = false;
  }

  void _applyCompleteResponse(Map<String, dynamic> json) {
    _progress = _PickingProgress.fromJson(
      json['progress'] as Map<String, dynamic>?,
    );

    final nextTaskJson = json['nextTask'] as Map<String, dynamic>?;
    _pendingNextTask = nextTaskJson == null
        ? null
        : _PickingTask.fromJson(nextTaskJson);
    _isStageCompleted =
        json['isStageCompleted'] == true ||
        (json['stage'] as String? ?? '').toLowerCase() == 'packing';

    if (_isStageCompleted) {
      _task = null;
      _pendingNextTask = null;
      _isTaskVerified = true;
    }
  }

  void _showNextTask() {
    final nextTask = _pendingNextTask;
    if (nextTask == null) return;

    setState(() {
      _task = nextTask;
      _lastVerifiedTask = null;
      _pendingNextTask = null;
      _isTaskVerified = false;
      _isStageCompleted = false;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  bool _matchesShelfScan(String raw, _PickingTask task) {
    final scanned = _normalize(raw);
    final qrCode = _normalize(task.shelfQrCode);
    final shelfCode = _normalize(task.shelfCode);
    final shelfId = task.shelfId.toString();
    final qrUri = Uri.tryParse(task.shelfQrCode);
    final qrSegments = qrUri?.pathSegments ?? const <String>[];
    final qrFileName = _normalize(qrSegments.isEmpty ? null : qrSegments.last);

    final candidates = [
      qrCode,
      shelfCode,
      shelfId,
      qrFileName,
      qrFileName.replaceAll('.png', ''),
    ].where((value) => value.isNotEmpty);

    return candidates.any(
      (candidate) => scanned == candidate || scanned.contains(candidate),
    );
  }

  String _normalize(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('_', '-');
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('404')) {
      return 'Task picking belum tersedia untuk Sales Order ini.';
    }
    return text;
  }

  _PickingTask? _completedDisplayTask() {
    if (_lastVerifiedTask != null) return _lastVerifiedTask;
    if (!_isStageCompleted || widget.items.isEmpty) return null;

    final completedCount = _progress?.completedItems ?? widget.items.length;
    final lastIndex = completedCount <= 0 ? 0 : completedCount - 1;
    final itemIndex = lastIndex >= widget.items.length
        ? widget.items.length - 1
        : lastIndex;

    return _PickingTask.fromPickItem(widget.items[itemIndex]);
  }

  void _goToPacking() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => PackingPage(
          orderId: widget.orderId,
          orderNumber: widget.soNumber,
          items: widget.items,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _showPickingDonePopup() {
    showWhPopUpDone(
      context: context,
      nextStepLabel: 'Next Step: Packing Items.',
      onBackToFlow: () {
        Navigator.of(context).pop();
        _goToPacking();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final task = _task;
    final completedTask = _completedDisplayTask();
    final bottomAction = _bottomAction();
    final bottomOnPressed =
        bottomAction.onPressed ??
        (_isStageCompleted ? _showPickingDonePopup : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: const _FlowAppBar(title: 'PICK UP'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadNextTask)
          : ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _OrderProgressCard(
                  orderNumber: widget.soNumber,
                  current: progress?.completedItems ?? 0,
                  total: progress?.totalItems ?? widget.items.length,
                ),
                const SizedBox(height: 14),
                if (task != null) ...[
                  _PickProductBanner(task: task),
                  const SizedBox(height: 24),
                  TaskPickPutCard(
                    location: task.shelfCode,
                    qty: task.requiredQty,
                    uom: task.unitOfMeasure,
                    isCompleted: _isTaskVerified,
                    onScan: _isCompleting ? null : _scanLocation,
                  ),
                ] else if (_isStageCompleted) ...[
                  if (completedTask != null) ...[
                    _PickProductBanner(task: completedTask),
                    const SizedBox(height: 10),
                    TaskPickPutCard(
                      location: completedTask.shelfCode,
                      qty: completedTask.requiredQty,
                      uom: completedTask.unitOfMeasure,
                      isCompleted: true,
                    ),
                  ] else
                    const WHEmptyState(message: 'Picking selesai.'),
                ] else ...[
                  const WHEmptyState(message: 'Task picking tidak tersedia.'),
                ],
              ],
            ),
      bottomNavigationBar: _FlowBottomBar(
        label: bottomAction.label,
        icon: bottomAction.icon,
        onPressed: bottomOnPressed,
      ),
    );
  }

  _BottomAction _bottomAction() {
    final progress = _progress;
    final isCurrentLast =
        progress != null && progress.completedItems + 1 >= progress.totalItems;
    final defaultLabel = isCurrentLast ? 'Done' : 'Next Item';

    if (_isStageCompleted) {
      return _BottomAction(
        label: 'Done',
        icon: Icons.check_circle_outline,
        onPressed: _showPickingDonePopup,
      );
    }

    if (_isTaskVerified && _pendingNextTask != null) {
      return _BottomAction(
        label: 'Next Item',
        icon: Icons.arrow_forward,
        onPressed: _showNextTask,
      );
    }

    return _BottomAction(
      label: defaultLabel,
      icon: isCurrentLast ? Icons.check_circle_outline : Icons.arrow_forward,
    );
  }
}

class _BottomAction {
  const _BottomAction({required this.label, this.icon, this.onPressed});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
}

class _PickingTask {
  const _PickingTask({
    required this.salesOrderItemId,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.requiredQty,
    required this.unitOfMeasure,
    required this.shelfId,
    required this.shelfCode,
    required this.shelfQrCode,
  });

  final int salesOrderItemId;
  final int productId;
  final String sku;
  final String productName;
  final int requiredQty;
  final String unitOfMeasure;
  final int shelfId;
  final String shelfCode;
  final String shelfQrCode;

  factory _PickingTask.fromJson(Map<String, dynamic> json) {
    return _PickingTask(
      salesOrderItemId: _asInt(json['salesOrderItemId']),
      productId: _asInt(json['productId']),
      sku: json['sku'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      requiredQty: _asInt(json['requiredQty']),
      unitOfMeasure: json['unitOfMeasure'] as String? ?? 'PCS',
      shelfId: _asInt(json['shelfId']),
      shelfCode: json['shelfCode'] as String? ?? '',
      shelfQrCode: json['shelfQrCode'] as String? ?? '',
    );
  }

  factory _PickingTask.fromPickItem(PickItem item) {
    final location = item.locations.isEmpty ? null : item.locations.first;

    return _PickingTask(
      salesOrderItemId: 0,
      productId: 0,
      sku: item.sku,
      productName: item.productName,
      requiredQty: location?.requiredQty ?? item.expectedQty,
      unitOfMeasure: location?.unit ?? item.unitOfMeasure,
      shelfId: 0,
      shelfCode: location?.label ?? 'ZONE B - AISLE 02 - SHELF 03',
      shelfQrCode: '',
    );
  }
}

class _PickingProgress {
  const _PickingProgress({
    required this.completedItems,
    required this.totalItems,
  });

  final int completedItems;
  final int totalItems;

  factory _PickingProgress.fromJson(Map<String, dynamic>? json) {
    return _PickingProgress(
      completedItems: _asInt(json?['completedItems']),
      totalItems: _asInt(json?['totalItems']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class _FlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FlowAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: WHColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: WHColors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: WHColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFD7E2F5)),
      ),
    );
  }
}

class _OrderProgressCard extends StatelessWidget {
  const _OrderProgressCard({
    required this.orderNumber,
    required this.current,
    required this.total,
  });

  final String orderNumber;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'ORDER #',
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                orderNumber,
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.primary1,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFE6E6E6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      WHColors.secondary4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$current / $total Items',
                style: WHTypography.bodyText.copyWith(
                  color: WHColors.secondary4,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickProductBanner extends StatelessWidget {
  const _PickProductBanner({required this.task});

  final _PickingTask task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      color: WHColors.secondary6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SKU: ${task.sku}',
            style: WHTypography.caption.copyWith(
              color: WHColors.textSecondary,
              fontSize: 13,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: WHTypography.bodyText.copyWith(
              color: WHColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ],
      ),
    );
  }

}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WHEmptyState(message: message),
            const SizedBox(height: 16),
            WHButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _FlowBottomBar extends StatelessWidget {
  const _FlowBottomBar({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: const BoxDecoration(
            color: WHColors.surface,
            border: Border(top: BorderSide(color: WHColors.grey5)),
          ),
          child: WhPrimaryButton(text: label, icon: icon, onPressed: onPressed),
        ),
        WHBottomNav(
          currentIndex: 2,
          onTap: (_) =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }
}

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

    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;

    _hasScanned = true;
    _controller.stop();

    if (!mounted) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Shelf QR'),
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
        ],
      ),
    );
  }
}
