import '../models/car.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';

void printMotorcycle(Motorcycle m) {
  print('--- Motorcycle ---');
  print('Company: ${m.manufactureCompany}');
  print('Date: ${m.manufactureDate}');
  print('Model: ${m.model}');
  print('Plate: ${m.plateNum}');
  print('Gear: ${m.gearType}');
  print('Body Serial: ${m.bodySerialNum}');
  print('Tier Diameter: ${m.tierDiameter}');
  print('Length: ${m.length}');
}

void printCar(Car c) {
  print('--- Car ---');
  print('Company: ${c.manufactureCompany}');
  print('Date: ${c.manufactureDate}');
  print('Model: ${c.model}');
  print('Plate: ${c.plateNum}');
  print('Gear: ${c.gearType}');
  print('Body Serial: ${c.bodySerialNum}');
  print('Color: ${c.color}');
  print('Length: ${c.length}, Width: ${c.width}');
  print('Chair Num: ${c.chairNum}');
  print('Leather: ${c.isFurnitureLeather}');
}

void printTruck(Truck t) {
  print('--- Truck ---');
  print('Company: ${t.manufactureCompany}');
  print('Date: ${t.manufactureDate}');
  print('Model: ${t.model}');
  print('Plate: ${t.plateNum}');
  print('Gear: ${t.gearType}');
  print('Body Serial: ${t.bodySerialNum}');
  print('Color: ${t.color}');
  print('Length: ${t.length}, Width: ${t.width}');
  print('Free Weight: ${t.freeWeight}');
  print('Full Weight: ${t.fullWeight}');
}

void printAll({
  required List<Motorcycle> motorcycles,
  required List<Car> cars,
  required List<Truck> trucks,
}) {
  print('===== ALL VEHICLES =====');
  for (final m in motorcycles) printMotorcycle(m);
  for (final c in cars) printCar(c);
  for (final t in trucks) printTruck(t);
}
