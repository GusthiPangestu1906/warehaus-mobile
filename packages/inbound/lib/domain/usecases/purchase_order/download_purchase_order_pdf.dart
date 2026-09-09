import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';
import 'package:inbound/domain/services/local_file_service.dart';

class DownloadPurchaseOrderPdf {
  final PurchaseOrderRepository repository;
  final LocalFileService fileService;

  const DownloadPurchaseOrderPdf(this.repository, this.fileService);

  Future<Either<Failure, String>> call(int id, String poNumber) async {
    final downloadResult = await repository.downloadPurchaseOrderPdf(id);

    return downloadResult.fold((failure) => Left(failure), (bytes) async {
      return await fileService.savePdf(bytes, poNumber);
    });
  }
}
