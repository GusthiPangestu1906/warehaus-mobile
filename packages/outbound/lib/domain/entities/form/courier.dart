import 'package:equatable/equatable.dart';

class Courier extends Equatable {
  final String code;
  final String name;
  final String serviceType;
  final bool isActive;

  const Courier({
    required this.code,
    required this.name,
    required this.serviceType,
    required this.isActive,
  });

  @override
  List<Object?> get props => [code, name, serviceType, isActive];
}
