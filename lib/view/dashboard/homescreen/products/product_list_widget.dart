import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'product_card_widget.dart';

class ProductListWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> products;
  final Map<String, Future<String>?> imageUrls;
  final Map<String, int> selectedIndexes;
  final Function(String) onProductTap;

  const ProductListWidget({
    Key? key,
    required this.products,
    required this.imageUrls,
    required this.selectedIndexes,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      padding: EdgeInsets.only(top: 5.h, bottom: 200.h),
      itemBuilder: (context, index) {
        var product = products[index];
        return ProductCardWidget(
          product: product,
          imageUrl: imageUrls[product.id],
          selectedIndex: selectedIndexes[product.id] ?? 0,
          onProductTap: () => onProductTap(product.id),
        );
      },
    );
  }
}
