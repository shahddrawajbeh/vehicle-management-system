import 'package:dio/dio.dart';
import 'dart:io';

import '../models/automobile.dart';
import '../models/car.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';
import '../exceptions/vehicle_exceptions.dart';

class VehicleApiService {
  final Dio dio;

  VehicleApiService({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://192.168.1.15:3000',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                },
              ),
            );

  Future<List<Automobile>> getVehicles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/vehicles',
        queryParameters: {
          '_page': page,
          '_per_page': limit,
        },
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => _vehicleFromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => _vehicleFromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception('Invalid API response format');
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<void> addVehicle(Automobile vehicle) async {
    try {
      await dio.post(
        '/vehicles',
        data: vehicle.toJson(),
      );
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<void> updateVehicle(Automobile vehicle) async {
    try {
      await dio.put(
        '/vehicles/${vehicle.id}',
        data: vehicle.toJson(),
      );
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await dio.delete('/vehicles/$id');
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    }
  }

  void _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw TimeoutException();
      case DioExceptionType.badResponse:
        throw ServerErrorException(
          statusCode: e.response?.statusCode,
          message: 'Server returned ${e.response?.statusCode}',
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          throw NetworkUnavailableException();
        }
        throw UnknownException(e.message ?? 'Unknown error occurred');
      case DioExceptionType.cancel:
        throw UnknownException('Request cancelled');
      case DioExceptionType.badCertificate:
        throw UnknownException('Bad certificate');
    }
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
