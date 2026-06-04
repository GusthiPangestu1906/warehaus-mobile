# WareHaus Mobile - Dokumentasi Sistem

## 1. Overview Project

**WareHaus Mobile** adalah aplikasi mobile Flutter untuk mengelola operasional warehouse/gudang. Sistem ini mencakup manajemen produk, zona penyimpanan, inbound (penerimaan barang), dan outbound (pengiriman barang).

- **Base URL API**: Dikonfigurasi via environment variable `API_URL` di file `.env`
- **HTTP Client**: Dio dengan interceptors untuk error handling
- **State Management**: BLoC pattern (flutter_bloc)
- **Dependency Injection**: GetIt
- **Arsitektur**: Clean Architecture (data/domain/presentation layers)

---

## 2. Struktur Package

```
c:\pdbl\mobile\2026-WareHaus-mobile\
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── injector.dart                      # Dependency injection setup
│   ├── route_observer.dart               # Route navigation observer
│   └── presentation/
│       ├── bloc/
│       │   ├── navigation_bloc.dart       # Navigation state management
│       │   ├── navigation_event.dart
│       │   └── navigation_state.dart
│       └── pages/
│           └── main_page.dart             # Main page dengan bottom navigation
│
├── packages/
│   ├── core_services/                     # Shared API client & interceptors
│   │   └── lib/
│   │       ├── api/api_client.dart        # Dio HTTP client setup
│   │       ├── interceptors/
│   │       │   ├── api_exception.dart
│   │       │   ├── error_interceptor.dart
│   │       │   └── app_error_handler.dart
│   │       └── core_services.dart
│   │
│   ├── core_ui/                           # Reusable UI components
│   │   └── lib/src/
│   │       ├── colors.dart
│   │       ├── typography.dart
│   │       └── widgets/
│   │           ├── wh_appbar.dart
│   │           ├── wh_empty_state.dart
│   │           ├── wh_refresh.dart
│   │           ├── wh_search.dart
│   │           ├── wh_snackbar.dart
│   │           ├── wh_bottom_nav.dart
│   │           ├── button/
│   │           │   ├── wh_button.dart
│   │           │   ├── wh_button_primary.dart
│   │           │   ├── wh_button_secondary.dart
│   │           │   ├── wh_button_tersiery.dart
│   │           │   └── wh_outlined_button.dart
│   │           └── input/
│   │               ├── wh_date_field.dart
│   │               ├── wh_dropdown.dart
│   │               ├── wh_stepper_field.dart
│   │               └── wh_text_field.dart
│   │
│   ├── dashboard/                         # Dashboard feature
│   │   └── lib/
│   │       ├── dashboard.dart
│   │       ├── presentation/pages/dashboard_page.dart
│   │       └── services/dashboard_service.dart
│   │
│   ├── inbound/                           # Inbound/Purchase Order feature
│   │   └── lib/
│   │       ├── inbound.dart
│   │       ├── data/
│   │       │   ├── datasources/purchase_order_api_datasource.dart
│   │       │   ├── models/purchase_order_model.dart
│   │       │   └── repositories/purchase_order_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   ├── po_item.dart
│   │       │   │   └── purchase_order.dart
│   │       │   ├── params/create_po_params.dart
│   │       │   ├── repositories/purchase_order_repository.dart
│   │       │   └── usecases/purchase_order/create_purchase_order.dart
│   │       └── presentation/
│   │           ├── bloc/purchase_order/
│   │           │   ├── purchase_order_bloc.dart
│   │           │   ├── purchase_order_event.dart
│   │           │   └── purchase_order_state.dart
│   │           ├── pages/
│   │           │   ├── create_purchase_order_page.dart
│   │           │   ├── flow_management_page.dart
│   │           │   └── inbound_order_list_page.dart
│   │           └── widgets/
│   │               ├── flow_tab_content.dart
│   │               └── product_form_card.dart
│   │
│   ├── outbound/                          # Outbound feature
│   │   └── lib/
│   │       ├── outbound.dart
│   │       └── presentation/pages/outbound_list_page.dart
│   │
│   ├── product/                           # Product & Stock management
│   │   └── lib/
│   │       ├── product.dart
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   ├── product_model.dart
│   │       │   │   ├── stock_model.dart
│   │       │   │   └── stock_location_input_model.dart
│   │       │   ├── datasources/product_api_datasource.dart
│   │       │   └── repositories/product_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   ├── product.dart
│   │       │   │   ├── stock.dart
│   │       │   │   └── stock_location_input.dart
│   │       │   ├── repositories/product_repository.dart
│   │       │   └── usecases/
│   │       │       ├── create_product.dart
│   │       │       ├── delete_product.dart
│   │       │       ├── get_product_detail.dart
│   │       │       ├── get_products.dart
│   │       │       ├── update_product.dart
│   │       │       ├── add_stock_location.dart      # TODO: Belum ada di backend
│   │       │       ├── update_stock_location.dart  # TODO: Belum ada di backend
│   │       │       ├── move_stock_location.dart    # TODO: Belum ada di backend
│   │       │       └── delete_product_stock_location.dart  # TODO: Belum ada di backend
│   │       └── presentation/
│   │           ├── bloc/
│   │           │   ├── product_bloc.dart
│   │           │   ├── product_event.dart
│   │           │   └── product_state.dart
│   │           ├── pages/
│   │           │   ├── product_detail_page.dart
│   │           │   ├── product_list_page.dart
│   │           │   ├── create_product_page.dart
│   │           │   ├── add_stock.dart
│   │           │   └── barcode_scanner_page.dart
│   │           └── widgets/
│   │               ├── product_card.dart
│   │               ├── product_edit_dialog.dart
│   │               ├── shelf_card.dart
│   │               ├── stock_edit_dialog.dart
│   │               └── move_stock_dialog.dart
│   │
│   └── zone/                              # Zone/Shelf management
│       └── lib/
│           ├── zone.dart
│           ├── data/
│           │   ├── models/
│           │   │   ├── aisle_model.dart
│           │   │   ├── shelf_model.dart
│           │   │   └── zone_model.dart
│           │   ├── datasources/zone_api_datasource.dart
│           │   └── repositories/zone_repository_impl.dart
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── zone.dart
│           │   │   ├── aisle.dart
│           │   │   ├── shelves.dart
│           │   │   └── shelf_detail.dart
│           │   ├── repositories/zone_repository.dart
│           │   └── usecases/
│           │       ├── create_zone.dart
│           │       ├── delete_zone.dart
│           │       ├── get_zones.dart
│           │       ├── get_zone_by_aisle.dart
│           │       ├── get_zone_details.dart
│           │       ├── update_zone.dart
│           │       └── get_shelf_details.dart  # TODO: Belum ada di backend
│           └── presentation/
│               ├── bloc/
│               │   ├── zone_bloc.dart
│               │   ├── zone_event.dart
│               │   └── zone_state.dart
│               ├── pages/
│               │   ├── zone_list_page.dart
│               │   ├── zone_detail_page.dart
│               │   ├── zone_aisle_detail_page.dart
│               │   ├── create_zone_page.dart
│               │   ├── shelf_detail_page.dart
│               │   └── shelf_qr_page.dart
│               └── widgets/
│                   ├── zone_card.dart
│                   ├── zone_edit_dialog.dart
│                   ├── zone_detail_card.dart
│                   ├── zone_aisle_visualizer.dart
│                   ├── zone_visualizer.dart
│                   ├── location_identity_card.dart
│                   ├── filled_status_banner.dart
│                   ├── download_qr.dart
│                   └── format_dialog_qr.dart
```

