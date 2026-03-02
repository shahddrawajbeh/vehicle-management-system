import 'vehicle.dart';
import 'engine.dart';
import 'enums.dart';

class Truck extends Vehicle {
  double _freeWeight;
  double _fullWeight;

  Truck()
      : _freeWeight = 0.0,
        _fullWeight = 0.0,
        super();

  Truck.full(
    String manufactureCompany,
    DateTime manufactureDate,
    String model,
    Engine engine,
    int plateNum,
    GearType gearType,
    int bodySerialNum,
    int length,
    int width,
    String color,
    double freeWeight,
    double fullWeight,
  )   : _freeWeight = freeWeight,
        _fullWeight = fullWeight,
        super.full(
          manufactureCompany,
          manufactureDate,
          model,
          engine,
          plateNum,
          gearType,
          bodySerialNum,
          length,
          width,
          color,
        );

  double get freeWeight => _freeWeight;
  set freeWeight(double value) => _freeWeight = value;

  double get fullWeight => _fullWeight;
  set fullWeight(double value) => _fullWeight = value;

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'freeWeight': _freeWeight,
      'fullWeight': _fullWeight,
    });
    return base;
  }

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck.full(
      json['manufactureCompany'] ?? '',
      DateTime.parse(json['manufactureDate']),
      json['model'] ?? '',
      Engine.fromJson(Map<String, dynamic>.from(json['engine'])),
      (json['plateNum'] ?? 0) as int,
      gearTypeFromString(json['gearType']),
      (json['bodySerialNum'] ?? 0) as int,
      (json['length'] ?? 0) as int,
      (json['width'] ?? 0) as int,
      json['color'] ?? '',
      (json['freeWeight'] ?? 0.0).toDouble(),
      (json['fullWeight'] ?? 0.0).toDouble(),
    );
  }
}
