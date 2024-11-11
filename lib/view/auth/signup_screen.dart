import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:red_coprative/view/auth/login.dart'; // Import the login screen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore (optional for saving other fields)
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import flutter_screenutil

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

  // Firebase Auth and Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of account types
  String? selectedAccountType;
  final List<String> accountTypes = ['Super Dealer', 'Mechanics', 'Dealer'];

  // Method to handle signup
  Future<void> _signup() async {
    if (selectedAccountType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an account type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the terms and conditions"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'account_type': selectedAccountType,
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'cnic': cnicController.text.trim(),
        'address': addressController.text.trim(),
        'points': 0,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
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
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: 1.sh,
        width: 1.sw,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backk.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10.h),
              Center(
                child: Image.asset(
                  'assets/Logo.png',
                  height: 100.h,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Create your Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              DropdownButtonFormField<String>(
                value: selectedAccountType,
                hint: const Text("Select Account Type", style: TextStyle(color: Colors.white54)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 8, 8, 8),
                  labelText: "Account Type",
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                items: accountTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedAccountType = newValue;
                  });
                },
              ),
              SizedBox(height: 20.h),
              _buildTextField(fullNameController, "Full Name", "Full Name"),
              SizedBox(height: 20.h),
              _buildTextField(emailController, "name@example.com", "Email"),
              SizedBox(height: 20.h),
              _buildTextField(phoneController, "+92 312 3456789", "Phone", keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 20.h),
              _buildTextField(cnicController, "35123 - 4567891 - 0", "CNIC", keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)]),
              SizedBox(height: 20.h),
              _buildTextField(addressController, "Your address", "Address"),
              SizedBox(height: 20.h),
              _buildTextField(passwordController, "********", "Password", obscureText: true),
              SizedBox(height: 20.h),
              _buildTextField(confirmPasswordController, "********", "Confirm Password", obscureText: true),
              SizedBox(height: 20.h),
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
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.all(16.h),
                  ),
                  child: Text(
                    "Create Account",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
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
                            builder: (context) => const LoginScreen(),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 8, 8, 8),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

