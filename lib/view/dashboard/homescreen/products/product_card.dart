import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/homescreen/products/cart_button.dart';
import 'product_image.dart';
import 'product_info.dart';
import 'quantity_selector.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final Future<String>? imageUrl;
  final String category;
  final String description;
  final int quantity;
  final int availableQuantity;
  final int price;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductCard({
    Key? key,
    required this.productId,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.quantity,
    required this.availableQuantity,
    required this.price,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 8, 8, 8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ProductImage(imageUrl: imageUrl),
          ProductInfo(category: category, description: description),
          QuantitySelector(
            quantity: quantity,
            availableQuantity: availableQuantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
          AddToCartButton(
            quantity: quantity,
            availableQuantity: availableQuantity,
            onAddToCart: onAddToCart,
          ),
        ],
      ),
    );
  }
}
