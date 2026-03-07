import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Models ───────────────────────────────────────────────────────────────────

class PlacePrediction {
  final String placeId;
  final String description;

  const PlacePrediction({required this.placeId, required this.description});

  @override
  String toString() => description;
}

class PlaceDetails {
  final String formattedAddress;
  final String? streetAddress; // street number + route
  final String? city;
  final String? province;
  final String? postalCode;
  final double latitude;
  final double longitude;

  const PlaceDetails({
    required this.formattedAddress,
    this.streetAddress,
    this.city,
    this.province,
    this.postalCode,
    required this.latitude,
    required this.longitude,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

class PlacesService {
  static const _apiKey = 'AIzaSyCL0HDEG3I5smjBavMG65Ct4Y8mYoxkFyA';
  static const _base = 'https://maps.googleapis.com/maps/api/place';

  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.length < 3) return const [];
    try {
      final uri = Uri.parse('$_base/autocomplete/json').replace(
        queryParameters: {
          'input': input,
          'key': _apiKey,
          'types': 'address',
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final predictions = data['predictions'] as List? ?? [];
      return predictions
          .map((p) => PlacePrediction(
                placeId: p['place_id'] as String,
                description: p['description'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<PlaceDetails?> getDetails(String placeId) async {
    try {
      final uri = Uri.parse('$_base/details/json').replace(
        queryParameters: {
          'place_id': placeId,
          'fields': 'formatted_address,address_components,geometry',
          'key': _apiKey,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) return null;

      final components = result['address_components'] as List? ?? [];

      String? getComponent(String type) {
        for (final c in components) {
          final types = (c['types'] as List).cast<String>();
          if (types.contains(type)) return c['long_name'] as String?;
        }
        return null;
      }

      final streetNumber = getComponent('street_number') ?? '';
      final route = getComponent('route') ?? '';
      final street =
          [streetNumber, route].where((s) => s.isNotEmpty).join(' ');

      final location =
          (result['geometry'] as Map?)?['location'] as Map<String, dynamic>?;

      return PlaceDetails(
        formattedAddress: result['formatted_address'] as String? ?? '',
        streetAddress: street.isEmpty ? null : street,
        city: getComponent('locality') ?? getComponent('sublocality_level_1'),
        province: getComponent('administrative_area_level_1'),
        postalCode: getComponent('postal_code'),
        latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
        longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
