import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/widgets/create_purchase_order/arrival_form_card.dart';
import 'package:inbound/presentation/widgets/create_purchase_order/product_form_card.dart';
import 'package:product/domain/entities/product.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';

class CreatePurchaseOrderPage extends StatefulWidget {
  const CreatePurchaseOrderPage({super.key});

  @override
  State<CreatePurchaseOrderPage> createState() =>
      _CreatePurchaseOrderPageState();
}

class _CreatePurchaseOrderPageState extends State<CreatePurchaseOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierName = TextEditingController();
  final _eta = TextEditingController();
  final _carrier = TextEditingController();

  final List<CreatePoItemParams> _selectedItems = [];
  bool _isSubmittingPo = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductsEvent());
  }

  @override
  void dispose() {
    _supplierName.dispose();
    _eta.dispose();
    _carrier.dispose();
    super.dispose();
  }

  void _onSUbmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedItems.isEmpty) {
        WHSnackBar.showError(context, 'Pilih minimal 1 item produk!');
        return;
      }

      if (_selectedItems.any((item) => item.productId == 0)) {
        WHSnackBar.showError(
          context,
          'Harap pilih produk pada semua form list!',
        );
        return;
      }

      if (_selectedItems.any((item) => item.qtyExpected <= 0)) {
        WHSnackBar.showError(context, 'Qty expected harus lebih dari 0.');
        return;
      }

      final params = CreatePoParams(
        supplierName: _supplierName.text,
        eta: DateTime.parse(_eta.text),
        carrier: _carrier.text,
        items: _selectedItems,
      );

      setState(() => _isSubmittingPo = true);
      context.read<PurchaseOrderBloc>().add(CreatePurchaseOrderEvent(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseOrderBloc, PurchaseOrderState>(
      listener: (context, state) {
        if (state is CreatePurchaseOrderSuccess) {
          setState(() => _isSubmittingPo = false);
          WHSnackBar.showSuccess(context, 'Purchase Order berhasil dibuat!');
          Navigator.of(context).pop();
        } else if (state is PurchaseOrderError && _isSubmittingPo) {
          setState(() => _isSubmittingPo = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is PurchaseOrderLoading && _isSubmittingPo;

        return Scaffold(
          backgroundColor: WHColors.background,
          appBar: WHAppbar(title: 'PURCHASE ORDER FORM'),

          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: WHButton(
              label: 'Submit Form',
              icon: Icons.check_circle_outline,
              backgroundColor: WHColors.secondary,
              isLoading: isLoading,
              onPressed: isLoading ? null : _onSUbmit,
            ),
          ),

          body: AbsorbPointer(
            absorbing: isLoading,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ArrivalFormCard(
                    supplierNameController: _supplierName,
                    etaController: _eta,
                    carrierController: _carrier,
                  ),
                  const SizedBox(height: 24),

                  // Header List Produk
                  const Text(
                    'Product List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, productState) {
                      final masterProducts = productState is ProductLoaded
                          ? productState.products
                          : const <Product>[];

                      return Column(
                        children: [
                          if (productState is ProductLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: LinearProgressIndicator(),
                            ),
                          if (productState is ProductError)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: WHError(message: productState.message),
                            ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedItems.length,
                            itemBuilder: (context, index) {
                              final currentItem = _selectedItems[index];

                              return ProductFormCard(
                                masterProducts: masterProducts,
                                selectedProductId: currentItem.productId == 0
                                    ? null
                                    : currentItem.productId,
                                quantity: currentItem.qtyExpected,
                                onProductChanged: (productId) {
                                  setState(() {
                                    _selectedItems[index] = CreatePoItemParams(
                                      productId: productId ?? 0,
                                      qtyExpected: currentItem.qtyExpected,
                                    );
                                  });
                                },
                                onQtyChanged: (value) {
                                  setState(() {
                                    _selectedItems[index] = CreatePoItemParams(
                                      productId: currentItem.productId,
                                      qtyExpected: value,
                                    );
                                  });
                                },
                                onDelete: () {
                                  setState(() {
                                    _selectedItems.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          WHOutlinedButton(
                            label: 'Product',
                            icon: Icons.add,
                            onPressed: () {
                              setState(() {
                                _selectedItems.add(
                                  CreatePoItemParams(
                                    productId: 0,
                                    qtyExpected: 0,
                                  ),
                                );
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
