import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Model/AccountModel.dart';
import 'package:weather_app/Model/ThemeProvider.dart';
import 'package:weather_app/Pages/WelcomeScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  await Firebase.initializeApp();

  // Initialize Awesome Notifications
  AwesomeNotifications().initialize(
    null, // Default notification icon
    [
      NotificationChannel(
        channelKey: 'daily_weather',
        channelName: 'Daily Weather Notifications',
        channelDescription: 'Notification channel for daily weather updates',
        defaultColor: const Color.fromARGB(255, 45, 49, 73),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Access the theme provider

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme, // Set the app theme dynamically
      home: const WelcomeScreen(), // Initial screen for the app
    );
  }
}
