import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/Model/ThemeProvider.dart';
import 'package:weather_app/NavigationBar/compass.dart';
import 'package:weather_app/NavigationBar/search.dart';
import 'package:weather_app/NavigationBar/setting.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _locationName = 'Your Location';
  String _currentDateTime = '';
  String _temperature = '...';
  String _weatherCondition = '...';
  String _rain = '0 mm';
  String _windSpeed = '0 km/h';
  String _humidity = '0%';
  String _mainImagePath =
      'Images/Screenshot_2024-12-05_211856-removebg-preview.png';
  bool _isLoading = true;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Search(),
    Compass(),
    Setting(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentDateTime();
    _loadSavedWeatherData();
    _getLocation();
  }

  void _getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMMM').format(now);
    setState(() {
      _currentDateTime = formattedDate;
    });
  }

  Future<void> _loadSavedWeatherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locationName = prefs.getString('locationName') ?? _locationName;
      _temperature = prefs.getString('temperature') ?? _temperature;
      _weatherCondition =
          prefs.getString('weatherCondition') ?? _weatherCondition;
      _rain = prefs.getString('rain') ?? _rain;
      _windSpeed = prefs.getString('windSpeed') ?? _windSpeed;
      _humidity = prefs.getString('humidity') ?? _humidity;
      _updateMainImage();
      _isLoading = false;
    });
  }

  Future<void> _saveWeatherData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locationName', _locationName);
    await prefs.setString('temperature', _temperature);
    await prefs.setString('weatherCondition', _weatherCondition);
    await prefs.setString('rain', _rain);
    await prefs.setString('windSpeed', _windSpeed);
    await prefs.setString('humidity', _humidity);
  }

  void _updateMainImage() {
    final rainValue = double.tryParse(_rain.split(' ')[0]) ?? 0;
    final windValue = double.tryParse(_windSpeed.split(' ')[0]) ?? 0;
    final humidityValue = double.tryParse(_humidity.split('%')[0]) ?? 0;

    if (rainValue > windValue && rainValue > humidityValue) {
      _mainImagePath =
          'Images/Screenshot_2024-12-06_220217-removebg-preview.png';
    } else if (windValue > humidityValue) {
      _mainImagePath =
          'Images/Screenshot_2024-12-06_215751-removebg-preview.png';
    } else {
      _mainImagePath =
          'Images/thermometer-with-snowflakes-background_1308-68281-removebg-preview (1).png';
    }
  }

  Future<void> _getWeatherData(double lat, double lon) async {
    const apiKey =
        "4d82a93258dcd53e3cb1d132aeaf5966"; // استبدل بمفتاح API الخاص بك
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = "${data['main']['temp']}°";
          _weatherCondition = data['weather'][0]['description'];
          _rain = data['rain'] != null ? "${data['rain']['1h']} mm" : "0 mm";
          _windSpeed = "${data['wind']['speed']} km/h";
          _humidity = "${data['main']['humidity']}%";
          _updateMainImage();
          _isLoading = false;
        });
        await _saveWeatherData();
      } else {
        _showErrorSnackbar("Error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorSnackbar("Error fetching weather data: $e");
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackbar("Activate the Internet");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackbar("Activate the location feature");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _locationName = placemarks.first.locality ?? 'Unknown Location';
      });
      _getWeatherData(position.latitude, position.longitude);
    } catch (e) {
      _showErrorSnackbar("Activate the location feature");
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Get Location"),
          content: const Text("Do You Want get Your Loaction"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق النافذة
              },
              child: const Text(
                "No",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق النافذة
                _getLocation();
              },
              child: const Text(
                "Yes",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeView(
            locationName: _locationName,
            currentDateTime: _currentDateTime,
            temperature: _temperature,
            weatherCondition: _weatherCondition,
            rain: _rain,
            windSpeed: _windSpeed,
            humidity: _humidity,
            isLoading: _isLoading,
            mainImagePath: _mainImagePath,
            showLocationPermissionDialog: _showLocationPermissionDialog,
          ),
          const Search(),
          const Compass(),
          const Setting(),
        ],
      ),
      bottomNavigationBar: Stack(alignment: Alignment.bottomCenter, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(26)),
              color: themeProvider.Container,
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: const Color(0xff60b8f0),
              unselectedItemColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              iconSize: 28,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.compass),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '',
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: MediaQuery.of(context).size.width / (4 * 1) * _selectedIndex +
              MediaQuery.of(context).size.width / 6 -
              27,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 24,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xff4fadf1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              )),
        ),
      ]),
    );
  }
}

class HomeView extends StatelessWidget {
  final String locationName;
  final String currentDateTime;
  final String temperature;
  final String weatherCondition;
  final String rain;
  final String windSpeed;
  final String humidity;
  final bool isLoading;
  final String mainImagePath;
  final VoidCallback showLocationPermissionDialog;

  const HomeView({
    super.key,
    required this.locationName,
    required this.currentDateTime,
    required this.temperature,
    required this.weatherCondition,
    required this.rain,
    required this.windSpeed,
    required this.humidity,
    required this.isLoading,
    required this.mainImagePath,
    required this.showLocationPermissionDialog,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Container(
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
              : null, // إذا لم يكن الوضع الليلي، اتركه بدون تدرج
          color: themeProvider.isDarkMode ? null : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xff4fadf1),
                      size: 27,
                    ),
                    SizedBox(width: 5),
                    Text(
                      locationName,
                      style: TextStyle(
                          color: themeProvider.textColor, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: showLocationPermissionDialog,
                      child: Container(
                        height: 36,
                        width: 26,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 3, 6, 36),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(blurRadius: 1, color: Colors.white70)
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'About Today',
                style: TextStyle(
                    color: themeProvider.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  mainImagePath,
                  height: 230,
                  width: 230,
                  fit: BoxFit.fill,
                ),
              ),
              Center(
                child: Text(
                  currentDateTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              Center(
                child: Text(
                  temperature,
                  style: TextStyle(
                      color: themeProvider.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 64),
                ),
              ),
              Center(
                child: Text(
                  weatherCondition,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeatherCard('Rain', rain,
                      'Images/Screenshot_2024-12-06_220217-removebg-preview.png'),
                  _buildWeatherCard('Wind', windSpeed,
                      'Images/Screenshot_2024-12-06_215751-removebg-preview.png'),
                  _buildWeatherCard('Humidity', humidity,
                      'Images/thermometer-with-snowflakes-background_1308-68281-removebg-preview (1).png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildWeatherCard(
    String title,
    String value,
    String imagePath,
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 140,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: themeProvider.Container, // تغيير لون الخلفية بناءً على الوضع
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 50,
                  width: 50,
                ),
                const SizedBox(height: 10),
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
      },
    );
  }
}