---

## 3. API Endpoints

### 3.1 Product API (`/v1/Product`)

| Method | Endpoint | Request Body | Response | Deskripsi |
|--------|----------|--------------|----------|-----------|
| `GET` | `/v1/Product` | - | `List<ProductModel>` | Mendapatkan semua produk |
| `GET` | `/v1/Product/{id}` | - | `ProductModel` | Mendapatkan detail produk berdasarkan ID |
| `POST` | `/v1/Product` | `ProductModel` JSON | `void` | Membuat produk baru |
| `PUT` | `/v1/Product/{id}` | `ProductModel` JSON | `void` | Mengupdate produk |
| `DELETE` | `/v1/Product/{id}` | - | `void` | Menghapus produk |

### 3.1.1 Product Stock Location API - >> DIBUTUHKAN BACKEND / BELUM ADA

> TANDA: Endpoint di bawah ini belum tersedia di backend, tetapi sudah dibutuhkan oleh mobile untuk fitur tambah, ubah, pindah, hapus, dan ambil stock per shelf. Field wajib yang dibutuhkan mobile: `productId`, `shelfId`, dan `quantity`.

| Method | Endpoint | Request Body | Response | Deskripsi |
|--------|----------|--------------|----------|-----------|
| `GET` | `/v1/Product/{productId}/stock-locations` | - | `List<StockModel>` | >> DIBUTUHKAN: Mengambil semua lokasi stock untuk 1 produk |
| `GET` | `/v1/Product/{productId}/stock-locations/{shelfId}` | - | `StockModel` | >> DIBUTUHKAN: Mengambil stock produk pada shelf tertentu |
| `POST` | `/v1/Product/stock-locations` | `StockLocationInput` JSON | `void` atau `StockModel` | >> DIBUTUHKAN: Menambahkan stock produk ke shelf |
| `PUT` | `/v1/Product/stock-locations/{productId}/{shelfId}` | `StockLocationInput` JSON | `void` atau `StockModel` | >> DIBUTUHKAN: Mengubah quantity stock pada shelf |
| `PUT` | `/v1/Product/stock-locations/move` | `MoveStockInput` JSON | `void` | >> DIBUTUHKAN: Memindahkan stock dari shelf asal ke shelf tujuan |
| `DELETE` | `/v1/Product/stock-locations/{productId}/{shelfId}` | - | `void` | >> DIBUTUHKAN: Menghapus lokasi stock produk dari shelf |

