
import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Map<String, dynamic>>> searchCities(String name) async {
    final response = await _dio.get(
      'https://geocoding-api.open-meteo.com/v1/search',
      queryParameters: {
        'name': name,
        'count': 10,
        'language': 'en',
        'format': 'json',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'];

    if (results == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(results);
  }


  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    const url = 'https://api.open-meteo.com/v1/forecast';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
          'hourly': 'temperature_2m,weather_code,is_day',
          'forecast_days': 7,
          'timezone': 'auto',
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException {
      rethrow;
    }
  }

}

