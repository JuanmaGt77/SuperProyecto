import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../errors/exceptions.dart';

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);

  double distanceTo(LatLng other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  double distanceKmTo(LatLng other) => distanceTo(other) / 1000;

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<LatLng> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Los servicios de ubicación están desactivados',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'El permiso de ubicación está permanentemente denegado',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  Stream<LatLng> locationStream({
    int distanceFilter = 50,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isEmpty) return 'Dirección desconocida';
      final place = placemarks.first;
      final parts = [
        if (place.street != null && place.street!.isNotEmpty) place.street,
        if (place.locality != null && place.locality!.isNotEmpty) place.locality,
        if (place.administrativeArea != null) place.administrativeArea,
      ].where((p) => p != null).join(', ');
      return parts.isEmpty ? 'Dirección desconocida' : parts;
    } catch (_) {
      return 'Dirección desconocida';
    }
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (_) {
      return null;
    }
  }
}
