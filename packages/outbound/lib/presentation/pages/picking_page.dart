import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
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
  int _currentIndex = 0;
  late List<bool> _verifiedLocations;

  PickItem get _currentItem => widget.items[_currentIndex];
  bool get _isLastItem => _currentIndex == widget.items.length - 1;
  bool get _allVerified => _verifiedLocations.every((verified) => verified);

  @override
  void initState() {
    super.initState();
    _resetLocationState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetLocationState() {
    final count = _currentItem.locations.isEmpty
        ? 1
        : _currentItem.locations.length;
    _verifiedLocations = List.generate(count, (index) => index != 0);
  }

  void _scanLocation(int index) {
    setState(() => _verifiedLocations[index] = true);
  }

  void _next() {
    if (!_allVerified) return;

    if (_isLastItem) {
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
      return;
    }

    setState(() {
      _currentIndex++;
      _resetLocationState();
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: _FlowAppBar(title: 'PICK UP'),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _OrderProgressCard(
            orderNumber: widget.soNumber,
            current: _currentIndex + 1,
            total: widget.items.length,
          ),
          const SizedBox(height: 14),
          _PickProductBanner(item: _currentItem),
          const SizedBox(height: 24),
          ..._locationCards(),
          if (!_isLastItem) ...[
            const SizedBox(height: 8),
            Text(
              'Upcoming',
              style: WHTypography.bodyText.copyWith(
                color: WHColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _UpcomingLocationCard(item: widget.items[_currentIndex + 1]),
          ],
        ],
      ),
      bottomNavigationBar: _FlowBottomBar(
        label: _isLastItem ? 'Done' : 'Next Item',
        icon: _isLastItem ? Icons.check_circle_outline : null,
        onPressed: _allVerified ? _next : null,
      ),
    );
  }

  List<Widget> _locationCards() {
    final locations = _currentItem.locations.isEmpty
        ? [
            PickLocation(
              zone: 'ZONE B',
              aisle: 'AISLE 02',
              shelf: 'SHELF 03',
              requiredQty: _currentItem.expectedQty,
              unit: _currentItem.unitOfMeasure,
            ),
          ]
        : _currentItem.locations;

    return List.generate(locations.length, (index) {
      final location = locations[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: TaskPickPutCard(
          location: location.label,
          qty: location.requiredQty,
          uom: location.unit,
          isCompleted: _verifiedLocations[index],
          onScan: () => _scanLocation(index),
        ),
      );
    });
  }
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
  const _PickProductBanner({required this.item});

  final PickItem item;

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
            'SKU: ${item.sku}',
            style: WHTypography.bodyText.copyWith(
              color: WHColors.textSecondary,
              fontSize: 16,
            ),
          ),
          Text(
            item.productName,
            style: WHTypography.heading1.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingLocationCard extends StatelessWidget {
  const _UpcomingLocationCard({required this.item});

  final PickItem item;

  @override
  Widget build(BuildContext context) {
    final location = item.locations.isEmpty
        ? 'B-04-Shelf-1'
        : item.locations.first.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SmallInfo(label: 'LOCATION', value: location),
          ),
          _SmallInfo(
            label: 'QTY',
            value: item.expectedQty.toString(),
            alignEnd: true,
          ),
        ],
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WHTypography.caption.copyWith(
            color: WHColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: WHTypography.bodyText.copyWith(
            color: WHColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
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
