import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/climate_models.dart';
import '../services/api_service.dart';

class ClimateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Current data
  ClimateData? _currentData;
  double? _prediction;
  final List<ClimateData> _history = [];
  
  // Profiles
  List<ClimateProfile> _profiles = [];
  ClimateProfile? _activeProfile;
  
  // Status
  bool _isLoading = false;
  bool _serverOnline = false;
  String? _error;
  
  // Logs
  final List<EventLog> _logs = [];
  
  // Settings
  int _forecastMinutes = 5;
  bool _notificationsEnabled = true;
  bool _soundEnabled = false;
  
  // Auto-refresh timer
  Timer? _refreshTimer;
  
  // Getters
  ClimateData? get currentData => _currentData;
  double? get prediction => _prediction;
  List<ClimateData> get history => _history;
  List<ClimateProfile> get profiles => _profiles;
  ClimateProfile? get activeProfile => _activeProfile;
  bool get isLoading => _isLoading;
  bool get serverOnline => _serverOnline;
  String? get error => _error;
  List<EventLog> get logs => _logs;
  int get forecastMinutes => _forecastMinutes;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  
  ClimateProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _loadSettings();
    await loadProfiles();
    await refreshData();
    _startAutoRefresh();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _forecastMinutes = prefs.getInt('forecast_minutes') ?? 5;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? false;
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('forecast_minutes', _forecastMinutes);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
  }
  
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshData();
    });
  }
  
  Future<void> refreshData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.getCurrentData(
        forecastMin: _forecastMinutes,
      );
      
      _currentData = response.current;
      _prediction = response.prediction;
      _serverOnline = true;
      
      // Add to history
      _history.add(response.current);
      if (_history.length > 20) {
        _history.removeAt(0);
      }
      
      // Check for alerts
      _checkAlerts();
      
      _addLog('Data updated successfully', 'System');
    } catch (e) {
      _error = e.toString();
      _serverOnline = false;
      _addLog('Failed to fetch data: $e', 'Error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _checkAlerts() {
    if (_currentData == null || _activeProfile == null) return;
    if (!_notificationsEnabled) return;
    
    final alerts = <String>[];
    
    if (_currentData!.temp < _activeProfile!.tempMin ||
        _currentData!.temp > _activeProfile!.tempMax) {
      alerts.add(
        'Температура ${_currentData!.temp.toStringAsFixed(1)}°C вне диапазона '
        '${_activeProfile!.tempMin}-${_activeProfile!.tempMax}°C',
      );
    }
    
    if (_currentData!.humidity > _activeProfile!.humidityMax) {
      alerts.add(
        'Влажность ${_currentData!.humidity.toStringAsFixed(0)}% выше нормы '
        '(${_activeProfile!.humidityMax}%)',
      );
    }
    
    if (_currentData!.co2 > _activeProfile!.co2Max) {
      alerts.add(
        'CO₂ ${_currentData!.co2} ppm выше нормы '
        '(${_activeProfile!.co2Max} ppm)',
      );
    }
    
    if (alerts.isNotEmpty) {
      _addLog(alerts.join(' | '), 'Alert');
    }
  }
  
  Future<void> loadProfiles() async {
    try {
      _profiles = await _apiService.getProfiles();
      
      // Load active profile from preferences
      final prefs = await SharedPreferences.getInstance();
      final activeProfileName = prefs.getString('active_profile');
      
      if (activeProfileName != null) {
        _activeProfile = _profiles.firstWhere(
          (p) => p.name == activeProfileName,
          orElse: () => _profiles.first,
        );
      } else {
        _activeProfile = _profiles.first;
      }
      
      _addLog('Profiles loaded', 'System');
      notifyListeners();
    } catch (e) {
      _addLog('Failed to load profiles: $e', 'Error');
    }
  }
  
  Future<void> setActiveProfile(ClimateProfile profile) async {
    _activeProfile = profile;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_profile', profile.name);
    
    _addLog('Profile changed to: ${profile.name}', 'System');
    notifyListeners();
  }
  
  // add / update / delete profiles
  void addProfile(ClimateProfile profile) {
    _profiles.add(profile);
    _addLog('system', 'Profile created: ${profile.name}');
    notifyListeners();
  }

  void updateProfile(ClimateProfile profile) {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _profiles[index] = profile;
      _addLog('system', 'Profile updated: ${profile.name}');
      notifyListeners();
    }
  }

  void deleteProfile(ClimateProfile profile) {
    _profiles.removeWhere((p) => p.id == profile.id);
    if (_activeProfile?.id == profile.id) {
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    _addLog('system', 'Profile deleted: ${profile.name}');
    notifyListeners();
  }
  
  void setForecastMinutes(int minutes) {
    _forecastMinutes = minutes;
    _saveSettings();
    refreshData();
    notifyListeners();
  }
  
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }
  
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }
  
  void _addLog(String message, String type) {
    _logs.insert(
      0,
      EventLog(time: DateTime.now(), message: message, type: type),
    );
    if (_logs.length > 50) {
      _logs.removeLast();
    }
  }
  
  bool isDangerMode() {
    if (_currentData == null || _activeProfile == null) return false;
    return _currentData!.temp > _activeProfile!.tempMax;
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
