import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/car.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';

class StorageService {
  Future<Directory> _dir() async => await getApplicationDocumentsDirectory();

  Future<File> _file(String name) async {
    final d = await _dir();
    return File('${d.path}/$name');
  }

  Future<void> saveAll({
    required List<Motorcycle> motorcycles,
    required List<Car> cars,
    required List<Truck> trucks,
  }) async {
    await _saveList(
        'motorcycles.json', motorcycles.map((m) => m.toJson()).toList());
    await _saveList('cars.json', cars.map((c) => c.toJson()).toList());
    await _saveList('trucks.json', trucks.map((t) => t.toJson()).toList());
  }

  Future<Map<String, dynamic>> loadAll() async {
    final motorcycles = await _loadList('motorcycles.json');
    final cars = await _loadList('cars.json');
    final trucks = await _loadList('trucks.json');

    return {
      'motorcycles': motorcycles.map((e) => Motorcycle.fromJson(e)).toList(),
      'cars': cars.map((e) => Car.fromJson(e)).toList(),
      'trucks': trucks.map((e) => Truck.fromJson(e)).toList(),
    };
  }

  Future<void> _saveList(
      String fileName, List<Map<String, dynamic>> data) async {
    final f = await _file(fileName);
    final jsonStr = jsonEncode(data);
    await f.writeAsString(jsonStr, flush: true);
  }

  Future<List<Map<String, dynamic>>> _loadList(String fileName) async {
    final f = await _file(fileName);
    if (!await f.exists()) return [];

    final content = await f.readAsString();
    if (content.trim().isEmpty) return [];

    final decoded = jsonDecode(content);
    if (decoded is! List) return [];

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
