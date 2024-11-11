import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CartItemsFetching {
  List<QueryDocumentSnapshot> cartItems = [];
  Map<String, int> quantities = {};
  Map<String, int> availableQuantities = {};
  Map<String, Future<String>?> imageUrls = {};

  Future<void> fetchCartItems() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      List<QueryDocumentSnapshot> fetchedCartItems = snapshot.docs;
      Map<String, int> fetchedQuantities = {};
      Map<String, Future<String>?> fetchedImageUrls = {};
      Map<String, int> fetchedAvailableQuantities = {};

      for (var item in fetchedCartItems) {
        String itemId = item.id;

        int availableQuantity = 1;
        final itemData = item.data() as Map<String, dynamic>?;

        if (itemData != null && itemData.containsKey('availableQuantity')) {
          availableQuantity = itemData['availableQuantity'] as int;
        }

        fetchedAvailableQuantities[itemId] = availableQuantity;
        fetchedQuantities[itemId] = item.get('quantity') ?? 1;
        fetchedImageUrls[itemId] = item.get('imageUrl') != null
            ? _getDownloadUrl(item.get('imageUrl'))
            : Future.value('');
      }

      cartItems = fetchedCartItems;
      quantities = fetchedQuantities;
      imageUrls = fetchedImageUrls;
      availableQuantities = fetchedAvailableQuantities;
    }
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching download URL: $e");
      return '';
    }
  }
}
