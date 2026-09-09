import 'package:equatable/equatable.dart';
import 'package:inbound/domain/entities/carrier.dart';

sealed class CarrierState extends Equatable {
  const CarrierState();

  @override
  List<Object?> get props => [];
}

class CarrierInitial extends CarrierState {}

class CarrierLoading extends CarrierState {}

class CarrierLoaded extends CarrierState {
  final List<Carrier> carriers;

  const CarrierLoaded(this.carriers);

  @override
  List<Object?> get props => [carriers];
}

class CarrierError extends CarrierState {
  final String message;

  const CarrierError(this.message);

  @override
  List<Object?> get props => [message];
}
