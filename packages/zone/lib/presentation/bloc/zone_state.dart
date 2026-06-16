import 'package:zone/domain/entities/shelf_detail.dart';
import 'package:zone/domain/entities/zone.dart';

abstract class ZoneState {}

class ZoneInitial extends ZoneState {}

class ZoneLoading extends ZoneState {}

class ZoneLoaded extends ZoneState {
  final List<Zone> zones;

  ZoneLoaded(this.zones);
}

/// State khusus setelah operasi mutasi (create/update/delete) berhasil.
/// Digunakan untuk memberi sinyal "selesai" kepada page/dialog
/// tanpa mencampur dengan state ZoneLoaded (yang dipakai untuk render list).
class ZoneOperationSuccess extends ZoneState {
  final List<Zone> zones;
  final String? message;

  ZoneOperationSuccess(this.zones, {this.message});
}

class ZoneError extends ZoneState {
  final String message;

  ZoneError(this.message);
}

class ShelfDetailLoaded extends ZoneState {
  final int shelfId;
  final ShelfDetail? shelfDetail;

  ShelfDetailLoaded({required this.shelfId, this.shelfDetail});
}
