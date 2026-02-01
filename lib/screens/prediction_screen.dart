import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/climate_provider.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

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
              _buildPredictionCard(context),
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
          'ИИ ПРОГНОЗ',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Интеллектуальный анализ микроклимата',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionCard(BuildContext context) {
    return Consumer<ClimateProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF312E81),
                Color(0xFF1E293B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF312E81).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ПРОГНОЗ',
                    style: TextStyle(
                      color: Colors.indigo[200],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  _buildForecastButtons(context, provider),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Ожидаемая температура:',
                style: TextStyle(
                  color: Colors.indigo[200],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              if (provider.prediction != null)
                Text(
                  '${provider.prediction!.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                )
              else
                const Text(
                  '--.-°C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.indigo[300],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ИИ анализирует тренды на основе последних ${provider.history.length} измерений...',
                        style: TextStyle(
                          color: Colors.indigo[300],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildPredictionDetails(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastButtons(BuildContext context, ClimateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildForecastButton('5M', 5, provider),
          const SizedBox(width: 4),
          _buildForecastButton('1H', 60, provider),
          const SizedBox(width: 4),
          _buildForecastButton('24H', 1440, provider),
        ],
      ),
    );
  }

  Widget _buildForecastButton(
    String label,
    int minutes,
    ClimateProvider provider,
  ) {
    final isActive = provider.forecastMinutes == minutes;

    return GestureDetector(
      onTap: () => provider.setForecastMinutes(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionDetails(BuildContext context, ClimateProvider provider) {
    if (provider.currentData == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildDetailRow(
          'Текущая',
          '${provider.currentData!.temp.toStringAsFixed(1)}°C',
          Colors.white70,
        ),
        const SizedBox(height: 12),
        if (provider.prediction != null)
          _buildDetailRow(
            'Изменение',
            _getPredictionChange(provider),
            _getPredictionChangeColor(provider),
          ),
        const SizedBox(height: 12),
        _buildDetailRow(
          'Точность модели',
          'R² > 0.85',
          Colors.green[300]!,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getPredictionChange(ClimateProvider provider) {
    if (provider.prediction == null || provider.currentData == null) {
      return '—';
    }
    final change = provider.prediction! - provider.currentData!.temp;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}°C';
  }

  Color _getPredictionChangeColor(ClimateProvider provider) {
    if (provider.prediction == null || provider.currentData == null) {
      return Colors.white70;
    }
    final change = provider.prediction! - provider.currentData!.temp;
    if (change > 0.5) return Colors.red[300]!;
    if (change < -0.5) return Colors.blue[300]!;
    return Colors.green[300]!;
  }
}
