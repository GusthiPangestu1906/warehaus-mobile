import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_form_state.dart';
import 'package:outbound/domain/usecases/form/get_products.dart';
import 'package:outbound/domain/usecases/form/get_couriers.dart';
import 'package:outbound/domain/usecases/form/get_provinces.dart';
import 'package:outbound/domain/usecases/form/get_cities.dart';
import 'package:outbound/domain/usecases/form/get_districts.dart';

class SalesOrderFormCubit extends Cubit<SalesOrderFormState> {
  final GetProducts getProductsUseCase;
  final GetCouriers getCouriersUseCase;
  final GetProvinces getProvincesUseCase;
  final GetCities getCitiesUseCase;
  final GetDistricts getDistrictsUseCase;

  SalesOrderFormCubit({
    required this.getProductsUseCase,
    required this.getCouriersUseCase,
    required this.getProvincesUseCase,
    required this.getCitiesUseCase,
    required this.getDistrictsUseCase,
  }) : super(const SalesOrderFormState());

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

    final result = await getProductsUseCase();

    result.fold(
      (failure) {
        debugPrint(
          '[SalesOrderFormCubit] failed to load products: ${failure.message}',
        );
        emit(
          state.copyWith(
            isLoadingProducts: false,
            errorMessage: failure.message,
          ),
        );
      },
      (products) =>
          emit(state.copyWith(products: products, isLoadingProducts: false)),
    );
  }

  Future<void> fetchCouriers() async {
    emit(state.copyWith(isLoadingCouriers: true, clearError: true));

    final result = await getCouriersUseCase();

    result.fold(
      (failure) {
        debugPrint(
          '[SalesOrderFormCubit] failed to load couriers: ${failure.message}',
        );
        emit(
          state.copyWith(
            isLoadingCouriers: false,
            errorMessage: failure.message,
          ),
        );
      },
      (couriers) =>
          emit(state.copyWith(couriers: couriers, isLoadingCouriers: false)),
    );
  }

  Future<void> fetchProvinces() async {
    emit(state.copyWith(isLoadingProvinces: true, clearError: true));

    final result = await getProvincesUseCase();

    result.fold(
      (failure) {
        debugPrint(
          '[SalesOrderFormCubit] failed to load provinces: ${failure.message}',
        );
        emit(
          state.copyWith(
            isLoadingProvinces: false,
            errorMessage: failure.message,
          ),
        );
      },
      (provinces) =>
          emit(state.copyWith(provinces: provinces, isLoadingProvinces: false)),
    );
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

    final result = await getCitiesUseCase(provinceCode);

    await result.fold(
      (failure) async {
        debugPrint(
          '[SalesOrderFormCubit] failed to load cities: ${failure.message}',
        );
        emit(
          state.copyWith(isLoadingCities: false, errorMessage: failure.message),
        );
      },
      (cities) async {
        emit(state.copyWith(cities: cities, isLoadingCities: false));
        if (selectedCityCode != null) {
          await fetchDistricts(selectedCityCode);
        }
      },
    );
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

    final result = await getDistrictsUseCase(cityCode);

    result.fold(
      (failure) {
        debugPrint(
          '[SalesOrderFormCubit] failed to load districts: ${failure.message}',
        );
        emit(
          state.copyWith(
            isLoadingDistricts: false,
            errorMessage: failure.message,
          ),
        );
      },
      (districts) =>
          emit(state.copyWith(districts: districts, isLoadingDistricts: false)),
    );
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
}
