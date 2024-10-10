import 'package:flutter/material.dart';
import 'package:red_coprative/login.dart'; // Make sure to import your login screen

class Logoscreen extends StatefulWidget {
  const Logoscreen({super.key});

  @override
  State<Logoscreen> createState() => _LogoscreenState();
}

class _LogoscreenState extends State<Logoscreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and then navigate to the login screen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 165, 6, 13), // Background color of the splash screen
      body: Center(
        child: Image.asset(
          'assets/Logo.png', // Replace with your logo image path
          height: 150, // Adjust the logo size
        ),
      ),
    );
  }
}
