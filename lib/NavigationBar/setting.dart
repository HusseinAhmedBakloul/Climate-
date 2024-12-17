import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:weather_app/Model/AccountModel.dart';
import 'package:weather_app/Model/ThemeProvider.dart';
import 'package:weather_app/Model/notifications.dart';
import 'package:weather_app/login/login.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  File? _imageFile;
  String _locationName = 'Unknown';
  bool _notificationsEnabled = false;
  bool _isLoading = false;

  void _toggleLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final accountModel = Provider.of<AccountModel>(context, listen: false);
      await accountModel.updateImagePath(pickedFile.path);
    }
  }

  void toggleNotifications(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
    if (enabled) {
      scheduleWeatherNotifications(); // Schedule notifications
    } else {
      AwesomeNotifications().cancelAll(); // Cancel all notifications
    }
  }

  Future<void> _getLocation() async {
    _toggleLoading(true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackbar("Activate the Internet");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackbar("Activate the Internet");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _locationName = placemarks.first.locality ?? 'Unknown';
      });
    } catch (e) {
      _showErrorSnackbar("Activate the Internet");
    } finally {
      _toggleLoading(false);
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Get Location"),
          content: const Text("Do You Want to get Your Location?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "No",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: _imageFile == null
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : ClipOval(
                                  child: Image.file(
                                    _imageFile!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: "Name"),
                              onChanged: (value) {
                                Provider.of<AccountModel>(context,
                                        listen: false)
                                    .updateName(value);
                              },
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: "Email"),
                              onChanged: (value) {
                                Provider.of<AccountModel>(context,
                                        listen: false)
                                    .updateEmail(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 45, 49, 73),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Location",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            SizedBox(width: 105),
                            Text(
                              _locationName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 34,
                              ),
                              onPressed: _showLocationPermissionDialog,
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 45, 49, 73),
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: ListTile(
                        title: const Text(
                          "Dark Mode",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          activeColor: const Color.fromARGB(255, 45, 49, 73),
                          activeTrackColor: Colors.white,
                          inactiveThumbColor:
                              const Color.fromARGB(255, 45, 49, 73),
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 45, 49, 73),
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: SwitchListTile(
                        title: const Text(
                          'Notifications',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        value: _notificationsEnabled,
                        onChanged: toggleNotifications,
                        activeColor: Color.fromARGB(255, 45, 49, 73),
                        activeTrackColor: Colors.white,
                        inactiveThumbColor: Color.fromARGB(255, 45, 49, 73),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 45, 49, 73),
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: ListTile(
                        title: const Text(
                          "Log Out",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
