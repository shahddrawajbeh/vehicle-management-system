import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/bloc/vehicle/vehicle_bloc.dart';
import 'package:flutter_application_1/bloc/vehicle/vehicle_event.dart';
import 'package:flutter_application_1/bloc/vehicle/vehicle_state.dart';
import 'package:flutter_application_1/models/automobile.dart';
import 'package:flutter_application_1/models/car.dart';
import 'package:flutter_application_1/models/engine.dart';
import 'package:flutter_application_1/models/enums.dart';
import 'package:flutter_application_1/repository/vehicle_repository.dart';
import 'package:flutter_application_1/services/vehicle_api_service.dart';
import 'package:flutter_application_1/services/cache_service.dart';

class FakeVehicleApiService extends VehicleApiService {
  final List<Automobile> fakeVehicles = [];

  @override
  Future<List<Automobile>> getVehicles({
    int page = 1,
    int limit = 10,
  }) async {
    return List<Automobile>.from(fakeVehicles);
  }

  @override
  Future<void> addVehicle(Automobile vehicle) async {
    fakeVehicles.add(vehicle);
  }

  @override
  Future<void> updateVehicle(Automobile vehicle) async {
    final index = fakeVehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      fakeVehicles[index] = vehicle;
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    fakeVehicles.removeWhere((v) => v.id == id);
  }
}

void main() {
  late VehicleRepository repository;
  late FakeVehicleApiService apiService;
  late CacheService cacheService;
  late VehicleBloc vehicleBloc;

  Car buildTestCar() {
    final car = Car.full(
      'Toyota',
      DateTime(2024, 1, 1),
      'Corolla',
      Engine.full(
        'Toyota',
        DateTime(2024, 1, 1),
        'E1',
        1600,
        4,
        FuelType.gasoline,
      ),
      1234,
      GearType.automatic,
      999,
      10,
      5,
      'White',
      5,
      true,
    );
    car.id = 'car1';
    return car;
  }

  setUp(() {
    repository = VehicleRepository();
    apiService = FakeVehicleApiService();
    cacheService = CacheService();
    vehicleBloc = VehicleBloc(
      repository: repository,
      apiService: apiService,
      cacheService: cacheService,
    );
  });

  tearDown(() async {
    await vehicleBloc.close();
  });

  blocTest<VehicleBloc, VehicleState>(
    'add vehicle emits VehicleLoading then VehicleLoaded with one car',
    build: () => vehicleBloc,
    act: (bloc) => bloc.add(AddVehicleEvent(buildTestCar())),
    expect: () => [
      isA<VehicleLoading>(),
      isA<VehicleLoaded>(),
    ],
    verify: (_) {
      expect(repository.cars.length, 1);
      expect(repository.cars.first.id, 'car1');
      expect(apiService.fakeVehicles.length, 1);
    },
  );

  blocTest<VehicleBloc, VehicleState>(
    'delete vehicle emits VehicleLoading then VehicleLoaded and removes car',
    build: () {
      final car = buildTestCar();
      repository.addVehicle(car);
      apiService.fakeVehicles.add(car);
      return vehicleBloc;
    },
    act: (bloc) => bloc.add(DeleteVehicleEvent('car1', VehicleType.car)),
    expect: () => [
      isA<VehicleLoading>(),
      isA<VehicleLoaded>(),
    ],
    verify: (_) {
      expect(repository.cars.isEmpty, true);
      expect(apiService.fakeVehicles.isEmpty, true);
    },
  );

  blocTest<VehicleBloc, VehicleState>(
    'load vehicles emits VehicleLoading then VehicleLoaded',
    build: () {
      apiService.fakeVehicles.add(buildTestCar());
      return vehicleBloc;
    },
    act: (bloc) => bloc.add(LoadVehiclesEvent()),
    expect: () => [
      isA<VehicleLoading>(),
      isA<VehicleLoaded>(),
    ],
    verify: (_) {
      expect(repository.cars.length, 1);
      expect(repository.cars.first.id, 'car1');
    },
  );
}
