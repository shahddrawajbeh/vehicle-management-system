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

abstract class VehicleError extends VehicleState {
  final String message;
  VehicleError(this.message);
}

class NetworkUnavailableState extends VehicleError {
  NetworkUnavailableState()
      : super('Network is unavailable. Using cached data if available.');
}

class ServerErrorState extends VehicleError {
  final int? statusCode;

  ServerErrorState({this.statusCode, String? message})
      : super(message ??
            'Server error occurred. Using cached data if available.');
}

class TimeoutState extends VehicleError {
  TimeoutState() : super('Request timed out. Using cached data if available.');
}

class UnknownErrorState extends VehicleError {
  UnknownErrorState(String msg) : super(msg);
}

// For cached data when offline
class VehicleLoadedOffline extends VehicleState {
  final List<Motorcycle> motorcycles;
  final List<Car> cars;
  final List<Truck> trucks;

  VehicleLoadedOffline({
    required this.motorcycles,
    required this.cars,
    required this.trucks,
  });
}
