import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuantitySelector extends StatefulWidget {
  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int quantity = 1;

  void _incrementQuantity() {
    setState(() {
      quantity += 1;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) quantity -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.remove, color: Colors.white, size: 20.sp),
          onPressed: _decrementQuantity,
        ),
        Text(
          '$quantity',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
          onPressed: _incrementQuantity,
        ),
      ],
    );
  }
}
