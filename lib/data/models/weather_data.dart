class WeatherData {
  final DateTime date;
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String conditionText;
  final String iconUrl;
  final double feelsLike;
  final double uvIndex;
  final double visibility;
  final double pressure;
  final int isDay;

  WeatherData({
    required this.date,
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.conditionText,
    required this.iconUrl,
    required this.feelsLike,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
    required this.isDay,
  });

  Map<String, double> get probabilities {
    return {
      'very_hot': _calculateHotProbability(),
      'very_cold': _calculateColdProbability(),
      'very_windy': _calculateWindyProbability(),
      'very_wet': _calculateWetProbability(),
      'very_uncomfortable': _calculateUncomfortableProbability(),
    };
  }

  double _calculateHotProbability() {
    if (temperature > 40) return 95.0;
    if (temperature > 35) return 80.0;
    if (temperature > 30) return 60.0;
    if (temperature > 25) return 30.0;
    return 10.0;
  }

  double _calculateColdProbability() {
    if (temperature < 0) return 95.0;
    if (temperature < 5) return 80.0;
    if (temperature < 10) return 50.0;
    if (temperature < 15) return 20.0;
    return 5.0;
  }

  double _calculateWindyProbability() {
    if (windSpeed > 30) return 90.0;
    if (windSpeed > 20) return 70.0;
    if (windSpeed > 15) return 50.0;
    if (windSpeed > 10) return 30.0;
    return 10.0;
  }

  double _calculateWetProbability() {
    if (condition.contains('rain') || condition.contains('drizzle')) return 85.0;
    if (humidity > 85) return 70.0;
    if (humidity > 70) return 40.0;
    return 15.0;
  }

  double _calculateUncomfortableProbability() {
    double score = 0.0;

    // Temperature discomfort
    if (temperature > 35 || temperature < 5) score += 40;
    else if (temperature > 30 || temperature < 10) score += 25;

    // Humidity discomfort
    if (humidity > 85) score += 30;
    else if (humidity > 70) score += 15;

    // Wind discomfort
    if (windSpeed > 25) score += 20;
    else if (windSpeed > 15) score += 10;

    // UV discomfort
    if (uvIndex > 8) score += 10;

    return score.clamp(0.0, 100.0);
  }
}