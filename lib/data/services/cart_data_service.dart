// File: cart_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Fetch main product data from Firestore
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('cart_data').get();
      return snapshot.docs;
    } catch (e) {
      print('Error fetching products: $e');
      return []; // Return an empty list if there's an error
    }
  }

  /// Fetch models for a specific product
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getModels(
      String productId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('cart_data')
          .doc(productId)
          .collection('Models')
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error fetching models for product $productId: $e');
      return []; // Return an empty list if there's an error
    }
  }

  /// Fetch public download URL for image stored in Firebase Storage
  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = _storage.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error fetching download URL: $e");
      return '';
    }
  }

  /// Add a product to the user's cart
  Future<void> addToCart({
    required String productId,
    required String category,
    required List<String> selectedModel,
    required List<String> selectedDescription,
    required List<int> selectedPrice,
    required String imageUrl,
    required int quantity,
  }) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        // Resolve the image URL
        String resolvedImageUrl = await getDownloadUrl(imageUrl);

        // Prepare the cart item data
        Map<String, dynamic> cartItem = {
          'productId': productId,
          'category': category,
          'models': selectedModel,
          'descriptions': selectedDescription,
          'prices': selectedPrice,
          'quantity': quantity,
          'imageUrl': resolvedImageUrl,
          'timestamp': FieldValue.serverTimestamp(), // Optional: to sort cart items
        };

        // Add the cart item to Firestore under the user's cart collection
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .add(cartItem);

        print('Product added to cart successfully.');
      } catch (e) {
        print('Error adding product to cart: $e');
        throw Exception('Failed to add product to cart.');
      }
    } else {
      print('User not logged in.');
      throw Exception("User not logged in");
    }
  }

  /// Optional: Fetch cart items for the current user
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCartItems() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .orderBy('timestamp', descending: true)
            .get();
        return snapshot.docs;
      } catch (e) {
        print('Error fetching cart items: $e');
        return [];
      }
    } else {
      print('User not logged in.');
      return [];
    }
  }

  /// Optional: Remove an item from the cart
  Future<void> removeFromCart(String cartItemId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(cartItemId)
            .delete();
        print('Cart item removed successfully.');
      } catch (e) {
        print('Error removing cart item: $e');
        throw Exception('Failed to remove cart item.');
      }
    } else {
      print('User not logged in.');
      throw Exception("User not logged in");
    }
  }

  /// Optional: Update the quantity of a cart item
  Future<void> updateCartItemQuantity(String cartItemId, int newQuantity) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(cartItemId)
            .update({'quantity': newQuantity});
        print('Cart item quantity updated successfully.');
      } catch (e) {
        print('Error updating cart item quantity: $e');
        throw Exception('Failed to update cart item quantity.');
      }
    } else {
      print('User not logged in.');
      throw Exception("User not logged in");
    }
  }
}
