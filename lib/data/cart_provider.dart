import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> _products = [];

  List<QueryDocumentSnapshot> get products => _products;

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  final Map<String, int> _cartItems = {}; // Map of productId and quantity

  // Method to preload product data
  Future<void> preloadProductData() async {
    if (!_isLoaded) {
      try {
        final CollectionReference productsCollection = FirebaseFirestore
            .instance.collection('cart_data');
        QuerySnapshot snapshot = await productsCollection.get();
        _products = snapshot.docs;
        _isLoaded = true;
        notifyListeners();
      } catch (error) {
        print("Error fetching products: $error");
      }
    }
  }

  // Get the quantity of a specific product
  int getQuantity(String productId) {
    return _cartItems[productId] ?? 1; // Default to 1 if not present
  }

  // Update the quantity of a product in the cart
  void updateQuantity(String productId, int quantity) {
    if (quantity > 0) {
      _cartItems[productId] = quantity;
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  // Add a product to the cart with a specific quantity
  void addToCart(String productId, int quantity) {
    if (_cartItems.containsKey(productId)) {
      _cartItems[productId] = _cartItems[productId]! + quantity;
    } else {
      _cartItems[productId] = quantity;
    }
    notifyListeners();
  }

  // Remove a product from the cart
  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  // Get all cart items
  Map<String, int> get cartItems => _cartItems;

  // Function to calculate points based on price and quantity
  int calculatePoints(int price, int quantity) {
    return (price / 1000).floor() * quantity;
  }

  // Checkout logic: update stock in Firestore and remove from cart
  // Checkout logic: update stock in Firestore and remove from cart
  Future<void> checkout(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return; // Handle case when user is not logged in
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    List<String> outOfStockItems = [];
    List<String> successfullyPurchasedItems = [];

    for (String productId in _cartItems.keys) {
      int quantityInCart = _cartItems[productId]!;

      try {
        await firestore.runTransaction((transaction) async {
          // Get product reference from 'cart_data'
          DocumentReference productRef = firestore.collection('cart_data').doc(
              productId);
          DocumentSnapshot productSnapshot = await transaction.get(productRef);

          if (!productSnapshot.exists) {
            throw Exception('Product does not exist.');
          }

          // Get current stock of the product
          int currentStock = productSnapshot['quantity'];

          // CHECK STOCK
          if (currentStock < quantityInCart) {
            // If stock is insufficient for the current user, show "Out of Stock"
            throw Exception("${productSnapshot['name']} is out of stock.");
          }

          // Proceed with the purchase if stock is sufficient

          // If stock is enough, reduce the stock by the quantity being purchased
          int newStock = currentStock - quantityInCart;

          // Update the stock in the database
          transaction.update(productRef, {'quantity': newStock});

          // Remove the product from the user's cart (once purchase is successful)
          DocumentReference userCartRef = firestore.collection('users').doc(
              userId).collection('cart').doc(productId);
          transaction.delete(userCartRef);

          // Add to the successfully purchased list
          successfullyPurchasedItems.add(productSnapshot['name']);
        });
      } catch (e) {
        // If there's an error (out of stock), add to the outOfStockItems list
        outOfStockItems.add(productId);
      }
    }

    // Notify about successful purchases
    if (successfullyPurchasedItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Successfully purchased: ${successfullyPurchasedItems.join(
                  ', ')}'),
          duration: const Duration(seconds: 3),
        ),
      );
      // Remove the purchased items from the local cart
      successfullyPurchasedItems.forEach((productId) {
        removeFromCart(productId); // Local cart clearing after success
      });
    }

    // Notify about out-of-stock items
    if (outOfStockItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Out of stock: ${outOfStockItems.join(', ')}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}