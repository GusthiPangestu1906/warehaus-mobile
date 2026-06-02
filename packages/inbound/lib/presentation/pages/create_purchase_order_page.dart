import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/widgets/product_form_card.dart';
import 'package:product/domain/entities/product.dart';

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

  // Array utama penyimpan form produk dinamis
  final List<CreatePoItemParams> _selectedItems = [];

  // Gunakan tipe data Entity Product dari package sebelah, jangan dynamic raw map
  final List<Product> _masterProducts = [];

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih minimal 1 item produk!')),
        );
        return;
      }

      // Validasi tambahan agar tidak ada produk kosong (id == 0) yang terkirim
      if (_selectedItems.any((item) => item.productId == 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap pilih produk pada semua form list!'),
          ),
        );
        return;
      }

      final params = CreatePoParams(
        supplierName: _supplierName.text,
        eta: DateTime.parse(_eta.text),
        carrier: _carrier.text,
        items: _selectedItems,
      );

      context.read<PurchaseOrderBloc>().add(CreatePurchaseOrderEvent(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseOrderBloc, PurchaseOrderState>(
      listener: (context, state) {
        if (state is CreatePurchaseOrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase Order berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is PurchaseOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is PurchaseOrderLoading;

        return Scaffold(
          backgroundColor: WHColors.background,
          appBar: WHAppbar(title: 'PURCHASE ORDER FORM'),

          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: WHButton(
              label: 'Submit Form',
              icon: Icons.check_circle_outline,
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
                  WHTextField(
                    label: 'Supplier Name',
                    hintText: 'e.g., Mayora',
                    controller: _supplierName,
                  ),
                  const SizedBox(height: 16),
                  WHDateField(
                    label: 'Expected Arrival Date (ETA):',
                    hintText: '01/01/2026',
                    selectedDate: _eta.text.isEmpty
                        ? null
                        : DateTime.tryParse(_eta.text),
                    onDateSelected: (date) {
                      setState(() {
                        _eta.text = date.toIso8601String();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  WHTextField(
                    label: 'Carrier',
                    hintText: 'e.g., JNE Cargo',
                    controller: _carrier,
                  ),
                  const SizedBox(height: 24),

                  // Header List Produk
                  const Text(
                    'Product List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final currentItem = _selectedItems[index];

                      return ProductFormCard(
                        masterProducts: _masterProducts,
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
                          CreatePoItemParams(productId: 0, qtyExpected: 0),
                        );
                      });
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
