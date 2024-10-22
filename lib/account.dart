import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:red_coprative/viewproducts.dart';
import 'covert_points.dart';
import 'feeds.dart';
import 'cart_items.dart';
import 'cash_withdraw.dart';
import 'history.dart';
import 'models/accountgridmodelclass.dart';  // Assuming you have this screen

class Accountscreen extends StatefulWidget {
  const Accountscreen({super.key});

  @override
  State<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends State<Accountscreen> {
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
      body: userData == null // Show loading indicator if data is still being fetched
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        margin: const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            // Top section with app name and QR code icon
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 32),
                    onPressed: () {
                      // Navigate to the Feedsscreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Feedsscreen()),
                      );
                    },
                  ),
                  const Icon(
                    Icons.qr_code_scanner_sharp,
                    size: 28,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Profile info card with reduced width and centered
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.9, // Adjusted width to 90% of screen
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the profile section
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12)), // Rounded corners
              ),
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
                            // Display fetched full name, or a default value if not available
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
                                Text(
                                  userData?['address'] ?? "Location not available",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 12, 12, 12),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Display fetched account type, or a default value if not available
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
                            // Display fetched points, or default to 0
                            Text(
                              "${userData?['totalPoints'] ?? 0}", // Display totalPoints safely
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

            // Cash Withdraw and History buttons, styled similarly to profile ca
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.9, // Adjusted width to 90% of screen
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CashWithdrawScreen(),
                              ));
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
                  Container(
                    height: 45,
                    width: 1,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const Historyscreen(),
                              ));
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

            const SizedBox(height: 24),
            const Text(
              "More From ISH",
              style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
            ),

            // GridView with reduced spacing and smaller images
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,  // Reduced spacing between grid items
                    mainAxisSpacing: 5,  // Reduced spacing between rows
                    childAspectRatio: 1, // Adjust the aspect ratio for smaller grids
                  ),
                  itemCount: accountgridmodelclasslist.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (accountgridmodelclasslist[index].text == "View Products") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ViewproductScreen(),
                            ),
                          );
                        } else if (accountgridmodelclasslist[index].text == "Cart") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(),
                            ),
                          );
                        } else if (accountgridmodelclasslist[index].text == "Convert Points") {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ConvertPointsScreen(),),);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
                        margin: const EdgeInsets.symmetric(vertical: 8), // Reduced margin
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Removed background color
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "${accountgridmodelclasslist[index].image}",
                              height: 40, // Smaller icon size
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${accountgridmodelclasslist[index].text}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
