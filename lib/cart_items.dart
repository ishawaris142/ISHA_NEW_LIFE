import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CollectionReference historyCollection = FirebaseFirestore.instance.collection('history');
  double _totalAmount = 0.0;
  int _totalPoints = 0;

  // Function to get the current user ID
  String? getUserID() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  Future<void> _calculateTotals() async {
    String? userId = getUserID();
    if (userId != null) {
      final cartItems = await FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').get();
      double totalAmount = 0.0;
      int totalPoints = 0;

      for (var doc in cartItems.docs) {
        totalAmount += (doc['price'] * doc['quantity']).toDouble();
        num pointsValue = doc['points'];
        totalPoints += (pointsValue * doc['quantity']).toInt();
      }

      setState(() {
        _totalAmount = totalAmount;
        _totalPoints = totalPoints;
      });
    }
  }

  Future<void> _deleteItem(String docId, String name) async {
    String? userId = getUserID();
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').doc(docId).delete();
        _calculateTotals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name has been removed from the cart')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $e')),
        );
      }
    }
  }

  Future<void> _checkout() async {
    String? userId = getUserID();
    if (userId != null) {
      final cartItems = await FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').get();
      if (cartItems.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items in the cart to checkout')),
        );
        return;
      }

      List<String> imageUrls = [];
      List<String> names = [];
      List<String> descriptions = [];
      List<double> prices = [];
      List<int> quantities = [];
      List<int> points = [];

      for (var doc in cartItems.docs) {
        var data = doc.data() as Map<String, dynamic>;
        imageUrls.add(data['imageUrl'] ?? '');
        names.add(data['name'] ?? '');
        descriptions.add(data['description'] ?? '');
        prices.add((data['price'] ?? 0.0).toDouble());
        quantities.add(data['quantity'] ?? 1);
        num pointsValue = data['points'];
        points.add((pointsValue).toInt());
      }

      await historyCollection.add({
        'imageUrls': imageUrls,
        'names': names,
        'descriptions': descriptions,
        'prices': prices,
        'quantities': quantities,
        'points': points,
        'totalAmount': _totalAmount,
        'totalPoints': _totalPoints,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId
      });

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in cartItems.docs) {
        batch.delete(FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').doc(doc.id));
      }
      await batch.commit();

      setState(() {
        _totalAmount = 0.0;
        _totalPoints = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout successful. Items moved to history')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userId = getUserID();
    if (userId == null) {
      return const Center(
        child: Text('You need to be logged in to view the cart.'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1B),
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFF1E1C1B),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').snapshots(),
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
                      color: const Color.fromARGB(38, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['description'],
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text(
                                  'Price: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  '\$${item['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Quantity: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Points: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  '${item['points']}',
                                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item.id, item['name']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA5060D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  'Checkout',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
