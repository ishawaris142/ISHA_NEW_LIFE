import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
    
      // appBar: AppBar(
      
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 174, 40, 40)),
      //     onPressed: () {
      //       Navigator.pop(context); // Go back to the previous screen
      //     },
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.check, color: Color.fromARGB(255, 223, 31, 31)),
      //       onPressed: _updateProfile, // Save the profile changes
      //     ),
      //   ],
      // ),
      body: GestureDetector(
        onTap: () {
           FocusScope.of(context).unfocus();
        },
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/backk.png"),fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 15),
              child: SingleChildScrollView(
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
                    const SizedBox(height: 10),
                    Center(
                      child: Image.asset(
                        'assets/smalllogo.png', // Your profile image here
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Edit your Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                        
                    // Account Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedAccountType,
                      hint: const Text("Select Account Type",
                          style: TextStyle(color: Colors.white54)),
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
                    const SizedBox(height: 13),
                        Text("Your's Name",style: TextStyle(color: Colors.white),),
                        SizedBox(height: 3),
                    // Full Name
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "Full Name",
                        hintStyle: const TextStyle(color: Colors.white54),
                       
                       
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 13),
                        
                    // Phone
                    Text("Phone ",style: TextStyle(color: Colors.white),),
                        SizedBox(height: 3),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "+92 312 3456789",
                        hintStyle: const TextStyle(color: Colors.white54),
                      
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 13),
                        
                    // CNIC
                    Text("CNIC",style: TextStyle(color: Colors.white),),
                        SizedBox(height: 3),
                    TextField(
                      controller: cnicController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "35123 - 4567891 - 0",
                        hintStyle: const TextStyle(color: Colors.white54),
                      
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),
                        
                    // Address
                    Text("Address",style: TextStyle(color: Colors.white),),
                        SizedBox(height: 3),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "Your address",
                        hintStyle: const TextStyle(color: Colors.white54),
                       
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 13),
                        
                    // Password Field
                    Text("New Password",style: TextStyle(color: Colors.white),),
                        SizedBox(height: 3),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "New Password",
                        hintStyle: const TextStyle(color: Colors.white54),
                       
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 13),
                        
                    // Confirm Password Field
                    Text("Confirm Password",style: TextStyle(color: Colors.white),),
                        SizedBox(height: 3),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: "Confirm Password",
                        hintStyle: const TextStyle(color: Colors.white54),
                        
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
