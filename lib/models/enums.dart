enum FuelType { diesel, gasoline }

enum GearType { normal, automatic }

FuelType fuelTypeFromString(String value) =>
    FuelType.values.firstWhere((e) => e.name == value);

GearType gearTypeFromString(String value) =>
    GearType.values.firstWhere((e) => e.name == value);
