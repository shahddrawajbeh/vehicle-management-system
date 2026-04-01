// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../repository/storage_service.dart';
// import '../../repository/vehicle_repository.dart';
// import 'vehicle_event.dart';
// import 'vehicle_state.dart';

// class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
//   final VehicleRepository repository;
//   final StorageService storageService;

//   VehicleBloc({
//     required this.repository,
//     required this.storageService,
//   }) : super(VehicleInitial()) {
//     on<LoadVehiclesEvent>(_onLoadVehicles);
//     on<SaveVehiclesEvent>(_onSaveVehicles);
//     on<AddVehicleEvent>(_onAddVehicle);
//     on<DeleteVehicleEvent>(_onDeleteVehicle);
//     on<InsertVehicleAtEvent>(_onInsertVehicleAt);
//     on<UpdateVehicleEvent>(_onUpdateVehicle);
//   }

//   Future<void> _onLoadVehicles(
//     LoadVehiclesEvent event,
//     Emitter<VehicleState> emit,
//   ) async {
//     try {
//       emit(VehicleLoading());

//       final data = await storageService.loadAll();

//       repository.setAll(
//         motorcycles: data['motorcycles'],
//         cars: data['cars'],
//         trucks: data['trucks'],
//       );

//       emit(_buildLoadedState());
//     } catch (e) {
//       emit(VehicleError('Failed to load vehicles: $e'));
//     }
//   }

//   Future<void> _onSaveVehicles(
//     SaveVehiclesEvent event,
//     Emitter<VehicleState> emit,
//   ) async {
//     try {
//       await storageService.saveAll(
//         motorcycles: repository.motorcycles,
//         cars: repository.cars,
//         trucks: repository.trucks,
//       );

//       emit(_buildLoadedState());
//     } catch (e) {
//       emit(VehicleError('Failed to save vehicles: $e'));
//     }
//   }

//   void _onAddVehicle(
//     AddVehicleEvent event,
//     Emitter<VehicleState> emit,
//   ) {
//     repository.addVehicle(event.vehicle);
//     emit(_buildLoadedState());
//   }

//   void _onDeleteVehicle(
//     DeleteVehicleEvent event,
//     Emitter<VehicleState> emit,
//   ) {
//     repository.deleteVehicle(event.id, event.type);
//     emit(_buildLoadedState());
//   }

//   void _onInsertVehicleAt(
//     InsertVehicleAtEvent event,
//     Emitter<VehicleState> emit,
//   ) {
//     repository.insertVehicleAt(event.index, event.vehicle);
//     emit(_buildLoadedState());
//   }

//   void _onUpdateVehicle(
//     UpdateVehicleEvent event,
//     Emitter<VehicleState> emit,
//   ) {
//     repository.updateVehicle(event.updated);
//     emit(_buildLoadedState());
//   }

//   VehicleLoaded _buildLoadedState() {
//     return VehicleLoaded(
//       motorcycles: repository.motorcycles,
//       cars: repository.cars,
//       trucks: repository.trucks,
//     );
//   }
// }
//---------------------------------one
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

    // مؤقتًا نخليه موجود حتى ما ينهار التطبيق
    // لو لسا الشاشة بتبعث SaveVehiclesEvent
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

      // Cache successful response
      await cacheService.cacheVehicles(vehicles);

      emit(_buildLoadedState());
    } on NetworkUnavailableException {
      // Try to load from cache
      await _loadFromCacheOrEmitError(
        emit,
        NetworkUnavailableState(),
      );
    } on TimeoutException {
      // Try to load from cache
      await _loadFromCacheOrEmitError(
        emit,
        TimeoutState(),
      );
    } on ServerErrorException catch (e) {
      // Try to load from cache
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

      // Cache after add
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

      // Cache after delete
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

      // Cache after insert
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

      // Cache after update
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

    // Initial load
    add(LoadVehiclesEvent());

    // Poll every 30 seconds
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
//------------------threeee