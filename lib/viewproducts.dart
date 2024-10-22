import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cart_provider.dart';
import 'login.dart';

class ViewproductScreen extends StatefulWidget {
  const ViewproductScreen({super.key});

  @override
  State<ViewproductScreen> createState() => _ViewproductScreenState();
}

class _ViewproductScreenState extends State<ViewproductScreen> {
  final CollectionReference productsCollection = FirebaseFirestore.instance.collection('cart_data');

  // Function to get the current user ID
  String? getUserID() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error fetching download URL: $e");
      return '';
    }
  }

  int calculatePoints(int price, int quantity) {
    int pointsPerItem = (price / 1000).floor();
    return pointsPerItem * quantity;
  }

  Future<void> addToCart(String productId, String name, String description, int price, int quantity, int points, String imageUrl) async {
    String? userId = getUserID();
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').add({
          'productId': productId,
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
          'totalPrice': price * quantity,
          'points': points,
          'imageUrl': imageUrl
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name has been added to cart with $points points'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add $name to cart: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  // Function to show the contact options in a modal bottom sheet
  void _showCallInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Call Support',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text('Support: +1234567890', style: TextStyle(color: Colors.white)),
                subtitle: Text('Available 24/7', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _makePhoneCall('+1234567890'); // Replace with your support number
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Call Now', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Close the bottom sheet
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Image.asset("assets/profilelogout.png"),
                    onPressed: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: productsCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return const Center(child: Text("No products available", style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return ProductItem(
                        product: product,
                        getDownloadUrl: getDownloadUrl,
                        calculatePoints: calculatePoints,
                        addToCart: addToCart,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating action button to open the call info
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCallInfo(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.phone),
      ),
    );
  }
}

class ProductItem extends StatefulWidget {
  final QueryDocumentSnapshot product;
  final Future<String> Function(String) getDownloadUrl;
  final int Function(int, int) calculatePoints;
  final Future<void> Function(String, String, String, int, int, int, String) addToCart;

  const ProductItem({
    Key? key,
    required this.product,
    required this.getDownloadUrl,
    required this.calculatePoints,
    required this.addToCart,
  }) : super(key: key);

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  Future<String>? _downloadUrlFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future to avoid fetching the image URL multiple times
    _downloadUrlFuture = widget.getDownloadUrl(widget.product['imageUrl']);
  }

  @override
  Widget build(BuildContext context) {
    int price = widget.product['price'];
    int availableQuantity = widget.product['quantity'];

    return FutureBuilder<String>(
      future: _downloadUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red, size: 50),
              title: Text(
                widget.product['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text(
                "Failed to load image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        String downloadUrl = snapshot.data!;

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          downloadUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.product['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product['description'],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\$${widget.product['price']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              int quantity = cartProvider.getQuantity(widget.product.id);
              int totalPoints = widget.calculatePoints(price, quantity);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 0, right: 8.0),
                  leading: Container(
                    height: 100,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: downloadUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.product['description'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            "\$${widget.product['price']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.blur_circular_rounded,
                            size: 16,
                            color: Color.fromARGB(255, 165, 6, 13),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              "$totalPoints pts",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.amber),
                    onPressed: () {
                      int points = widget.calculatePoints(widget.product['price'], quantity);
                      widget.addToCart(
                        widget.product.id,
                        widget.product['name'],
                        widget.product['description'],
                        widget.product['price'],
                        quantity,
                        points,
                        downloadUrl,
                      );
                    },
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                        onPressed: () {
                          if (quantity > 1) {
                            cartProvider.updateQuantity(widget.product.id, quantity - 1); // Update quantity
                          }
                        },
                      ),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                        onPressed: () {
                          if (quantity < availableQuantity) {
                            cartProvider.updateQuantity(widget.product.id, quantity + 1); // Update quantity
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
