import 'automobile.dart';
import 'engine.dart';
import 'enums.dart';

class Vehicle extends Automobile {
  int _length;
  int _width;
  String _color;

  Vehicle()
      : _length = 0,
        _width = 0,
        _color = '',
        super();

  Vehicle.full(
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
  )   : _length = length,
        _width = width,
        _color = color,
        super.full(
          manufactureCompany,
          manufactureDate,
          model,
          engine,
          plateNum,
          gearType,
          bodySerialNum,
        );

  int get length => _length;
  set length(int value) => _length = value;

  int get width => _width;
  set width(int value) => _width = value;

  String get color => _color;
  set color(String value) => _color = value;

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'length': _length,
      'width': _width,
      'color': _color,
    });
    return base;
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle.full(
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
    );
  }
}
