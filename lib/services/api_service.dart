import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ApiService {
  static const String _backendUrl = "https://gramingpt-backend-api.onrender.com";

  // --- Feature 1: Healthcare Directory ---
  static Future<List<dynamic>> findNearbyPlaces(String placeType) async {
    // 1. Get current location
    Position position = await _determinePosition();

    // 2. Call the /nearby-health-centers/ endpoint
    final response = await http.post(
      Uri.parse("$_backendUrl/nearby-health-centers/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "place_type": placeType, // "hospital", "pharmacy", etc.
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      return responseBody['places'];
    } else {
      throw Exception('Failed to load nearby places.');
    }
  }

  // --- Feature 2: Smarter AI Assistant ---
  static Future<String> getAiResponse(String userQuery) async {
    // 1. Get current location
    Position position = await _determinePosition();

    // 2. Call the /ask-rural-assistant/ endpoint with location
    final response = await http.post(
      Uri.parse("$_backendUrl/ask-rural-assistant/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "text": userQuery,
        "latitude": position.latitude,
        "longitude": position.longitude,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      return responseBody['answer'] ?? "No answer found.";
    } else {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception("Server error: ${errorBody['detail']}");
    }
  }

  // --- Helper function to get location using Geolocator ---
  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
