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

  // Function to move an item from cart to history and delete it from cart
  Future<void> _buyItem(String docId, Map<String, dynamic> itemData, String name) async {
    try {
      // Move the item to the 'history' collection
      await historyCollection.add(itemData);

      // Delete the item from the 'cart' collection
      await cartCollection.doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name has been bought and moved to history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to buy item: $e')),
      );
    }
  }

  // Function to delete all items from the cart
  Future<void> _deleteAllItems() async {
    final cartItems = await cartCollection.get();
    for (var doc in cartItems.docs) {
      await cartCollection.doc(doc.id).delete();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All items have been removed from the cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1B), // Background color of the page
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
                                  style: const TextStyle(color: Color(0xFFFFFFFF)), // Normal value
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.shopping_bag, color: Colors.green),
                          onPressed: () => _buyItem(item.id, item.data() as Map<String, dynamic>, item['name']), // Buy the item
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Buttons: Delete All and Buy All
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea( // Using SafeArea to prevent overflow
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _deleteAllItems, // Delete all items action
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5060D), // Red color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Button border radius
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Delete All',
                      style: TextStyle(color: Color(0xFFFFFFFF)), // Button text color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Fetch all cart items
                        final cartItems = await cartCollection.get();

                        // Initialize a batch for atomic operations
                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        // Loop through each cart item
                        for (var doc in cartItems.docs) {
                          // Add each item to the history collection
                          batch.set(historyCollection.doc(), doc.data());

                          // Delete each item from the cart collection
                          batch.delete(cartCollection.doc(doc.id));
                        }

                        // Commit the batch operation (moves all items at once)
                        await batch.commit();

                        // Show confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All items have been bought and moved to history')),
                        );

                      } catch (e) {
                        // Show error message if something goes wrong
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to buy all items: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA5060D), // Red color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Button border radius
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Buy All',
                      style: TextStyle(color: Color(0xFFFFFFFF)), // Button text color
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
