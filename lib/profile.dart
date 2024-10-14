import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:red_coprative/account.dart';
import 'package:red_coprative/login.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  // Create a variable to store user details
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen is initialized
  }

  // Function to fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user's document from Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Use UID to identify the user's document
            .get();

        // Check if the document exists and contains data
        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>?; // Store the data in the state
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding:const EdgeInsets.symmetric(horizontal: 6),
        margin:const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            // Top section with app name and logout icon
            Padding(
              padding:const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    onPressed: () {
                      // Navigate to the Accountscreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Accountscreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset("assets/profilelogout.png"),
                    onPressed: () async {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            // If the data has been fetched, display it
            userData != null
                ? ListTile(
              leading:const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/Kid.png"),
              ),
              title: Text(
                userData?['full_name'] ?? "Name not available",
                style:const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.access_time_filled, color: Colors.white),
                  Text(
                    userData?['account_type'] ?? "Account type not available", // Dynamically display the account type
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  )
                ],
              ),

              trailing: Image.asset("assets/BiSolidEditAlt.png"),
            )
                :const CircularProgressIndicator(), // Show a loading spinner while data is being fetched
            const SizedBox(height: 40),
            // Display the rest of the user details
            if (userData != null)
              Container(
                margin:const EdgeInsets.only(left: 25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color:  Color.fromARGB(255, 211, 35, 23),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          userData?['email'] ?? "Email not available",
                          style:const TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: const Color.fromARGB(255, 211, 35, 23),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          userData?['phone'] ?? "Phone not available",
                          style:const TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(
                          Icons.credit_card_rounded,
                          color: Color.fromARGB(255, 211, 35, 23),
                        ),
                        const SizedBox(width: 3),
                        Text(
                           userData?['cnic'] ?? "CNIC not available",
                          style:const TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color.fromARGB(255, 211, 35, 23),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          userData?['address'] ?? "Address not available",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}