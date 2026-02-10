import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/climate_provider.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              _buildLanguageSettings(context),
              const SizedBox(height: 24),
              _buildNotificationSettings(context),
              const SizedBox(height: 24),
              _buildAboutSection(context),
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
          'settings'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'settings_desc'.tr(),
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLanguageSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.language_rounded, 'language'.tr()),
          const SizedBox(height: 20),
          const LanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Consumer<ClimateProvider>(
      builder: (context, provider, _) {
        if (provider.notificationsEnabled == null || provider.soundEnabled == null) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(Icons.notifications_rounded, 'notifications'.tr()),
              const SizedBox(height: 8),
              Text(
                'notifications_desc'.tr(),
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'enable_notifications'.tr(),
                'show_warnings'.tr(),
                Icons.notifications_active_rounded,
                provider.notificationsEnabled!,
                (value) => provider.setNotificationsEnabled(value),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'sound_alert'.tr(),
                'play_sound'.tr(),
                Icons.volume_up_rounded,
                provider.soundEnabled!,
                (value) => provider.setSoundEnabled(value),
              ),
              const SizedBox(height: 20),
              _buildInfoBanner(),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        secondary: Icon(icon, color: value ? const Color(0xFF4F46E5) : Colors.grey),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4F46E5),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'check_every_5sec'.tr(),
              style: TextStyle(fontSize: 11, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildSectionTitle(Icons.info_rounded, 'about_app'.tr()),
          const SizedBox(height: 20),
          _buildInfoRow('app_name'.tr(), 'MicroClimate AI Pro'),
          _buildInfoRow('version'.tr(), '1.0.0'),
          const SizedBox(height: 20),
          _buildConnectionInfo(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildConnectionInfo(BuildContext context) {
    final provider = Provider.of<ClimateProvider>(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: provider.serverOnline ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: provider.serverOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            provider.serverOnline ? 'server_online'.tr() : 'server_offline'.tr(),
          ),
        ],
      ),
    );
  }
}