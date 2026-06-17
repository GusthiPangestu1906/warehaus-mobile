import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:product/domain/entities/category.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.productId,
    required this.initialSku,
    required this.initialProductName,
    required this.initialBarcode,
    required this.initialUnitOfMeasure,
    this.initialCategoryId,
  });

  final String productId;
  final String initialSku;
  final String initialProductName;
  final String initialBarcode;
  final String initialUnitOfMeasure;
  final int? initialCategoryId;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController;
  late final TextEditingController _productNameController;
  late final TextEditingController _barcodeController;

  int? _selectedCategoryId;
  String? _selectedUnit;
  late List<String> _unitOptions;

  bool _isSubmitting = false;

  static const _primaryOrange = WHStyles.primary;

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController(text: widget.initialSku);
    _productNameController = TextEditingController(
      text: widget.initialProductName,
    );
    _barcodeController = TextEditingController(text: widget.initialBarcode);
    _selectedCategoryId = widget.initialCategoryId;

    // Default unit options, same as Create Product page. If the product's
    // current unit isn't in the default list (e.g. legacy/free-text data),
    // it's injected so the dropdown always has a matching value and never
    // throws a "no matching item" assertion.
    _unitOptions = ['PCS', 'BOX', 'KG', 'L'];
    final initialUnit = widget.initialUnitOfMeasure.trim();
    if (initialUnit.isNotEmpty) {
      final match = _unitOptions.firstWhere(
        (u) => u.toLowerCase() == initialUnit.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        _selectedUnit = match;
      } else {
        _unitOptions = [initialUnit, ..._unitOptions];
        _selectedUnit = initialUnit;
      }
    }

    context.read<ProductBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _skuController.dispose();
    _productNameController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _onScanBarcodePressed() async {
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
        _barcodeController.text = result;
      });
    }
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final sku = _skuController.text.trim();
    final productName = _productNameController.text.trim();
    final barcode = _barcodeController.text.trim();

    if (sku.isEmpty) {
      WHSnackBar.showError(context, 'SKU wajib diisi.');
      return;
    }

    if (productName.isEmpty) {
      WHSnackBar.showError(context, 'Nama produk wajib diisi.');
      return;
    }

    if (_selectedCategoryId == null) {
      WHSnackBar.showError(context, 'Silakan pilih kategori.');
      return;
    }

    if (_selectedUnit == null || _selectedUnit!.trim().isEmpty) {
      WHSnackBar.showError(context, 'Silakan pilih unit of measure.');
      return;
    }

    setState(() => _isSubmitting = true);
    context.read<ProductBloc>().add(
      UpdateProductEvent(
        id: widget.productId,
        sku: sku,
        productName: productName,
        barcode: barcode,
        unitOfMeasure: _selectedUnit,
        categoryId: _selectedCategoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (!_isSubmitting) return;

        if (state is ProductActionSuccess && state.action == 'updated') {
          setState(() => _isSubmitting = false);
          WHSnackBar.showSuccess(context, 'Produk berhasil diupdate!');
          Navigator.of(context).pop(true);
        } else if (state is ProductError) {
          setState(() => _isSubmitting = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: WHAppbar(title: 'Edit Product'),
        body: AbsorbPointer(
          absorbing: _isSubmitting,
          child: Column(
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
                          controller: _barcodeController,
                          hintText: 'Scan or enter barcode',
                          suffixIcon: Icons.qr_code_scanner_rounded,
                          onSuffixTap: _onScanBarcodePressed,
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<ProductBloc, ProductState>(
                          buildWhen: (prev, curr) =>
                              curr is CategoriesLoaded ||
                              curr is CategoriesLoading ||
                              curr is CategoriesError,
                          builder: (context, state) {
                            final List<Category> categories =
                                state is CategoriesLoaded
                                ? state.categories
                                : <Category>[];

                            // Only pass a selectedValue once we know it
                            // actually exists among the loaded items, so we
                            // never hand the dropdown a value with no
                            // matching item (e.g. while categories are still
                            // loading).
                            final matchedCategoryId =
                                categories.any(
                                  (c) => c.id == _selectedCategoryId,
                                )
                                ? _selectedCategoryId
                                : null;

                            return WHDropdownField<int>(
                              label: 'Category',
                              hintText: state is CategoriesLoading
                                  ? 'Loading categories...'
                                  : 'Select Category',
                              selectedValue: matchedCategoryId,
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
                        WHDropdownField<String>(
                          label: 'Unit of Measure',
                          hintText: 'Select Unit',
                          selectedValue: _selectedUnit,
                          items: _unitOptions
                              .map((u) => WHDropdownItem(value: u, label: u))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedUnit = val),
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
                    onPressed: _isSubmitting ? null : _onSubmit,
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
                      _isSubmitting ? 'Saving...' : 'Update Product',
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
