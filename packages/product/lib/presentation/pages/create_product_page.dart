import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:product/domain/entities/category.dart';
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
  final _qrCodeController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  // local-only UI selection for category (not sent to backend in current model)
  String? _selectedCategory;
  String? _selectedUnit;
  int? _selectedCategoryId;

  // Use shared style tokens
  static const _primaryOrange = WHStyles.primary;
  static const _borderColor = WHStyles.border;
  static const _hintColor = WHStyles.hint;

  List<Category> _categories = [];

  final List<String> _unitOptions = ['PCS', 'BOX', 'KG', 'L'];

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
    context.read<ProductBloc>().add(LoadCategoriesEvent());
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategoryId == null) {
      WHSnackBar.showError(context, 'Please select a category');
      return;
    }

    context.read<ProductBloc>().add(
      CreateProductEvent(
        sku: _skuController.text.trim(),
        productName: _productNameController.text.trim(),
        barcode: _qrCodeController.text.trim(),
        categoryId: _selectedCategoryId,
        unitOfMeasure: (_selectedUnit ?? _unitOfMeasureController.text).trim(),
      ),
    );
  }

  // barcode scanner removed for this iteration

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _hintColor, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              icon: Icon(Icons.keyboard_arrow_down, color: _hintColor),
              hint: hint != null
                  ? Text(hint, style: TextStyle(color: _hintColor))
                  : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onScanQrPressed() async {
    final result = await Navigator.of(context).push(
      WHScannerPage.route(
        title: 'Scan Barcode',
        subtitle: 'Arahkan kamera ke barcode produk',
        formats: const [
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _qrCodeController.text = result;
      });
    }
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
                      WHTextField(
                        label: 'SKU Number',
                        controller: _skuController,
                        hintText: 'e.g., LTP-ASUS-001',
                      ),
                      const SizedBox(height: 16),
                      WHTextField(
                        label: 'Product Name',
                        controller: _productNameController,
                        hintText: 'e.g., Electronic',
                      ),
                      const SizedBox(height: 16),
                      WHTextField(
                        label: 'Barcode',
                        controller: _qrCodeController,
                        hintText: 'Scan or enter barcode',
                        suffixIcon: Icons.qr_code_scanner_rounded,
                        onSuffixTap: _onScanQrPressed,
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ProductBloc, ProductState>(
                        buildWhen: (prev, curr) =>
                            curr is CategoriesLoaded ||
                            curr is CategoriesLoading,
                        builder: (context, state) {
                          // FIX: Added explicit List<Category> type so cat.id is recognized
                          final List<Category> categories =
                              state is CategoriesLoaded
                              ? state.categories
                              : <Category>[];

                          return WHDropdownField<int>(
                            label: 'Category',
                            hintText: state is CategoriesLoading
                                ? 'Loading categories...'
                                : 'Select Category',
                            selectedValue: _selectedCategoryId,
                            // Now cat.id and cat.name will be recognized perfectly
                            items: categories
                                .map(
                                  (cat) => WHDropdownItem<int>(
                                    value: cat.id,
                                    label: cat.name,
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() => _selectedCategoryId = val);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      // Unit of measure dropdown
                      WHDropdownField<String>(
                        label: 'Unit of Measure',
                        hintText: 'Select Unit',
                        selectedValue: _selectedUnit,
                        items: _unitOptions.map((u) {
                          return WHDropdownItem(value: u, label: u);
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedUnit = val),
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
