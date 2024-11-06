import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Define TextEditingControllers for each field
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController cnicController;
  late TextEditingController addressController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // Account type dropdown
  String? selectedAccountType;
  final List<String> accountTypes = ['Super Dealer', 'Mechanics', 'Dealer'];

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with the current user data
    fullNameController = TextEditingController(text: widget.userData['full_name']);
    phoneController = TextEditingController(text: widget.userData['phone']);
    cnicController = TextEditingController(text: widget.userData['cnic']);
    addressController = TextEditingController(text: widget.userData['address']);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    selectedAccountType = widget.userData['account_type'];
  }

  // Function to update user data in Firestore and FirebaseAuth (for password)
  Future<void> _updateProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update Firestore data
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'full_name': fullNameController.text,
          'phone': phoneController.text,
          'cnic': cnicController.text,
          'address': addressController.text,
          'account_type': selectedAccountType,
        });

        // Update password if both fields are non-empty and match
        if (passwordController.text.isNotEmpty && passwordController.text == confirmPasswordController.text) {
          await user.updatePassword(passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Passwords do not match"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Return to the profile screen after saving
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: 1.sh,
          width: 1.sw,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backk.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 20,right: 12,left: 12,bottom: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context); // Go back to the previous screen
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: _updateProfile, // Save the profile changes
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Image.asset(
                      'assets/smalllogo.png', // Your profile image here
                      height: 100.h,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Edit your Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Account Type Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedAccountType,
                    hint: const Text("Select Account Type", style: TextStyle(color: Colors.white54)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
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
                  SizedBox(height: 13.h),

                  _buildLabel("Your Name"),
                  _buildTextField(fullNameController, "Full Name"),

                  _buildLabel("Phone"),
                  _buildTextField(phoneController, "+92 312 3456789", keyboardType: TextInputType.phone),

                  _buildLabel("CNIC"),
                  _buildTextField(cnicController, "35123 - 4567891 - 0", keyboardType: TextInputType.number),

                  _buildLabel("Address"),
                  _buildTextField(addressController, "Your address"),

                  _buildLabel("New Password"),
                  _buildTextField(passwordController, "New Password", obscureText: true),

                  _buildLabel("Confirm Password"),
                  _buildTextField(confirmPasswordController, "Confirm Password", obscureText: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(top: 13.h, bottom: 3.h),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[800],
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
