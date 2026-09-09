import 'package:core_services/api/api_client.dart';
import 'package:core_services/storage/auth_token_storage.dart';
import 'package:dashboard/services/dashboard_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:inbound/data/datasources/purchase_order_api_datasource.dart';
import 'package:inbound/data/repositories/purchase_order_repository_impl.dart';
import 'package:inbound/domain/usecases/inbound/get_pa_next_item.dart';
import 'package:inbound/domain/usecases/inbound/get_qc_next_item.dart';
import 'package:inbound/domain/usecases/inbound/submit_pa.dart';
import 'package:inbound/domain/usecases/inbound/submit_qc.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/delete_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/download_purchase_order_pdf.dart';
import 'package:inbound/domain/usecases/purchase_order/get_carriers.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_order_detail.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_orders.dart';
import 'package:inbound/domain/usecases/purchase_order/invoice_update.dart';
import 'package:inbound/domain/usecases/purchase_order/update_purchase_order.dart';
import 'package:inbound/data/services/local_file_service_impl.dart';
import 'package:inbound/domain/services/local_file_service.dart';
import 'package:inbound/presentation/bloc/carrier/carrier_cubit.dart';
import 'package:inbound/presentation/bloc/inbound/inbound_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:outbound/data/datasources/form_api_datasource.dart';
import 'package:outbound/data/datasources/outbound_product_api_datasource.dart';
import 'package:outbound/data/datasources/region_api_datasource.dart';
import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/data/repositories/form_repository_impl.dart';
import 'package:outbound/data/repositories/sales_order_repository_impl.dart';
import 'package:outbound/domain/usecases/create_sales_order.dart';
import 'package:outbound/domain/usecases/delete_sales_order.dart';
import 'package:outbound/domain/usecases/form/get_cities.dart' as outbound_form;
import 'package:outbound/domain/usecases/form/get_couriers.dart' as outbound_form;
import 'package:outbound/domain/usecases/form/get_districts.dart' as outbound_form;
import 'package:outbound/domain/usecases/form/get_products.dart' as outbound_form;
import 'package:outbound/domain/usecases/form/get_provinces.dart' as outbound_form;
import 'package:outbound/domain/usecases/get_sales_orders.dart';
import 'package:outbound/domain/usecases/update_sales_order.dart';
import 'package:outbound/domain/usecases/update_sales_order_tracking.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_form_cubit.dart';
import 'package:product/data/datasources/product_api_datasource.dart';
import 'package:product/data/repositories/product_repository_impl.dart';
import 'package:product/domain/usecases/add_stock_location.dart';
import 'package:product/domain/usecases/create_product.dart';
import 'package:product/domain/usecases/delete_product.dart';
import 'package:product/domain/usecases/delete_product_stock_location.dart';
import 'package:product/domain/usecases/get_categories.dart';
import 'package:product/domain/usecases/get_product_detail.dart';
import 'package:product/domain/usecases/get_products.dart';
import 'package:product/domain/usecases/move_stock_location.dart';
import 'package:product/domain/usecases/update_product.dart';
import 'package:product/domain/usecases/update_stock_location.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:zone/data/datasources/zone_api_datasource.dart';
import 'package:zone/data/repositories/zone_repository_impl.dart';
import 'package:zone/domain/usecases/create_zone.dart';
import 'package:zone/domain/usecases/delete_zone.dart';
import 'package:zone/domain/usecases/download_aisle_qr.dart';
import 'package:zone/domain/usecases/download_shelf_qr.dart';
import 'package:zone/domain/usecases/get_shelf_details.dart';
import 'package:zone/domain/usecases/get_zone_by_aisle.dart';
import 'package:zone/domain/usecases/get_zone_details.dart';
import 'package:zone/domain/usecases/get_zones.dart';
import 'package:zone/domain/usecases/update_zone.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupInjector() async {
  // 1. SOLUSI HOT RESTART: Bersihkan semua instance lama sebelum mendaftar ulang
  await getIt.reset();

  // ===========================================================================
  // CORE & DRIVER SERVICES
  // ===========================================================================
  getIt.registerLazySingleton<AuthTokenStorage>(() => AuthTokenStorage());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      tokenStorage: getIt<AuthTokenStorage>(),
      onSessionExpired: () {},
    ),
  );
  getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);
  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(getIt<Dio>()),
  );

  // ===========================================================================
  // FEATURE: ZONE
  // ===========================================================================
  // Datasource & Repository
  getIt.registerLazySingleton<ZoneApiDatasource>(
    () => ZoneApiDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ZoneRepositoryImpl>(
    () => ZoneRepositoryImpl(getIt<ZoneApiDatasource>()),
  );

  // Use Cases
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
  getIt.registerLazySingleton(
    () => DownloadAisleQr(getIt<ZoneRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => DownloadShelfQr(getIt<ZoneRepositoryImpl>()),
  );

  // BLoC
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

  // ===========================================================================
  // FEATURE: PRODUCT
  // ===========================================================================
  // Datasource & Repository
  getIt.registerLazySingleton<ProductApiDatasource>(
    () => ProductApiDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProductRepositoryImpl>(
    () => ProductRepositoryImpl(getIt<ProductApiDatasource>()),
  );

  // Use Cases
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

  // ── Categories ─────────────────────────────────────────────────
  getIt.registerLazySingleton(
    () => GetCategories(getIt<ProductRepositoryImpl>()),
  );

  // BLoC
  getIt.registerFactory(
    () => ProductBloc(
      getProductsUsecase: getIt<GetProducts>(),
      getProductDetailUsecase: getIt<GetProductDetail>(),
      createProductUsecase: getIt<CreateProduct>(),
      updateProductUsecase: getIt<UpdateProduct>(),
      deleteProductUsecase: getIt<DeleteProduct>(),
      getCategoriesUsecase: getIt<GetCategories>(),
    ),
  );

  // ===========================================================================
  // FEATURE: INBOUND / PURCHASE ORDER
  // ===========================================================================
  // Datasource & Repository (DUPLIKASI DI SINI SUDAH DIHAPUS)
  getIt.registerLazySingleton<PurchaseOrderApiDatasource>(
    () => PurchaseOrderApiDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<PurchaseOrderRepositoryImpl>(
    () => PurchaseOrderRepositoryImpl(getIt<PurchaseOrderApiDatasource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetPurchaseOrders(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetPurchaseOrderDetail(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => CreatePurchaseOrder(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => UpdatePurchaseOrder(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => InvoiceUpdate(repository: getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => DeletePurchaseOrder(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton<LocalFileService>(
    () => LocalFileServiceImpl(),
  );
  getIt.registerLazySingleton(
    () => DownloadPurchaseOrderPdf(
      getIt<PurchaseOrderRepositoryImpl>(),
      getIt<LocalFileService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetQcNextItem(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => SubmitQc(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetPaNextItem(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => SubmitPa(getIt<PurchaseOrderRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => GetCarriers(getIt<PurchaseOrderRepositoryImpl>()),
  );

  // ── Purchase Order BLoC ──────────────────────────────────────────
  getIt.registerFactory(
    () => PurchaseOrderBloc(
      getPurchaseOrdersUsecase: getIt<GetPurchaseOrders>(),
      getPurchaseOrderDetailUsecase: getIt<GetPurchaseOrderDetail>(),
      createPurchaseOrderUsecase: getIt<CreatePurchaseOrder>(),
      updatePurchaseOrderUsecase: getIt<UpdatePurchaseOrder>(),
      invoiceUpdateUsecase: getIt<InvoiceUpdate>(),
      deletePurchaseOrderUsecase: getIt<DeletePurchaseOrder>(),
      downloadPurchaseOrderPdfUsecase: getIt<DownloadPurchaseOrderPdf>(),
    ),
  );

  // ── Inbound (QC / PA) BLoC ───────────────────────────────────────
  getIt.registerFactory(
    () => InboundBloc(
      getQcNextItemUsecase: getIt<GetQcNextItem>(),
      submitQcUsecase: getIt<SubmitQc>(),
      getPaNextItemUsecase: getIt<GetPaNextItem>(),
      submitPaUsecase: getIt<SubmitPa>(),
    ),
  );

  // ── Carrier Cubit ────────────────────────────────────────────────
  getIt.registerFactory(
    () => CarrierCubit(getCarriersUsecase: getIt<GetCarriers>()),
  );

  // ===========================================================================
  // FEATURE: OUTBOUND / SALES ORDER
  // ===========================================================================
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

  getIt.registerLazySingleton<FormApiDatasource>(
    () => FormApiDatasource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<FormRepositoryImpl>(
    () => FormRepositoryImpl(getIt<FormApiDatasource>()),
  );

  getIt.registerFactory(
    () => SalesOrderFormCubit(
      getProductsUseCase: outbound_form.GetProducts(getIt<FormRepositoryImpl>()),
      getCouriersUseCase: outbound_form.GetCouriers(getIt<FormRepositoryImpl>()),
      getProvincesUseCase: outbound_form.GetProvinces(getIt<FormRepositoryImpl>()),
      getCitiesUseCase: outbound_form.GetCities(getIt<FormRepositoryImpl>()),
      getDistrictsUseCase: outbound_form.GetDistricts(getIt<FormRepositoryImpl>()),
    ),
  );
}
