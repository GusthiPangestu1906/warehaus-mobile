import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';

class CreateSalesOrderPage extends StatefulWidget {
  const CreateSalesOrderPage({super.key});

  @override
  State<CreateSalesOrderPage> createState() => _CreateSalesOrderPageState();
}

class _CreateSalesOrderPageState extends State<CreateSalesOrderPage> {
  final _formKey = GlobalKey<FormState>();

  final _customerNameCtrl = TextEditingController();
  final _shippingAddressCtrl = TextEditingController();
  final _courierCtrl = TextEditingController();
  DateTime? _requiredDeliveryDate;

  // List item: [{productId, qtyOrdered}]
  final List<Map<String, dynamic>> _items = [];

  // Controllers untuk item baru
  final _productIdCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _shippingAddressCtrl.dispose();
    _courierCtrl.dispose();
    _productIdCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  void _addItem() {
    final productId = int.tryParse(_productIdCtrl.text.trim());
    final qty = int.tryParse(_qtyCtrl.text.trim());

    if (productId == null || productId < 1) {
      WHSnackBar.showError(context, 'Product ID tidak valid');
      return;
    }
    if (qty == null || qty < 1) {
      WHSnackBar.showError(context, 'Qty minimal 1');
      return;
    }

    setState(() {
      _items.add({'productId': productId, 'qtyOrdered': qty});
    });
    _productIdCtrl.clear();
    _qtyCtrl.clear();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _requiredDeliveryDate = picked);
    }
  }

  void _submit() {
    final customerName = _customerNameCtrl.text.trim();
    final shippingAddress = _shippingAddressCtrl.text.trim();
    final courier = _courierCtrl.text.trim();

    if (_validateNotEmpty(customerName, 'Nama pelanggan') != null) {
      WHSnackBar.showError(context, 'Nama pelanggan wajib diisi');
      return;
    }
    if (_validateNotEmpty(shippingAddress, 'Alamat') != null) {
      WHSnackBar.showError(context, 'Alamat wajib diisi');
      return;
    }
    if (_validateNotEmpty(courier, 'Kurir') != null) {
      WHSnackBar.showError(context, 'Kurir wajib diisi');
      return;
    }
    if (_requiredDeliveryDate == null) {
      WHSnackBar.showError(context, 'Pilih tanggal pengiriman');
      return;
    }
    if (_items.isEmpty) {
      WHSnackBar.showError(context, 'Tambahkan minimal 1 item');
      return;
    }

    context.read<SalesOrderBloc>().add(
          CreateSalesOrderEvent(
            customerName: customerName,
            shippingAddress: shippingAddress,
            courier: courier,
            requiredDeliveryDate: _requiredDeliveryDate!.toIso8601String(),
            items: _items,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesOrderBloc, SalesOrderState>(
      listener: (context, state) {
        if (state is SalesOrderActionSuccess) {
          WHSnackBar.showSuccess(context, state.message);
          Navigator.of(context).pop();
        } else if (state is SalesOrderError) {
          WHSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: const WHAppbar(title: 'CREATE SALES ORDER'),
        body: BlocBuilder<SalesOrderBloc, SalesOrderState>(
          builder: (context, state) {
            final isLoading = state is SalesOrderLoading;
            return Stack(
              children: [
                Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Customer Info ──────────────────────────────
                      _SectionHeader(title: 'Informasi Pelanggan'),
                      const SizedBox(height: 12),
                      WHTextField(
                        label: 'Nama Pelanggan',
                        controller: _customerNameCtrl,
                      ),
                      const SizedBox(height: 12),
                      WHTextField(
                        label: 'Alamat Pengiriman',
                        controller: _shippingAddressCtrl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      WHTextField(
                        label: 'Kurir',
                        hintText: 'Contoh: JNE, TIKI, SiCepat',
                        controller: _courierCtrl,
                      ),
                      const SizedBox(height: 12),

                      // ── Delivery Date ──────────────────────────────
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: WHColors.surface,
                            border: Border.all(color: WHColors.grey5, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: WHColors.grey3, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _requiredDeliveryDate == null
                                    ? 'Tanggal Pengiriman'
                                    : '${_requiredDeliveryDate!.day}/${_requiredDeliveryDate!.month}/${_requiredDeliveryDate!.year}',
                                style: TextStyle(
                                  color: _requiredDeliveryDate == null
                                      ? WHColors.grey3
                                      : WHColors.grey1,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Items ──────────────────────────────────────
                      _SectionHeader(title: 'Item Produk'),
                      const SizedBox(height: 12),

                      // Form tambah item
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WHColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: WHColors.grey5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: WHTextField(
                                    label: 'Product ID',
                                    controller: _productIdCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: WHTextField(
                                    label: 'Qty',
                                    controller: _qtyCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: WHOutlinedButton(
                                label: '+ Tambah Item',
                                onPressed: _addItem,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // List item yang sudah ditambah
                      if (_items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Belum ada item ditambahkan',
                            style: TextStyle(color: WHColors.grey3, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: WHColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: WHColors.grey5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Product ID: ${item['productId']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${item['qtyOrdered']}',
                                        style: TextStyle(
                                          color: WHColors.grey2,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () => _removeItem(index),
                                    icon: const Icon(Icons.delete_outline,
                                        color: WHColors.error2),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 32),

                      // ── Submit ─────────────────────────────────────
                      WhPrimaryButton(
                        text: 'Buat Sales Order',
                        onPressed: isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: WHColors.grey1,
      ),
    );
  }
}