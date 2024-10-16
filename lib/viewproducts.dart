import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'cart_items.dart'; // Import the CartScreen
import 'account.dart';
import 'login.dart';

class ViewproductScreen extends StatefulWidget {
  const ViewproductScreen({super.key});

  @override
  State<ViewproductScreen> createState() => _ViewproductScreenState();
}

class _ViewproductScreenState extends State<ViewproductScreen> {
  // Reference to the Firestore collection where product data is stored
  final CollectionReference productsCollection = FirebaseFirestore.instance.collection('cart_data');

  // This function retrieves the download URL of an image from Firebase Storage
  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      // Accessing the file using the Firebase Storage reference URL (gs://)
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL(); // Getting the actual HTTP URL
      return downloadUrl;
    } catch (e) {
      print("Error fetching download URL: $e");
      return ''; // Return an empty string if an error occurs
    }
  }

  // This function calculates points based on the price and quantity of the product
  int calculatePoints(int price, int quantity) {
    int pointsPerItem = (price / 1000).floor(); // 1 point per 1000 price
    return pointsPerItem * quantity; // Multiply points by quantity
  }

  // This function adds a product to the cart in Firestore, including the image URL and description
  Future<void> addToCart(String productId, String name, String description, int price, int quantity, int points, String imageUrl) async {
    try {
      // Add the product details to the 'cart' collection in Firestore
      await FirebaseFirestore.instance.collection('cart').add({
        'productId': productId,
        'name': name,
        'description': description, // Adding description to the cart
        'price': price,
        'quantity': quantity,
        'totalPrice': price * quantity,
        'points': points, // Adding points to the cart
        'imageUrl': imageUrl // Adding image URL to the cart
      });
      // Show a confirmation message using Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name has been added to cart with $points points'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show an error message in case of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add $name to cart: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                  // Back button to navigate to the account screen
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Accountscreen()),
                      );
                    },
                  ),
                  // Logout button to navigate to the login screen
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
            // StreamBuilder listens to real-time updates from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: productsCollection.snapshots(), // Listen to snapshots from 'cart_data' collection
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
                    return const Center(child: CircularProgressIndicator()); // Show a loader while waiting for data
                  }

                  var products = snapshot.data!.docs; // Retrieve the documents from Firestore

                  if (products.isEmpty) {
                    return const Center(child: Text("No products available", style: TextStyle(color: Colors.white)));
                  }

                  // Build a list of products
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return ProductItem(
                        product: product, // Pass the product data to the ProductItem widget
                        getDownloadUrl: getDownloadUrl, // Pass the download URL function
                        calculatePoints: calculatePoints, // Pass the points calculation function
                        addToCart: addToCart,  // Pass the addToCart function
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItem extends StatefulWidget {
  final QueryDocumentSnapshot product; // Product data from Firestore
  final Future<String> Function(String) getDownloadUrl; // Function to get the image URL
  final int Function(int, int) calculatePoints; // Function to calculate points
  final Future<void> Function(String, String, String, int, int, int, String) addToCart; // addToCart function with points, description, and imageUrl

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
  int quantity = 1; // Local state for each product's quantity

  @override
  Widget build(BuildContext context) {
    int availableQuantity = widget.product['quantity']; // Retrieve available quantity from Firestore
    int price = widget.product['price']; // Retrieve product price from Firestore
    String gsUrl = widget.product['imageUrl']; // Retrieve the image URL from Firestore

    int totalPoints = widget.calculatePoints(price, quantity); // Calculate total points for the selected quantity

    return FutureBuilder<String>(
      future: widget.getDownloadUrl(gsUrl), // Get the actual image download URL
      builder: (context, AsyncSnapshot<String> downloadSnapshot) {
        if (downloadSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: CircularProgressIndicator()), // Show a loader while the image is loading
          );
        }

        if (downloadSnapshot.hasError || !downloadSnapshot.hasData || downloadSnapshot.data!.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red, size: 50), // Show error if image loading fails
              title: Text(
                widget.product['name'], // Show product name
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

        String downloadUrl = downloadSnapshot.data!; // Get the download URL

        return GestureDetector(
          onTap: () {
            // Show Dialog with product details when product is clicked
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
                          downloadUrl, // Show product image
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.product['name'], // Show product name
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product['description'], // Show product description
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\$${widget.product['price']}", // Show product price
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
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: SizedBox(
                height: 100,
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: downloadUrl, // Display product image using CachedNetworkImage
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()), // Show a loader while loading
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red), // Show error icon on failure
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'], // Display product name
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.product['description'], // Display product description
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
                        "\$${widget.product['price']}", // Display product price
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.blur_circular_rounded,
                        size: 16,
                        color: Color.fromARGB(255, 165, 6, 13),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "$totalPoints pts", // Display calculated points
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevents overflow
                      ),
                    ],
                  ),
                ],
              ),
              // Add to Cart button
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.amber),
                onPressed: () {
                  // Calculate points before adding to cart
                  int points = widget.calculatePoints(widget.product['price'], quantity);

                  // Call the addToCart function with product details, points, and imageUrl
                  widget.addToCart(
                      widget.product.id,              // Product ID
                      widget.product['name'],          // Product name
                      widget.product['description'],   // Product description
                      widget.product['price'],         // Product price
                      quantity,                        // Quantity
                      points,                          // Calculated points
                      downloadUrl                      // Image URL
                  );
                },
              ),
              // Quantity controls
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Decrease quantity button
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--; // Decrease quantity
                        });
                      }
                    },
                  ),
                  // Display current quantity
                  Text(
                    "$quantity",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Increase quantity button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                    onPressed: () {
                      if (quantity < availableQuantity) {
                        setState(() {
                          quantity++; // Increase quantity
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
















