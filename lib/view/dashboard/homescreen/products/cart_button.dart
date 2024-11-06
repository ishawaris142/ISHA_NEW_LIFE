import 'package:flutter/material.dart';

class AddToCartButton extends StatelessWidget {
  final int quantity;
  final int availableQuantity;
  final VoidCallback onAddToCart;

  const AddToCartButton({
    Key? key,
    required this.quantity,
    required this.availableQuantity,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return availableQuantity > 0
        ? ElevatedButton(
            onPressed: quantity <= availableQuantity ? onAddToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 172, 31, 37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        : const Text(
            "Out of Stock",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          );
  }
}
