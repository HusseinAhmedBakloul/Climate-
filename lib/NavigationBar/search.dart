import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Model/ThemeProvider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchedCity;
  Map<String, dynamic>? _weatherData;

  final String apiKey = "4d82a93258dcd53e3cb1d132aeaf5966";

  Future<void> _searchWeather(String city) async {
    if (city.isEmpty) return;

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchedCity = city;
          _weatherData = {
            'Temperature': data['main']['temp'].toString(),
            'Humidity': data['main']['humidity'].toString(),
            'Wind Speed': data['wind']['speed'].toString(),
            'Description': data['weather'][0]['description'],
            'Pressure': data['main']['pressure'].toString(),
            'Feels Like': data['main']['feels_like'].toString(),
            'Sunrise': DateFormat.jm().format(
                DateTime.fromMillisecondsSinceEpoch(
                    data['sys']['sunrise'] * 1000)),
            'Sunset': DateFormat.jm().format(
                DateTime.fromMillisecondsSinceEpoch(
                    data['sys']['sunset'] * 1000)),
          };
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _searchedCity = 'Error';
        _weatherData = null;
      });
      print('Error fetching data: $e');
    }
  }

  Future<List<String>> _getSuggestions(String query) async {
    final url =
        'https://api.openweathermap.org/data/2.5/find?q=$query&type=like&sort=population&cnt=10&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['list'] as List)
            .map((city) => city['name'] as String)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBody: true,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Pick Location',
                  style:
                      TextStyle(color: themeProvider.textColor, fontSize: 22),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Find the area or the city that you want to know the detailed weather info at this time',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TypeAheadField(
                  suggestionsCallback: (pattern) async {
                    return await _getSuggestions(pattern);
                  },
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: themeProvider.textColor,
                      cursorErrorColor: themeProvider.textColor,
                      style: TextStyle(color: themeProvider.textColor),
                      decoration: InputDecoration(
                          labelText: 'Search City',
                          labelStyle: TextStyle(color: themeProvider.textColor),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: themeProvider.textColor)),
                          fillColor: themeProvider.textColor,
                          iconColor: themeProvider.textColor,
                          focusColor: themeProvider.textColor,
                          hoverColor: themeProvider.textColor,
                          prefixIconColor: themeProvider.textColor,
                          suffixIconColor: themeProvider.textColor,
                          counterStyle:
                              TextStyle(color: themeProvider.textColor)),
                    );
                  },
                  itemBuilder: (context, String suggestion) {
                    return ListTile(
                      title: Text(suggestion,
                          style: const TextStyle(color: Colors.black)),
                    );
                  },
                  onSelected: (String suggestion) {
                    _searchController.text = suggestion;
                    _searchWeather(suggestion);
                  },
                ),
                const SizedBox(height: 5),
                if (_searchedCity != null &&
                    _searchedCity != 'Error' &&
                    _weatherData != null)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      childAspectRatio: 3 / 3,
                    ),
                    itemCount: _weatherData!.length,
                    itemBuilder: (context, index) {
                      final item = _weatherData!.entries.elementAt(index);
                      final imagePath = _getImagePath(item.key);
                      return _buildWeatherCard(item.key, item.value, imagePath);
                    },
                  )
                else if (_searchedCity == 'Error')
                  const Text(
                    'Error fetching weather data',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(String title, String value, String? imagePath) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      height: 180,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: themeProvider.Container,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                height: 80,
                width: 80,
              ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String? _getImagePath(String key) {
    const images = {
      'Temperature': 'Images/Screenshot_2024-12-06_220217-removebg-preview.png',
      'Humidity':
          'Images/thermometer-with-snowflakes-background_1308-68281-removebg-preview (1).png',
      'Wind Speed': 'Images/Screenshot_2024-12-06_215751-removebg-preview.png',
      'Description': 'Images/Screenshot_2024-12-05_211856-removebg-preview.png',
      'Pressure': 'Images/Screenshot_2024-12-11_203940-removebg-preview.png',
      'Feels Like': 'Images/weather-icon-psd-392111-removebg-preview.png',
      'Sunrise': 'Images/Screenshot_2024-12-06_161249-removebg-preview.png',
      'Sunset': 'Images/Screenshot_2024-12-11_204928-removebg-preview.png',
    };
    return images[key];
  }
}
