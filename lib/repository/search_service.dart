import '../models/automobile.dart';

class SearchService {
  List<Automobile> searchByCompany(
    List<Automobile> vehicles,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    return vehicles
        .where((v) => v.manufactureCompany.toLowerCase().contains(q))
        .toList();
  }

  List<Automobile> searchByPlate(
    List<Automobile> vehicles,
    String query,
  ) {
    final q = query.trim();
    return vehicles.where((v) => v.plateNum.toString().contains(q)).toList();
  }

  List<Automobile> searchByDate(
    List<Automobile> vehicles,
    String query,
  ) {
    final q = query.trim().replaceAll('/', '-');
    return vehicles.where((v) {
      final d = v.manufactureDate.toIso8601String().split('T').first;
      return d.contains(q);
    }).toList();
  }
}
