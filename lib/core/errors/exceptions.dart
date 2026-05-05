class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Sin conexión a internet']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Recurso no encontrado']);
}

class UploadException implements Exception {
  final String message;
  const UploadException([this.message = 'Error al subir imagen']);
}

class LocationException implements Exception {
  final String message;
  const LocationException([this.message = 'No se pudo obtener la ubicación']);
}
