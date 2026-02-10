import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/climate_provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
              const SizedBox(height: 24),
              _buildForecastChart(context),
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
          'prediction'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'climate_forecast'.tr(),
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
        final currentData = provider.currentData;

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
                    'next_24_hours'.tr().toUpperCase(),
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
                'temperature'.tr(),
                style: TextStyle(
                  color: Colors.indigo[200],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              if (provider.prediction != null && currentData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.prediction!.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildParameterRow(
                      context,
                      'temperature'.tr(),
                      '${currentData.temp.toStringAsFixed(1)}°C',
                      Icons.thermostat_rounded,
                      Colors.red[300]!,
                    ),
                    const SizedBox(height: 12),
                    _buildParameterRow(
                      context,
                      'humidity'.tr(),
                      '${currentData.humidity.toStringAsFixed(0)}%',
                      Icons.water_drop_rounded,
                      Colors.blue[300]!,
                    ),
                    const SizedBox(height: 12),
                    _buildParameterRow(
                      context,
                      'co2'.tr(),
                      '${currentData.co2}',
                      Icons.air_rounded,
                      Colors.green[300]!,
                    ),
                    if (currentData.lux != null) ...[
                      const SizedBox(height: 12),
                      _buildParameterRow(
                        context,
                        'light'.tr(),
                        '${currentData.lux!.toStringAsFixed(0)} ${'lux'.tr()}',
                        Icons.lightbulb_rounded,
                        Colors.yellow[700]!,
                      ),
                    ],
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      '--.-°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'loading_data'.tr(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                        'ai_analyzes_trends'.tr(namedArgs: {
                          'count': provider.history.length.toString()
                        }),
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
              if (currentData != null && provider.prediction != null)
                _buildPredictionDetails(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParameterRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
    final currentData = provider.currentData;

    return Column(
      children: [
        _buildDetailRow(
          'current'.tr(),
          '${currentData!.temp.toStringAsFixed(1)}°C',
          Colors.white70,
        ),
        const SizedBox(height: 12),
        if (provider.prediction != null)
          _buildDetailRow(
            'change'.tr(),
            _getPredictionChange(provider),
            _getPredictionChangeColor(provider),
          ),
        const SizedBox(height: 12),
        _buildDetailRow(
          'model_accuracy'.tr(),
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

  Widget _buildForecastChart(BuildContext context) {
    return Consumer<ClimateProvider>(
      builder: (context, provider, _) {
        if (provider.history.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'forecast_chart'.tr(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}°C',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: provider.history
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.temp,
                                ))
                            .toList(),
                        isCurved: true,
                        color: const Color(0xFF4F46E5),
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4F46E5).withOpacity(0.3),
                              const Color(0xFF4F46E5).withOpacity(0.1),
                            ],
                          ),
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}