import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_coprative/login.dart'; // Make sure to import the login screen

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool acceptTerms = false;

  // Controllers to get input values
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the login screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/Logo.png', // Make sure this image is in your assets folder
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Create your Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Full Name
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "Full Name",
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: "Full Name",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Email
            TextField(
              controller: emailController,
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
            // Phone (numbers only)
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "+92 312 3456789",
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: "Phone",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Allow only numbers
              ],
            ),
            const SizedBox(height: 20),
            // CNIC (13 digits only)
            TextField(
              controller: cnicController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "35123 - 4567891 - 0",
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: "CNIC",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
                LengthLimitingTextInputFormatter(13),   // Limit to 13 digits
              ],
            ),
            const SizedBox(height: 20),
            // Address
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "Your address",
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: "Address",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "********",
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
            // Confirm Password
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "********",
                hintStyle: const TextStyle(color: Colors.white54),
                labelText: "Confirm Password",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Checkbox for terms and conditions
            Row(
              children: [
                Checkbox(
                  value: acceptTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      acceptTerms = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                  checkColor: Colors.white,
                ),
                const Text(
                  "I accept the Terms and Conditions.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Create Account Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add signup logic here
                  if (passwordController.text != confirmPasswordController.text) {
                    // Passwords do not match
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwords do not match"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (!acceptTerms) {
                    // Terms and conditions not accepted
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please accept the terms and conditions"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Handle sign up logic here
                    // For example, send data to a server or authenticate
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Login navigation
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already Have An Account?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(), // Navigate back to login screen
                        ),
                      );
                    },
                    child: const Text(
                      "Login Here",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
