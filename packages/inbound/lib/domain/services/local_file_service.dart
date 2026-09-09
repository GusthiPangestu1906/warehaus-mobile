import 'package:dartz/dartz.dart';
import 'package:core_services/core_services.dart';

abstract class LocalFileService {
  Future<Either<Failure, String>> savePdf(List<int> bytes, String fileName);
}
