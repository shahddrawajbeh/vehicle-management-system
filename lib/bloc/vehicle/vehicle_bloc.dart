import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/storage_service.dart';
import '../../repository/vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository repository;
  final StorageService storageService;

  VehicleBloc({
    required this.repository,
    required this.storageService,
  }) : super(VehicleInitial()) {
    on<LoadVehiclesEvent>(_onLoadVehicles);
    on<SaveVehiclesEvent>(_onSaveVehicles);
    on<AddVehicleEvent>(_onAddVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<InsertVehicleAtEvent>(_onInsertVehicleAt);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
  }

  Future<void> _onLoadVehicles(
    LoadVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      final data = await storageService.loadAll();

      repository.setAll(
        motorcycles: data['motorcycles'],
        cars: data['cars'],
        trucks: data['trucks'],
      );

      emit(_buildLoadedState());
    } catch (e) {
      emit(VehicleError('Failed to load vehicles: $e'));
    }
  }

  Future<void> _onSaveVehicles(
    SaveVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await storageService.saveAll(
        motorcycles: repository.motorcycles,
        cars: repository.cars,
        trucks: repository.trucks,
      );

      emit(_buildLoadedState());
    } catch (e) {
      emit(VehicleError('Failed to save vehicles: $e'));
    }
  }

  void _onAddVehicle(
    AddVehicleEvent event,
    Emitter<VehicleState> emit,
  ) {
    repository.addVehicle(event.vehicle);
    emit(_buildLoadedState());
  }

  void _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) {
    repository.deleteVehicle(event.id, event.type);
    emit(_buildLoadedState());
  }

  void _onInsertVehicleAt(
    InsertVehicleAtEvent event,
    Emitter<VehicleState> emit,
  ) {
    repository.insertVehicleAt(event.index, event.vehicle);
    emit(_buildLoadedState());
  }

  void _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) {
    repository.updateVehicle(event.updated);
    emit(_buildLoadedState());
  }

  VehicleLoaded _buildLoadedState() {
    return VehicleLoaded(
      motorcycles: repository.motorcycles,
      cars: repository.cars,
      trucks: repository.trucks,
    );
  }
}
