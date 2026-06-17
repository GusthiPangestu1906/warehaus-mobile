import 'package:zone/domain/params/create_zone_param.dart';

abstract class ZoneEvent {}

class GetZonesEvent extends ZoneEvent {}

class GetZoneByAisleEvent extends ZoneEvent {
  final int zoneId;
  final int aisleNumber;

  GetZoneByAisleEvent({required this.zoneId, required this.aisleNumber});
}

class GetZoneDetailsEvent extends ZoneEvent {
  final int zoneId;

  GetZoneDetailsEvent({required this.zoneId});
}

class CreateZoneEvent extends ZoneEvent {
  final CreateZoneParam zone;

  CreateZoneEvent(this.zone);
}

class UpdateZoneEvent extends ZoneEvent {
  final int id;
  final String? zoneName;
  final int? categoryId;
  final String? description;

  UpdateZoneEvent({
    required this.id,
    this.zoneName,
    this.categoryId,
    this.description,
  });
}

class DeleteZoneEvent extends ZoneEvent {
  final int id;

  DeleteZoneEvent(this.id);
}

class GetShelfDetailsEvent extends ZoneEvent {
  final int shelfId;

  GetShelfDetailsEvent({required this.shelfId});
}