#### StockLocationInput JSON Structure - >> DIBUTUHKAN BACKEND:
```json
{
  "productId": "string",
  "shelfId": "int",
  "quantity": "int"
}
```

#### MoveStockInput JSON Structure - >> DIBUTUHKAN BACKEND:
```json
{
  "productId": "string",
  "fromShelfId": "int",
  "toShelfId": "int",
  "quantity": "int"
}
```

#### ProductModel JSON Structure:
```json
{
  "id": "string",
  "sku": "string",
  "productName": "string",
  "barcode": "string",
  "unitOfMeasure": "string",
  "currentStock": "int",
  "stocks": [
    {
      "id": "string",
      "shelfId": "int",
      "productId": "string",
      "quantity": "int",
      "shelfCode": "string?",
      "zoneId": "int?",
      "zoneCode": "string?",
      "zoneName": "string?",
      "aisle": "int?",
      "locationName": "string?",
      "shelfCapacity": "int?",
      "shelfCurrentVolume": "int?",
      "shelfAvailableCapacity": "int?",
      "qrCodePath": "string?"
    }
  ]
}
```

### 3.2 Zone API (`/v1/Zone`)

| Method | Endpoint | Request Body | Response | Deskripsi |
|--------|----------|--------------|----------|-----------|
| `GET` | `/v1/Zone` | - | `List<ZoneModel>` | Mendapatkan semua zone |
| `GET` | `/v1/Zone/{id}` | - | `ZoneModel` | Mendapatkan detail zone |
| `GET` | `/v1/Zone/{zoneId}/{aisleNumber}` | - | `ZoneModel` atau `List<ZoneModel>` | Mendapatkan zone berdasarkan aisle |
| `POST` | `/v1/Zone` | `ZoneModel` JSON | `void` | Membuat zone baru |
| `PUT` | `/v1/Zone/{id}` | Partial update JSON | `void` | Mengupdate zone (partial) |
| `DELETE` | `/v1/Zone/{id}` | - | `void` | Menghapus zone |

