import 'package:core_services/api/api_client.dart';
import 'package:dashboard/services/dashboard_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:inbound/data/datasources/purchase_order_api_datasource.dart';
import 'package:inbound/data/repositories/purchase_order_repository_impl.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:product/data/datasources/product_api_datasource.dart';
import 'package:product/data/repositories/product_repository_impl.dart';
import 'package:product/domain/usecases/add_stock_location.dart';
import 'package:product/domain/usecases/create_product.dart';
import 'package:product/domain/usecases/delete_product.dart';
import 'package:product/domain/usecases/get_product_detail.dart';
import 'package:product/domain/usecases/get_products.dart';
import 'package:product/domain/usecases/move_stock_location.dart';
import 'package:product/domain/usecases/update_product.dart';
import 'package:product/domain/usecases/update_stock_location.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:zone/domain/usecases/get_shelf_details.dart';
import 'package:zone/domain/usecases/get_zone_by_aisle.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/zone.dart';

final getIt = GetIt.instance;

void setupInjector() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);

  getIt.registerLazySingleton<ProductApiDatasource>(
    () => ProductApiDatasource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProductRepositoryImpl>(
    () => ProductRepositoryImpl(getIt<ProductApiDatasource>()),
  );

  getIt.registerLazySingleton<ZoneApiDatasource>(
    () => ZoneApiDatasource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ZoneRepositoryImpl>(
    () => ZoneRepositoryImpl(getIt<ZoneApiDatasource>()),
  );

  // Use Case
  getIt.registerLazySingleton(() => GetZones(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(
    () => GetZoneByAisle(getIt<ZoneRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetZoneDetails(getIt<ZoneRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetShelfDetails(getIt<ZoneRepositoryImpl>()),
  );
  getIt.registerLazySingleton(() => CreateZone(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(() => UpdateZone(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(() => DeleteZone(getIt<ZoneRepositoryImpl>()));

  // Product use cases
  getIt.registerLazySingleton(
    () => GetProducts(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetProductDetail(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => CreateProduct(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => UpdateProduct(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => DeleteProduct(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => AddStockLocation(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => UpdateStockLocation(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => MoveStockLocation(getIt<ProductRepositoryImpl>()),
  );

  // Dashboard
  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<PurchaseOrderApiDatasource>(
    () => PurchaseOrderApiDatasource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<PurchaseOrderRepositoryImpl>(
    () => PurchaseOrderRepositoryImpl(getIt<PurchaseOrderApiDatasource>()),
  );

  getIt.registerLazySingleton(
    () => CreatePurchaseOrder(getIt<PurchaseOrderRepositoryImpl>()),
  );

  getIt.registerFactory(
    () => ZoneBloc(
      getZonesUsecase: getIt<GetZones>(),
      getZoneByAisleUsecase: getIt<GetZoneByAisle>(),
      getZoneDetailsUsecase: getIt<GetZoneDetails>(),
      createZoneUsecase: getIt<CreateZone>(),
      updateZoneUsecase: getIt<UpdateZone>(),
      deleteZoneUsecase: getIt<DeleteZone>(),
      getShelfDetailsUsecase: getIt<GetShelfDetails>(),
    ),
  );

  getIt.registerFactory(
    () => PurchaseOrderBloc(
      createPurchaseOrderUsecase: getIt<CreatePurchaseOrder>(),
    ),
  );

  getIt.registerFactory(
    () => ProductBloc(
      getProductsUsecase: getIt<GetProducts>(),
      getProductDetailUsecase: getIt<GetProductDetail>(),
      createProductUsecase: getIt<CreateProduct>(),
      updateProductUsecase: getIt<UpdateProduct>(),
      deleteProductUsecase: getIt<DeleteProduct>(),
      addStockLocationUsecase: getIt<AddStockLocation>(),
      updateStockLocationUsecase: getIt<UpdateStockLocation>(),
      moveStockLocationUsecase: getIt<MoveStockLocation>(),
    ),
  );
}
