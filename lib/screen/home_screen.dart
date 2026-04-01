import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_event.dart';
import '../bloc/vehicle/vehicle_state.dart';
import '../models/automobile.dart';
import '../models/car.dart';
import '../models/engine.dart';
import '../models/enums.dart';
import '../models/motorcycle.dart';
import '../models/truck.dart';
import '../services/print_utils.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
//import '../bloc/search/search_state.dart';

enum SearchField { company, date, plate }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _addItem() async {
    if (tabIndex == 0) {
      final m = await _motorcycleDialog();
      if (m == null) return;

      context.read<VehicleBloc>().add(AddVehicleEvent(m));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    } else if (tabIndex == 1) {
      final c = await _carDialog();
      if (c == null) return;

      context.read<VehicleBloc>().add(AddVehicleEvent(c));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    } else {
      final t = await _truckDialog();
      if (t == null) return;

      context.read<VehicleBloc>().add(AddVehicleEvent(t));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    }
  }

  Future<void> _insertAt(int index) async {
    if (index < 0) return;

    if (tabIndex == 0) {
      final m = await _motorcycleDialog();
      if (m == null) return;

      context.read<VehicleBloc>().add(InsertVehicleAtEvent(index, m));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    } else if (tabIndex == 1) {
      final c = await _carDialog();
      if (c == null) return;

      context.read<VehicleBloc>().add(InsertVehicleAtEvent(index, c));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    } else {
      final t = await _truckDialog();
      if (t == null) return;

      context.read<VehicleBloc>().add(InsertVehicleAtEvent(index, t));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    }
  }

  Future<void> _editItem(Automobile item) async {
    if (item is Motorcycle) {
      final edited = await _motorcycleDialog(existing: item);
      if (edited == null) return;

      edited.id = item.id;
      context.read<VehicleBloc>().add(UpdateVehicleEvent(edited));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    } else if (item is Car) {
      final edited = await _carDialog(existing: item);
      if (edited == null) return;

      edited.id = item.id;
      context.read<VehicleBloc>().add(UpdateVehicleEvent(edited));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    } else if (item is Truck) {
      final edited = await _truckDialog(existing: item);
      if (edited == null) return;

      edited.id = item.id;
      context.read<VehicleBloc>().add(UpdateVehicleEvent(edited));
      context.read<VehicleBloc>().add(SaveVehiclesEvent());
    }
  }

  Future<void> _deleteItem(Automobile item) async {
    VehicleType type;

    if (item is Motorcycle) {
      type = VehicleType.motorcycle;
    } else if (item is Car) {
      type = VehicleType.car;
    } else {
      type = VehicleType.truck;
    }

    context.read<VehicleBloc>().add(DeleteVehicleEvent(item.id, type));
    context.read<VehicleBloc>().add(SaveVehiclesEvent());
  }

  Future<void> _showInsertDialog() async {
    final ctrl = TextEditingController();

    final idx = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Insert at position'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter index (0,1,2...)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.pop(context, v);
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );

    if (idx == null) return;
    await _insertAt(idx);
  }

  Engine _defaultEngine() {
    return Engine.full(
      'DefaultCo',
      DateTime(2020, 1, 1),
      'E-Model',
      1600,
      4,
      FuelType.gasoline,
    );
  }

  Widget _buildListTile(int i, List<dynamic> list) {
    final item = list[i] as Automobile;

    String title = '';
    String sub = '';

    if (item is Motorcycle) {
      title = '${item.manufactureCompany} - ${item.model}';
      sub = 'Plate: ${item.plateNum} | Body: ${item.bodySerialNum}';
    } else if (item is Car) {
      title = '${item.manufactureCompany} - ${item.model}';
      sub =
          'Plate: ${item.plateNum} | Color: ${item.color} | Body: ${item.bodySerialNum}';
    } else if (item is Truck) {
      title = '${item.manufactureCompany} - ${item.model}';
      sub =
          'Plate: ${item.plateNum} | FullW: ${item.fullWeight} | Body: ${item.bodySerialNum}';
    }

    return ListTile(
      title: Text(title),
      subtitle: Text(sub),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editItem(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(item),
          ),
        ],
      ),
      onTap: () {
        if (item is Motorcycle) {
          printMotorcycle(item);
        } else if (item is Car) {
          printCar(item);
        } else if (item is Truck) {
          printTruck(item);
        }
      },
    );
  }

  Future<Motorcycle?> _motorcycleDialog({Motorcycle? existing}) async {
    final company =
        TextEditingController(text: existing?.manufactureCompany ?? '');
    final model = TextEditingController(text: existing?.model ?? '');
    final plate =
        TextEditingController(text: (existing?.plateNum ?? 0).toString());
    final body =
        TextEditingController(text: (existing?.bodySerialNum ?? 0).toString());
    final tier =
        TextEditingController(text: (existing?.tierDiameter ?? 0.0).toString());
    final len =
        TextEditingController(text: (existing?.length ?? 0.0).toString());

    GearType gear = existing?.gearType ?? GearType.normal;
    DateTime date = existing?.manufactureDate ?? DateTime.now();

    return showDialog<Motorcycle>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Motorcycle' : 'Edit Motorcycle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: company,
                decoration: const InputDecoration(
                  labelText: 'Manufacture Company',
                ),
              ),
              TextField(
                controller: model,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: plate,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: body,
                decoration: const InputDecoration(
                  labelText: 'Body Serial Number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GearType>(
                value: gear,
                items: GearType.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => gear = v ?? gear,
                decoration: const InputDecoration(labelText: 'Gear Type'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${date.toIso8601String().split('T').first}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1990),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) {
                        date = picked;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: const Text('Pick'),
                  ),
                ],
              ),
              TextField(
                controller: tier,
                decoration: const InputDecoration(labelText: 'Tier Diameter'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: len,
                decoration: const InputDecoration(labelText: 'Length'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 6),
              const Text(
                'Engine will be set to a default object (you can expand later).',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final m = Motorcycle.full(
                company.text.trim(),
                date,
                model.text.trim(),
                existing?.engine ?? _defaultEngine(),
                int.tryParse(plate.text.trim()) ?? 0,
                gear,
                int.tryParse(body.text.trim()) ?? 0,
                double.tryParse(tier.text.trim()) ?? 0.0,
                double.tryParse(len.text.trim()) ?? 0.0,
              );

              if (existing != null) {
                m.id = existing.id;
              }

              Navigator.pop(context, m);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<Car?> _carDialog({Car? existing}) async {
    final company =
        TextEditingController(text: existing?.manufactureCompany ?? '');
    final model = TextEditingController(text: existing?.model ?? '');
    final plate =
        TextEditingController(text: (existing?.plateNum ?? 0).toString());
    final body =
        TextEditingController(text: (existing?.bodySerialNum ?? 0).toString());

    final vLen =
        TextEditingController(text: (existing?.length ?? 0).toString());
    final vWid = TextEditingController(text: (existing?.width ?? 0).toString());
    final color = TextEditingController(text: existing?.color ?? '');

    final chairs =
        TextEditingController(text: (existing?.chairNum ?? 0).toString());
    bool leather = existing?.isFurnitureLeather ?? false;

    GearType gear = existing?.gearType ?? GearType.normal;
    DateTime date = existing?.manufactureDate ?? DateTime.now();

    return showDialog<Car>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Car' : 'Edit Car'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: company,
                decoration: const InputDecoration(
                  labelText: 'Manufacture Company',
                ),
              ),
              TextField(
                controller: model,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: plate,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: body,
                decoration: const InputDecoration(
                  labelText: 'Body Serial Number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GearType>(
                value: gear,
                items: GearType.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => gear = v ?? gear,
                decoration: const InputDecoration(labelText: 'Gear Type'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${date.toIso8601String().split('T').first}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1990),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) {
                        date = picked;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: const Text('Pick'),
                  ),
                ],
              ),
              TextField(
                controller: vLen,
                decoration: const InputDecoration(labelText: 'Vehicle Length'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: vWid,
                decoration: const InputDecoration(labelText: 'Vehicle Width'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: color,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: chairs,
                decoration: const InputDecoration(labelText: 'Chair Number'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                value: leather,
                onChanged: (v) {
                  leather = v;
                },
                title: const Text('Furniture Leather?'),
              ),
              const Text(
                'Engine will be set to a default object (you can expand later).',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final c = Car.full(
                company.text.trim(),
                date,
                model.text.trim(),
                existing?.engine ?? _defaultEngine(),
                int.tryParse(plate.text.trim()) ?? 0,
                gear,
                int.tryParse(body.text.trim()) ?? 0,
                int.tryParse(vLen.text.trim()) ?? 0,
                int.tryParse(vWid.text.trim()) ?? 0,
                color.text.trim(),
                int.tryParse(chairs.text.trim()) ?? 0,
                leather,
              );

              if (existing != null) {
                c.id = existing.id;
              }

              Navigator.pop(context, c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<Truck?> _truckDialog({Truck? existing}) async {
    final company =
        TextEditingController(text: existing?.manufactureCompany ?? '');
    final model = TextEditingController(text: existing?.model ?? '');
    final plate =
        TextEditingController(text: (existing?.plateNum ?? 0).toString());
    final body =
        TextEditingController(text: (existing?.bodySerialNum ?? 0).toString());

    final vLen =
        TextEditingController(text: (existing?.length ?? 0).toString());
    final vWid = TextEditingController(text: (existing?.width ?? 0).toString());
    final color = TextEditingController(text: existing?.color ?? '');

    final freeW =
        TextEditingController(text: (existing?.freeWeight ?? 0.0).toString());
    final fullW =
        TextEditingController(text: (existing?.fullWeight ?? 0.0).toString());

    GearType gear = existing?.gearType ?? GearType.normal;
    DateTime date = existing?.manufactureDate ?? DateTime.now();

    return showDialog<Truck>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Truck' : 'Edit Truck'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: company,
                decoration: const InputDecoration(
                  labelText: 'Manufacture Company',
                ),
              ),
              TextField(
                controller: model,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: plate,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: body,
                decoration: const InputDecoration(
                  labelText: 'Body Serial Number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GearType>(
                value: gear,
                items: GearType.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => gear = v ?? gear,
                decoration: const InputDecoration(labelText: 'Gear Type'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${date.toIso8601String().split('T').first}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1990),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) {
                        date = picked;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: const Text('Pick'),
                  ),
                ],
              ),
              TextField(
                controller: vLen,
                decoration: const InputDecoration(labelText: 'Vehicle Length'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: vWid,
                decoration: const InputDecoration(labelText: 'Vehicle Width'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: color,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: freeW,
                decoration: const InputDecoration(labelText: 'Free Weight'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fullW,
                decoration: const InputDecoration(labelText: 'Full Weight'),
                keyboardType: TextInputType.number,
              ),
              const Text(
                'Engine will be set to a default object (you can expand later).',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = Truck.full(
                company.text.trim(),
                date,
                model.text.trim(),
                existing?.engine ?? _defaultEngine(),
                int.tryParse(plate.text.trim()) ?? 0,
                gear,
                int.tryParse(body.text.trim()) ?? 0,
                int.tryParse(vLen.text.trim()) ?? 0,
                int.tryParse(vWid.text.trim()) ?? 0,
                color.text.trim(),
                double.tryParse(freeW.text.trim()) ?? 0.0,
                double.tryParse(fullW.text.trim()) ?? 0.0,
              );

              if (existing != null) {
                t.id = existing.id;
              }

              Navigator.pop(context, t);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Management System'),
          bottom: TabBar(
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
          actions: [
            BlocBuilder<VehicleBloc, VehicleState>(
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Print All (console)',
                  onPressed: state is VehicleLoaded
                      ? () {
                          printAll(
                            motorcycles: state.motorcycles,
                            cars: state.cars,
                            trucks: state.trucks,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printed to console'),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.print),
                );
              },
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'add',
              onPressed: _addItem,
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'insert',
              onPressed: _showInsertDialog,
              child: const Icon(Icons.playlist_add),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
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
                          context
                              .read<SearchBloc>()
                              .add(SearchByCompanyEvent(value));
                          break;
                        case SearchField.date:
                          context
                              .read<SearchBloc>()
                              .add(SearchByDateEvent(value));
                          break;
                        case SearchField.plate:
                          context
                              .read<SearchBloc>()
                              .add(SearchByPlateEvent(value));
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<VehicleBloc, VehicleState>(
                builder: (context, state) {
                  if (state is VehicleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NetworkUnavailableState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Network Unavailable',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(state.message),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<VehicleBloc>()
                                  .add(LoadVehiclesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TimeoutState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.hourglass_empty,
                              size: 64, color: Colors.amber),
                          const SizedBox(height: 16),
                          const Text(
                            'Request Timed Out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(state.message),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<VehicleBloc>()
                                  .add(LoadVehiclesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ServerErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Server Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(state.message),
                          if (state.statusCode != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Status Code: ${state.statusCode}'),
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<VehicleBloc>()
                                  .add(LoadVehiclesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UnknownErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning,
                              size: 64, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(state.message,
                                textAlign: TextAlign.center),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<VehicleBloc>()
                                  .add(LoadVehiclesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is VehicleLoadedOffline) {
                    final list = _filteredList(
                      motorcycles: state.motorcycles,
                      cars: state.cars,
                      trucks: state.trucks,
                    );

                    return Stack(
                      children: [
                        if (list.isEmpty)
                          const Center(child: Text('No items'))
                        else
                          ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) => _buildListTile(i, list),
                          ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.orange[100],
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.cloud_off,
                                    color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Offline Mode - Showing cached data',
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is VehicleLoaded) {
                    final list = _filteredList(
                      motorcycles: state.motorcycles,
                      cars: state.cars,
                      trucks: state.trucks,
                    );

                    if (list.isEmpty) {
                      return const Center(child: Text('No items'));
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _buildListTile(i, list),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
