import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/cart_data_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  double _totalAmount = 0.0;
  int _totalPoints = 0;
  List<QueryDocumentSnapshot> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      setState(() {
        cartItems = snapshot.docs;
        _calculateTotals();
      });
    }
  }

  Future<void> _calculateTotals() async {
    double totalAmount = 0.0;
    int totalPoints = 0;

    for (var item in cartItems) {
      int price = item['price'];
      int quantity = item['quantity'];
      totalAmount += price * quantity;
    }

    setState(() {
      _totalAmount = totalAmount;
    });
  }

  Future<void> _deleteItem(String docId, String name) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(docId)
          .delete();

      _fetchCartItems(); // Refresh cart items after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name has been removed from the cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1B),

      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backk.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: cartItems.isEmpty
            ? const Center(
          child: Text(
            "No items in the cart",
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
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
                leading: FutureBuilder<String>(
                  future: _cartService.getDownloadUrl(item['imageUrl']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Icon(Icons.error, color: Colors.red);
                    }
                    return Image.network(
                      snapshot.data!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    );
                  },
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
                      'Price: Rs. ${item['price']}',
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                    Text(
                      'Quantity: ${item['quantity']}',
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
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
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total Amount: Rs. ${_totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Checkout logic can be added here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA5060D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}