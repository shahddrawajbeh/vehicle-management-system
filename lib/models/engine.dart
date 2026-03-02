import 'enums.dart';

class Engine {
  String _manufacture;
  DateTime _manufactureDate;
  String _model;
  int _capacity;
  int _cylinders;
  FuelType _fuelType;

  // Default constructor (zero-argument)
  Engine()
      : _manufacture = '',
        _manufactureDate = DateTime(2000, 1, 1),
        _model = '',
        _capacity = 0,
        _cylinders = 0,
        _fuelType = FuelType.gasoline;

  // Full constructor with all parameters
  Engine.full(
    String manufacture,
    DateTime manufactureDate,
    String model,
    int capacity,
    int cylinders,
    FuelType fuelType,
  )   : _manufacture = manufacture,
        _manufactureDate = manufactureDate,
        _model = model,
        _capacity = capacity,
        _cylinders = cylinders,
        _fuelType = fuelType;

  // Getters/Setters
  String get manufacture => _manufacture;
  set manufacture(String value) => _manufacture = value;

  DateTime get manufactureDate => _manufactureDate;
  set manufactureDate(DateTime value) => _manufactureDate = value;

  String get model => _model;
  set model(String value) => _model = value;

  int get capacity => _capacity;
  set capacity(int value) => _capacity = value;

  int get cylinders => _cylinders;
  set cylinders(int value) => _cylinders = value;

  FuelType get fuelType => _fuelType;
  set fuelType(FuelType value) => _fuelType = value;

  // JSON
  Map<String, dynamic> toJson() {
    return {
      'manufacture': _manufacture,
      'manufactureDate': _manufactureDate.toIso8601String(),
      'model': _model,
      'capacity': _capacity,
      'cylinders': _cylinders,
      'fuelType': _fuelType.name,
    };
  }

  factory Engine.fromJson(Map<String, dynamic> json) {
    return Engine.full(
      json['manufacture'] ?? '',
      DateTime.parse(json['manufactureDate']),
      json['model'] ?? '',
      (json['capacity'] ?? 0) as int,
      (json['cylinders'] ?? 0) as int,
      fuelTypeFromString(json['fuelType']),
    );
  }
}
