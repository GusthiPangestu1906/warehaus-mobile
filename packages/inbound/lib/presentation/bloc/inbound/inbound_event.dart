import 'package:equatable/equatable.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';

sealed class InboundEvent extends Equatable {
  const InboundEvent();

  @override
  List<Object?> get props => [];
}

class GetQcNextItemEvent extends InboundEvent {
  final int poId;
  const GetQcNextItemEvent(this.poId);

  @override
  List<Object?> get props => [poId];
}

class SubmitQcEvent extends InboundEvent {
  final SubmitQcParams params;
  const SubmitQcEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class GetPaNextItemEvent extends InboundEvent {
  final int poId;
  const GetPaNextItemEvent(this.poId);

  @override
  List<Object?> get props => [poId];
}

class SubmitPaEvent extends InboundEvent {
  final SubmitPaParams params;
  final int receivingLogId;
  const SubmitPaEvent(this.params, this.receivingLogId);

  @override
  List<Object?> get props => [params, receivingLogId];
}
