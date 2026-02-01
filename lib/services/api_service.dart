import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/climate_models.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // For testing with a real device, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.1.XXX:8000';

  // Get current climate data with prediction
  Future<ApiResponse> getCurrentData({int forecastMin = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/now?forecast_min=$forecastMin'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Get available profiles
  Future<List<ClimateProfile>> getProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profiles'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final presets = data['presets'] as List;
        return presets.map((p) => ClimateProfile.fromJson(p)).toList();
      } else {
        // Return default profiles if backend is unavailable
        return ClimateProfile.defaults;
      }
    } catch (e) {
      // Return default profiles on error
      return ClimateProfile.defaults;
    }
  }

  // Update active profile
  Future<Map<String, dynamic>> updateProfile(ClimateProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/profile/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      // Return local success if backend is unavailable
      return {
        'status': 'success',
        'message': 'Profile updated locally (backend unavailable)',
      };
    }
  }

  // Check server status
  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/now?forecast_min=5'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
