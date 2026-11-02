
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'city_search_screen.dart';
import '../services/weather_service.dart';
import '../models/weather_helpers.dart';
import '../models/weather.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.weatherService,
  });

  final String title;
  final WeatherService? weatherService;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WeatherService _weatherService;

  Weather? weather;
  bool isLoading = true;

  double selectedLatitude = 52.3676;
  double selectedLongitude = 4.9041;

  String selectedCity = 'Amsterdam';

  List<Map<String, dynamic>> cityResults = [];
  List<double?> hourlyRainProbabilities = [];

  static const Color cardColor = Color(0xFF201C49);
  static const Color purpleColor = Color(0xFF7964F5);

  Future<void> getWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _weatherService.getWeather(
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );

      final result = Weather.fromJson(data);

      final hourlyData = data['hourly'] as Map<String, dynamic>?;
      final rainValues =
      hourlyData?['precipitation_probability'] as List?;

      final parsedRainProbabilities = rainValues
          ?.map(
            (value) =>
        value == null ? null : (value as num).toDouble(),
      )
          .toList() ??
          <double?>[];

      if (!mounted) return;

      setState(() {
        weather = result;
        hourlyRainProbabilities = parsedRainProbabilities;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('حدث خطأ: $e');
    }
  }

  Future<void> selectCity(Map<String, dynamic> city) async {
    setState(() {
      selectedCity = city['name'] as String;
      selectedLatitude = (city['latitude'] as num).toDouble();
      selectedLongitude = (city['longitude'] as num).toDouble();
    });

    await getWeather();
  }

  Future<void> openCitySearch() async {
    final city = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CitySearchScreen(
          weatherService: _weatherService,
        ),
      ),
    );

    if (!mounted) return;

    if (city != null) {
      await selectCity(city);
    }
  }

  Future<void> searchForCities(String name) async {
    if (name.trim().isEmpty) {
      setState(() {
        cityResults = [];
      });
      return;
    }

    try {
      final results = await _weatherService.searchCities(name.trim());

      if (!mounted) return;

      setState(() {
        cityResults = results;
      });
    } catch (e) {
      debugPrint('حدث خطأ أثناء البحث عن المدن: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _weatherService = widget.weatherService ?? WeatherService();

    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final currentHourIndex = weather?.hourlyTimes.indexWhere(
          (time) {
        final dateTime = DateTime.parse(time);

        return dateTime.year == now.year &&
            dateTime.month == now.month &&
            dateTime.day == now.day &&
            dateTime.hour == now.hour;
      },
    ) ??
        -1;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/sky.jpg',
            fit: BoxFit.cover,
          ),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: purpleColor,
              ),
            )
          else if (weather == null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذر تحميل بيانات الطقس',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: getWeather,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          else
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // اسم المدينة والبحث والتحديث
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: TextButton(
                            onPressed: isLoading ? null : openCitySearch,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(selectedCity,style: TextStyle(fontSize:25),),
                                const SizedBox(width: 6),
                                const Icon(Icons.keyboard_arrow_down_rounded,size: 28,),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: isLoading ? null : getWeather,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            tooltip: 'Reload weather',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // وصف حالة الطقس
                    Text(
                      getWeatherDescription(weather!.weatherCode),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // درجة الحرارة الحالية
                    Text(
                      '${weather!.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 76,
                        height: 1.1,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Current temperature',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // أيقونة حالة الطقس الكبيرة
                    SizedBox(
                      height: 210,
                      width: double.infinity,
                      child: Center(
                        child: Icon(
                          getWeatherIcon(weather!.weatherCode),
                          size: 118,
                          color: const Color(0xFFE0DCFF),
                          shadows: const [
                            Shadow(
                              color: Color(0x887A68FF),
                              blurRadius: 35,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // الكارد الكبير للتوقعات الساعية
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Color(0xFFB9ACFF),
                                size: 21,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hourly Forecast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const Row(
                            children: [
                              SizedBox(width: 28),
                              Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 205,
                            child: Builder(
                              builder: (context) {
                                final startIndex =
                                currentHourIndex >= 0
                                    ? currentHourIndex
                                    : 0;

                                final availableHours =
                                    weather!.hourlyTemperatures.length -
                                        startIndex;

                                if (availableHours <= 0) {
                                  return const Center(
                                    child: Text(
                                      'No hourly forecast available',
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  );
                                }

                                // نعرض الساعات الإحدى عشرة القادمة
                                final count = availableHours >= 11
                                    ? 11
                                    : availableHours;

                                final temperatures =
                                weather!.hourlyTemperatures.sublist(
                                  startIndex,
                                  startIndex + count,
                                );

                                final minTemp = temperatures.reduce(
                                      (a, b) => a < b ? a : b,
                                );

                                final maxTemp = temperatures.reduce(
                                      (a, b) => a > b ? a : b,
                                );

                                final padding =
                                (maxTemp - minTemp) < 2
                                    ? 1.0
                                    : (maxTemp - minTemp) * 0.15;

                                // عرض الساعات داخل مساحة قابلة للسحب أفقيًا
                                const double itemWidth = 66;
                                final contentWidth = count * itemWidth;

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: contentWidth,
                                    child: Column(
                                      children: [
                                        // 1. صف الساعات
                                        Row(
                                          children: List.generate(
                                            count,
                                                (index) {
                                              final actualIndex =
                                                  startIndex + index;

                                              final time = weather!
                                                  .hourlyTimes[actualIndex];

                                              return SizedBox(
                                                width: itemWidth,
                                                child: Text(
                                                  index == 0
                                                      ? 'Now'
                                                      : time.substring(11, 16),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // 2. صف أيقونات الطقس
                                        Row(
                                          children: List.generate(
                                            count,
                                                (index) {
                                              final actualIndex =
                                                  startIndex + index;

                                              return SizedBox(
                                                width: itemWidth,
                                                child: Icon(
                                                  getWeatherIcon(
                                                    weather!
                                                        .hourlyWeatherCodes[
                                                    actualIndex],
                                                  ),
                                                  color:
                                                  const Color(0xFFDCD6FF),
                                                  size: 23,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        // 3. صف درجات الحرارة
                                        Row(
                                          children: List.generate(
                                            count,
                                                (index) {
                                              return SizedBox(
                                                width: itemWidth,
                                                child: Text(
                                                  '${temperatures[index].toStringAsFixed(0)}°',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        // 4. الخط البياني المتصل
                                        SizedBox(
                                          height: 65,
                                          width: contentWidth,
                                          child: LineChart(
                                            LineChartData(
                                              minX: 0,
                                              maxX: count.toDouble(),
                                              minY: minTemp - padding,
                                              maxY: maxTemp + padding,
                                              gridData:
                                              const FlGridData(show: false),
                                              titlesData:
                                              const FlTitlesData(show: false),
                                              borderData:
                                              FlBorderData(show: false),
                                              lineTouchData:
                                              const LineTouchData(
                                                enabled: false,
                                              ),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: List.generate(
                                                    count,
                                                        (index) => FlSpot(
                                                      index + 0.5,
                                                      temperatures[index],
                                                    ),
                                                  ),
                                                  isCurved: true,
                                                  curveSmoothness: 0.25,
                                                  color:
                                                  const Color(0xFFB9ACFF),
                                                  barWidth: 3,
                                                  dotData:
                                                  const FlDotData(
                                                    show: false,
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color:
                                                    const Color(0x337964F5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        // 5. صف احتمالية هطول الأمطار
                                        Row(
                                          children: List.generate(
                                            count,
                                                (index) {
                                              final actualIndex =
                                                  startIndex + index;

                                              final rain = actualIndex <
                                                  hourlyRainProbabilities
                                                      .length
                                                  ? hourlyRainProbabilities[
                                              actualIndex] ??
                                                  0
                                                  : 0;

                                              return SizedBox(
                                                width: itemWidth,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.water_drop_rounded,
                                                      color:
                                                      Color(0xFF9EDCFF),
                                                      size: 11,
                                                    ),
                                                    Text(
                                                      '${rain.round()}%',
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // الرطوبة وسرعة الرياح
                    Row(
                      children: [
                        Expanded(
                          child: _weatherDetail(
                            Icons.water_drop_rounded,
                            'Humidity',
                            '${weather!.humidity.toStringAsFixed(0)}%',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _weatherDetail(
                            Icons.air_rounded,
                            'Wind Speed',
                            '${weather!.windSpeed.toStringAsFixed(1)} km/h',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // عنوان التوقعات الأسبوعية
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'WEEKLY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // كارد التوقعات الأسبوعية
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: weather!.dailyForecasts
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final day = entry.value;

                          final date = DateTime.parse(day.date);

                          const weekdays = [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                            'Sunday',
                          ];

                          final dayName = index == 0
                              ? 'Today'
                              : weekdays[date.weekday - 1];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                // اسم اليوم على اليسار
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    dayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // أيقونة الطقس في الوسط
                                Expanded(
                                  flex: 2,
                                  child: Icon(
                                    getWeatherIcon(day.weatherCode),
                                    color: const Color(0xFFDCD6FF),
                                    size: 25,
                                  ),
                                ),

                                // درجات الحرارة على اليمين
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${day.dayHigh.toStringAsFixed(0)}°',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${day.nightHigh.toStringAsFixed(0)}°',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // الكارد الصغير لكل ساعة
  Widget _hourItem(
      String time,
      IconData icon,
      double temp,
      List<double> trendTemperatures,
      double? rainProbability,
      ) {
    final minTemp = trendTemperatures.reduce(
          (a, b) => a < b ? a : b,
    );

    final maxTemp = trendTemperatures.reduce(
          (a, b) => a > b ? a : b,
    );

    final range = (maxTemp - minTemp).abs();
    final padding = range < 2 ? 1.0 : range * 0.15;

    return Container(
      width: 64,
      margin: const EdgeInsets.only(right: 9),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الوقت
          Text(
            time,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          // أيقونة الطقس
          Icon(
            icon,
            color: const Color(0xFFDCD6FF),
            size: 22,
          ),

          // درجة الحرارة
          Text(
            '${temp.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          // الخط البياني تحت درجة الحرارة
          SizedBox(
            height: 24,
            width: 52,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: trendTemperatures.length > 1
                    ? (trendTemperatures.length - 1).toDouble()
                    : 1,
                minY: minTemp - padding,
                maxY: maxTemp + padding,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      trendTemperatures.length,
                          (index) => FlSpot(
                        index.toDouble(),
                        trendTemperatures[index],
                      ),
                    ),
                    isCurved: true,
                    color: const Color(0xFFB9ACFF),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),

          // احتمال هطول المطر في هذه الساعة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: Color(0xFF9EDCFF),
                size: 10,
              ),
              const SizedBox(width: 2),
              Text(
                '${(rainProbability ?? 0).round()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // كروت تفاصيل الطقس
  Widget _weatherDetail(
      IconData icon,
      String label,
      String value,
      ) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: purpleColor.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD5CEFF),
              size: 27,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
