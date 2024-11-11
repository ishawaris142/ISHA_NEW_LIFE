import 'package:flutter/material.dart';

class BundlesProduct extends StatefulWidget {
  const BundlesProduct({super.key});

  @override
  State<BundlesProduct> createState() => _BundlesProductState();
}

class _BundlesProductState extends State<BundlesProduct> {
  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
     body: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/backk.png"),fit: BoxFit.fill)),
     ),
    );
  }
}