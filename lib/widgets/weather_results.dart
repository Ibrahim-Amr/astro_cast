
import 'package:flutter/material.dart';
import '../data/models/weather_data.dart';
import 'weather_card.dart';

class WeatherResultsGrid extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherResultsGrid({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conditions = {
      'very_hot': {'label': 'حار جداً', 'icon': Icons.wb_sunny, 'color': Colors.orange},
      'very_cold': {'label': 'بارد جداً', 'icon': Icons.ac_unit, 'color': Colors.blue},
      'very_windy': {'label': 'عاصف جداً', 'icon': Icons.air, 'color': Colors.green},
      'very_wet': {'label': 'ممطر جداً', 'icon': Icons.beach_access, 'color': Colors.blueAccent},
      'very_uncomfortable': {'label': 'غير مريح', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.red},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'احتمالات الطقس لـ ${weatherData.location}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'في ${weatherData.date.day}/${weatherData.date.month}/${weatherData.date.year}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        const SizedBox(height: 20),

        // شبكة متجاوبة مع عدد الأعمدة بناء على حجم الشاشة
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: conditions.entries.map((entry) {
                final condition = entry.key;
                final data = entry.value;
                return WeatherCard(
                  title: data['label'] as String,
                  probability: weatherData.probabilities[condition] ?? 0.0,
                  color: data['color'] as Color,
                  icon: data['icon'] as IconData,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}