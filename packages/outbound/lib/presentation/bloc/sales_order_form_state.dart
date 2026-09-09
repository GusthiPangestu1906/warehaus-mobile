import 'package:equatable/equatable.dart';
import 'package:outbound/domain/entities/form/courier.dart';
import 'package:product/product.dart';
import 'package:outbound/domain/entities/form/region.dart';

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

  final List<Product> products;
  final List<Courier> couriers;
  final List<Region> provinces;
  final List<Region> cities;
  final List<Region> districts;
  final bool isLoadingProducts;
  final bool isLoadingCouriers;
  final bool isLoadingProvinces;
  final bool isLoadingCities;
  final bool isLoadingDistricts;
  final String? errorMessage;

  SalesOrderFormState copyWith({
    List<Product>? products,
    List<Courier>? couriers,
    List<Region>? provinces,
    List<Region>? cities,
    List<Region>? districts,
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
