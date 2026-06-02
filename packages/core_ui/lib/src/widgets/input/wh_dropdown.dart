import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Model item untuk WHDropdownField.
class WHDropdownItem<T> {
  const WHDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle; // opsional: teks kecil di bawah label
  final IconData? icon; // opsional: icon di kiri item
}

class WHDropdownField<T> extends StatefulWidget {
  const WHDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.hintText = 'Select an option',
    this.errorText,
    this.helperText,
    this.isDisabled = false,
    this.isSearchable = false,
    this.searchHint = 'Search…',
  });

  final String label;
  final List<WHDropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final String? errorText;
  final String? helperText;
  final bool isDisabled;

  /// Tampilkan search bar di dalam bottom sheet
  final bool isSearchable;
  final String searchHint;

  @override
  State<WHDropdownField<T>> createState() => _WHDropdownFieldState<T>();
}

class _WHDropdownFieldState<T> extends State<WHDropdownField<T>> {
  bool _isOpen = false;

  // ── Design tokens (WHColors) ──────────────────────────────────
  static const _mainColorBackground = WHColors.surface; // 0xFFD8E5E6
  static const _mainBorderColor = WHColors.grey5;

  static const _colorBackground = WHColors.grey5;
  static const _colorBorderDefault = WHColors.textPrimary;
  static const _colorBorderFocused = WHColors.primary3;
  static const _colorBorderError = WHColors.error2;
  static const _colorBorderDisabled = WHColors.grey5;

  static const _colorLabelDefault = WHColors.textSecondary;
  static const _colorLabelFocused = WHColors.primary3;
  static const _colorLabelError = WHColors.error2;
  static const _colorLabelDisabled = WHColors.grey4;

  static const _colorText = WHColors.textPrimary;
  static const _colorHint = WHColors.grey4;
  static const _colorIcon = WHColors.grey4;
  static const _colorIconFocused = WHColors.primary3;
  static const _colorIconError = WHColors.error2;
  static const _colorIconDisabled = WHColors.grey5;

  static const _colorHelperText = WHColors.grey3;
  static const _colorErrorText = WHColors.error2;
  static const _colorDisabledBg = WHColors.background;
  static const _colorDisabledText = WHColors.grey4;

  static const _borderRadius = 12.0;
  static const _labelFontSize = 13.0;
  static const _inputFontSize = 14.0;
  static const _helperFontSize = 12.0;

  // ── Helpers ────────────────────────────────────────────────────
  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;
  bool get _hasValue => widget.selectedValue != null;

  WHDropdownItem<T>? get _selectedItem => _hasValue
      ? widget.items.where((i) => i.value == widget.selectedValue).firstOrNull
      : null;

  Color get _borderColor {
    if (widget.isDisabled) return _colorBorderDisabled;
    if (_hasError) return _colorBorderError;
    if (_isOpen) return _colorBorderFocused;
    return _colorBorderDefault;
  }

  Color get _labelColor {
    if (widget.isDisabled) return _colorLabelDisabled;
    if (_hasError) return _colorLabelError;
    if (_isOpen) return _colorLabelFocused;
    return _colorLabelDefault;
  }

  Color get _iconColor {
    if (widget.isDisabled) return _colorIconDisabled;
    if (_hasError) return _colorIconError;
    if (_isOpen) return _colorIconFocused;
    return _colorIcon;
  }

  // ── Open bottom sheet ─────────────────────────────────────────
  Future<void> _openSheet() async {
    if (widget.isDisabled || widget.items.isEmpty) return;

    setState(() => _isOpen = true);

    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DropdownSheet<T>(
        label: widget.label,
        items: widget.items,
        selectedValue: widget.selectedValue,
        isSearchable: widget.isSearchable,
        searchHint: widget.searchHint,
      ),
    );

    setState(() => _isOpen = false);

    if (result != null || (result == null && _hasValue)) {
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _mainColorBackground,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: _mainBorderColor,
          width: _hasError ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ─────────────────────────────────────────────────
          Text(
            widget.label,
            style: TextStyle(
              fontSize: _labelFontSize,
              fontWeight: FontWeight.w500,
              color: _labelColor,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),

          // ── Dropdown trigger ──────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.isDisabled ? _colorDisabledBg : _colorBackground,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: _borderColor,
                width: _isOpen || _hasError ? 1.5 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isDisabled ? null : _openSheet,
                borderRadius: BorderRadius.circular(_borderRadius),
                splashColor: WHColors.primary6.withOpacity(0.3),
                highlightColor: WHColors.primary6.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      // Icon item terpilih (jika ada)
                      if (_selectedItem?.icon != null) ...[
                        Icon(_selectedItem!.icon, size: 18, color: _iconColor),
                        const SizedBox(width: 8),
                      ],

                      // Label terpilih / placeholder
                      Expanded(
                        child: Text(
                          _selectedItem?.label ?? widget.hintText,
                          style: TextStyle(
                            fontSize: _inputFontSize,
                            fontWeight: FontWeight.w400,
                            color: widget.isDisabled
                                ? _colorDisabledText
                                : _hasValue
                                ? _colorText
                                : _colorHint,
                            height: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Chevron icon — rotasi saat terbuka
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: _iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Helper / Error text ───────────────────────────────────
          if (_hasError || widget.helperText != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                if (_hasError)
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 13,
                    color: _colorErrorText,
                  ),
                if (_hasError) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _hasError ? widget.errorText! : widget.helperText!,
                    style: TextStyle(
                      fontSize: _helperFontSize,
                      color: _hasError ? _colorErrorText : _colorHelperText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom sheet internal ──────────────────────────────────────────
class _DropdownSheet<T> extends StatefulWidget {
  const _DropdownSheet({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.isSearchable,
    required this.searchHint,
  });

  final String label;
  final List<WHDropdownItem<T>> items;
  final T? selectedValue;
  final bool isSearchable;
  final String searchHint;

  @override
  State<_DropdownSheet<T>> createState() => _DropdownSheetState<T>();
}

class _DropdownSheetState<T> extends State<_DropdownSheet<T>> {
  late List<WHDropdownItem<T>> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
                .where((i) => i.label.toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: WHColors.grey5,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: WHColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: WHColors.grey4,
                  ),
                ),
              ],
            ),
          ),

          // Search bar (opsional)
          if (widget.isSearchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: WHColors.grey5,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: WHColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: WHColors.grey4,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: WHColors.grey4,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ),

          const Divider(height: 1, thickness: 0.5, color: WHColors.grey5),

          // Item list
          Flexible(
            child: _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Tidak ada hasil',
                      style: TextStyle(fontSize: 14, color: WHColors.grey4),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: WHColors.grey5,
                    ),
                    itemBuilder: (context, i) {
                      final item = _filtered[i];
                      final isSelected = item.value == widget.selectedValue;

                      return InkWell(
                        onTap: () => Navigator.pop(context, item.value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              if (item.icon != null) ...[
                                Icon(
                                  item.icon,
                                  size: 18,
                                  color: isSelected
                                      ? WHColors.primary3
                                      : WHColors.grey4,
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? WHColors.primary3
                                            : WHColors.textPrimary,
                                      ),
                                    ),
                                    if (item.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: WHColors.grey4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: WHColors.primary3,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
