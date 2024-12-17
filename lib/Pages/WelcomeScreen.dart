import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Model/ThemeProvider.dart';
import 'package:weather_app/Pages/HomeView.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            : null, // إذا لم يكن الوضع الليلي، اتركه بدون تدرج
        color: themeProvider.isDarkMode ? null : Colors.white,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 140,
            left: MediaQuery.of(context).size.width / 2 - 150, // توسيط العنصر
            child: ClipOval(
              child: Image.asset(
                'Images/Screenshot_2024-12-05_211856-removebg-preview.png',
                fit: BoxFit.fill,
                height: 300,
                width: 300,
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: 0,
            right: 0,
            child: Text(
              'Daily',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // النص الثاني
          Positioned(
            top: 550,
            left: 0,
            right: 0,
            child: Text(
              'Weather',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Positioned(
            top: 630,
            left: 0,
            right: 0,
            child: Text(
              'Get to know your weather',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            ),
          ),
          const Positioned(
            top: 655,
            left: 0,
            right: 0,
            child: Text(
              'maps and radar precipitation',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            ),
          ),
          const Positioned(
            top: 680,
            left: 0,
            right: 0,
            child: Text(
              'forecast',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            ),
          ),
          // زر Get Started
          Positioned(
            bottom: 35,
            left: MediaQuery.of(context).size.width / 2 - 125, // توسيط العنصر
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
                backgroundColor: const Color(0xff38acff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
