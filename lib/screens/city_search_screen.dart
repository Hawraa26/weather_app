import 'dart:async';
import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({
    super.key,
    required this.weatherService,
  });

  final WeatherService weatherService;

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  Timer? _debounce;


  List<Map<String, dynamic>> cityResults = [];
  bool isSearching = false;

  void searchForCities(String name) {
    // إلغاء المؤقت السابق إذا كان موجوداً
    _debounce?.cancel();

    // إذا كان حقل البحث فارغاً، نمسح النتائج
    if (name.trim().isEmpty) {
      setState(() {
        cityResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    // انتظر نصف ثانية بعد آخر حرف كتبته المستخدمة
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results =
        await widget.weatherService.searchCities(name.trim());

        if (!mounted) return;

        setState(() {
          cityResults = results;
          isSearching = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          cityResults = [];
          isSearching = false;
        });

        debugPrint('حدث خطأ أثناء البحث عن المدن: $e');
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('اختيار المدينة'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: searchForCities,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب اسم المدينة...',
                  hintStyle: const TextStyle(
                    color: Colors.white70,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isSearching)
                const CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: cityResults.length,
                    itemBuilder: (context, index) {
                      final city = cityResults[index];

                      final name = city['name'] ?? '';
                      final country = city['country'] ?? '';
                      final region = city['admin1'] ?? '';

                      return ListTile(
                        title: Text(
                          name.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (region.toString().isNotEmpty)
                              region.toString(),
                            if (country.toString().isNotEmpty)
                              country.toString(),
                          ].join(', '),
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.pop(context, city);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