#### ZoneModel JSON Structure:
```json
{
  "id": "string",
  "zoneCode": "string",
  "zoneName": "string",
  "category": "string",
  "description": "string",
  "totalAisle": "int",
  "shelfPerAisle": "int",
  "capacityPerShelf": "int",
  "emptyShelves": "int",
  "shelves": [
    {
      "id": "String",
      "shelfCode": "String",
      "aisle": "int",
      "capacity": "int",
      "currentVolume": "int",
      "qrCodePath": "String"
    }
  ],
  "aisles": [
    {
      "aisleNumber": "int",
      "isEmpty": "bool",
      "totalShelves": "int",
      "capacity": "int",
      "occupiedCapacity": "int"
    }
  ]
}
```

#### PUT /v1/Zone/{id} - Partial Update Request:
```json
{
  "zoneName": "string (optional)",
  "category": "string (optional)",
  "description": "string (optional)"
}
```

### 3.2.1 Shelf API - >> DIBUTUHKAN BACKEND / BELUM ADA

> TANDA: Endpoint ini dibutuhkan mobile untuk halaman Shelf Detail dan validasi `shelfId` ketika user memilih/scan lokasi shelf.

| Method | Endpoint | Request Body | Response | Deskripsi |
|--------|----------|--------------|----------|-----------|
| `GET` | `/v1/Zone/shelves/{shelfId}` | - | `ShelfDetail` | >> DIBUTUHKAN: Mendapatkan detail shelf berdasarkan `shelfId`, termasuk produk/stock di dalam shelf |
| `GET` | `/v1/Zone/shelves/{shelfId}/stocks` | - | `List<ShelfStock>` | >> DIBUTUHKAN: Mendapatkan daftar stock di shelf tertentu |

#### ShelfDetail JSON Structure - >> DIBUTUHKAN BACKEND:
```json
{
  "id": "int",
  "shelfCode": "string",
  "aisle": "int",
  "capacity": "int",
  "currentVolume": "int",
  "qrCodePath": "string",
  "stocks": [
    {
      "shelfId": "int",
      "quantity": "int",
      "product": {
        "id": "string",
        "sku": "string",
        "productName": "string",
        "barcode": "string",
        "unitOfMeasure": "string"
      }
    }
  ]
}
```

### 3.3 Purchase Order API (`/api/PurchaseOrders`)

| Method | Endpoint | Request Body | Response | Deskripsi |
|--------|----------|--------------|----------|-----------|
| `POST` | `/api/PurchaseOrders` | `Map<String, dynamic>` (dynamic structure) | `void` | Membuat purchase order baru |

---

## 4. Domain Entities

### 4.1 Product Entity (`product` package)
```dart
class Product {
  String id;
  String sku;
  String productName;
  String barcode;
  String unitOfMeasure;
  int currentStock;
  List<Stock>? stocks;
}
```

### 4.2 Stock Entity (`product` package)
```dart
class Stock {
  String id;
  int shelfId;
  String productId;
  int quantity;
  String? shelfCode;
  int? zoneId;
  String? zoneCode;
  String? zoneName;
  int? aisle;
  String? locationName;
  int? shelfCapacity;
  int? shelfCurrentVolume;
  int? shelfAvailableCapacity;
  String? qrCodePath;
}
```

### 4.3 StockLocationInput Entity (`product` package)
```dart
class StockLocationInput {
  String productId;
  int shelfId;
  int quantity;
}
```

