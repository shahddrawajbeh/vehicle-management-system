import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/storage_service.dart';
import 'persistence_event.dart';
import 'persistence_state.dart';

class PersistenceBloc extends Bloc<PersistenceEvent, PersistenceState> {
  final StorageService storageService;

  PersistenceBloc({
    required this.storageService,
  }) : super(PersistenceIdle()) {
    on<PersistLoadEvent>(_onLoad);
    on<PersistSaveEvent>(_onSave);
  }

  Future<void> _onLoad(
    PersistLoadEvent event,
    Emitter<PersistenceState> emit,
  ) async {
    try {
      final data = await storageService.loadAll();
      emit(PersistenceLoaded(data));
    } catch (e) {
      emit(PersistenceError('Load failed: $e'));
    }
  }

  Future<void> _onSave(
    PersistSaveEvent event,
    Emitter<PersistenceState> emit,
  ) async {
    try {
      emit(PersistenceSaving());

      await storageService.saveAll(
        motorcycles: event.data['motorcycles'],
        cars: event.data['cars'],
        trucks: event.data['trucks'],
      );

      emit(PersistenceLoaded(event.data));
    } catch (e) {
      emit(PersistenceError('Save failed: $e'));
    }
  }
}
