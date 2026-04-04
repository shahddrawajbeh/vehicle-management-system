import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../exceptions/vehicle_exceptions.dart';
import '../../models/automobile.dart';
import '../../models/car.dart';
import '../../models/motorcycle.dart';
import '../../models/truck.dart';
import '../../repository/vehicle_repository.dart';
import '../../services/vehicle_api_service.dart';
import '../../services/cache_service.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository repository;
  final VehicleApiService apiService;
  final CacheService cacheService;

  Timer? _pollingTimer;

  VehicleBloc({
    required this.repository,
    required this.apiService,
    required this.cacheService,
  }) : super(VehicleInitial()) {
    on<LoadVehiclesEvent>(_onLoadVehicles);

    on<SaveVehiclesEvent>(_onSaveVehicles);

    on<AddVehicleEvent>(_onAddVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<InsertVehicleAtEvent>(_onInsertVehicleAt);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<StartPollingEvent>(_onStartPolling);
    on<StopPollingEvent>(_onStopPolling);
  }

  Future<void> _onLoadVehicles(
    LoadVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      final vehicles = await apiService.getVehicles();

      repository.setAll(
        motorcycles: vehicles.whereType<Motorcycle>().toList(),
        cars: vehicles.whereType<Car>().toList(),
        trucks: vehicles.whereType<Truck>().toList(),
      );

      await cacheService.cacheVehicles(vehicles);

      emit(_buildLoadedState());
    } on NetworkUnavailableException {
      await _loadFromCacheOrEmitError(
        emit,
        NetworkUnavailableState(),
      );
    } on TimeoutException {
      await _loadFromCacheOrEmitError(
        emit,
        TimeoutState(),
      );
    } on ServerErrorException catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        ServerErrorState(statusCode: e.statusCode),
      );
    } catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        UnknownErrorState('Failed to load vehicles: $e'),
      );
    }
  }

  Future<void> _loadFromCacheOrEmitError(
    Emitter<VehicleState> emit,
    VehicleError errorState,
  ) async {
    try {
      final cached = await cacheService.getCachedVehicles();

      if (cached.isNotEmpty) {
        repository.setAll(
          motorcycles: cached.whereType<Motorcycle>().toList(),
          cars: cached.whereType<Car>().toList(),
          trucks: cached.whereType<Truck>().toList(),
        );

        emit(VehicleLoadedOffline(
          motorcycles: cached.whereType<Motorcycle>().toList(),
          cars: cached.whereType<Car>().toList(),
          trucks: cached.whereType<Truck>().toList(),
        ));
      } else {
        emit(errorState);
      }
    } catch (e) {
      emit(errorState);
    }
  }

  void _onSaveVehicles(
    SaveVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) {
    emit(_buildLoadedState());
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      if (event.vehicle.id.isEmpty) {
        event.vehicle.id = DateTime.now().microsecondsSinceEpoch.toString();
      }

      await apiService.addVehicle(event.vehicle);
      repository.addVehicle(event.vehicle);

      final allVehicles = [
        ...repository.motorcycles,
        ...repository.cars,
        ...repository.trucks,
      ] as List<Automobile>;
      await cacheService.cacheVehicles(allVehicles);

      emit(_buildLoadedState());
    } on NetworkUnavailableException {
      await _loadFromCacheOrEmitError(
        emit,
        NetworkUnavailableState(),
      );
    } on TimeoutException {
      await _loadFromCacheOrEmitError(
        emit,
        TimeoutState(),
      );
    } on ServerErrorException catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        ServerErrorState(statusCode: e.statusCode),
      );
    } catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        UnknownErrorState('Failed to add vehicle: $e'),
      );
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      await apiService.deleteVehicle(event.id);
      repository.deleteVehicle(event.id, event.type);

      final allVehicles = [
        ...repository.motorcycles,
        ...repository.cars,
        ...repository.trucks,
      ] as List<Automobile>;
      await cacheService.cacheVehicles(allVehicles);

      emit(_buildLoadedState());
    } on NetworkUnavailableException {
      await _loadFromCacheOrEmitError(
        emit,
        NetworkUnavailableState(),
      );
    } on TimeoutException {
      await _loadFromCacheOrEmitError(
        emit,
        TimeoutState(),
      );
    } on ServerErrorException catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        ServerErrorState(statusCode: e.statusCode),
      );
    } catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        UnknownErrorState('Failed to delete vehicle: $e'),
      );
    }
  }

  Future<void> _onInsertVehicleAt(
    InsertVehicleAtEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      if (event.vehicle.id.isEmpty) {
        event.vehicle.id = DateTime.now().microsecondsSinceEpoch.toString();
      }

      await apiService.addVehicle(event.vehicle);
      repository.insertVehicleAt(event.index, event.vehicle);

      final allVehicles = [
        ...repository.motorcycles,
        ...repository.cars,
        ...repository.trucks,
      ] as List<Automobile>;
      await cacheService.cacheVehicles(allVehicles);

      emit(_buildLoadedState());
    } on NetworkUnavailableException {
      await _loadFromCacheOrEmitError(
        emit,
        NetworkUnavailableState(),
      );
    } on TimeoutException {
      await _loadFromCacheOrEmitError(
        emit,
        TimeoutState(),
      );
    } on ServerErrorException catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        ServerErrorState(statusCode: e.statusCode),
      );
    } catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        UnknownErrorState('Failed to insert vehicle: $e'),
      );
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      await apiService.updateVehicle(event.updated);
      repository.updateVehicle(event.updated);

      final allVehicles = [
        ...repository.motorcycles,
        ...repository.cars,
        ...repository.trucks,
      ] as List<Automobile>;
      await cacheService.cacheVehicles(allVehicles);

      emit(_buildLoadedState());
    } on NetworkUnavailableException {
      await _loadFromCacheOrEmitError(
        emit,
        NetworkUnavailableState(),
      );
    } on TimeoutException {
      await _loadFromCacheOrEmitError(
        emit,
        TimeoutState(),
      );
    } on ServerErrorException catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        ServerErrorState(statusCode: e.statusCode),
      );
    } catch (e) {
      await _loadFromCacheOrEmitError(
        emit,
        UnknownErrorState('Failed to update vehicle: $e'),
      );
    }
  }

  VehicleLoaded _buildLoadedState() {
    return VehicleLoaded(
      motorcycles: repository.motorcycles,
      cars: repository.cars,
      trucks: repository.trucks,
    );
  }

  Future<void> _onStartPolling(
    StartPollingEvent event,
    Emitter<VehicleState> emit,
  ) async {
    _pollingTimer?.cancel();

    add(LoadVehiclesEvent());

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(LoadVehiclesEvent()),
    );
  }

  Future<void> _onStopPolling(
    StopPollingEvent event,
    Emitter<VehicleState> emit,
  ) async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
