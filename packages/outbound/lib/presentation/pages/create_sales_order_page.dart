import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:outbound/data/datasources/outbound_product_api_datasource.dart';
import 'package:outbound/data/datasources/region_api_datasource.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_form_cubit.dart';
import 'package:outbound/presentation/bloc/sales_order_form_state.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';
import 'package:outbound/presentation/models/sales_order_product_line.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_bottom_bar.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_product_step.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_shipping_step.dart';

class CreateSalesOrderPage extends StatelessWidget {
  const CreateSalesOrderPage({super.key, this.initialOrder});

  final SalesOrder? initialOrder;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SalesOrderFormCubit(
            productApi: GetIt.instance<OutboundProductApiDatasource>(),
            regionApi: GetIt.instance<RegionApiDatasource>(),
          ),
        ),
        BlocProvider(create: (_) => GetIt.instance<SalesOrderBloc>()),
      ],
      child: _CreateSalesOrderView(initialOrder: initialOrder),
    );
  }
}

class _CreateSalesOrderView extends StatefulWidget {
  const _CreateSalesOrderView({this.initialOrder});

  final SalesOrder? initialOrder;

  @override
  State<_CreateSalesOrderView> createState() => _CreateSalesOrderViewState();
}

class _CreateSalesOrderViewState extends State<_CreateSalesOrderView> {
  final _shippingFormKey = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _phoneNumberCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final List<SalesOrderProductLine> _productLines = [SalesOrderProductLine()];
  final DateTime _today = DateTime.now();

  int _step = 0;
  DateTime? _requiredDeliveryDate;

  int? _selectedCourierId;
  String? _selectedProvinceCode;
  String? _selectedCityCode;
  String? _selectedDistrictCode;

  bool get _isEdit => widget.initialOrder != null;

