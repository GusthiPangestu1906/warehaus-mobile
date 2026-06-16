import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outbound/data/datasources/outbound_product_api_datasource.dart';
import 'package:outbound/data/datasources/region_api_datasource.dart';
import 'package:outbound/presentation/bloc/sales_order_form_state.dart';

class SalesOrderFormCubit extends Cubit<SalesOrderFormState> {
  SalesOrderFormCubit({
    required OutboundProductApiDatasource productApi,
    required RegionApiDatasource regionApi,
  })  : _productApi = productApi,
        _regionApi = regionApi,
        super(const SalesOrderFormState());

  final OutboundProductApiDatasource _productApi;
  final RegionApiDatasource _regionApi;

  Future<void> loadInitialData({
    String? initialProvinceCode,
    String? initialCityCode,
    String? initialDistrictCode,
  }) async {
    await Future.wait([fetchProducts(), fetchCouriers(), fetchProvinces()]);

    if (initialProvinceCode != null) {
      await fetchCities(
        initialProvinceCode,
        selectedCityCode: initialCityCode,
        selectedDistrictCode: initialDistrictCode,
      );
    }
  }

  Future<void> fetchProducts() async {
    emit(state.copyWith(isLoadingProducts: true, clearError: true));
    try {
      final products = await _productApi.getProducts();
      emit(state.copyWith(products: products, isLoadingProducts: false));
    } catch (e) {
      debugPrint('[SalesOrderFormCubit] failed to load products: $e');
      emit(
        state.copyWith(
          isLoadingProducts: false,
          errorMessage: _loadErrorMessage('products', e),
        ),
      );
    }
  }

  Future<void> fetchCouriers() async {
    emit(state.copyWith(isLoadingCouriers: true, clearError: true));
    try {
      final couriers = await _regionApi.getCouriers();
      emit(state.copyWith(couriers: couriers, isLoadingCouriers: false));
    } catch (e) {
      debugPrint('[SalesOrderFormCubit] failed to load couriers: $e');
      emit(
        state.copyWith(
          isLoadingCouriers: false,
          errorMessage: _loadErrorMessage('couriers', e),
        ),
      );
    }
  }

  Future<void> fetchProvinces() async {
    emit(state.copyWith(isLoadingProvinces: true, clearError: true));
    try {
      final provinces = await _regionApi.getProvinces();
      emit(state.copyWith(provinces: provinces, isLoadingProvinces: false));
    } catch (e) {
      debugPrint('[SalesOrderFormCubit] failed to load provinces: $e');
      emit(
        state.copyWith(
          isLoadingProvinces: false,
          errorMessage: _loadErrorMessage('provinces', e),
        ),
      );
    }
  }

  Future<void> fetchCities(
    String provinceCode, {
    String? selectedCityCode,
    String? selectedDistrictCode,
  }) async {
    emit(
      state.copyWith(
        cities: const [],
        districts: const [],
        isLoadingCities: true,
        clearError: true,
      ),
    );

    try {
      final cities = await _regionApi.getCities(provinceCode);
      emit(state.copyWith(cities: cities, isLoadingCities: false));

      if (selectedCityCode != null) {
        await fetchDistricts(selectedCityCode);
      }
    } catch (e) {
      debugPrint('[SalesOrderFormCubit] failed to load cities: $e');
      emit(
        state.copyWith(
          isLoadingCities: false,
          errorMessage: _loadErrorMessage('cities', e),
        ),
      );
    }
  }

  void clearCitiesAndDistricts() {
    emit(
      state.copyWith(
        cities: const [],
        districts: const [],
        isLoadingCities: false,
        isLoadingDistricts: false,
        clearError: true,
      ),
    );
  }

  Future<void> fetchDistricts(String cityCode) async {
    emit(
      state.copyWith(
        districts: const [],
        isLoadingDistricts: true,
        clearError: true,
      ),
    );

    try {
      final districts = await _regionApi.getDistricts(cityCode);
      emit(state.copyWith(districts: districts, isLoadingDistricts: false));
    } catch (e) {
      debugPrint('[SalesOrderFormCubit] failed to load districts: $e');
      emit(
        state.copyWith(
          isLoadingDistricts: false,
          errorMessage: _loadErrorMessage('districts', e),
        ),
      );
    }
  }

  void clearDistricts() {
    emit(
      state.copyWith(
        districts: const [],
        isLoadingDistricts: false,
        clearError: true,
      ),
    );
  }

  String _loadErrorMessage(String label, Object error) {
    final message = error.toString();
    if (message.contains('ApiException')) {
      return 'Failed to load $label: $message';
    }
    return 'Failed to load $label';
  }
}
