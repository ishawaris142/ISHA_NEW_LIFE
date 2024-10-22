
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:red_coprative/cash_withdraw.dart';
import 'package:red_coprative/history.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // PageController to keep track of the current page
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Variable to hold user data
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen initializes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: userData == null
          ? const Center(child: CircularProgressIndicator()) // Show loading if userData is null
          : SingleChildScrollView(
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
                              // Dynamically display user's name
                              Text(
                                userData?['full_name'] ?? "Name not available",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 12, 12, 12),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Color.fromARGB(255, 165, 6, 13),
                                  ),
                                  const SizedBox(width: 4),
                                  // Dynamically display user's location
                                  Text(
                                    userData?['address'] ?? "Lahore",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 12, 12, 12),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Dynamically display user's account type
                              Text(
                                userData?['account_type'] ?? "Account type not available",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 12, 12, 12),
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
                              // Dynamically display user's points, defaulting to 0 if not available
                              Text(
                                "${userData?['totalPoints'] ?? 0}",
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
                                    color: Color.fromARGB(255, 165, 6, 13),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "Points",
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

              // Cash Withdraw and History buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(10), // Rounded outer corners
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
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CashWithdrawScreen()),
                            );
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
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Historyscreen()),
                            );
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

              // PageView with Dots Indicator
              const SizedBox(height: 16),
              Container(
                height: 400, // Set a fixed height for the page view
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    Image.asset(
                      "assets/technology.jpg", // First image
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/technology.jpg", // Second image
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/technology.jpg", // Third image
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Dot Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.red // Active dot color
                          : Colors.grey, // Inactive dot color
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
