import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:inbound/data/datasources/purchase_order_api_datasource.dart';
import 'package:inbound/data/models/carrier_model.dart';
import 'package:inbound/data/models/pa_next_item_model.dart';
import 'package:inbound/data/models/purchase_order_model.dart';
import 'package:inbound/data/models/qc_next_item_model.dart';
import 'package:inbound/domain/failure/po_failure.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class PurchaseOrderRepositoryImpl extends PurchaseOrderRepository {
  final PurchaseOrderApiDatasource apiDatasource;
  PurchaseOrderRepositoryImpl(this.apiDatasource);

  @override
  Future<Either<Failure, List<PurchaseOrderModel>>> getPurchaseOrders(
    DateTime date,
  ) async {
    try {
      final response = await apiDatasource.getPurchaseOrders(date);

      return Right(response);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PurchaseOrderModel>> getPurchaseOrderDetail(
    int id,
  ) async {
    try {
      final response = await apiDatasource.getPurchaseOrderDetail(id);
      return Right(response);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createPurchaseOrder(
    CreatePoParams params,
  ) async {
    try {
      await apiDatasource.createPurchaseOrder(params.toJson());
      return Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> invoiceUpdate(
    int id,
    String invoiceNumber,
  ) async {
    try {
      await apiDatasource.invoiceUpdate(id, invoiceNumber);
      return Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePurchaseOrder(int id) async {
    try {
      await apiDatasource.deletePurchaseOrder(id);
      return Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> downloadPurchaseOrderPdf(
    int id,
    String poNumber,
  ) async {
    try {
      final filePath = await apiDatasource.downloadPurchaseOrderPdf(
        id,
        poNumber,
      );
      return Right(filePath);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QcNextItemModel>> getQcNextItem(int poId) async {
    try {
      final response = await apiDatasource.getQcNextItem(poId);
      return Right(response);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitQc(SubmitQcParams params) async {
    try {
      await apiDatasource.submitQc(params.toJson());
      return Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaNextItemModel>> getPaNextItem(int poId) async {
    try {
      final response = await apiDatasource.getPaNextItem(poId);
      return Right(response);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitPa(
    SubmitPaParams params,
    int receivingLogId,
  ) async {
    try {
      await apiDatasource.submitPa(params.toJson(), receivingLogId);
      return Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CarrierModel>>> getCarriers() async {
    try {
      final response = await apiDatasource.getCarriers();
      return Right(response);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  Failure _failureFromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    if (e.type == DioExceptionType.badResponse) {
      final responseData = e.response?.data;
      String errorMessage = 'Terjadi kesalahan validasi (400).';

      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['detail']?.toString() ?? errorMessage;
      }

      return BadRequestFailure(errorMessage);
    }

    return ServerFailure();
  }
}
