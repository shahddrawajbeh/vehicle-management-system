import 'vehicle.dart';
import 'engine.dart';
import 'enums.dart';

class Car extends Vehicle {
  int _chairNum;
  bool _isFurnitureLeather;

  Car()
      : _chairNum = 0,
        _isFurnitureLeather = false,
        super();

  Car.full(
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
    int chairNum,
    bool isFurnitureLeather,
  )   : _chairNum = chairNum,
        _isFurnitureLeather = isFurnitureLeather,
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

  int get chairNum => _chairNum;
  set chairNum(int value) => _chairNum = value;

  bool get isFurnitureLeather => _isFurnitureLeather;
  set isFurnitureLeather(bool value) => _isFurnitureLeather = value;

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'chairNum': _chairNum,
      'isFurnitureLeather': _isFurnitureLeather,
    });
    return base;
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car.full(
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
      (json['chairNum'] ?? 0) as int,
      (json['isFurnitureLeather'] ?? false) as bool,
    );
  }
}
