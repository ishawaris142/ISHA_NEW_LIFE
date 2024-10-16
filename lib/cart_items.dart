import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');
  final CollectionReference historyCollection = FirebaseFirestore.instance.collection('history');

  double _totalAmount = 0.0; // Total amount variable
  int _totalPoints = 0; // Total points variable

  @override
  void initState() {
    super.initState();
    _calculateTotals(); // Calculate total amount and points when the screen is loaded
  }

  // Function to calculate the total amount and total points of all items in the cart
  Future<void> _calculateTotals() async {
    final cartItems = await cartCollection.get();
    double totalAmount = 0.0;
    int totalPoints = 0;

    for (var doc in cartItems.docs) {
      totalAmount += (doc['price'] * doc['quantity']).toDouble(); // Total amount as double

      // Handle points as int, ensure correct casting
      num pointsValue = doc['points'];
      totalPoints += (pointsValue * doc['quantity']).toInt(); // Explicitly cast to int
    }

    setState(() {
      _totalAmount = totalAmount; // Update the total amount
      _totalPoints = totalPoints; // Update the total points
    });
  }

  // Function to delete an item from the cart
  Future<void> _deleteItem(String docId, String name) async {
    try {
      await cartCollection.doc(docId).delete(); // Delete the item
      _calculateTotals(); // Recalculate the totals after deletion

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name has been removed from the cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }

  // Function to move all items from cart to history and clear the cart
  Future<void> _checkout() async {
    try {
      final cartItems = await cartCollection.get();

      if (cartItems.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items in the cart to checkout')),
        );
        return;
      }

      // Prepare arrays for storing purchase session data
      List<String> imageUrls = [];
      List<String> names = [];
      List<String> descriptions = [];
      List<double> prices = [];
      List<int> quantities = [];
      List<int> points = []; // Points as int

      // Loop through each cart item and add to the arrays
      for (var doc in cartItems.docs) {
        var data = doc.data() as Map<String, dynamic>;
        imageUrls.add(data['imageUrl'] ?? '');
        names.add(data['name'] ?? '');
        descriptions.add(data['description'] ?? '');
        prices.add((data['price'] ?? 0.0).toDouble()); // Ensure price is double
        quantities.add(data['quantity'] ?? 1); // Quantities as int

        // Handle points casting
        num pointsValue = data['points']; // Capture points value as num
        points.add((pointsValue).toInt()); // Convert points to int
      }

      // Create a new document in the 'history' collection with these arrays
      await historyCollection.add({
        'imageUrls': imageUrls,
        'names': names,
        'descriptions': descriptions,
        'prices': prices,
        'quantities': quantities,
        'points': points,
        'totalAmount': _totalAmount, // Store the total amount for reference
        'totalPoints': _totalPoints, // Store the total points for reference
        'timestamp': FieldValue.serverTimestamp(), // To track when the purchase was made
      });

      // Clear the cart after checkout
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in cartItems.docs) {
        batch.delete(cartCollection.doc(doc.id)); // Remove from cart
      }
      await batch.commit();

      // Clear total amount and points after checkout
      setState(() {
        _totalAmount = 0.0;
        _totalPoints = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout successful. Items moved to history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to checkout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1B), // Background color
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFF1E1C1B), // Match app bar with background
        elevation: 0, // Remove shadow
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cartCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var cartItems = snapshot.data!.docs;

                if (cartItems.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items in the cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: const Color.fromARGB(38, 255, 255, 255), // Item background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Border radius
                      ),
                      child: ListTile(
                        leading: Image.network(
                          item['imageUrl'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold, // Bold product name
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['description'],
                              style: const TextStyle(color: Color(0xFFFFFFFF)), // Font color (white)
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text(
                                  'Price: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Bold key
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  '\$${item['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFFFFFFFF)), // Normal value
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Quantity: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Bold key
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(color: Color(0xFFFFFFFF)), // Normal value
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Points: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Bold key
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  '${item['points']}',
                                  style: const TextStyle(color: Color(0xFFFFFFFF)), // Points value
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red), // Delete icon
                          onPressed: () => _deleteItem(item.id, item['name']), // Delete the item
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Display Total Amount and Total Points
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Total Amount: \$${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Total Points: $_totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Checkout Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea( // Using SafeArea to prevent overflow
              child: ElevatedButton.icon(
                onPressed: _checkout, // Checkout action
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA5060D), // Red color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Button border radius
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15), // Full width button
                  minimumSize: const Size(double.infinity, 50), // Full width button
                ),
                icon: const Icon(Icons.shopping_cart), // Optional icon
                label: const Text(
                  'Checkout',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18), // Button text color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
