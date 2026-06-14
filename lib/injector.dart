import 'package:core_services/api/api_client.dart';
import 'package:dashboard/services/dashboard_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:inbound/data/datasources/purchase_order_api_datasource.dart';
import 'package:inbound/data/repositories/purchase_order_repository_impl.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:outbound/data/datasources/outbound_product_api_datasource.dart';
import 'package:outbound/data/datasources/region_api_datasource.dart';
import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/data/repositories/sales_order_repository_impl.dart';
import 'package:outbound/domain/usecases/create_sales_order.dart';
import 'package:outbound/domain/usecases/delete_sales_order.dart';
import 'package:outbound/domain/usecases/get_sales_orders.dart';
import 'package:outbound/domain/usecases/update_sales_order.dart';
import 'package:outbound/domain/usecases/update_sales_order_tracking.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_form_cubit.dart';
import 'package:product/data/datasources/product_api_datasource.dart';
import 'package:product/data/repositories/product_repository_impl.dart';
import 'package:product/domain/usecases/create_product.dart';
import 'package:product/domain/usecases/delete_product.dart';
import 'package:product/domain/usecases/get_product_detail.dart';
import 'package:product/domain/usecases/get_products.dart';
import 'package:product/domain/usecases/update_product.dart';
import 'package:product/domain/usecases/add_stock_location.dart';
import 'package:product/domain/usecases/update_stock_location.dart';
import 'package:product/domain/usecases/move_stock_location.dart';
import 'package:product/domain/usecases/delete_product_stock_location.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:zone/data/datasources/zone_api_datasource.dart';
import 'package:zone/data/repositories/zone_repository_impl.dart';
import 'package:zone/domain/usecases/create_zone.dart';
import 'package:zone/domain/usecases/delete_zone.dart';
import 'package:zone/domain/usecases/get_zone_by_aisle.dart';
import 'package:zone/domain/usecases/get_zone_details.dart';
import 'package:zone/domain/usecases/get_zones.dart';
import 'package:zone/domain/usecases/update_zone.dart';
import 'package:zone/domain/usecases/get_shelf_details.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';

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

  // Zone use cases
  getIt.registerLazySingleton(() => GetZones(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(
    () => GetZoneByAisle(getIt<ZoneRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetZoneDetails(getIt<ZoneRepositoryImpl>()),
  );
  getIt.registerLazySingleton(() => CreateZone(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(() => UpdateZone(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(() => DeleteZone(getIt<ZoneRepositoryImpl>()));
  getIt.registerLazySingleton(
    () => GetShelfDetails(getIt<ZoneRepositoryImpl>()),
  );

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
  // Stock location use cases — sekarang sudah ada di backend
  getIt.registerLazySingleton(
    () => AddStockLocation(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => UpdateStockLocation(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => MoveStockLocation(getIt<ProductRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => DeleteProductStockLocation(getIt<ProductRepositoryImpl>()),
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

  // ── Outbound ──────────────────────────────────────────────────
  getIt.registerLazySingleton<SalesOrderApiDatasource>(
    () => SalesOrderApiDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<RegionApiDatasource>(
    () => RegionApiDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<OutboundProductApiDatasource>(
    () => OutboundProductApiDatasource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<SalesOrderRepositoryImpl>(
    () => SalesOrderRepositoryImpl(getIt<SalesOrderApiDatasource>()),
  );

  getIt.registerLazySingleton(
    () => GetSalesOrders(getIt<SalesOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => CreateSalesOrder(getIt<SalesOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => DeleteSalesOrder(getIt<SalesOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => UpdateSalesOrder(getIt<SalesOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
      () => UpdateSalesOrderTracking(getIt<SalesOrderRepositoryImpl>()),
  );

  getIt.registerFactory(
    () => SalesOrderBloc(
      getSalesOrdersUsecase: getIt<GetSalesOrders>(),
      createSalesOrderUsecase: getIt<CreateSalesOrder>(),
      deleteSalesOrderUsecase: getIt<DeleteSalesOrder>(),
      updateSalesOrderUsecase: getIt<UpdateSalesOrder>(),
      updateSalesOrderTrackingUsecase: getIt<UpdateSalesOrderTracking>(),
    ),
  );

  getIt.registerFactory(
    () => SalesOrderFormCubit(
      productApi: getIt<OutboundProductApiDatasource>(),
      regionApi: getIt<RegionApiDatasource>(),
    ),
  );

  // ── Blocs ───────────────────────────────────────────────────────
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
