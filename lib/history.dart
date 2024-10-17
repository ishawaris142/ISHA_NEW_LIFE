import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'history_data.dart';

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

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No Date Available';
    }
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

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
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text('You need to be logged in to view purchase history.'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Icon(Icons.commit, size: 30, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                userData?['full_name'] ?? "Name not available",
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: StreamBuilder<QuerySnapshot>(
                stream: historyCollection.where('userId', isEqualTo: user.uid).snapshots(),
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
                      Timestamp? timestamp = historyItem['timestamp'] as Timestamp?;
                      double totalAmount = historyItem['totalAmount'];
                      int totalPoints = historyItem['totalPoints'];
                      String docId = historyItem.id;
                      Map<String, dynamic> purchaseData = historyItem.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          showPurchaseDetails(context, purchaseData);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          color: const Color.fromARGB(38, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              'Date of Purchase: ${formatDate(timestamp)}',
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteHistoryItem(docId),
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
