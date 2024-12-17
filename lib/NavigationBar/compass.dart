import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_app/Model/ThemeProvider.dart';

class Compass extends StatefulWidget {
  const Compass({Key? key}) : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  double? _currentHeading;
  Position? _currentPosition;
  String? _currentCity = "Loading...";
  double? _elevation;
  final String _apiKey = '4d82a93258dcd53e3cb1d132aeaf5966';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // تحميل بيانات البوصلة والموقع بالتوازي
    await Future.wait([
      _fetchCurrentLocation(),
      _listenToCompass(),
    ]);
  }

  Future<void> _listenToCompass() async {
    FlutterCompass.events?.listen((event) {
      setState(() {
        _currentHeading = event.heading;
      });
    });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      _fetchCityAndElevation(position);
    } catch (e) {
      setState(() {
        _currentCity = "Location Error";
      });
    }
  }

  Future<void> _fetchCityAndElevation(Position position) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentCity = data['name'] ?? "Unknown";
          _elevation = data['main']['grnd_level']?.toDouble();
        });
      } else {
        setState(() {
          _currentCity = "API Error";
        });
      }
    } catch (e) {
      setState(() {
        _currentCity = "Error fetching data";
      });
    }
  }

  Widget _buildCompass() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Transform.rotate(
            angle: (_currentHeading ?? 0) * (math.pi / 180) * -1,
            child: Image.asset(
              'Images/images__1_-removebg-preview (1).png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          "${_currentHeading?.toStringAsFixed(1) ?? '0'}° ${_getDirection()}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
      ],
    );
  }

  String _getDirection() {
    if (_currentHeading == null) return "N";
    const directions = [
      "N",
      "NE",
      "E",
      "SE",
      "S",
      "SW",
      "W",
      "NW",
    ];
    int index = ((_currentHeading! + 22.5) ~/ 45) % 8;
    return directions[index];
  }

  Widget _buildDetails() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Text(
          _currentCity ?? "Fetching city...",
          style: TextStyle(fontSize: 18, color: themeProvider.textColor),
        ),
        Text(
          _elevation != null
              ? "Elevation: ${_elevation?.toStringAsFixed(2)} ft"
              : "Fetching elevation...",
          style: TextStyle(fontSize: 18, color: themeProvider.textColor),
        ),
        Text(
          _currentPosition != null
              ? "${_currentPosition?.latitude.toStringAsFixed(2)}° N, ${_currentPosition?.longitude.toStringAsFixed(2)}° W"
              : "Fetching coordinates...",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? const RadialGradient(
                  center: Alignment(0.0, -0.04),
                  radius: 0.7,
                  colors: [
                    Color.fromARGB(255, 45, 49, 73),
                    Color.fromARGB(255, 3, 6, 36),
                  ],
                )
              : null,
          color: themeProvider.isDarkMode ? null : Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCompass(),
              const SizedBox(height: 80),
              _buildDetails(),
            ],
          ),
        ),
      ),
    );
  }
}
