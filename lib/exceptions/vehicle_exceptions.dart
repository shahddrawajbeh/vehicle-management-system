abstract class VehicleException implements Exception {
  final String message;
  VehicleException(this.message);

  @override
  String toString() => message;
}

class NetworkUnavailableException extends VehicleException {
  NetworkUnavailableException()
      : super('Network is unavailable. Please check your internet connection.');
}

class ServerErrorException extends VehicleException {
  final int? statusCode;

  ServerErrorException({this.statusCode, String? message})
      : super(message ?? 'Server error occurred. Please try again later.');
}

class TimeoutException extends VehicleException {
  TimeoutException()
      : super('Request timed out. Please check your connection and try again.');
}

class UnknownException extends VehicleException {
  UnknownException(String message) : super('Error: $message');
}
