import '../../models/automobile.dart';
import '../../models/enums.dart';

abstract class VehicleEvent {}

class LoadVehiclesEvent extends VehicleEvent {}

class SaveVehiclesEvent extends VehicleEvent {}

class AddVehicleEvent extends VehicleEvent {
  final Automobile vehicle;
  AddVehicleEvent(this.vehicle);
}

class DeleteVehicleEvent extends VehicleEvent {
  final String id;
  final VehicleType type;

  DeleteVehicleEvent(this.id, this.type);
}

class InsertVehicleAtEvent extends VehicleEvent {
  final int index;
  final Automobile vehicle;

  InsertVehicleAtEvent(this.index, this.vehicle);
}

class UpdateVehicleEvent extends VehicleEvent {
  final Automobile updated;

  UpdateVehicleEvent(this.updated);
}
