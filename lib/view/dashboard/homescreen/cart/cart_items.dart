import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../../../../data/services/cart_data_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  double _totalAmount = 0.0;
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

  void _calculateTotals() {
    double totalAmount = 0.0;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.red,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backk.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 150),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboardscreen(),)),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Cart",
                      style: TextStyle(fontSize: 19, color: Colors.white),
                    ),
                    Spacer(),
                  ],
                ),
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(child: Text('No items in the cart', style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      return CustomButton(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 8, 8, 8),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color.fromARGB(255, 97, 92, 86),
                          ),
                        ),
                        child: ListTile(
                          leading: FutureBuilder<String>(
                            future: _cartService.getDownloadUrl(item['imageUrl']), // Make sure this is a String
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error, color: Colors.red),
                                );
                              } else {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(snapshot.data!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Price: Rs. ${item['price']} x ${item['quantity']}',
                            style: const TextStyle(color: Colors.white),
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
                SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 67, 60, 60),borderRadius: BorderRadius.circular(10)),
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
                           //  const SizedBox(height: 60),
                              CustomButton(
                                height: 50,
                                width: 400,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 165, 6, 13),border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                  child: const Text(
                    'Checkout',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                                ),
                                onTap: () {
                  // Checkout logic can be added here
                                },
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
     
    );
  }
}
