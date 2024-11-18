import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';

class Feedsscreen extends StatefulWidget {
  const Feedsscreen({super.key});

  @override
  State<Feedsscreen> createState() => _FeedsscreenState();
}

class _FeedsscreenState extends State<Feedsscreen> {
  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return WillPopScope(
       onWillPop: () async {
        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Dashboardscreen()),
                                (Route) => false,
                          );
      return true; 
    },
      child: Scaffold(
       body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/backk.png"),fit: BoxFit.fill)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Feed Screen",style: TextStyle(fontSize: 40,color: Colors.white),)
          ],
        ),
       ),
      ),
    );
  }
}