  @override
  void initState() {
    super.initState();
    _requiredDeliveryDate = DateTime(_today.year, _today.month, _today.day + 1);
    _populateInitialOrder();
    _noteCtrl.addListener(_refreshNoteCounter);
    context.read<SalesOrderFormCubit>().loadInitialData(
      initialProvinceCode: _selectedProvinceCode,
      initialCityCode: _selectedCityCode,
      initialDistrictCode: _selectedDistrictCode,
    );
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _phoneNumberCtrl.dispose();
    _addressCtrl.dispose();
    _postalCodeCtrl.dispose();
    _noteCtrl
      ..removeListener(_refreshNoteCounter)
      ..dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _requiredDeliveryDate ?? _today.add(const Duration(days: 1)),
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _requiredDeliveryDate = picked);
    }
  }

  void _refreshNoteCounter() {
    if (mounted) setState(() {});
  }

  void _populateInitialOrder() {
    final order = widget.initialOrder;
    if (order == null) return;

    _companyNameCtrl.text = order.companyName ?? '';
    _contactPersonCtrl.text = order.contactPerson ?? order.customerName;
    _phoneNumberCtrl.text = order.phoneNumber ?? '';
    _noteCtrl.text = order.note ?? '';
    _addressCtrl.text = order.shippingAddress;
    _postalCodeCtrl.text = order.postalCode ?? '';
    _selectedCourierId = order.courierId;
    _selectedProvinceCode = order.provinceCode;
    _selectedCityCode = order.cityCode;
    _selectedDistrictCode = order.districtCode;
    _requiredDeliveryDate =
        DateTime.tryParse(order.requiredDeliveryDate)?.toLocal() ??
        _requiredDeliveryDate;

    _productLines
      ..clear()
      ..addAll(
        order.items.isEmpty
            ? [SalesOrderProductLine()]
            : order.items.map(
                (item) => SalesOrderProductLine(
                  productId: item.productId,
                  qty: item.qtyOrdered,
                ),
              ),
      );
  }

  void _addProductLine() {
    setState(() => _productLines.add(SalesOrderProductLine()));
  }

  void _deleteProductLine(int index) {
    setState(() {
      if (_productLines.length == 1) {
        _productLines[index] = SalesOrderProductLine();
      } else {
        _productLines.removeAt(index);
      }
    });
  }

  void _setProduct(int index, int? productId) {
    setState(() => _productLines[index].productId = productId);
  }

  void _setQty(int index, int qty) {
    if (qty < 1) return;
    setState(() => _productLines[index].qty = qty);
  }

  void _setProvince(String? code) {
    setState(() {
      _selectedProvinceCode = code;
      _selectedCityCode = null;
      _selectedDistrictCode = null;
    });
    if (code != null) {
      context.read<SalesOrderFormCubit>().fetchCities(code);
    } else {
      context.read<SalesOrderFormCubit>().clearCitiesAndDistricts();
    }
  }

  void _setCity(String? code) {
    setState(() {
      _selectedCityCode = code;
      _selectedDistrictCode = null;
    });
    if (code != null) {
      context.read<SalesOrderFormCubit>().fetchDistricts(code);
    } else {
      context.read<SalesOrderFormCubit>().clearDistricts();
    }
  }

  void _goToShipping() {
    if (_requiredDeliveryDate == null) {
      WHSnackBar.showError(context, 'Please select required delivery date');
      return;
    }

    if (_productLines.any((line) => line.productId == null)) {
      WHSnackBar.showError(context, 'Please select all products');
      return;
    }

    final productIds = _productLines.map((line) => line.productId!).toList();
    if (productIds.toSet().length != productIds.length) {
      WHSnackBar.showError(context, 'Product cannot be duplicated');
      return;
    }

    setState(() => _step = 1);
  }

  void _submit() {
    if (!_shippingFormKey.currentState!.validate()) return;
    if (_selectedCourierId == null) {
      WHSnackBar.showError(context, 'Please select courier');
      return;
    }
    if (_selectedProvinceCode == null ||
        _selectedCityCode == null ||
        _selectedDistrictCode == null) {
      WHSnackBar.showError(context, 'Please complete shipping address');
      return;
    }

    final contactPerson = _contactPersonCtrl.text.trim();
    final companyName = _companyNameCtrl.text.trim();
    final products = context.read<SalesOrderFormCubit>().state.products;
    final payload = _selectedItems(products);
    final bloc = context.read<SalesOrderBloc>();
    final order = widget.initialOrder;

    if (order == null) {
      bloc.add(
        CreateSalesOrderEvent(
          customerName: contactPerson,
          companyName: companyName.isEmpty ? contactPerson : companyName,
          contactPerson: contactPerson,
          phoneNumber: _phoneNumberCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
          shippingAddress: _addressCtrl.text.trim(),
          provinceCode: _selectedProvinceCode!,
          cityCode: _selectedCityCode!,
          districtCode: _selectedDistrictCode!,
          postalCode: _postalCodeCtrl.text.trim(),
          courierId: _selectedCourierId!,
          requiredDeliveryDate: _toUtcDateString(_requiredDeliveryDate!),
          items: payload,
        ),
      );
      return;
    }

    bloc.add(
      UpdateSalesOrderEvent(
        id: order.id,
        customerName: contactPerson,
        companyName: companyName.isEmpty ? contactPerson : companyName,
        contactPerson: contactPerson,
        phoneNumber: _phoneNumberCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        shippingAddress: _addressCtrl.text.trim(),
        provinceCode: _selectedProvinceCode!,
        cityCode: _selectedCityCode!,
        districtCode: _selectedDistrictCode!,
        postalCode: _postalCodeCtrl.text.trim(),
        courierId: _selectedCourierId!,
        requiredDeliveryDate: _toUtcDateString(_requiredDeliveryDate!),
        items: payload,
      ),
    );
  }

  List<SalesOrderItemParams> _selectedItems(
    List<Map<String, dynamic>> products,
  ) {
    return _productLines.map((line) {
      final product = _findProduct(products, line.productId!);
      return SalesOrderItemParams(
        productId: line.productId!,
        qtyOrdered: line.qty,
        productName: product?['productName'] as String?,
      );
    }).toList();
  }

  Map<String, dynamic>? _findProduct(
    List<Map<String, dynamic>> products,
    int productId,
  ) {
    for (final product in products) {
      if (_intValue(product, 'id') == productId) return product;
    }
    return null;
  }

  int? _firstId(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;
    return _intValue(rows.first, 'id') ?? _intValue(rows.first, 'courierId');
  }

  int? _intValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _toUtcDateString(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SalesOrderFormCubit, SalesOrderFormState>(
          listenWhen: (previous, current) =>
              previous.couriers != current.couriers ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (_selectedCourierId == null && state.couriers.isNotEmpty) {
              setState(() => _selectedCourierId = _firstId(state.couriers));
            }

            final errorMessage = state.errorMessage;
            if (errorMessage != null && errorMessage.isNotEmpty) {
              WHSnackBar.showError(context, errorMessage);
            }
          },
        ),
        BlocListener<SalesOrderBloc, SalesOrderState>(
          listener: (context, state) {
            if (state is SalesOrderActionSuccess) {
              Navigator.of(context).pop(true);
            } else if (state is SalesOrderError) {
              WHSnackBar.showError(context, state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
        builder: (context, state) {
          final isSubmitting = state is SalesOrderLoading;
          return Scaffold(
            backgroundColor: WHColors.background,
            appBar: WHAppbar(
              title: _isEdit ? 'Edit Sales Order' : 'Sales Order Form',
            ),
            body: BlocBuilder<SalesOrderFormCubit, SalesOrderFormState>(
              builder: (context, formState) {
                return _step == 0
                    ? _buildProductStep(formState)
                    : _buildShippingStep(formState);
              },
            ),
            bottomNavigationBar: SalesOrderBottomBar(
              label: _step == 0
                  ? 'Next'
                  : _isEdit
                  ? 'Save Changes'
                  : 'Submit Form',
              showCheckIcon: _step == 1,
              isLoading: isSubmitting,
              onPressed: isSubmitting
                  ? null
                  : _step == 0
                  ? _goToShipping
                  : _submit,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductStep(SalesOrderFormState formState) {
    return SalesOrderProductStep(
      requiredDeliveryDate: _requiredDeliveryDate,
      lines: _productLines,
      products: formState.products,
      isLoadingProducts: formState.isLoadingProducts,
      onPickDate: _pickDate,
      onAddProduct: _addProductLine,
      onDeleteProduct: _deleteProductLine,
      onProductChanged: _setProduct,
      onQtyChanged: _setQty,
    );
  }

  Widget _buildShippingStep(SalesOrderFormState formState) {
    return SalesOrderShippingStep(
      formKey: _shippingFormKey,
      companyNameController: _companyNameCtrl,
      contactPersonController: _contactPersonCtrl,
      phoneNumberController: _phoneNumberCtrl,
      addressController: _addressCtrl,
      postalCodeController: _postalCodeCtrl,
      noteController: _noteCtrl,
      noteLength: _noteCtrl.text.length,
      couriers: formState.couriers,
      provinces: formState.provinces,
      cities: formState.cities,
      districts: formState.districts,
      selectedCourierId: _selectedCourierId,
      selectedProvinceCode: _selectedProvinceCode,
      selectedCityCode: _selectedCityCode,
      selectedDistrictCode: _selectedDistrictCode,
      loadingCouriers: formState.isLoadingCouriers,
      loadingProvinces: formState.isLoadingProvinces,
      loadingCities: formState.isLoadingCities,
      loadingDistricts: formState.isLoadingDistricts,
      onCourierChanged: (id) => setState(() => _selectedCourierId = id),
      onProvinceChanged: _setProvince,
      onCityChanged: _setCity,
      onDistrictChanged: (code) => setState(() => _selectedDistrictCode = code),
    );
  }
}
