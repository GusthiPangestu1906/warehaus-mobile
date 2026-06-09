import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _productNameController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  // local-only UI selection for category (not sent to backend in current model)
  String? _selectedCategory;
  String? _selectedUnit;
  // categories loaded from backend
  List<String> _categories = [];
  bool _isLoadingCategories = false;

  // Use shared style tokens
  static const _primaryOrange = WHStyles.primary;
  static const _borderColor = WHStyles.border;
  static const _hintColor = WHStyles.hint;

  @override
  void dispose() {
    _skuController.dispose();
    _productNameController.dispose();
    _unitOfMeasureController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final dio = GetIt.instance.get<Dio>();
      final resp = await dio.get('/api/categories');

      final data = resp.data;
      final List<String> parsed = [];
      if (data is List) {
        for (final e in data) {
          if (e == null) continue;
          if (e is String) {
            parsed.add(e);
          } else if (e is Map) {
            if (e.containsKey('name')) {
              parsed.add(e['name']?.toString() ?? '');
            } else if (e.containsKey('categoryName')) {
              parsed.add(e['categoryName']?.toString() ?? '');
            } else if (e.containsKey('title')) {
              parsed.add(e['title']?.toString() ?? '');
            } else if (e.containsKey('label')) {
              parsed.add(e['label']?.toString() ?? '');
            } else {
              parsed.add(e.toString());
            }
          } else {
            parsed.add(e.toString());
          }
        }
      }

      setState(() {
        _categories = parsed.where((s) => s.isNotEmpty).toList();
        if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      });
    } catch (err, st) {
      // debug print; production should handle errors properly
      // ignore: avoid_print
      print('Failed to load categories: $err\\n$st');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // barcode was removed per request; pass empty string for barcode to keep
    // existing event signature unchanged. Category is currently UI-only.
    context.read<ProductBloc>().add(
      CreateProductEvent(
        sku: _skuController.text.trim(),
        productName: _productNameController.text.trim(),
        barcode: '',
        unitOfMeasure: (_selectedUnit ?? _unitOfMeasureController.text).trim(),
      ),
    );
  }

  // barcode scanner removed for this iteration

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _hintColor, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: WHStyles.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WHStyles.inputRadius),
          borderSide: BorderSide(color: _borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WHStyles.inputRadius),
          borderSide: BorderSide(color: _borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WHStyles.inputRadius),
          borderSide: BorderSide(color: _hintColor, width: 1.2),
        ),
      );

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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          padding: const EdgeInsets.all(10),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(hint).copyWith(suffixIcon: suffixIcon),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? hint,
  }) {
    // Outer white rounded card and inner pale filled rounded pill to match
    // the product screenshot. The inner container holds the dropdown.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: WHStyles.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor, width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: value,
              items: items.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e))).toList(),
              onChanged: onChanged,
              icon: Icon(Icons.keyboard_arrow_down, color: _hintColor),
              hint: hint != null ? Text(hint, style: TextStyle(color: _hintColor)) : null,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is ProductError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: WHAppbar(title: 'Add Product'),
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
                      _buildField(
                        label: 'SKU Number',
                        controller: _skuController,
                        hint: 'e.g., LTP-ASUS-001',
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'SKU required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Product Name',
                        controller: _productNameController,
                        hint: 'e.g., Electronic',
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Product name required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      // Category dropdown (UI only for now)
                      _buildDropdownField(
                        label: 'Category',
                        value: _selectedCategory,
                        hint: 'Select Category',
                        items: _isLoadingCategories
                            ? ['Loading...']
                            : (['Select Category'] + (_categories.isNotEmpty ? _categories : ['Uncategorized'])),
                        onChanged: (v) {
                          setState(() {
                            if (v == 'Select Category' || v == 'Loading...') {
                              _selectedCategory = null;
                            } else {
                              _selectedCategory = v;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Unit of measure dropdown
                      _buildDropdownField(
                        label: 'Unit of Measure',
                        value: _selectedUnit,
                        items: const [
                          'PCS',
                          'BOX',
                          'KG',
                          'L',
                        ],
                        onChanged: (v) => setState(() {
                          _selectedUnit = v;
                          _unitOfMeasureController.text = v ?? '';
                        }),
                      ),
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
                  onPressed: _submit,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Save Product',
                    style: TextStyle(
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
    );
  }
}
