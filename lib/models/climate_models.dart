class ClimateData {
  final double temp;
  final double humidity;
  final int co2;
  final int mcScore;
  final DateTime timestamp;

  ClimateData({
    required this.temp,
    required this.humidity,
    required this.co2,
    required this.mcScore,
    required this.timestamp,
  });

  factory ClimateData.fromJson(Map<String, dynamic> json) {
    return ClimateData(
      temp: (json['temp'] as num).toDouble(),
      humidity: (json['hum'] as num).toDouble(),
      co2: json['co2'] as int,
      mcScore: json['mc_score'] as int? ?? 98,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'hum': humidity,
      'co2': co2,
      'mc_score': mcScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ClimateProfile {
  final String name;
  final double tempMin;
  final double tempMax;
  final double humidityMax;
  final int co2Max;

  ClimateProfile({
    required this.name,
    required this.tempMin,
    required this.tempMax,
    required this.humidityMax,
    required this.co2Max,
  });

  factory ClimateProfile.fromJson(Map<String, dynamic> json) {
    return ClimateProfile(
      name: json['name'] as String,
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
      humidityMax: (json['humidity_max'] as num).toDouble(),
      co2Max: json['co2_max'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'humidity_max': humidityMax,
      'co2_max': co2Max,
    };
  }

  // Default profiles
  static List<ClimateProfile> get defaults => [
        ClimateProfile(
          name: '💊 Аптека',
          tempMin: 20,
          tempMax: 24,
          humidityMax: 60,
          co2Max: 800,
        ),
        ClimateProfile(
          name: '🧪 Лаборатория',
          tempMin: 19,
          tempMax: 23,
          humidityMax: 55,
          co2Max: 700,
        ),
        ClimateProfile(
          name: '🏠 Дом',
          tempMin: 20,
          tempMax: 26,
          humidityMax: 65,
          co2Max: 1000,
        ),
        ClimateProfile(
          name: '❄️ Холодная комната',
          tempMin: 4,
          tempMax: 8,
          humidityMax: 80,
          co2Max: 800,
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
