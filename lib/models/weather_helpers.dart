
import 'package:flutter/material.dart';

String getWeatherDescription(int code) {
  if (code == 0) {
    return 'Clear Sky';
  } else if (code == 1 || code == 2) {
    return 'Partly Cloudy';
  } else if (code == 3) {
    return 'Overcast';
  } else if (code >= 51 && code <= 67) {
    return 'Rainy';
  } else if (code >= 71 && code <= 77) {
    return 'Snowy';
  } else if (code >= 80 && code <= 82) {
    return 'Rain Showers';
  } else if (code >= 95) {
    return 'Thunderstorm';
  } else {
    return 'Unknown Weather';
  }
}

IconData getWeatherIcon(int code) {
  if (code == 0) {
    return Icons.wb_sunny;
  } else if (code == 1 || code == 2) {
    return Icons.cloud_queue;
  } else if (code == 3) {
    return Icons.cloud;
  } else if (code >= 51 && code <= 82) {
    return Icons.umbrella;
  } else if (code >= 95) {
    return Icons.thunderstorm;
  } else {
    return Icons.cloud;
  }
}

