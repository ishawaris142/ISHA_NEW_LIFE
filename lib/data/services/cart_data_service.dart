import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch main product data from Firestore with specified types
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('cart_data').get();
      return snapshot.docs;
    } catch (e) {
      print('Error fetching products: $e');
      return []; // Return an empty list if there's an error
    }
  }

  // Fetch models for a specific product, specifying types
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getModels(String productId) async {
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

  // Fetch public download URL for image stored in Firebase Storage
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
}