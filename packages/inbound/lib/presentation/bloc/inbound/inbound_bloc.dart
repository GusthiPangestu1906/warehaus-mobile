import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/usecases/inbound/get_pa_next_item.dart';
import 'package:inbound/domain/usecases/inbound/get_qc_next_item.dart';
import 'package:inbound/domain/usecases/inbound/submit_pa.dart';
import 'package:inbound/domain/usecases/inbound/submit_qc.dart';

import 'inbound_event.dart';
import 'inbound_state.dart';

class InboundBloc extends Bloc<InboundEvent, InboundState> {
  final GetQcNextItem getQcNextItemUsecase;
  final SubmitQc submitQcUsecase;
  final GetPaNextItem getPaNextItemUsecase;
  final SubmitPa submitPaUsecase;

  InboundBloc({
    required this.getQcNextItemUsecase,
    required this.submitQcUsecase,
    required this.getPaNextItemUsecase,
    required this.submitPaUsecase,
  }) : super(InboundInitial()) {
    on<GetQcNextItemEvent>(_onGetQcNextItem);
    on<SubmitQcEvent>(_onSubmitQc);
    on<GetPaNextItemEvent>(_onGetPaNextItem);
    on<SubmitPaEvent>(_onSubmitPa);
  }

  Future<void> _onGetQcNextItem(
    GetQcNextItemEvent event,
    Emitter<InboundState> emit,
  ) async {
    emit(InboundLoading());
    final result = await getQcNextItemUsecase(event.poId);
    result.fold(
      (failure) => emit(InboundError(failure.message)),
      (item) => emit(QcNextItemLoaded(item)),
    );
  }

  Future<void> _onSubmitQc(
    SubmitQcEvent event,
    Emitter<InboundState> emit,
  ) async {
    emit(InboundLoading());
    final result = await submitQcUsecase(event.params);
    result.fold(
      (failure) => emit(InboundError(failure.message)),
      (_) => emit(SubmitQcSuccess()),
    );
  }

  Future<void> _onGetPaNextItem(
    GetPaNextItemEvent event,
    Emitter<InboundState> emit,
  ) async {
    emit(InboundLoading());
    final result = await getPaNextItemUsecase(event.poId);
    result.fold(
      (failure) => emit(InboundError(failure.message)),
      (item) => emit(PaNextItemLoaded(item)),
    );
  }

  Future<void> _onSubmitPa(
    SubmitPaEvent event,
    Emitter<InboundState> emit,
  ) async {
    emit(InboundLoading());
    final result = await submitPaUsecase(event.params, event.receivingLogId);
    result.fold(
      (failure) => emit(InboundError(failure.message)),
      (_) => emit(SubmitPaSuccess()),
    );
  }
}
