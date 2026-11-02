
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/services/weather_service.dart';

void main() {
  test('Search cities using Geocoding API', () async {
    final service = WeatherService();

    final cities = await service.searchCities('Damascus');

    expect(cities, isNotEmpty);

    print('Search results:');

    for (final city in cities) {
      print(
        'City: ${city['name']}, '
            'Country: ${city['country']}, '
            'Latitude: ${city['latitude']}, '
            'Longitude: ${city['longitude']}',
      );
    }
  });
}
