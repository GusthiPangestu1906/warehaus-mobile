import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:outbound/data/datasources/outbound_product_api_datasource.dart';
import 'package:outbound/data/datasources/region_api_datasource.dart';
import 'package:outbound/data/models/so_item_model.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';
import 'package:outbound/presentation/models/sales_order_product_line.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_bottom_bar.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_product_step.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_shipping_step.dart';

class CreateSalesOrderPage extends StatefulWidget {
  const CreateSalesOrderPage({super.key});

  @override
  State<CreateSalesOrderPage> createState() => _CreateSalesOrderPageState();
}

class _CreateSalesOrderPageState extends State<CreateSalesOrderPage> {
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

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _couriers = [];
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _districts = [];

  int? _selectedCourierId;
  String? _selectedProvinceCode;
  String? _selectedCityCode;
  String? _selectedDistrictCode;

  bool _loadingProducts = true;
  bool _loadingCouriers = true;
  bool _loadingProvinces = true;
  bool _loadingCities = false;
  bool _loadingDistricts = false;

  OutboundProductApiDatasource get _productApi =>
      GetIt.instance<OutboundProductApiDatasource>();
  RegionApiDatasource get _regionApi => GetIt.instance<RegionApiDatasource>();

  @override
  void initState() {
    super.initState();
    _requiredDeliveryDate = DateTime(_today.year, _today.month, _today.day + 1);
    _noteCtrl.addListener(_refreshNoteCounter);
    _loadInitialDropdowns();
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

  Future<void> _loadInitialDropdowns() async {
    await Future.wait([_fetchProducts(), _fetchCouriers(), _fetchProvinces()]);
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _productApi.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProducts = false);
      WHSnackBar.showError(context, 'Failed to load products');
    }
  }

  Future<void> _fetchCouriers() async {
    try {
      final couriers = await _regionApi.getCouriers();
      if (!mounted) return;
      setState(() {
        _couriers = couriers;
        _selectedCourierId = _firstId(couriers);
        _loadingCouriers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCouriers = false);
      WHSnackBar.showError(context, 'Failed to load couriers');
    }
  }

  Future<void> _fetchProvinces() async {
    try {
      final provinces = await _regionApi.getProvinces();
      if (!mounted) return;
      setState(() {
        _provinces = provinces;
        _loadingProvinces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProvinces = false);
      WHSnackBar.showError(context, 'Failed to load provinces');
    }
  }

  Future<void> _fetchCities(String provinceCode) async {
    setState(() {
      _loadingCities = true;
      _cities = [];
      _districts = [];
      _selectedCityCode = null;
      _selectedDistrictCode = null;
    });

    try {
      final cities = await _regionApi.getCities(provinceCode);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCities = false);
      WHSnackBar.showError(context, 'Failed to load cities');
    }
  }

  Future<void> _fetchDistricts(String cityCode) async {
    setState(() {
      _loadingDistricts = true;
      _districts = [];
      _selectedDistrictCode = null;
    });

    try {
      final districts = await _regionApi.getDistricts(cityCode);
      if (!mounted) return;
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDistricts = false);
      WHSnackBar.showError(context, 'Failed to load districts');
    }
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
    setState(() => _selectedProvinceCode = code);
    if (code != null) _fetchCities(code);
  }

  void _setCity(String? code) {
    setState(() => _selectedCityCode = code);
    if (code != null) _fetchDistricts(code);
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
    context.read<SalesOrderBloc>().add(
      CreateSalesOrderEvent(
        customerName: contactPerson,
        companyName: companyName.isEmpty ? contactPerson : companyName,
        contactPerson: contactPerson,
        phoneNumber: _phoneNumberCtrl.text.trim(),
        shippingAddress: _addressCtrl.text.trim(),
        provinceCode: _selectedProvinceCode!,
        cityCode: _selectedCityCode!,
        districtCode: _selectedDistrictCode!,
        postalCode: _postalCodeCtrl.text.trim(),
        courierId: _selectedCourierId!,
        requiredDeliveryDate: _toUtcDateString(_requiredDeliveryDate!),
        items: _selectedItems.map((item) => item.toJson()).toList(),
      ),
    );
  }

  List<SoItemModel> get _selectedItems {
    return _productLines.map((line) {
      final product = _findProduct(line.productId!);
      return SoItemModel(
        productId: line.productId!,
        qtyOrdered: line.qty,
        productName: product?['productName'] as String?,
      );
    }).toList();
  }

  Map<String, dynamic>? _findProduct(int productId) {
    for (final product in _products) {
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
    return BlocListener<SalesOrderBloc, SalesOrderState>(
      listener: (context, state) {
        if (state is SalesOrderActionSuccess) {
          WHSnackBar.showSuccess(context, state.message);
          Navigator.of(context).pop();
        } else if (state is SalesOrderError) {
          WHSnackBar.showError(context, state.message);
        }
      },
      child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
        builder: (context, state) {
          final isSubmitting = state is SalesOrderLoading;
          return Scaffold(
            backgroundColor: WHColors.background,
            appBar: WHAppbar(title: 'Sales Order Form'),
            body: _step == 0 ? _buildProductStep() : _buildShippingStep(),
            bottomNavigationBar: SalesOrderBottomBar(
              label: _step == 0 ? 'Next' : 'Submit Form',
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

  Widget _buildProductStep() {
    return SalesOrderProductStep(
      requiredDeliveryDate: _requiredDeliveryDate,
      lines: _productLines,
      products: _products,
      isLoadingProducts: _loadingProducts,
      onPickDate: _pickDate,
      onAddProduct: _addProductLine,
      onDeleteProduct: _deleteProductLine,
      onProductChanged: _setProduct,
      onQtyChanged: _setQty,
    );
  }

  Widget _buildShippingStep() {
    return SalesOrderShippingStep(
      formKey: _shippingFormKey,
      companyNameController: _companyNameCtrl,
      contactPersonController: _contactPersonCtrl,
      phoneNumberController: _phoneNumberCtrl,
      addressController: _addressCtrl,
      postalCodeController: _postalCodeCtrl,
      noteController: _noteCtrl,
      noteLength: _noteCtrl.text.length,
      couriers: _couriers,
      provinces: _provinces,
      cities: _cities,
      districts: _districts,
      selectedCourierId: _selectedCourierId,
      selectedProvinceCode: _selectedProvinceCode,
      selectedCityCode: _selectedCityCode,
      selectedDistrictCode: _selectedDistrictCode,
      loadingCouriers: _loadingCouriers,
      loadingProvinces: _loadingProvinces,
      loadingCities: _loadingCities,
      loadingDistricts: _loadingDistricts,
      onCourierChanged: (id) => setState(() => _selectedCourierId = id),
      onProvinceChanged: _setProvince,
      onCityChanged: _setCity,
      onDistrictChanged: (code) => setState(() => _selectedDistrictCode = code),
    );
  }
}
