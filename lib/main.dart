import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/persistence/persistence_bloc.dart';
import 'bloc/search/search_bloc.dart';
import 'bloc/vehicle/vehicle_bloc.dart';
import 'bloc/vehicle/vehicle_event.dart';
import 'repository/search_service.dart';
import 'repository/storage_service.dart';
import 'repository/vehicle_repository.dart';
import 'screen/dashboard_page.dart';
import 'services/vehicle_api_service.dart';
import 'services/cache_service.dart';
import 'screen/home_screen.dart';

void main() {
  final storageService = StorageService();
  final vehicleRepository = VehicleRepository();
  final searchService = SearchService();
  final apiService = VehicleApiService();
  final cacheService = CacheService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => VehicleBloc(
            repository: vehicleRepository,
            apiService: apiService,
            cacheService: cacheService,
          )..add(LoadVehiclesEvent()),
        ),
        BlocProvider(
          create: (_) => SearchBloc(
            repository: vehicleRepository,
            searchService: searchService,
          ),
        ),
        BlocProvider(
          create: (_) => PersistenceBloc(
            storageService: storageService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Management',
      theme: ThemeData(useMaterial3: true),

      home: const DashboardPage(),
      //home: const HomeScreen(),
    );
  }
}
