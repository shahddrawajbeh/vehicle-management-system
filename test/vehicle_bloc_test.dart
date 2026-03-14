import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/bloc/vehicle/vehicle_bloc.dart';
import 'package:flutter_application_1/bloc/vehicle/vehicle_event.dart';
import 'package:flutter_application_1/bloc/vehicle/vehicle_state.dart';
import 'package:flutter_application_1/models/car.dart';
import 'package:flutter_application_1/models/engine.dart';
import 'package:flutter_application_1/models/enums.dart';
import 'package:flutter_application_1/models/motorcycle.dart';
import 'package:flutter_application_1/models/truck.dart';
import 'package:flutter_application_1/repository/storage_service.dart';
import 'package:flutter_application_1/repository/vehicle_repository.dart';

class FakeStorageService extends StorageService {
  List<Motorcycle> fakeMotorcycles = [];
  List<Car> fakeCars = [];
  List<Truck> fakeTrucks = [];

  @override
  Future<Map<String, dynamic>> loadAll() async {
    return {
      'motorcycles': fakeMotorcycles,
      'cars': fakeCars,
      'trucks': fakeTrucks,
    };
  }

  @override
  Future<void> saveAll({
    required List<Motorcycle> motorcycles,
    required List<Car> cars,
    required List<Truck> trucks,
  }) async {}
}

void main() {
  late VehicleRepository repository;
  late FakeStorageService storageService;
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
    storageService = FakeStorageService();
    vehicleBloc = VehicleBloc(
      repository: repository,
      storageService: storageService,
    );
  });

  tearDown(() async {
    await vehicleBloc.close();
  });

  blocTest<VehicleBloc, VehicleState>(
    'add vehicle emits VehicleLoaded with one car',
    build: () => vehicleBloc,
    act: (bloc) => bloc.add(AddVehicleEvent(buildTestCar())),
    expect: () => [
      isA<VehicleLoaded>(),
    ],
    verify: (_) {
      expect(repository.cars.length, 1);
      expect(repository.cars.first.id, 'car1');
    },
  );

  blocTest<VehicleBloc, VehicleState>(
    'delete vehicle emits VehicleLoaded and removes car',
    build: () {
      repository.addVehicle(buildTestCar());
      return vehicleBloc;
    },
    act: (bloc) => bloc.add(DeleteVehicleEvent('car1', VehicleType.car)),
    expect: () => [
      isA<VehicleLoaded>(),
    ],
    verify: (_) {
      expect(repository.cars.isEmpty, true);
    },
  );

  blocTest<VehicleBloc, VehicleState>(
    'load vehicles emits VehicleLoading then VehicleLoaded',
    build: () {
      storageService.fakeCars = [buildTestCar()];
      storageService.fakeMotorcycles = [];
      storageService.fakeTrucks = [];
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
