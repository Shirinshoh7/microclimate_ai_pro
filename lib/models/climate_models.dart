import 'package:flutter/material.dart';

class ClimateData {
  final double temp;
  final double humidity;
  final double lux;
  final int co2;
  final int mcScore;
  final DateTime timestamp;

  ClimateData({
    required this.temp,
    required this.humidity,
    required this.lux,
    required this.co2,
    required this.mcScore,
    required this.timestamp,
  });

  factory ClimateData.fromJson(Map<String, dynamic> json) {
    return ClimateData(
      temp: (json['temp'] as num).toDouble(),
      humidity: (json['hum'] as num).toDouble(),
      lux: (json['lux'] as num).toDouble(),
      co2: json['co2'] as int,
      mcScore: json['mc_score'] as int? ?? 98,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'hum': humidity,
      "lux": lux,
      'co2': co2,
      'mc_score': mcScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ClimateProfile {
  final String id;
  final String name;
  final String? description;
  final double tempMin;
  final double tempMax;
  final double humidityMin;
  final double humidityMax;
  final int co2Max;
  final double luxMax;
  final DateTime createdAt;

  ClimateProfile({
    String? id,
    required this.name,
    this.description,
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.co2Max,
    required this.luxMax,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  factory ClimateProfile.fromJson(Map<String, dynamic> json) {
    return ClimateProfile(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'],
      tempMin: (json['tempMin'] ?? 20.0).toDouble(),
      tempMax: (json['tempMax'] ?? 25.0).toDouble(),
      humidityMin: (json['humidityMin'] ?? 40.0).toDouble(),
      humidityMax: (json['humidityMax'] ?? 60.0).toDouble(),
      co2Max: (json['co2Max'] ?? 1000),
      luxMax: (json['luxMax'] ?? 500.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tempMin': tempMin,
        'tempMax': tempMax,
        'humidityMin': humidityMin,
        'humidityMax': humidityMax,
        'co2Max': co2Max,
        'luxMax': luxMax,
        'createdAt': createdAt.toIso8601String(),
      };

  // Default profiles
  static List<ClimateProfile> get defaults => [
        ClimateProfile(
          id: '1',
          name: '💊 Аптека',
          tempMin: 20,
          tempMax: 24,
          humidityMin: 30,
          humidityMax: 60,
          co2Max: 800,
          luxMax: 300,
        ),
        ClimateProfile(
          id: '2',
          name: '🧪 Лаборатория',
          tempMin: 19,
          tempMax: 23,
          humidityMin: 35,
          humidityMax: 55,
          co2Max: 700,
          luxMax: 500,
        ),
        ClimateProfile(
          id: '3',
          name: '🏠 Дом',
          tempMin: 20,
          tempMax: 26,
          humidityMin: 40,
          humidityMax: 65,
          co2Max: 1000,
          luxMax: 400,
        ),
        ClimateProfile(
          id: '4',
          name: '❄️ Холодная комната',
          tempMin: 4,
          tempMax: 8,
          humidityMin: 50,
          humidityMax: 80,
          co2Max: 800,
          luxMax: 200,
        ),
      ];
}

class ApiResponse {
  final ClimateData current;
  final double prediction;
  final String? error;

  ApiResponse({
    required this.current,
    required this.prediction,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] == 'no_data') {
      throw Exception('No data available');
    }

    return ApiResponse(
      current: ClimateData.fromJson(json['current']),
      prediction: (json['prediction'] as num).toDouble(),
      error: json['error'] as String?,
    );
  }
}

class EventLog {
  final DateTime time;
  final String message;
  final String type;

  EventLog({
    required this.time,
    required this.message,
    required this.type,
  });

  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
