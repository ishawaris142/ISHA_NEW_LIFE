import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/account.dart';
import 'package:red_coprative/view/dashboard/feeds.dart';
import 'package:red_coprative/view/dashboard/homescreen.dart';
import 'package:red_coprative/view/dashboard/profile.dart';
import 'package:red_coprative/view/dashboard/qrcodescreen.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  int currentIndex = 0;

  final pages = [
    Homescreen(),
    Feedsscreen(),
    Qrscreen(),
    Accountscreen(),
    Profilescreen(),
  ];

  final List<Widget> items = <Widget>[
    Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset('assets/nav1.png', width: 28, height: 25),
    ),
    Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset('assets/nav2.png', width: 28, height: 25),
    ),
    Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset('assets/navQR.png', width: 28, height: 25),
    ),
    Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset('assets/nav3.png', width: 28, height: 25),
    ),
    Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset('assets/nav4.png', width: 28, height: 25),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        color: Colors.red,
        items: items,
        backgroundColor: Colors.transparent,
        
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        height: 50,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: Container(
        color: Colors.transparent,
        child: pages[currentIndex],
      ),
    );
  }
}
