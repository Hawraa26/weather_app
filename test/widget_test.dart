
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/screens/weather_screen.dart';
import 'package:weather_app/services/weather_service.dart';

class FakeWeatherService extends WeatherService {
  @override
  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    return {
      'current': {
        'temperature_2m': 15.0,
        'relative_humidity_2m': 60,
        'apparent_temperature': 14.0,
        'is_day': 1,
        'precipitation': 0.0,
        'weather_code': 1,
        'wind_speed_10m': 10.0,
      },
      'hourly': {
        'time': ['2026-10-28T14:00'],
        'temperature_2m': [15.0],
        'weather_code': [1],
      },
    };
  }
}

void main() {
  testWidgets('Weather app starts successfully', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MyApp(
        weatherService: FakeWeatherService(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
  });
}
