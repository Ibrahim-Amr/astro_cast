import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/weather_data.dart';

class WeatherApiService {
  static const String _apiKey = '251239fb602f4517952133655250210';
  static const String _baseUrl = 'http://api.weatherapi.com/v1';

  static Future<WeatherData> getCurrentWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseWeatherData(data);
      } else if (response.statusCode == 400) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<WeatherData> getHistoricalWeather(String city, DateTime date) async {
    try {
      // Format date as YYYY-MM-DD for the API
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('$_baseUrl/history.json?key=$_apiKey&q=$city&dt=$formattedDate'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseHistoricalWeatherData(data, date);
      } else if (response.statusCode == 400) {
        throw Exception('City not found or historical data not available');
      } else {
        throw Exception('Failed to load historical weather data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<WeatherData> getForecastWeather(String city, DateTime date) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=14&aqi=no&alerts=no'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseForecastWeatherData(data, date);
      } else if (response.statusCode == 400) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static WeatherData _parseWeatherData(Map<String, dynamic> data) {
    final location = data['location'];
    final current = data['current'];

    return WeatherData(
      date: DateTime.parse(current['last_updated']),
      location: '${location['name']}, ${location['country']}',
      temperature: current['temp_c'].toDouble(),
      humidity: current['humidity'].toDouble(),
      windSpeed: current['wind_kph'].toDouble(),
      condition: current['condition']['code'].toString(),
      conditionText: current['condition']['text'],
      iconUrl: 'https:${current['condition']['icon']}',
      feelsLike: current['feelslike_c'].toDouble(),
      uvIndex: current['uv'].toDouble(),
      visibility: current['vis_km'].toDouble(),
      pressure: current['pressure_mb'].toDouble(),
      isDay: current['is_day'],
    );
  }

  static WeatherData _parseHistoricalWeatherData(Map<String, dynamic> data, DateTime selectedDate) {
    final location = data['location'];
    final forecast = data['forecast'];

    if (forecast['forecastday'] == null || forecast['forecastday'].isEmpty) {
      throw Exception('No historical data available for this date');
    }

    final forecastday = forecast['forecastday'][0];
    final dayData = forecastday['day'];

    // Get hour data for noon (12:00) or use the first available hour
    final hourData = forecastday['hour'].isNotEmpty
        ? forecastday['hour'][forecastday['hour'].length ~/ 2] // Middle hour of the day
        : null;

    return WeatherData(
      date: selectedDate,
      location: '${location['name']}, ${location['country']}',
      temperature: hourData != null ? hourData['temp_c'].toDouble() : dayData['avgtemp_c'].toDouble(),
      humidity: dayData['avghumidity'].toDouble(),
      windSpeed: dayData['maxwind_kph'].toDouble(),
      condition: dayData['condition']['code'].toString(),
      conditionText: dayData['condition']['text'],
      iconUrl: 'https:${dayData['condition']['icon']}',
      feelsLike: hourData != null ? hourData['feelslike_c'].toDouble() : dayData['avgtemp_c'].toDouble(),
      uvIndex: dayData['uv'].toDouble(),
      visibility: hourData != null ? hourData['vis_km'].toDouble() : 10.0,
      pressure: hourData != null ? hourData['pressure_mb'].toDouble() : 1013.0,
      isDay: hourData != null ? hourData['is_day'] : 1,
    );
  }

  static WeatherData _parseForecastWeatherData(Map<String, dynamic> data, DateTime selectedDate) {
    final location = data['location'];
    final forecast = data['forecast'];
    final selectedDateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    // Find the forecast for the selected date
    final forecastDay = forecast['forecastday'].firstWhere(
            (day) => day['date'] == selectedDateStr,
        orElse: () => throw Exception('No forecast available for selected date')
    );

    final dayData = forecastDay['day'];
    final hourData = forecastDay['hour'][12]; // Use noon data

    return WeatherData(
      date: selectedDate,
      location: '${location['name']}, ${location['country']}',
      temperature: dayData['avgtemp_c'].toDouble(),
      humidity: dayData['avghumidity'].toDouble(),
      windSpeed: dayData['maxwind_kph'].toDouble(),
      condition: dayData['condition']['code'].toString(),
      conditionText: dayData['condition']['text'],
      iconUrl: 'https:${dayData['condition']['icon']}',
      feelsLike: dayData['avgtemp_c'].toDouble(),
      uvIndex: dayData['uv'].toDouble(),
      visibility: 10.0,
      pressure: 1013.0,
      isDay: 1,
    );
  }

  // Helper method to decide which API to call based on date
  static Future<WeatherData> getWeatherByDate(String city, DateTime date) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      // Use current weather API for today
      return await getCurrentWeather(city);
    } else if (selected.isBefore(today)) {
      // Use historical API for past dates (limited to 7 days in past for free tier)
      final daysDifference = today.difference(selected).inDays;
      if (daysDifference <= 7) {
        return await getHistoricalWeather(city, date);
      } else {
        throw Exception('Historical data only available for the past 7 days');
      }
    } else {
      // Use forecast API for future dates (limited to 14 days for free tier)
      final daysDifference = selected.difference(today).inDays;
      if (daysDifference <= 14) {
        return await getForecastWeather(city, date);
      } else {
        throw Exception('Forecast only available for the next 14 days');
      }
    }
  }
}