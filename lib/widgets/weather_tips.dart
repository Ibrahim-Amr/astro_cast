import 'package:flutter/material.dart';
import '../data/models/weather_data.dart';


class WeatherTips extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherTips({Key? key, required this.weatherData}) : super(key: key);

  // Enhanced tips data with more detailed information
  static final Map<String, Map<String, dynamic>> _tipsData = {
    'very_hot': {
      'title': '🌡️ Extreme Heat Safety Guide',
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFF6584),
      'riskLevel': 'High Risk',
      'tips': [
        '💧 Hydrate frequently with water and electrolyte drinks',
        '⛱️ Seek shade between 11 AM - 3 PM when UV is strongest',
        '👕 Wear light-colored, loose-fitting cotton clothing',
        '🧴 Apply SPF 50+ sunscreen every 2 hours',
        '🌳 Take cooling breaks in air-conditioned spaces',
        '🏃 Avoid intense outdoor activities during peak heat',
        '🚗 Never leave children or pets in vehicles',
        '🔍 Watch for signs of heat exhaustion'
      ],
      'recommendedActivities': [
        'Swimming in pools or beaches',
        'Indoor museum visits',
        'Early morning or evening walks',
        'Air-conditioned shopping malls'
      ],
    },
    'very_cold': {
      'title': '❄️ Extreme Cold Safety Guide',
      'icon': Icons.ac_unit,
      'color': Color(0xFF6C63FF),
      'riskLevel': 'High Risk',
      'tips': [
        '🧥 Dress in layers: base, insulation, and waterproof outer',
        '🧤 Protect extremities with gloves, hat, and warm socks',
        '⏱️ Limit outdoor exposure to 15-20 minutes at a time',
        '🏠 Maintain indoor temperature at 18-20°C',
        '🚗 Check antifreeze levels and keep emergency kit in car',
        '🧊 Watch for black ice on roads and pathways',
        '🔋 Keep electronic devices fully charged',
        '🏥 Know signs of frostbite and hypothermia'
      ],
      'recommendedActivities': [
        'Indoor sports activities',
        'Visiting heated pools',
        'Winter photography with proper gear',
        'Ice skating in indoor rinks'
      ],
    },
    'very_windy': {
      'title': '💨 High Wind Safety Guide',
      'icon': Icons.air,
      'color': Color(0xFF00BFA6),
      'riskLevel': 'Moderate Risk',
      'tips': [
        '🪑 Secure outdoor furniture and loose objects',
        '🌳 Avoid parking under trees or near buildings',
        '🚗 Drive cautiously, especially on bridges and open roads',
        '👓 Wear protective eyewear against dust and debris',
        '🌊 Avoid water activities on lakes and oceans',
        '🔌 Have backup power sources ready',
        '📱 Keep communication devices charged',
        '🚧 Be aware of potential road closures'
      ],
      'recommendedActivities': [
        'Indoor rock climbing',
        'Visiting wind-protected areas',
        'Kite flying in open fields',
        'Photography of dramatic skies'
      ],
    },
    'very_wet': {
      'title': '🌧️ Heavy Rain Safety Guide',
      'icon': Icons.beach_access,
      'color': Color(0xFF2196F3),
      'riskLevel': 'Moderate Risk',
      'tips': [
        '☔ Carry waterproof gear: umbrella, raincoat, boots',
        '🚗 Increase following distance and reduce speed',
        '🏞️ Avoid low-lying areas prone to flooding',
        '⚡ Stay away from electrical equipment outdoors',
        '🏠 Check home for leaks and proper drainage',
        '📞 Keep emergency numbers handy',
        '🌊 Never attempt to cross flooded roads',
        '🔦 Have emergency lighting available'
      ],
      'recommendedActivities': [
        'Indoor cinema or theater',
        'Museum and gallery visits',
        'Coffee shop reading',
        'Cooking or baking indoors'
      ],
    },
    'very_uncomfortable': {
      'title': '😣 Uncomfortable Weather Guide',
      'icon': Icons.sentiment_dissatisfied,
      'color': Color(0xFFFF9800),
      'riskLevel': 'Variable Risk',
      'tips': [
        '📱 Check real-time weather updates frequently',
        '🎒 Pack versatile clothing options',
        '💊 Carry necessary medications and first aid',
        '🔋 Keep power banks and emergency supplies ready',
        '🏠 Have indoor backup plans prepared',
        '👥 Travel with companions when possible',
        '⏰ Allow extra time for travel and activities',
        '🌡️ Monitor personal comfort levels regularly'
      ],
      'recommendedActivities': [
        'Flexible indoor-outdoor activities',
        'Short-duration outdoor trips',
        'Weather-adaptive sports',
        'Local exploration with easy retreat options'
      ],
    },
  };

  String get dominantCondition {
    final probabilities = weatherData.probabilities;
    String dominant = 'very_uncomfortable';
    double maxProb = 0.0;

    probabilities.forEach((condition, prob) {
      if (prob > maxProb) {
        maxProb = prob;
        dominant = condition;
      }
    });

    return dominant;
  }

  String _getTemperatureWarning() {
    if (weatherData.temperature > 35) {
      return '🚨 HEAT ALERT: Extreme temperatures (${weatherData.temperature}°C) - High risk of heat-related illnesses';
    } else if (weatherData.temperature < 5) {
      return '⚠️ COLD ALERT: Freezing conditions (${weatherData.temperature}°C) - Risk of hypothermia';
    } else if (weatherData.temperature > 30) {
      return '🌡️ WARM ALERT: High temperatures (${weatherData.temperature}°C) - Stay hydrated';
    } else {
      return '✅ Temperature: ${weatherData.temperature}°C - Within comfortable range';
    }
  }

  String _getHumidityWarning() {
    if (weatherData.humidity > 80) {
      return '💧 High humidity may feel uncomfortable';
    } else if (weatherData.humidity < 30) {
      return '🏜️ Low humidity - Stay hydrated';
    } else {
      return '💧 Humidity levels are comfortable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dominant = dominantCondition;
    final tipData = _tipsData[dominant] ?? _tipsData['very_uncomfortable']!;
    final probability = weatherData.probabilities[dominant] ?? 0;
    final Color tipColor = tipData['color'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tipColor.withOpacity(0.1),
            tipColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tipColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with condition and probability
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tipColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(tipData['icon'] as IconData, size: 28, color: tipColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipData['title'] as String,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: tipColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tipData['riskLevel'] as String} • ${probability.toInt()}% Probability',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Weather warnings
          _buildInfoCard(
            context,
            'Temperature Status',
            _getTemperatureWarning(),
            Icons.thermostat,
            Colors.orange,
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            context,
            'Humidity Status',
            _getHumidityWarning(),
            Icons.water_drop,
            Colors.blue,
          ),

          const SizedBox(height: 20),

          // Safety tips section
          Text(
            '🛡️ Safety Recommendations:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...List.generate((tipData['tips'] as List<String>).length, (index) {
            final tipsList = tipData['tips'] as List<String>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: tipColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: tipColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tipsList[index],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Recommended activities
          if (tipData['recommendedActivities'] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Recommended Activities:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: List.generate(
                    (tipData['recommendedActivities'] as List<String>).length,
                        (index) {
                      final activities = tipData['recommendedActivities'] as List<String>;
                      return Chip(
                        label: Text(
                          activities[index],
                          style: TextStyle(
                            color: tipColor,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: tipColor.withOpacity(0.1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Emergency contact reminder
          _buildWarningCard(
            context,
            '🚑 In case of emergency, contact local authorities immediately. Keep emergency numbers saved.',
            Colors.red,
            Icons.emergency,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String message, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, String message, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}