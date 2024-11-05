import 'package:flutter/material.dart';

class Convertpoints extends StatefulWidget {
  const Convertpoints({super.key});

  @override
  State<Convertpoints> createState() => _ConvertpointsState();
}

class _ConvertpointsState extends State<Convertpoints> {
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