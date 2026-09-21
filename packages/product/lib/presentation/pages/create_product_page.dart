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
  String? _selectedUnit;
  int? _selectedCategoryId;

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
    final sku = _skuController.text.trim();
    final productName = _productNameController.text.trim();
    final barcode = _qrCodeController.text.trim();

    if (sku.isEmpty) {
      WHSnackBar.showError(context, 'SKU Number is required');
      return;
    }

    if (productName.isEmpty) {
      WHSnackBar.showError(context, 'Product Name is required');
      return;
    }

    if (barcode.isEmpty) {
      WHSnackBar.showError(context, 'Barcode is required');
      return;
    }

    if (_selectedCategoryId == null) {
      WHSnackBar.showError(context, 'Please select a category');
      return;
    }

    if (_selectedUnit == null || _selectedUnit!.isEmpty) {
      WHSnackBar.showError(context, 'Please select a unit of measure');
      return;
    }

    context.read<ProductBloc>().add(
      CreateProductEvent(
        sku: sku,
        productName: productName,
        barcode: barcode,
        categoryId: _selectedCategoryId,
        unitOfMeasure: _selectedUnit!.trim(),
      ),
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
          WHSnackBar.showError(context, state.message);
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
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: WHButton(
                      label: 'Save Product',
                      icon: Icons.check_circle_outline,
                      onPressed: state is ProductLoading ? null : _submit,
                      backgroundColor: WHColors.secondary,
                      isLoading: state is ProductLoading,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
