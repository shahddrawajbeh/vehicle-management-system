import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_event.dart';
import '../bloc/vehicle/vehicle_state.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../models/automobile.dart';
import '../models/car.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';
import '../services/print_utils.dart';
import 'vehicle_detail_page.dart';

enum SearchField { company, date, plate }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int tabIndex = 0;
  SearchField searchField = SearchField.company;
  final TextEditingController searchCtrl = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(StartPollingEvent());
    searchCtrl.addListener(() {
      final value = searchCtrl.text.trim();

      setState(() {
        searchText = value;
      });

      if (value.isEmpty) {
        context.read<SearchBloc>().add(ClearSearchEvent());
        return;
      }

      switch (searchField) {
        case SearchField.company:
          context.read<SearchBloc>().add(SearchByCompanyEvent(value));
          break;
        case SearchField.date:
          context.read<SearchBloc>().add(SearchByDateEvent(value));
          break;
        case SearchField.plate:
          context.read<SearchBloc>().add(SearchByPlateEvent(value));
          break;
      }
    });
  }

  @override
  void dispose() {
    context.read<VehicleBloc>().add(StopPollingEvent());
    searchCtrl.dispose();
    super.dispose();
  }

  List<dynamic> _filteredList({
    required List<Motorcycle> motorcycles,
    required List<Car> cars,
    required List<Truck> trucks,
  }) {
    bool matchCommon({
      required String company,
      required DateTime date,
      required int plate,
    }) {
      if (searchText.isEmpty) return true;

      switch (searchField) {
        case SearchField.company:
          return company.toLowerCase().contains(searchText.toLowerCase());
        case SearchField.plate:
          return plate.toString().contains(searchText);
        case SearchField.date:
          final d = date.toIso8601String().split('T').first;
          return d.contains(searchText.replaceAll('/', '-'));
      }
    }

    if (tabIndex == 0) {
      return motorcycles.where((m) {
        return matchCommon(
          company: m.manufactureCompany,
          date: m.manufactureDate,
          plate: m.plateNum,
        );
      }).toList();
    } else if (tabIndex == 1) {
      return cars.where((c) {
        return matchCommon(
          company: c.manufactureCompany,
          date: c.manufactureDate,
          plate: c.plateNum,
        );
      }).toList();
    } else {
      return trucks.where((t) {
        return matchCommon(
          company: t.manufactureCompany,
          date: t.manufactureDate,
          plate: t.plateNum,
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Dashboard'),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Extract vehicle lists from various states
            List<Motorcycle> motorcycles = _extractMotorcycles(state);
            List<Car> cars = _extractCars(state);
            List<Truck> trucks = _extractTrucks(state);

            // Check if offline
            final isOffline = state is VehicleLoadedOffline;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<VehicleBloc>().add(LoadVehiclesEvent());
                // Wait a bit for the bloc to emit new state
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: Column(
                children: [
                  // Summary Bar
                  _buildSummaryBar(motorcycles, cars, trucks, isOffline),

                  // Search Bar
                  _buildSearchBar(),

                  // Tab Bar
                  TabBar(
                    onTap: (i) {
                      setState(() {
                        tabIndex = i;
                      });
                    },
                    tabs: const [
                      Tab(text: 'Motorcycles'),
                      Tab(text: 'Cars'),
                      Tab(text: 'Trucks'),
                    ],
                  ),

                  // Vehicle List
                  Expanded(
                    child: _buildVehicleList(motorcycles, cars, trucks),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryBar(
    List<Motorcycle> motorcycles,
    List<Car> cars,
    List<Truck> trucks,
    bool isOffline,
  ) {
    final total = motorcycles.length + cars.length + trucks.length;
    final avgCapacity = total > 0
        ? ((motorcycles.fold<double>(0, (sum, m) => sum + m.engine.capacity) +
                    cars.fold<double>(0, (sum, c) => sum + c.engine.capacity) +
                    trucks.fold<double>(
                        0, (sum, t) => sum + t.engine.capacity)) /
                total)
            .toStringAsFixed(1)
        : '0';

    return Container(
      color: Colors.blueGrey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOffline)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Offline Mode - Showing cached data',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child:
                    _buildSummaryStat('Total', total.toString(), Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  '🏍️',
                  motorcycles.length.toString(),
                  Colors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  '🚗',
                  cars.length.toString(),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  '🚚',
                  trucks.length.toString(),
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  'Avg Cap',
                  avgCapacity,
                  Colors.deepPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Company / Date(yyyy-mm-dd) / Plate',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<SearchField>(
            value: searchField,
            items: const [
              DropdownMenuItem(
                value: SearchField.company,
                child: Text('Company'),
              ),
              DropdownMenuItem(
                value: SearchField.date,
                child: Text('Date'),
              ),
              DropdownMenuItem(
                value: SearchField.plate,
                child: Text('Plate'),
              ),
            ],
            onChanged: (v) {
              setState(() {
                searchField = v ?? searchField;
              });

              final value = searchCtrl.text.trim();

              if (value.isEmpty) {
                context.read<SearchBloc>().add(ClearSearchEvent());
                return;
              }

              switch (searchField) {
                case SearchField.company:
                  context.read<SearchBloc>().add(SearchByCompanyEvent(value));
                  break;
                case SearchField.date:
                  context.read<SearchBloc>().add(SearchByDateEvent(value));
                  break;
                case SearchField.plate:
                  context.read<SearchBloc>().add(SearchByPlateEvent(value));
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(
    List<Motorcycle> motorcycles,
    List<Car> cars,
    List<Truck> trucks,
  ) {
    final list = _filteredList(
      motorcycles: motorcycles,
      cars: cars,
      trucks: trucks,
    );

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No vehicles found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<VehicleBloc>().add(LoadVehiclesEvent());
              },
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _buildVehicleListTile(list[i] as Automobile),
    );
  }

  Widget _buildVehicleListTile(Automobile item) {
    String title = '';
    String sub = '';
    IconData icon = Icons.directions_car;

    if (item is Motorcycle) {
      title = '${item.manufactureCompany} - ${item.model}';
      sub = 'Plate: ${item.plateNum} | Tier: ${item.tierDiameter}';
      icon = Icons.two_wheeler;
    } else if (item is Car) {
      title = '${item.manufactureCompany} - ${item.model}';
      sub = 'Plate: ${item.plateNum} | Color: ${item.color}';
      icon = Icons.directions_car;
    } else if (item is Truck) {
      title = '${item.manufactureCompany} - ${item.model}';
      sub = 'Plate: ${item.plateNum} | Weight: ${item.fullWeight}kg';
      icon = Icons.local_shipping;
    }

    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailPage(vehicle: item),
          ),
        );
      },
      onLongPress: () {
        // Print vehicle details on long press
        if (item is Motorcycle) {
          printMotorcycle(item);
        } else if (item is Car) {
          printCar(item);
        } else if (item is Truck) {
          printTruck(item);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printed to console')),
        );
      },
    );
  }

  // Helper methods to extract vehicles from different states
  List<Motorcycle> _extractMotorcycles(VehicleState state) {
    if (state is VehicleLoaded) return state.motorcycles;
    if (state is VehicleLoadedOffline) return state.motorcycles;
    return [];
  }

  List<Car> _extractCars(VehicleState state) {
    if (state is VehicleLoaded) return state.cars;
    if (state is VehicleLoadedOffline) return state.cars;
    return [];
  }

  List<Truck> _extractTrucks(VehicleState state) {
    if (state is VehicleLoaded) return state.trucks;
    if (state is VehicleLoadedOffline) return state.trucks;
    return [];
  }
}
