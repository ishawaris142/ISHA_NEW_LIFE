import 'package:flutter/material.dart';

class Newupdates extends StatefulWidget {
  const Newupdates({super.key});

  @override
  State<Newupdates> createState() => _NewupdatesState();
}

class _NewupdatesState extends State<Newupdates> {
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