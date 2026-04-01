import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/automobile.dart';
import '../models/car.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';

class CacheService {
  static const String _vehiclesCacheKey = 'vehicles_cache';

  Future<void> cacheVehicles(List<Automobile> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(vehicles.map((v) => v.toJson()).toList());
    await prefs.setString(_vehiclesCacheKey, json);
  }

  Future<List<Automobile>> getCachedVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_vehiclesCacheKey);

    if (json == null) {
      return [];
    }

    try {
      final data = jsonDecode(json) as List;
      return data
          .map((e) => _vehicleFromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehiclesCacheKey);
  }

  Automobile _vehicleFromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'car':
        return Car.fromJson(json);
      case 'truck':
        return Truck.fromJson(json);
      case 'motorcycle':
        return Motorcycle.fromJson(json);
      default:
        throw Exception('Unknown vehicle type: ${json['type']}');
    }
  }
}
