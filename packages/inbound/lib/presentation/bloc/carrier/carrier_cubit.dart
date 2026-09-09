import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/usecases/purchase_order/get_carriers.dart';

import 'carrier_state.dart';

class CarrierCubit extends Cubit<CarrierState> {
  final GetCarriers getCarriersUsecase;

  CarrierCubit({required this.getCarriersUsecase}) : super(CarrierInitial());

  Future<void> fetchCarriers() async {
    emit(CarrierLoading());

    final result = await getCarriersUsecase();

    result.fold(
      (failure) => emit(CarrierError(failure.message)),
      (carriers) => emit(CarrierLoaded(carriers)),
    );
  }
}
