import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/search_service.dart';
import '../../repository/vehicle_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final VehicleRepository repository;
  final SearchService searchService;

  SearchBloc({
    required this.repository,
    required this.searchService,
  }) : super(SearchInitial()) {
    on<SearchByCompanyEvent>(_onSearchByCompany);
    on<SearchByDateEvent>(_onSearchByDate);
    on<SearchByPlateEvent>(_onSearchByPlate);
    on<ClearSearchEvent>(_onClearSearch);
  }

  void _onSearchByCompany(
    SearchByCompanyEvent event,
    Emitter<SearchState> emit,
  ) {
    final results =
        searchService.searchByCompany(repository.getAllVehicles(), event.query);

    emit(results.isEmpty ? SearchEmpty() : SearchResults(results));
  }

  void _onSearchByDate(
    SearchByDateEvent event,
    Emitter<SearchState> emit,
  ) {
    final results =
        searchService.searchByDate(repository.getAllVehicles(), event.query);

    emit(results.isEmpty ? SearchEmpty() : SearchResults(results));
  }

  void _onSearchByPlate(
    SearchByPlateEvent event,
    Emitter<SearchState> emit,
  ) {
    final results =
        searchService.searchByPlate(repository.getAllVehicles(), event.query);

    emit(results.isEmpty ? SearchEmpty() : SearchResults(results));
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
