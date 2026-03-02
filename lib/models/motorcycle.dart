import 'automobile.dart';
import 'engine.dart';
import 'enums.dart';

class Motorcycle extends Automobile {
  double _tierDiameter;
  double _length;

  // Default constructor
  Motorcycle()
      : _tierDiameter = 0.0,
        _length = 0.0,
        super();

  // Full constructor (including parent class parameters)
  Motorcycle.full(
    String manufactureCompany,
    DateTime manufactureDate,
    String model,
    Engine engine,
    int plateNum,
    GearType gearType,
    int bodySerialNum,
    double tierDiameter,
    double length,
  )   : _tierDiameter = tierDiameter,
        _length = length,
        super.full(
          manufactureCompany,
          manufactureDate,
          model,
          engine,
          plateNum,
          gearType,
          bodySerialNum,
        );

  // Getters/Setters
  double get tierDiameter => _tierDiameter;
  set tierDiameter(double value) => _tierDiameter = value;

  double get length => _length;
  set length(double value) => _length = value;

  // JSON
  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'tierDiameter': _tierDiameter,
      'length': _length,
    });
    return base;
  }

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    return Motorcycle.full(
      json['manufactureCompany'] ?? '',
      DateTime.parse(json['manufactureDate']),
      json['model'] ?? '',
      Engine.fromJson(Map<String, dynamic>.from(json['engine'])),
      (json['plateNum'] ?? 0) as int,
      gearTypeFromString(json['gearType']),
      (json['bodySerialNum'] ?? 0) as int,
      (json['tierDiameter'] ?? 0.0).toDouble(),
      (json['length'] ?? 0.0).toDouble(),
    );
  }
}
