import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/climate_provider.dart';
import '../models/climate_models.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _tempMinController;
  late TextEditingController _tempMaxController;
  late TextEditingController _humidityMaxController;
  late TextEditingController _co2MaxController;

  ClimateProfile? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _tempMinController = TextEditingController();
    _tempMaxController = TextEditingController();
    _humidityMaxController = TextEditingController();
    _co2MaxController = TextEditingController();

    // Load active profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ClimateProvider>();
      if (provider.activeProfile != null) {
        _loadProfile(provider.activeProfile!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _humidityMaxController.dispose();
    _co2MaxController.dispose();
    super.dispose();
  }

  void _loadProfile(ClimateProfile profile) {
    setState(() {
      _selectedPreset = profile;
      _nameController.text = profile.name;
      _tempMinController.text = profile.tempMin.toString();
      _tempMaxController.text = profile.tempMax.toString();
      _humidityMaxController.text = profile.humidityMax.toString();
      _co2MaxController.text = profile.co2Max.toString();
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = ClimateProfile(
      name: _nameController.text,
      tempMin: double.parse(_tempMinController.text),
      tempMax: double.parse(_tempMaxController.text),
      humidityMax: double.parse(_humidityMaxController.text),
      co2Max: int.parse(_co2MaxController.text),
    );

    try {
      await context.read<ClimateProvider>().updateProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно сохранён'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ПРОФИЛИ',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Настройка параметров микроклимата',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Consumer<ClimateProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выбрать готовый профиль',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ClimateProfile>(
                  initialValue: _selectedPreset,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: provider.profiles.map((profile) {
                    return DropdownMenuItem(
                      value: profile,
                      child: Text(profile.name),
                    );
                  }).toList(),
                  onChanged: (profile) {
                    if (profile != null) {
                      _loadProfile(profile);
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  'Название профиля',
                  _nameController,
                  validator: (v) => v!.isEmpty ? 'Введите название' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Мин. Темп. (°C)',
                        _tempMinController,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Макс. Темп. (°C)',
                        _tempMaxController,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Макс. Влажность (%)',
                        _humidityMaxController,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Макс. CO₂ (ppm)',
                        _co2MaxController,
                        isNumber: true,
                        isInt: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Сохранить и применить',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isInt = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator ??
              (v) {
                if (v == null || v.isEmpty) return 'Обязательно';
                if (isNumber) {
                  if (isInt) {
                    if (int.tryParse(v) == null) return 'Неверный формат';
                  } else {
                    if (double.tryParse(v) == null) return 'Неверный формат';
                  }
                }
                return null;
              },
        ),
      ],
    );
  }
}
