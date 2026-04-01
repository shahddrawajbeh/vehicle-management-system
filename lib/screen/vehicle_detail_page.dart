import 'package:flutter/material.dart';
import '../models/automobile.dart';
import '../models/car.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';

class VehicleDetailPage extends StatelessWidget {
  final Automobile vehicle;

  const VehicleDetailPage({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.manufactureCompany} - ${vehicle.model}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildEngineCard(),
            const SizedBox(height: 16),
            _buildSpecificCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('ID', vehicle.id),
            _buildDetailRow('Type', _getVehicleType()),
            _buildDetailRow('Manufacturer', vehicle.manufactureCompany),
            _buildDetailRow('Model', vehicle.model),
            _buildDetailRow('Manufacture Date',
                vehicle.manufactureDate.toIso8601String().split('T').first),
            _buildDetailRow('Plate Number', vehicle.plateNum.toString()),
            _buildDetailRow(
                'Body Serial Number', vehicle.bodySerialNum.toString()),
            _buildDetailRow('Gear Type', vehicle.gearType.name),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineCard() {
    final engine = vehicle.engine;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engine Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Manufacture', engine.manufacture),
            _buildDetailRow('Model', engine.model),
            _buildDetailRow('Capacity', engine.capacity.toString()),
            _buildDetailRow('Cylinders', engine.cylinders.toString()),
            _buildDetailRow('Fuel Type', engine.fuelType.name),
            _buildDetailRow('Manufacture Date',
                engine.manufactureDate.toIso8601String().split('T').first),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificCard() {
    if (vehicle is Car) {
      return _buildCarCard(vehicle as Car);
    } else if (vehicle is Motorcycle) {
      return _buildMotorcycleCard(vehicle as Motorcycle);
    } else if (vehicle is Truck) {
      return _buildTruckCard(vehicle as Truck);
    }
    return const SizedBox();
  }

  Widget _buildCarCard(Car car) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Car Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Length', car.length.toString()),
            _buildDetailRow('Width', car.width.toString()),
            _buildDetailRow('Color', car.color),
            _buildDetailRow('Chair Number', car.chairNum.toString()),
            _buildDetailRow(
              'Leather Furniture',
              car.isFurnitureLeather ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorcycleCard(Motorcycle motorcycle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motorcycle Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Tier Diameter', motorcycle.tierDiameter.toString()),
            _buildDetailRow('Length', motorcycle.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildTruckCard(Truck truck) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Truck Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Length', truck.length.toString()),
            _buildDetailRow('Width', truck.width.toString()),
            _buildDetailRow('Color', truck.color),
            _buildDetailRow('Free Weight', '${truck.freeWeight} kg'),
            _buildDetailRow('Full Weight', '${truck.fullWeight} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getVehicleType() {
    if (vehicle is Car) return 'Car';
    if (vehicle is Motorcycle) return 'Motorcycle';
    if (vehicle is Truck) return 'Truck';
    return 'Unknown';
  }
}
