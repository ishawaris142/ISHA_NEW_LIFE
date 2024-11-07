import 'package:cloud_firestore/cloud_firestore.dart';

class PopularProductsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getPopularProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore.collection('popular_products').get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching popular products: $e");
      return [];
    }
  }
}