### 4.4 Zone Entity (`zone` package)
```dart
class Zone {
  String id;
  String zoneCode;
  String zoneName;
  String category;
  String description;
  int totalAisle;
  int shelfPerAisle;
  int capacityPerShelf;
  int emptyShelves;
  List<Shelf>? shelves;
  List<Aisle>? aisles;
}
```

### 4.5 Aisle Entity (`zone` package)
```dart
class Aisle {
  int aisleNumber;
  bool isEmpty;
  int totalShelves;
  int capacity;
  int occupiedCapacity;
}
```

### 4.6 Shelf Entity (`zone` package)
```dart
class Shelf {
  String id;
  String shelfCode;
  int aisle;
  int capacity;
  int currentVolume;
  String qrCodePath;
}
```

### 4.7 ShelfDetail Entity (`zone` package)
```dart
class ShelfDetail {
  int id;
  String shelfCode;
  int aisle;
  int capacity;
  int currentVolume;
  String qrCodePath;
  List<ShelfStock> stocks;
}
```

### 4.8 PurchaseOrder Entity (`inbound` package)
```dart
class PurchaseOrder {
  int id;
  String poNumber;
  String supplierName;
  String status;
  int totalQtyExpected;
  int totalQtyReceived;
  List<PoItem> items;
}
```

### 4.9 PoItem Entity (`inbound` package)
```dart
class PoItem {
  int id;
  int productId;
  int qtyExpected;
  int qtyReceived;
}
```

---

## 5. Use Cases

### 5.1 Product Package Use Cases

| Use Case | Input | Output | Status |
|----------|-------|--------|--------|
| `GetProducts` | - | `Future<List<Product>>` | ✅ Active |
| `GetProductDetail` | `String id` | `Future<Product>` | ✅ Active |
| `CreateProduct` | `Product product` | `Future<void>` | ✅ Active |
| `UpdateProduct` | `Product product` | `Future<void>` | ✅ Active |
| `DeleteProduct` | `String id` | `Future<void>` | ✅ Active |
| `AddStockLocation` | `StockLocationInput input` | `Future<void>` | ❌ TODO: Backend belum ada |
| `UpdateStockLocation` | `StockLocationInput input` | `Future<void>` | ❌ TODO: Backend belum ada |
| `MoveStockLocation` | `MoveStockInput input` | `Future<void>` | ❌ TODO: Backend belum ada |
| `DeleteProductStockLocation` | `String productId, int shelfId` | `Future<void>` | ❌ TODO: Backend belum ada |

### 5.2 Zone Package Use Cases

| Use Case | Input | Output | Status |
|----------|-------|--------|--------|
| `GetZones` | - | `Future<List<Zone>>` | ✅ Active |
| `GetZoneDetails` | `String id` | `Future<Zone>` | ✅ Active |
| `GetZoneByAisle` | `String zoneId, int aisleNumber` | `Future<List<Zone>>` | ✅ Active |
| `CreateZone` | `Zone zone` | `Future<void>` | ✅ Active |
| `UpdateZone` | `String id, String? zoneName, String? category, String? description` | `Future<void>` | ✅ Active |
| `DeleteZone` | `String id` | `Future<void>` | ✅ Active |
| `GetShelfDetails` | `int shelfId` | `Future<ShelfDetail>` | ❌ TODO: Backend belum ada |

### 5.3 Inbound Package Use Cases

| Use Case | Input | Output | Status |
|----------|-------|--------|--------|
| `CreatePurchaseOrder` | `CreatePoParams params` | `Future<void>` | ✅ Active |

---

## 6. State Management (BLoC Pattern)

### 6.1 Navigation BLoC
- **Location**: `lib/presentation/bloc/`
- **Events**: `NavigationEvent`
- **States**: `NavigationState`
- **Purpose**: Mengelola navigasi utama aplikasi

### 6.2 Product BLoC
- **Location**: `packages/product/lib/presentation/bloc/`
- **Events**: `ProductEvent`
- **States**: `ProductState`
- **Purpose**: Mengelola state untuk fitur produk (list, detail, CRUD)
- **Registered**: `getIt.registerFactory(() => ProductBloc(...))`

