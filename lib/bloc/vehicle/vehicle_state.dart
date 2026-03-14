import '../../models/car.dart';
import '../../models/motorcycle.dart';
import '../../models/truck.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Motorcycle> motorcycles;
  final List<Car> cars;
  final List<Truck> trucks;

  VehicleLoaded({
    required this.motorcycles,
    required this.cars,
    required this.trucks,
  });
}

class VehicleError extends VehicleState {
  final String message;
  VehicleError(this.message);
}
