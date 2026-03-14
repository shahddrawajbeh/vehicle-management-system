import '../models/automobile.dart';
import '../models/car.dart';
import '../models/enums.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';

class VehicleRepository {
  final List<Motorcycle> _motorcycles = [];
  final List<Car> _cars = [];
  final List<Truck> _trucks = [];

  List<Motorcycle> get motorcycles => List.unmodifiable(_motorcycles);
  List<Car> get cars => List.unmodifiable(_cars);
  List<Truck> get trucks => List.unmodifiable(_trucks);

  void setAll({
    required List<Motorcycle> motorcycles,
    required List<Car> cars,
    required List<Truck> trucks,
  }) {
    _motorcycles
      ..clear()
      ..addAll(motorcycles);
    _cars
      ..clear()
      ..addAll(cars);
    _trucks
      ..clear()
      ..addAll(trucks);
  }

  void addVehicle(Automobile vehicle) {
    if (vehicle.id.isEmpty) {
      vehicle.id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    if (vehicle is Motorcycle) {
      _motorcycles.add(vehicle);
    } else if (vehicle is Car) {
      _cars.add(vehicle);
    } else if (vehicle is Truck) {
      _trucks.add(vehicle);
    }
  }

  void insertVehicleAt(int index, Automobile vehicle) {
    if (vehicle.id.isEmpty) {
      vehicle.id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    if (vehicle is Motorcycle) {
      final i = index.clamp(0, _motorcycles.length);
      _motorcycles.insert(i, vehicle);
    } else if (vehicle is Car) {
      final i = index.clamp(0, _cars.length);
      _cars.insert(i, vehicle);
    } else if (vehicle is Truck) {
      final i = index.clamp(0, _trucks.length);
      _trucks.insert(i, vehicle);
    }
  }

  void updateVehicle(Automobile updated) {
    if (updated is Motorcycle) {
      final index = _motorcycles.indexWhere((e) => e.id == updated.id);
      if (index != -1) _motorcycles[index] = updated;
    } else if (updated is Car) {
      final index = _cars.indexWhere((e) => e.id == updated.id);
      if (index != -1) _cars[index] = updated;
    } else if (updated is Truck) {
      final index = _trucks.indexWhere((e) => e.id == updated.id);
      if (index != -1) _trucks[index] = updated;
    }
  }

  void deleteVehicle(String id, VehicleType type) {
    switch (type) {
      case VehicleType.motorcycle:
        _motorcycles.removeWhere((e) => e.id == id);
        break;
      case VehicleType.car:
        _cars.removeWhere((e) => e.id == id);
        break;
      case VehicleType.truck:
        _trucks.removeWhere((e) => e.id == id);
        break;
    }
  }

  List<Automobile> getAllVehicles() {
    return [
      ..._motorcycles,
      ..._cars,
      ..._trucks,
    ];
  }
}
