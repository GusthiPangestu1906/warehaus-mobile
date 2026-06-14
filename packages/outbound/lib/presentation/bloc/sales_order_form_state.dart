import 'package:equatable/equatable.dart';

class SalesOrderFormState extends Equatable {
  const SalesOrderFormState({
    this.products = const [],
    this.couriers = const [],
    this.provinces = const [],
    this.cities = const [],
    this.districts = const [],
    this.isLoadingProducts = false,
    this.isLoadingCouriers = false,
    this.isLoadingProvinces = false,
    this.isLoadingCities = false,
    this.isLoadingDistricts = false,
    this.errorMessage,
  });

  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> couriers;
  final List<Map<String, dynamic>> provinces;
  final List<Map<String, dynamic>> cities;
  final List<Map<String, dynamic>> districts;
  final bool isLoadingProducts;
  final bool isLoadingCouriers;
  final bool isLoadingProvinces;
  final bool isLoadingCities;
  final bool isLoadingDistricts;
  final String? errorMessage;

  SalesOrderFormState copyWith({
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? couriers,
    List<Map<String, dynamic>>? provinces,
    List<Map<String, dynamic>>? cities,
    List<Map<String, dynamic>>? districts,
    bool? isLoadingProducts,
    bool? isLoadingCouriers,
    bool? isLoadingProvinces,
    bool? isLoadingCities,
    bool? isLoadingDistricts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SalesOrderFormState(
      products: products ?? this.products,
      couriers: couriers ?? this.couriers,
      provinces: provinces ?? this.provinces,
      cities: cities ?? this.cities,
      districts: districts ?? this.districts,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingCouriers: isLoadingCouriers ?? this.isLoadingCouriers,
      isLoadingProvinces: isLoadingProvinces ?? this.isLoadingProvinces,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        products,
        couriers,
        provinces,
        cities,
        districts,
        isLoadingProducts,
        isLoadingCouriers,
        isLoadingProvinces,
        isLoadingCities,
        isLoadingDistricts,
        errorMessage,
      ];
}
