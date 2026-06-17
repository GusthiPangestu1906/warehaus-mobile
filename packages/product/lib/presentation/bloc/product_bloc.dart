import 'package:core_services/interceptors/app_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product/domain/entities/product.dart';
import 'package:product/domain/usecases/create_product.dart';
import 'package:product/domain/usecases/delete_product.dart';
import 'package:product/domain/usecases/get_categories.dart';
import 'package:product/domain/usecases/get_product_detail.dart';
import 'package:product/domain/usecases/get_products.dart';
import 'package:product/domain/usecases/update_product.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProductsUsecase;
  final GetProductDetail getProductDetailUsecase;
  final CreateProduct createProductUsecase;
  final UpdateProduct updateProductUsecase;
  final DeleteProduct deleteProductUsecase;
  // Stock location use cases - not yet implemented in backend
  // final AddStockLocation addStockLocationUsecase;
  // final UpdateStockLocation updateStockLocationUsecase;
  // final MoveStockLocation moveStockLocationUsecase;
  final GetCategories getCategoriesUsecase;

  ProductBloc({
    required this.getProductsUsecase,
    required this.getProductDetailUsecase,
    required this.createProductUsecase,
    required this.updateProductUsecase,
    required this.deleteProductUsecase,
    // required this.addStockLocationUsecase,
    // required this.updateStockLocationUsecase,
    // required this.moveStockLocationUsecase,
    required this.getCategoriesUsecase,
  }) : super(ProductInitial()) {
    on<GetProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await getProductsUsecase();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(AppErrorHandler.extractMessage(e)));
      }
    });
    on<GetProductDetailsEvent>((event, emit) async {
      debugPrint('[ProductBloc] GetProductDetailsEvent: ${event.id}');
      emit(ProductLoading());
      try {
        final product = await getProductDetailUsecase(event.id);
        debugPrint(
          '[ProductBloc] GetProductDetailsEvent success: ${product.id}',
        );
        emit(ProductDetailLoaded(product));
      } catch (e) {
        debugPrint('[ProductBloc] GetProductDetailsEvent error: $e');
        emit(ProductError(AppErrorHandler.extractMessage(e)));
      }
    });
    on<CreateProductEvent>((event, emit) async {
      debugPrint('[ProductBloc] CreateProductEvent: ${event.sku}');
      emit(ProductLoading());
      try {
        await createProductUsecase(_productFromEvent(event));
        debugPrint('[ProductBloc] CreateProductEvent success');
        emit(ProductActionSuccess('created'));
        add(GetProductsEvent());
      } catch (e) {
        debugPrint('[ProductBloc] CreateProductEvent error: $e');
        emit(ProductError(AppErrorHandler.extractMessage(e)));
      }
    });
    on<UpdateProductEvent>((event, emit) async {
      debugPrint('[ProductBloc] UpdateProductEvent: ${event.id}');
      emit(ProductLoading());
      try {
        await updateProductUsecase(_productFromEvent(event));
        debugPrint('[ProductBloc] UpdateProductEvent success');
        emit(ProductActionSuccess('updated'));
        add(GetProductDetailsEvent(event.id));
      } catch (e) {
        debugPrint('[ProductBloc] UpdateProductEvent error: $e');
        emit(ProductError(AppErrorHandler.extractMessage(e)));
      }
    });
    on<DeleteProductEvent>((event, emit) async {
      debugPrint('[ProductBloc] DeleteProductEvent: ${event.id}');
      emit(ProductLoading());
      try {
        await deleteProductUsecase(event.id);
        debugPrint('[ProductBloc] DeleteProductEvent success');
        add(GetProductsEvent());
        emit(ProductActionSuccess('deleted'));
      } catch (e) {
        debugPrint('[ProductBloc] DeleteProductEvent error: $e');
        emit(ProductError(AppErrorHandler.extractMessage(e)));
      }
    });
    // Stock location events - not yet implemented in backend
    // on<AddStockLocationEvent>((event, emit) async { ... }
    // on<UpdateStockLocationEvent>((event, emit) async { ... }
    // on<MoveStockLocationEvent>((event, emit) async { ... }
    on<LoadCategoriesEvent>((event, emit) async {
      emit(CategoriesLoading());
      try {
        final categories = await getCategoriesUsecase();
        emit(CategoriesLoaded(categories));
      } catch (e) {
        emit(CategoriesError(AppErrorHandler.extractMessage(e)));
      }
    });
  }

  Product _productFromEvent(ProductEvent event) {
    if (event is CreateProductEvent) {
      return Product(
        id: '',
        sku: event.sku,
        productName: event.productName,
        barcode: event.barcode,
        categoryId: event.categoryId,
        unitOfMeasure: event.unitOfMeasure,
      );
    }
    if (event is UpdateProductEvent) {
      return Product(
        id: event.id,
        sku: event.sku ?? '',
        productName: event.productName ?? '',
        barcode: event.barcode ?? '',
        categoryId: event.categoryId,
        unitOfMeasure: event.unitOfMeasure ?? '',
      );
    }
    throw ArgumentError('Unsupported product event: $event');
  }
}
