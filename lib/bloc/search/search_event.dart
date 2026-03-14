abstract class SearchEvent {}

class SearchByCompanyEvent extends SearchEvent {
  final String query;
  SearchByCompanyEvent(this.query);
}

class SearchByDateEvent extends SearchEvent {
  final String query;
  SearchByDateEvent(this.query);
}

class SearchByPlateEvent extends SearchEvent {
  final String query;
  SearchByPlateEvent(this.query);
}

class ClearSearchEvent extends SearchEvent {}
