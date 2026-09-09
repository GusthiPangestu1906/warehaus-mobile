import 'package:equatable/equatable.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';
import 'package:inbound/domain/entities/qc_next_item.dart';

sealed class InboundState extends Equatable {
  const InboundState();

  @override
  List<Object?> get props => [];
}

class InboundInitial extends InboundState {}

class InboundLoading extends InboundState {}

class QcNextItemLoaded extends InboundState {
  final QcNextItem item;
  const QcNextItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

class SubmitQcSuccess extends InboundState {}

class PaNextItemLoaded extends InboundState {
  final PaNextItem item;
  const PaNextItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

class SubmitPaSuccess extends InboundState {}

class InboundError extends InboundState {
  final String message;
  const InboundError(this.message);

  @override
  List<Object?> get props => [message];
}
