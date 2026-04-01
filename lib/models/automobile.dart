import 'engine.dart';
import 'enums.dart';

class Automobile {
  String _id;
  String _manufactureCompany;
  DateTime _manufactureDate;
  String _model;
  Engine _engine;
  int _plateNum;
  GearType _gearType;
  int _bodySerialNum;

  Automobile()
      : _id = '',
        _manufactureCompany = '',
        _manufactureDate = DateTime(2000, 1, 1),
        _model = '',
        _engine = Engine(),
        _plateNum = 0,
        _gearType = GearType.normal,
        _bodySerialNum = 0;

  Automobile.full(
    String manufactureCompany,
    DateTime manufactureDate,
    String model,
    Engine engine,
    int plateNum,
    GearType gearType,
    int bodySerialNum, [
    String id = '',
  ])  : _id = id,
        _manufactureCompany = manufactureCompany,
        _manufactureDate = manufactureDate,
        _model = model,
        _engine = engine,
        _plateNum = plateNum,
        _gearType = gearType,
        _bodySerialNum = bodySerialNum;

  String get id => _id;
  set id(String value) => _id = value;

  String get manufactureCompany => _manufactureCompany;
  set manufactureCompany(String value) => _manufactureCompany = value;

  DateTime get manufactureDate => _manufactureDate;
  set manufactureDate(DateTime value) => _manufactureDate = value;

  String get model => _model;
  set model(String value) => _model = value;

  Engine get engine => _engine;
  set engine(Engine value) => _engine = value;

  int get plateNum => _plateNum;
  set plateNum(int value) => _plateNum = value;

  GearType get gearType => _gearType;
  set gearType(GearType value) => _gearType = value;

  int get bodySerialNum => _bodySerialNum;
  set bodySerialNum(int value) => _bodySerialNum = value;

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'manufactureCompany': _manufactureCompany,
      'manufactureDate': _manufactureDate.toIso8601String(),
      'model': _model,
      'engine': _engine.toJson(),
      'plateNum': _plateNum,
      'gearType': _gearType.name,
      'bodySerialNum': _bodySerialNum,
    };
  }

  factory Automobile.fromJson(Map<String, dynamic> json) {
    return Automobile.full(
      json['manufactureCompany'] ?? '',
      DateTime.parse(json['manufactureDate']),
      json['model'] ?? '',
      Engine.fromJson(Map<String, dynamic>.from(json['engine'])),
      (json['plateNum'] ?? 0) as int,
      gearTypeFromString(json['gearType']),
      (json['bodySerialNum'] ?? 0) as int,
      json['id'] ?? '',
    );
  }
}
