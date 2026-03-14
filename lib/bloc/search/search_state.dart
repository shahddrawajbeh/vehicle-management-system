import '../../models/automobile.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchResults extends SearchState {
  final List<Automobile> results;
  SearchResults(this.results);
}

class SearchEmpty extends SearchState {}
