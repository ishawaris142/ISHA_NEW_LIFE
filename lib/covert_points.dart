import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConvertPointsScreen extends StatefulWidget {
  @override
  _ConvertPointsScreenState createState() => _ConvertPointsScreenState();
}

class _ConvertPointsScreenState extends State<ConvertPointsScreen> {
  final TextEditingController _cartRupeesController = TextEditingController();
  final TextEditingController _cartPointsController = TextEditingController();
  final TextEditingController _withdrawRupeesController = TextEditingController();
  final TextEditingController _withdrawPointsController = TextEditingController();

  double _cartPoints = 0.0;
  double _withdrawPoints = 0.0;
  bool _isCartConverting = true; // To avoid conflict when user inputs in both fields
  bool _isWithdrawConverting = true; // To avoid conflict when user inputs in both fields

  num totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // Fetch user points when the screen initializes
  }

  // Function to fetch user's total points from Firestore
  Future<void> _fetchUserPoints() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          totalPoints = data['totalPoints'] ?? 0;

          setState(() {
            // Points can be fetched and used here
          });
        }
      }
    } catch (e) {
      print("Error fetching user points: $e");
    }
  }

  // Function to convert rupees to points for the Cart (1000 Rupees = 1 Point)
  void _convertRupeesToCartPoints(String rupees) {
    if (rupees.isNotEmpty && _isCartConverting) {
      double price = double.parse(rupees);
      setState(() {
        _cartPoints = price / 1000; // 1000 Rupees = 1 Point
        _cartPointsController.text = _cartPoints.toStringAsFixed(3); // Show 3 decimal places
      });
    } else {
      // Clear the points field if rupees is cleared
      _cartPointsController.clear();
    }
  }

  // Function to convert points to rupees for the Cart (1 Point = 1000 Rupees)
  void _convertCartPointsToRupees(String points) {
    if (points.isNotEmpty && !_isCartConverting) {
      double pointsValue = double.parse(points);
      setState(() {
        double rupees = pointsValue * 1000;
        _cartRupeesController.text = rupees.toStringAsFixed(2); // Show 2 decimal places
      });
    } else {
      // Clear the rupees field if points is cleared
      _cartRupeesController.clear();
    }
  }

  // Function to convert points to rupees for Cash Withdraw (10 Points = 1 Rupee)
  void _convertPointsToWithdrawRupees(String points) {
    if (points.isNotEmpty && _isWithdrawConverting) {
      double pointsValue = double.parse(points);
      setState(() {
        _withdrawPoints = pointsValue / 10; // 10 Points = 1 Rupee
        _withdrawRupeesController.text = _withdrawPoints.toStringAsFixed(2); // Show 2 decimal places
      });
    } else {
      // Clear the rupees field if points is cleared
      _withdrawRupeesController.clear();
    }
  }

  // Function to convert rupees to points for Cash Withdraw (1 Rupee = 10 Points)
  void _convertWithdrawRupeesToPoints(String rupees) {
    if (rupees.isNotEmpty && !_isWithdrawConverting) {
      double price = double.parse(rupees);
      setState(() {
        double points = price * 10; // 1 Rupee = 10 Points
        _withdrawPointsController.text = points.toStringAsFixed(0); // Show as integer points
      });
    } else {
      // Clear the points field if rupees is cleared
      _withdrawPointsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Convert Points"),
        backgroundColor: Colors.red, // Use your app's theme color here
      ),
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      resizeToAvoidBottomInset: true, // Allows the screen to resize when the keyboard is displayed
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Cart Points"),
            _buildConversionCard(
              rupeesController: _cartRupeesController,
              pointsController: _cartPointsController,
              onRupeesChanged: (value) {
                _isCartConverting = true;
                _convertRupeesToCartPoints(value);
                _isCartConverting = false;
              },
              onPointsChanged: (value) {
                _isCartConverting = false;
                _convertCartPointsToRupees(value);
                _isCartConverting = true;
              },
              icon: Icons.shopping_cart,
              rupeesLabel: "Rupees (Rs)",
              pointsLabel: "Points (Cart)",
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Cash Withdraw Points"),
            _buildConversionCard(
              rupeesController: _withdrawRupeesController,
              pointsController: _withdrawPointsController,
              onRupeesChanged: (value) {
                _isWithdrawConverting = false;
                _convertWithdrawRupeesToPoints(value);
                _isWithdrawConverting = true;
              },
              onPointsChanged: (value) {
                _isWithdrawConverting = true;
                _convertPointsToWithdrawRupees(value);
                _isWithdrawConverting = false;
              },
              icon: Icons.attach_money,
              rupeesLabel: "Rupees (Rs)",
              pointsLabel: "Points (Cash Withdraw)",
              isWithdraw: true,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  // Helper method to build the conversion card for both Cart and Cash Withdraw
  Widget _buildConversionCard({
    required TextEditingController rupeesController,
    required TextEditingController pointsController,
    required ValueChanged<String> onRupeesChanged,
    required ValueChanged<String> onPointsChanged,
    required IconData icon,
    required String rupeesLabel,
    required String pointsLabel,
    bool isWithdraw = false,
  }) {
    return Card(
      color: const Color.fromARGB(255, 40, 40, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: rupeesController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: rupeesLabel,
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      hintText: "Enter $rupeesLabel",
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    onChanged: onRupeesChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.yellow),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: pointsLabel,
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    onChanged: onPointsChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
