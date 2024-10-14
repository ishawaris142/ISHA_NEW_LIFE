import 'package:flutter/material.dart';

class CartItem {
  final String imageUrl;
  final String name;
  final String description;
  final double price;
  int quantity;
  final int points;

  CartItem({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.points,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Example list of cart items with dummy data
  List<CartItem> cartItems = [
    CartItem(
      imageUrl: 'assets/Kid.png',
      name: 'Wireless Mouse',
      description: 'A high-quality wireless mouse with ergonomic design.',
      price: 25.99,
      quantity: 1,
      points: 120,
    ),
    CartItem(
      imageUrl: 'assets/technology (1).png',
      name: 'Gaming Headset',
      description: 'A surround-sound gaming headset with a built-in microphone.',
      price: 49.99,
      quantity: 2,
      points: 300,
    ),
    CartItem(
      imageUrl: 'assets/Kid.png',
      name: 'Mechanical Keyboard',
      description: 'A mechanical keyboard with RGB lighting and tactile feedback.',
      price: 89.99,
      quantity: 1,
      points: 450,
    ),
    CartItem(
      imageUrl: 'assets/Kid.png',
      name: 'USB-C Hub',
      description: 'A multi-port USB-C hub for connecting various devices.',
      price: 39.99,
      quantity: 3,
      points: 200,
    ),
    CartItem(
      imageUrl: 'assets/Kid.png',
      name: 'Portable SSD',
      description: 'A 1TB portable SSD with fast read and write speeds.',
      price: 129.99,
      quantity: 1,
      points: 550,
    ),
  ];

  // Function to delete an item from the cart
  void _deleteItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  // Function to handle the Buy action (for demo purposes)
  void _buyItems() {
    // You can implement your buy functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buy ${cartItems.length} items!')),
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
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: const Color.fromARGB(38, 255, 255, 255), // Item background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Border radius
                  ),
                  child: ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(color: Color(0xFFFFFFFF)), // Font color (white)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(color: Color(0xFFFFFFFF)), // Font color (white)
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Price: \$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFFFFFFFF)), // Font color (white)
                        ),
                        Text(
                          'Quantity: ${item.quantity}',
                          style: const TextStyle(color: Color(0xFFFFFFFF)), // Font color (white)
                        ),
                        Text(
                          'Points: ${item.points}',
                          style: const TextStyle(color: Color(0xFFFFFFFF)), // Font color (white)
                        ),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFA5060D)),
                          onPressed: () => _deleteItem(index), // Delete the item
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Buttons: Delete and Buy
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Perform delete all items action
                    setState(() {
                      cartItems.clear(); // Clear all items from the cart
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5060D), // New red color
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
                  onPressed: _buyItems,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5060D), // New red color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Button border radius
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Buy',
                    style: TextStyle(color: Color(0xFFFFFFFF)), // Button text color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}