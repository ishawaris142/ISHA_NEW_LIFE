import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/account.dart';
import 'package:red_coprative/view/auth/login.dart';

import '../profile/edit_profile_screen.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>?;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
     var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
           height: height,
          width: width,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/backk.png"),fit: BoxFit.fill)),
     //   padding: const EdgeInsets.symmetric(horizontal: 1),
       
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  //   onPressed: () {
                  //     Navigator.pushReplacement(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => Accountscreen()),
                  //     );
                  //   },
                  // ),
                 IconButton(
  icon: Image.asset("assets/profilelogout.png"),
 onPressed: () async {
  print("Logout button pressed");
  await FirebaseAuth.instance.signOut();
  print("User signed out");
  
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
    // (Route<dynamic> route) => false, // Ensures all routes are removed.
  );
},
),
                ],
              ),
            ),
            const SizedBox(height: 17),
            userData != null
                ? ListTile(
                    leading: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/Kid.png"),
                    ),
                    title: Text(
                      userData?['full_name'] ?? "Name not available",
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    subtitle: Row(
                      children: [
                         Image.asset("assets/mechanic.png"),
                         SizedBox(width: 4),
                        Text(
                          userData?['account_type'] ?? "Account type not available",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        )
                      ],
                    ),
                    trailing: IconButton(
                      icon: Image.asset("assets/BiSolidEditAlt.png"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(userData: userData!),
                          ),
                        );
                      },
                    ),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 40),
            if (userData != null)
              Container(
                margin: const EdgeInsets.only(left: 25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color: Color.fromARGB(255, 211, 35, 23),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          userData?['email'] ?? "Email not available",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color.fromARGB(255, 211, 35, 23),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          userData?['phone'] ?? "Phone not available",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
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
                          style: const TextStyle(color: Colors.white, fontSize: 16),
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
