import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int availableQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    required this.availableQuantity,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: quantity > 1 ? onDecrement : null,
          child: Image.asset("assets/negative.png", height: 22),
        ),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        GestureDetector(
          onTap: quantity < availableQuantity ? onIncrement : null,
          child: Image.asset("assets/positive.png", height: 22),
        ),
      ],
    );
  }
}
