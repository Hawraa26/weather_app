
class DailyForecast {
  final String date;
  final int weatherCode;
  final double dayHigh;
  final double nightHigh;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.dayHigh,
    required this.nightHigh,
  });
}

class Weather {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int weatherCode;

  final List<double> hourlyTemperatures;
  final List<int> hourlyWeatherCodes;
  final List<String> hourlyTimes;
  final List<int> hourlyIsDay;

  final List<DailyForecast> dailyForecasts;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.hourlyTemperatures,
    required this.hourlyTimes,
    required this.hourlyWeatherCodes,
    required this.hourlyIsDay,
    required this.dailyForecasts,
  });

  // حساب أعلى درجة حرارة نهاراً وليلاً لكل يوم
  static List<DailyForecast> calculateDailyForecasts({
    required List<String> times,
    required List<double> temperatures,
    required List<int> isDay,
    required List<int> weatherCodes,
  }) {
    final Map<String, List<int>> groupedHours = {};

    for (int i = 0; i < times.length; i++) {
      final date = times[i].split('T')[0];

      groupedHours.putIfAbsent(date, () => []);
      groupedHours[date]!.add(i);
    }

    final List<DailyForecast> forecasts = [];

    for (final date in groupedHours.keys) {
      final indexes = groupedHours[date]!;

      double? dayHigh;
      double? nightHigh;
      int dailyWeatherCode = 0;

      for (final index in indexes) {
        final temperature = temperatures[index];

        if (isDay[index] == 1) {
          if (dayHigh == null || temperature > dayHigh) {
            dayHigh = temperature;
            dailyWeatherCode = weatherCodes[index];
          }
        } else {
          if (nightHigh == null || temperature > nightHigh) {
            nightHigh = temperature;
          }
        }
      }

      forecasts.add(
        DailyForecast(
          date: date,
          weatherCode: dailyWeatherCode,
          dayHigh: dayHigh ?? 0,
          nightHigh: nightHigh ?? 0,
        ),
      );
    }

    return forecasts;
  }

  factory Weather.fromJson(Map<String, dynamic> data) {
    final current = data['current'];
    final hourly = data['hourly'];

    final hourlyTemperatures =
    (hourly['temperature_2m'] as List)
        .map((value) => (value as num).toDouble())
        .toList();

    final hourlyWeatherCodes =
    (hourly['weather_code'] as List)
        .map((value) => (value as num).toInt())
        .toList();

    final hourlyTimes =
    (hourly['time'] as List)
        .map((value) => value.toString())
        .toList();

    final hourlyIsDay =
    (hourly['is_day'] as List)
        .map((value) => (value as num).toInt())
        .toList();

    final dailyForecasts = calculateDailyForecasts(
      times: hourlyTimes,
      temperatures: hourlyTemperatures,
      isDay: hourlyIsDay,
      weatherCodes: hourlyWeatherCodes,
    );

    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      hourlyTemperatures: hourlyTemperatures,
      hourlyWeatherCodes: hourlyWeatherCodes,
      hourlyTimes: hourlyTimes,
      hourlyIsDay: hourlyIsDay,
      dailyForecasts: dailyForecasts,
    );
  }
}

