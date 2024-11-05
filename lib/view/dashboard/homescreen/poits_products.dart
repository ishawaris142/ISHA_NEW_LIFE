import 'package:flutter/material.dart';

class Pointsproduct extends StatefulWidget {
  const Pointsproduct({super.key});

  @override
  State<Pointsproduct> createState() => _PointsproductState();
}

class _PointsproductState extends State<Pointsproduct> {
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