### 6.3 Zone BLoC
- **Location**: `packages/zone/lib/presentation/bloc/`
- **Events**: `ZoneEvent`
- **States**: `ZoneState`
- **Purpose**: Mengelola state untuk fitur zone (list, detail, CRUD)
- **Registered**: `getIt.registerFactory(() => ZoneBloc(...))`

### 6.4 Purchase Order BLoC
- **Location**: `packages/inbound/lib/presentation/bloc/purchase_order/`
- **Events**: `PurchaseOrderEvent`
- **States**: `PurchaseOrderState`
- **Purpose**: Mengelola state untuk Purchase Order
- **Registered**: `getIt.registerFactory(() => PurchaseOrderBloc(...))`

---

## 7. Dependency Injection (GetIt)

Injection setup di `lib/injector.dart`:

### Core Services
```dart
getIt.registerLazySingleton<ApiClient>(() => ApiClient());
getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);
```

### Product Dependencies
```dart
getIt.registerLazySingleton<ProductApiDatasource>(() => ProductApiDatasource(getIt<Dio>()));
getIt.registerLazySingleton<ProductRepositoryImpl>(() => ProductRepositoryImpl(getIt<ProductApiDatasource>()));

// Use cases
getIt.registerLazySingleton(() => GetProducts(getIt<ProductRepositoryImpl>()));
getIt.registerLazySingleton(() => GetProductDetail(getIt<ProductRepositoryImpl>()));
getIt.registerLazySingleton(() => CreateProduct(getIt<ProductRepositoryImpl>()));
getIt.registerLazySingleton(() => UpdateProduct(getIt<ProductRepositoryImpl>()));
getIt.registerLazySingleton(() => DeleteProduct(getIt<ProductRepositoryImpl>()));

// Commented out (belum ada di backend):
// getIt.registerLazySingleton(() => AddStockLocation(getIt<ProductRepositoryImpl>()));
// getIt.registerLazySingleton(() => UpdateStockLocation(getIt<ProductRepositoryImpl>()));
// getIt.registerLazySingleton(() => MoveStockLocation(getIt<ProductRepositoryImpl>()));
```

### Zone Dependencies
```dart
getIt.registerLazySingleton<ZoneApiDatasource>(() => ZoneApiDatasource(getIt<Dio>()));
getIt.registerLazySingleton<ZoneRepositoryImpl>(() => ZoneRepositoryImpl(getIt<ZoneApiDatasource>()));

// Use cases
getIt.registerLazySingleton(() => GetZones(getIt<ZoneRepositoryImpl>()));
getIt.registerLazySingleton(() => GetZoneByAisle(getIt<ZoneRepositoryImpl>()));
getIt.registerLazySingleton(() => GetZoneDetails(getIt<ZoneRepositoryImpl>()));
getIt.registerLazySingleton(() => CreateZone(getIt<ZoneRepositoryImpl>()));
getIt.registerLazySingleton(() => UpdateZone(getIt<ZoneRepositoryImpl>()));
getIt.registerLazySingleton(() => DeleteZone(getIt<ZoneRepositoryImpl>()));

// Commented out (belum ada di backend):
// getIt.registerLazySingleton(() => GetShelfDetails(getIt<ZoneRepositoryImpl>()));
```

### Inbound Dependencies
```dart
getIt.registerLazySingleton<PurchaseOrderApiDatasource>(() => PurchaseOrderApiDatasource(getIt<Dio>()));
getIt.registerLazySingleton<PurchaseOrderRepositoryImpl>(() => PurchaseOrderRepositoryImpl(getIt<PurchaseOrderApiDatasource>()));
getIt.registerLazySingleton(() => CreatePurchaseOrder(getIt<PurchaseOrderRepositoryImpl>()));
```

