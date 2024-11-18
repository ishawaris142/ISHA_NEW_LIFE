import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';

class Supportscreen extends StatefulWidget {
  const Supportscreen({super.key});

  @override
  State<Supportscreen> createState() => _SupportscreenState();
}

class _SupportscreenState extends State<Supportscreen> {
  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return WillPopScope(
       onWillPop: () async {
        Navigator.pushAndRemoveUntil(
        context,MaterialPageRoute(builder: (context) => const Dashboardscreen()),
       (Route) => false,
                          );
      return true; 
    },
      child: Scaffold(
       body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/backk.png"),fit: BoxFit.fill)),
       ),
      ),
    );
  }
}