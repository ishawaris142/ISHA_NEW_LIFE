import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_coprative/cash_withdraw.dart';
import 'package:red_coprative/history.dart';

class Feedsscreen extends StatefulWidget {
  const Feedsscreen({super.key});

  @override
  State<Feedsscreen> createState() => _FeedsscreenState();
}

class _FeedsscreenState extends State<Feedsscreen> {
  // Variable to hold user data
  Map<String, dynamic>? userData;
  num totalPoints = 0;  // Use `num` to handle both integer and decimal values

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen initializes
    fetchUserTotalPoints(); // Fetch total points for the user
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
            .doc(user.uid) // Use the UID to get the document
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

  // Function to fetch total points of the logged-in user from their cart collection
  Future<void> fetchUserTotalPoints() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the cart items for the logged-in user
        QuerySnapshot cartItemsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        // Calculate the total points for the user based on cart items
        num pointsSum = 0;
        for (var doc in cartItemsSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          num price = data['price'] ?? 0;  // Assume there is a 'price' field in cart items
          num quantity = data['quantity'] ?? 1;  // Default quantity to 1 if not present

          // Example: 1 point for every $100 spent
          pointsSum += (price / 100) * quantity;  // Adjust the points calculation logic as needed
        }

        // Update the totalPoints state
        setState(() {
          totalPoints = pointsSum;
        });
      }
    } catch (e) {
      print("Error fetching total points: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6),
          margin: EdgeInsets.only(top: 25),
          child: Column(
            children: [
              // Top section with app name and QR code icon
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ISH NEW LIFE",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_scanner_sharp,
                      size: 28,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // Profile info card
              Container(
                width: double.infinity,
                color: Colors.white, // Background color of the profile section
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile info row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dynamically display the user's name
                              Text(
                                userData?['full_name'] ?? "Name not available",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 12, 12, 12), // Dark color for the text
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Color.fromARGB(255, 165, 6, 13), // Location icon color
                                  ),
                                  const SizedBox(width: 4),
                                  // Dynamically display the user's location
                                  Text(
                                    userData?['location'] ?? "Lahore",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 12, 12, 12), // Text color
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Dynamically display the user's account type
                              Text(
                                userData?['account_type'] ?? "Account type not available",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 12, 12, 12), // Text color
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 27),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dynamically display the user's points
                              Text(
                                "$totalPoints", // Display the calculated total points here
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.blur_circular_rounded,
                                    size: 16,
                                    color: Color.fromARGB(255, 165, 6, 13), // Icon color
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "points",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Cash Withdraw button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade900, // Same red color
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ), // Rounded left corners
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CashWithdrawScreen(),));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Cash Withdraw",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Vertical divider
                    Container(
                      height: 45, // Same height as the buttons
                      width: 1,
                      color: Colors.white, // Divider color
                    ),
                    // History button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade900, // Same red color
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                          ), // Rounded right corners
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Historyscreen(),));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "History",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Facebook feed section with image
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black, // Background for the image section
                ),
                child: Column(
                  children: [
                    Container(
                      height: 362, // Adjust the height accordingly
                      width: 400,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/technology (1).jpg"), // Image asset
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "CAM GEAR SET FIBER CG 125",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
