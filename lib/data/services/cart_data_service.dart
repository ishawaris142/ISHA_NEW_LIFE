// lib/services/cart_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch main product data from Firestore
  Future<List<QueryDocumentSnapshot>> getProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('cart_data').get();
    return snapshot.docs;
  }

  // Fetch models for a specific product
  Future<List<QueryDocumentSnapshot>> getModels(String productId) async {
    QuerySnapshot snapshot = await _firestore.collection('cart_data').doc(productId).collection('Models').get();
    return snapshot.docs;
  }

  // Fetch public download URL for image stored in Firebase Storage
  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching download URL: $e");
      return ''; // Return an empty string if there's an error
    }
  }
}