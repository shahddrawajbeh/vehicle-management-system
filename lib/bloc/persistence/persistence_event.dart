abstract class PersistenceEvent {}

class PersistLoadEvent extends PersistenceEvent {}

class PersistSaveEvent extends PersistenceEvent {
  final Map<String, dynamic> data;
  PersistSaveEvent(this.data);
}
