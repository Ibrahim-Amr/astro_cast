import 'package:flutter/material.dart';
import '../data/models/weather_data.dart';

class CurrentWeather extends StatelessWidget {
  final WeatherData weatherData;
  final String dateType; // 'current', 'historical', or 'forecast'

  const CurrentWeather({
    Key? key,
    required this.weatherData,
    required this.dateType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.1),
              const Color(0xFFFF6584).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weatherData.location,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDateInfo(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDateTypeColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getDateTypeColor().withOpacity(0.5)),
                      ),
                      child: Text(
                        _getDateTypeText(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getDateTypeColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: weatherData.isDay == 1
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    weatherData.isDay == 1 ? Icons.wb_sunny : Icons.nightlight_round,
                    color: weatherData.isDay == 1 ? Colors.orange : Colors.blue,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main weather info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Temperature
                Column(
                  children: [
                    Text(
                      '${weatherData.temperature.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Feels like ${weatherData.feelsLike.toStringAsFixed(1)}°',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                // Weather icon and condition
                Column(
                  children: [
                    Image.network(
                      weatherData.iconUrl,
                      width:64,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.cloud,
                          size: 64,
                          color: const Color(0xFF6C63FF),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weatherData.conditionText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Weather details grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: [
                _buildDetailItem('💧', 'Humidity', '${weatherData.humidity.toInt()}%'),
                _buildDetailItem('💨', 'Wind', '${weatherData.windSpeed.toStringAsFixed(1)} km/h'),
                _buildDetailItem('👁️', 'Visibility', '${weatherData.visibility.toStringAsFixed(1)} km'),
                _buildDetailItem('🌡️', 'Pressure', '${weatherData.pressure.toStringAsFixed(0)} hPa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDateInfo() {
    final date = weatherData.date;
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    switch (dateType) {
      case 'historical':
        return 'Historical data for $formattedDate';
      case 'forecast':
        return 'Forecast for $formattedDate';
      default:
        return 'Current conditions • Updated: ${_formatTime(date)}';
    }
  }

  String _getDateTypeText() {
    switch (dateType) {
      case 'historical':
        return 'HISTORICAL DATA';
      case 'forecast':
        return 'WEATHER FORECAST';
      default:
        return 'LIVE DATA';
    }
  }

  Color _getDateTypeColor() {
    switch (dateType) {
      case 'historical':
        return Colors.blue;
      case 'forecast':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailItem(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}