### Dashboard
```dart
getIt.registerLazySingleton<DashboardService>(() => DashboardService(getIt<Dio>()));
```

### BLoC Factories
```dart
getIt.registerFactory(() => ZoneBloc(
  getZonesUsecase: getIt<GetZones>(),
  getZoneByAisleUsecase: getIt<GetZoneByAisle>(),
  getZoneDetailsUsecase: getIt<GetZoneDetails>(),
  createZoneUsecase: getIt<CreateZone>(),
  updateZoneUsecase: getIt<UpdateZone>(),
  deleteZoneUsecase: getIt<DeleteZone>(),
));

getIt.registerFactory(() => PurchaseOrderBloc(
  createPurchaseOrderUsecase: getIt<CreatePurchaseOrder>(),
));

getIt.registerFactory(() => ProductBloc(
  getProductsUsecase: getIt<GetProducts>(),
  getProductDetailUsecase: getIt<GetProductDetail>(),
  createProductUsecase: getIt<CreateProduct>(),
  updateProductUsecase: getIt<UpdateProduct>(),
  deleteProductUsecase: getIt<DeleteProduct>(),
));
```

---

## 8. API Client Configuration

**Location**: `packages/core_services/lib/api/api_client.dart`

```dart
class ApiClient {
  late Dio dio;

  ApiClient() {
    final configuredBaseUrl = dotenv.get('API_URL');  // Dari .env file
    final baseUrl = _resolveBaseUrl(configuredBaseUrl);

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 90),
      ),
    );

    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(LogInterceptor(requestBody: true));  // Debug logging
  }
}
```

### Interceptors:
- `ErrorInterceptor`: Handle error responses
- `AppErrorHandler`: Application-level error handling

---

## 9. Pages & Navigation

### Main Page
- **Location**: `lib/presentation/pages/main_page.dart`
- **Purpose**: Halaman utama dengan bottom navigation

### Dashboard
- **Location**: `packages/dashboard/lib/presentation/pages/dashboard_page.dart`
- **Service**: `DashboardService`

### Product Pages
| Page | Location |
|------|----------|
| Product List | `packages/product/lib/presentation/pages/product_list_page.dart` |
| Product Detail | `packages/product/lib/presentation/pages/product_detail_page.dart` |
| Create Product | `packages/product/lib/presentation/pages/create_product_page.dart` |
| Add Stock | `packages/product/lib/presentation/pages/add_stock.dart` |
| Barcode Scanner | `packages/product/lib/presentation/pages/barcode_scanner_page.dart` |

### Zone Pages
| Page | Location |
|------|----------|
| Zone List | `packages/zone/lib/presentation/pages/zone_list_page.dart` |
| Zone Detail | `packages/zone/lib/presentation/pages/zone_detail_page.dart` |
| Zone Aisle Detail | `packages/zone/lib/presentation/pages/zone_aisle_detail_page.dart` |
| Create Zone | `packages/zone/lib/presentation/pages/create_zone_page.dart` |
| Shelf Detail | `packages/zone/lib/presentation/pages/shelf_detail_page.dart` |
| Shelf QR | `packages/zone/lib/presentation/pages/shelf_qr_page.dart` |

### Inbound Pages
| Page | Location |
|------|----------|
| Inbound Order List | `packages/inbound/lib/presentation/pages/inbound_order_list_page.dart` |
| Create Purchase Order | `packages/inbound/lib/presentation/pages/create_purchase_order_page.dart` |
| Flow Management | `packages/inbound/lib/presentation/pages/flow_management_page.dart` |

### Outbound Pages
| Page | Location |
|------|----------|
| Outbound List | `packages/outbound/lib/presentation/pages/outbound_list_page.dart` |

---

## 10. Fitur-Fitur Sistem

### 10.1 Product Management
- Menampilkan daftar produk
- Membuat produk baru
- Mengedit produk
- Menghapus produk
- Melihat detail produk dengan stock locations
- Menambahkan stock ke lokasi shelf
- Memindahkan stock antar lokasi
- Barcode scanning

