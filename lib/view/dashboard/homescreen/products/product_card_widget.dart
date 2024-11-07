import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quantity_selector.dart';
import 'model_selector.dart';
import 'product_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductCardWidget extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> product;
  final Future<String>? imageUrl;
  final int selectedIndex;
  final VoidCallback onProductTap;

  const ProductCardWidget({
    Key? key,
    required this.product,
    required this.imageUrl,
    required this.selectedIndex,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var models = List<String>.from(product['models'] ?? ['Unknown']);
    var price = product['price'][selectedIndex];
    var quantity = product['quantity'][selectedIndex];
    var description = product['description'][selectedIndex];

    return GestureDetector(
      onTap: onProductTap,
      child: Container(
        margin: EdgeInsets.all(8.r),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(imageUrl: imageUrl),
            SizedBox(height: 8.h),
            Text(product['category'] ?? 'Unknown Category', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            Text(description, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: $price', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                Text('Quantity: $quantity', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
              ],
            ),
            ModelSelector(models: models, selectedIndex: selectedIndex),
            QuantitySelector(),
          ],
        ),
      ),
    );
  }
}
