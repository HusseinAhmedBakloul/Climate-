import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/Pages/WelcomeScreen.dart';
import 'package:weather_app/login/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isNameEmpty = false;
  bool isEmailEmpty = false;
  bool isPasswordEmpty = false;

  Future<void> login() async {
    setState(() {
      isNameEmpty = nameController.text.trim().isEmpty;
      isEmailEmpty = emailController.text.trim().isEmpty;
      isPasswordEmpty = passwordController.text.trim().isEmpty;
    });

    if (isNameEmpty || isEmailEmpty || isPasswordEmpty) {
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!
          .updateProfile(displayName: nameController.text.trim());

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Text(
                    'Welcome back to',
                    style: TextStyle(
                        color: Color.fromARGB(255, 45, 49, 73),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AbrilFatface'),
                  ),
                ),
                Text(
                  'Climate',
                  style: TextStyle(
                      color: Color.fromARGB(255, 45, 49, 73),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AbrilFatface'),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color.fromARGB(255, 45, 49, 73),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                buildTextField(
                    controller: nameController,
                    icon: Icons.person,
                    hintText: 'Enter your name',
                    isEmpty: isNameEmpty),
                const SizedBox(height: 20),
                buildTextField(
                    controller: emailController,
                    icon: Icons.email,
                    hintText: 'Enter your email',
                    isEmpty: isEmailEmpty),
                const SizedBox(height: 20),
                buildTextField(
                    controller: passwordController,
                    icon: Icons.lock,
                    hintText: 'Enter your password',
                    obscureText: true,
                    isEmpty: isPasswordEmpty),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 45, 49, 73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  onPressed: login,
                  child: const Text('Create Account',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 80),
                Center(
                    child: Text('Already have an account?',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 45, 49, 73)))),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Login here',
                      style: TextStyle(
                          color: Color.fromARGB(255, 207, 66, 14),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Color.fromARGB(255, 207, 66, 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      {required TextEditingController controller,
      required IconData icon,
      required String hintText,
      bool obscureText = false,
      required bool isEmpty}) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(78, 226, 225, 225),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 1,
          color: isEmpty ? Colors.red : Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Icon(icon, color: Color.fromARGB(255, 45, 49, 73), size: 24),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Color.fromARGB(255, 45, 49, 73)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