### 10.2 Zone Management
- Menampilkan daftar zone
- Membuat zone baru
- Mengedit zone (nama, kategori, deskripsi)
- Menghapus zone
- Melihat detail zone dengan aisles dan shelves
- Visualisasi zone dan aisle
- Download QR code shelf
- Format dialog QR

### 10.3 Inbound (Purchase Order)
- Menampilkan daftar purchase order
- Membuat purchase order baru
- Flow management untuk inbound
- Form produk dengan expected vs received quantity

### 10.4 Outbound
- Menampilkan daftar outbound orders

### 10.5 Dashboard
- Overview statistics
- Widget interaktif

---

## 11. TODO / Pending Features

### Backend Belum Ada / >> DIBUTUHKAN MOBILE:
1. **Stock Location APIs** (`/v1/Product/stock-locations` belum ada)
   - >> `GET /v1/Product/{productId}/stock-locations`
   - >> `GET /v1/Product/{productId}/stock-locations/{shelfId}`
   - >> `POST /v1/Product/stock-locations`
   - >> `PUT /v1/Product/stock-locations/{productId}/{shelfId}`
   - >> `PUT /v1/Product/stock-locations/move`
   - >> `DELETE /v1/Product/stock-locations/{productId}/{shelfId}`
   - Field penting: `productId`, `shelfId`, `quantity`
   - Dipakai untuk: `AddStockLocation`, `UpdateStockLocation`, `MoveStockLocation`, `DeleteProductStockLocation`

2. **Shelf Details API** (`/v1/Zone/shelves/{shelfId}` belum ada)
   - >> `GET /v1/Zone/shelves/{shelfId}`
   - >> `GET /v1/Zone/shelves/{shelfId}/stocks`
   - Field penting: `shelfId`
   - Dipakai untuk: `GetShelfDetails`

---

## 12. Summary API Requests

### Product Endpoints Summary
```
GET    /v1/Product                  → List<ProductModel>
GET    /v1/Product/{id}             → ProductModel
POST   /v1/Product                  → void (body: ProductModel)
PUT    /v1/Product/{id}             → void (body: ProductModel)
DELETE /v1/Product/{id}            → void
```

### Product Stock Location Endpoints Summary - >> DIBUTUHKAN BACKEND
```
GET    /v1/Product/{productId}/stock-locations             -> List<StockModel>
GET    /v1/Product/{productId}/stock-locations/{shelfId}   -> StockModel
POST   /v1/Product/stock-locations                         -> void/StockModel (body: productId, shelfId, quantity)
PUT    /v1/Product/stock-locations/{productId}/{shelfId}   -> void/StockModel (body: productId, shelfId, quantity)
PUT    /v1/Product/stock-locations/move                    -> void (body: productId, fromShelfId, toShelfId, quantity)
DELETE /v1/Product/stock-locations/{productId}/{shelfId}   -> void
```

### Zone Endpoints Summary
```
GET    /v1/Zone                    → List<ZoneModel>
GET    /v1/Zone/{id}               → ZoneModel
GET    /v1/Zone/{zoneId}/{aisleNumber} → ZoneModel atau List<ZoneModel>
POST   /v1/Zone                    → void (body: ZoneModel)
PUT    /v1/Zone/{id}               → void (body: partial update)
DELETE /v1/Zone/{id}               → void
```

### Shelf Endpoints Summary - >> DIBUTUHKAN BACKEND
```
GET    /v1/Zone/shelves/{shelfId}         -> ShelfDetail
GET    /v1/Zone/shelves/{shelfId}/stocks  -> List<ShelfStock>
```

### Inbound Endpoints Summary
```
POST   /api/PurchaseOrders         → void (body: Map<String, dynamic>)
```

---

*Document generated: 2026-06-04*
*WareHaus Mobile - Flutter Warehouse Management System*
