import 'package:flutter/material.dart';

class Popularproduct extends StatefulWidget {
  const Popularproduct({super.key});

  @override
  State<Popularproduct> createState() => _PopularproductState();
}

class _PopularproductState extends State<Popularproduct> {
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