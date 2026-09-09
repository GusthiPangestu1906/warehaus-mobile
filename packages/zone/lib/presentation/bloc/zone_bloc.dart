import 'package:core_services/interceptors/error/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zone/domain/usecases/create_zone.dart';
import 'package:zone/domain/usecases/delete_zone.dart';
import 'package:zone/domain/usecases/get_shelf_details.dart';
import 'package:zone/domain/usecases/get_zone_by_aisle.dart';
import 'package:zone/domain/usecases/get_zone_details.dart';
import 'package:zone/domain/usecases/get_zones.dart';
import 'package:zone/domain/usecases/update_zone.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';

class ZoneBloc extends Bloc<ZoneEvent, ZoneState> {
  final GetZones getZonesUsecase;
  final GetZoneByAisle getZoneByAisleUsecase;
  final GetZoneDetails getZoneDetailsUsecase;
  final CreateZone createZoneUsecase;
  final UpdateZone updateZoneUsecase;
  final DeleteZone deleteZoneUsecase;
  final GetShelfDetails getShelfDetailsUsecase;

  ZoneBloc({
    required this.getZonesUsecase,
    required this.getZoneByAisleUsecase,
    required this.createZoneUsecase,
    required this.updateZoneUsecase,
    required this.deleteZoneUsecase,
    required this.getZoneDetailsUsecase,
    required this.getShelfDetailsUsecase,
  }) : super(ZoneInitial()) {
    on<GetZonesEvent>((event, emit) async {
      debugPrint('[ZoneBloc] GetZonesEvent');
      emit(ZoneLoading());
      try {
        final zones = await getZonesUsecase();
        debugPrint('[ZoneBloc] GetZonesEvent success: ${zones.length}');
        emit(ZoneLoaded(zones));
      } catch (e) {
        debugPrint('[ZoneBloc] GetZonesEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
    on<GetZoneByAisleEvent>((event, emit) async {
      debugPrint('[ZoneBloc] GetZoneByAisleEvent');
      emit(ZoneLoading());
      try {
        final zones = await getZoneByAisleUsecase(
          event.zoneId,
          event.aisleNumber,
        );
        debugPrint('[ZoneBloc] GetZoneByAisleEvent success: ${zones.length}');
        emit(ZoneLoaded(zones));
      } catch (e) {
        debugPrint('[ZoneBloc] GetZoneByAisleEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
    on<GetZoneDetailsEvent>((event, emit) async {
      debugPrint('[ZoneBloc] GetZoneDetailsEvent: ${event.zoneId}');
      emit(ZoneLoading());
      try {
        final zone = await getZoneDetailsUsecase(event.zoneId);
        debugPrint('[ZoneBloc] GetZoneDetailsEvent success: ${zone.id}');
        emit(ZoneLoaded([zone]));
      } catch (e) {
        debugPrint('[ZoneBloc] GetZoneDetailsEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
    on<GetShelfDetailsEvent>((event, emit) async {
      debugPrint('[ZoneBloc] GetShelfDetailsEvent: ${event.shelfId}');
      emit(ZoneLoading());
      try {
        final shelfDetail = await getShelfDetailsUsecase(event.shelfId);
        debugPrint('[ZoneBloc] GetShelfDetailsEvent success');
        emit(
          ShelfDetailLoaded(shelfId: event.shelfId, shelfDetail: shelfDetail),
        );
      } catch (e) {
        debugPrint('[ZoneBloc] GetShelfDetailsEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
    on<CreateZoneEvent>((event, emit) async {
      emit(ZoneLoading());
      try {
        final zone = event.zone;
        await createZoneUsecase(zone);
        final zones = await getZonesUsecase();
        debugPrint('[ZoneBloc] CreateZoneEvent success');
        // Emit ZoneOperationSuccess agar listener (CreateZonePage) bisa pop,
        // lalu emit ZoneLoaded agar ZoneListPage punya data terbaru.
        emit(ZoneOperationSuccess(zones, message: 'Zone Saved'));
      } catch (e) {
        debugPrint('[ZoneBloc] CreateZoneEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
    on<UpdateZoneEvent>((event, emit) async {
      debugPrint('[ZoneBloc] UpdateZoneEvent: ${event.id}');
      emit(ZoneLoading());
      try {
        await updateZoneUsecase(
          id: event.id,
          zoneName: event.zoneName,
          categoryId: event.categoryId,
          description: event.description,
        );
        final zones = await getZonesUsecase();
        debugPrint('[ZoneBloc] UpdateZoneEvent success');
        // Emit ZoneOperationSuccess lalu ZoneLoaded agar list ter-refresh
        // tanpa race condition saat dialog/page sedang di-dispose.
        emit(ZoneOperationSuccess(zones, message: 'Zone Saved'));
        emit(ZoneLoaded(zones));
      } catch (e) {
        debugPrint('[ZoneBloc] UpdateZoneEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
    on<DeleteZoneEvent>((event, emit) async {
      debugPrint('[ZoneBloc] DeleteZoneEvent: ${event.id}');
      emit(ZoneLoading());
      try {
        await deleteZoneUsecase(event.id);
        final zones = await getZonesUsecase();
        debugPrint('[ZoneBloc] DeleteZoneEvent success');
        emit(ZoneOperationSuccess(zones, message: 'Zone Deleted'));
        emit(ZoneLoaded(zones));
      } catch (e) {
        debugPrint('[ZoneBloc] DeleteZoneEvent error: $e');
        emit(ZoneError(_extractErrorMessage(e)));
      }
    });
  }
}

String _extractErrorMessage(Object e) {
  // DioException membungkus ApiException di field .error
  if (e is DioException) {
    if (e.error is ApiException) {
      return (e.error as ApiException).message;
    }
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['detail'] ?? data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
  }
  if (e is ApiException) return e.message;
  return e.toString();
}
