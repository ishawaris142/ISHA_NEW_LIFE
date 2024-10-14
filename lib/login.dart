import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:red_coprative/signup_screen.dart'; // Import the signup screen
import 'package:red_coprative/dashboard.dart'; // Import your dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  // Controllers to retrieve input values
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to handle login
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Access user info if needed
      User? user = userCredential.user;
      if (user != null) {
        print('Logged in as: ${user.email}');
      }

      // Navigate to the dashboard on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Dashboardscreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/Logo.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Login to your Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController, // Add controller
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: "name@example.com",
                  hintStyle: const TextStyle(color: Colors.white54),
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController, // Add controller
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: "Enter your password",
                  hintStyle: const TextStyle(color: Colors.white54),
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        activeColor: Colors.red,
                        checkColor: Colors.white,
                      ),
                      const Text(
                        "Remember me",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Forgot Password logic
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Login button
              SizedBox(
                width: double.infinity, // Full width button
                child: ElevatedButton(
                  onPressed: _login, // Call Firebase login method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    "Login to Account",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Register section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t Have An Account?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register Here",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}