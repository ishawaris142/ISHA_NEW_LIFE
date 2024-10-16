import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for fetching data
import 'package:intl/intl.dart'; // Import for date formatting
import 'history_data.dart'; // Import the showPurchaseDetails function

class Historyscreen extends StatefulWidget {
  const Historyscreen({super.key});

  @override
  State<Historyscreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
  final CollectionReference historyCollection = FirebaseFirestore.instance.collection('history');
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Call fetchUserData when the screen is initialized
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

  // Function to format the Firestore timestamp to only display the date
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No Date Available'; // Handle missing timestamp
    }
    DateTime date = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd').format(date); // Format the date in 'YYYY-MM-DD' format
  }

  // Function to delete a specific history item by its document ID
  Future<void> _deleteHistoryItem(String docId) async {
    try {
      await historyCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase has been deleted from history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete purchase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to solid black
      body: Column(
        children: [
          // Top Section with Icons only
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Adjust padding for icons
            decoration: const BoxDecoration(
              color: Colors.black, // Solid black background
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
                const Icon(Icons.commit, size: 30, color: Colors.white), // Optional icon
              ],
            ),
          ),

          // Display user's name from Firestore
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Adjust padding for the title
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                userData?['full_name'] ?? "Name not available", // Show the user's full name or fallback text
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          // List of Purchases
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15), // Add padding around the list
              child: StreamBuilder<QuerySnapshot>(
                stream: historyCollection.snapshots(), // Fetch data from history collection
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var historyItems = snapshot.data!.docs;

                  if (historyItems.isEmpty) {
                    return const Center(
                      child: Text(
                        "No purchase history",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      var historyItem = historyItems[index];
                      Timestamp? timestamp = historyItem['timestamp'] as Timestamp?; // Safely get timestamp field
                      double totalAmount = historyItem['totalAmount'];
                      int totalPoints = historyItem['totalPoints'];
                      String docId = historyItem.id; // Get document ID for deletion
                      Map<String, dynamic> purchaseData = historyItem.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          // Call the showPurchaseDetails function from historyData.dart
                          showPurchaseDetails(context, purchaseData);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          color: const Color.fromARGB(38, 255, 255, 255), // Background color of the list item
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Border radius
                          ),
                          child: ListTile(
                            title: Text(
                              'Date of Purchase: ${formatDate(timestamp)}', // Format the timestamp to show only the date
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Points: $totalPoints', style: const TextStyle(color: Colors.white)),
                                Text('Amount of Purchase: \$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red), // Delete icon
                              onPressed: () => _deleteHistoryItem(docId), // Delete the item
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
