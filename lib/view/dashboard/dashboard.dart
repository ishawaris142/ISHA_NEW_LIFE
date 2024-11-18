import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:red_coprative/constant/static_veriable.dart';
import 'package:red_coprative/view/dashboard/supportscreen.dart';
import 'package:red_coprative/view/dashboard/feeds.dart';
import 'package:red_coprative/view/dashboard/homescreen/homescreen.dart';
import 'package:red_coprative/view/dashboard/profile.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({Key? key}) : super(key: key);

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const Homescreen(),
    const Feedsscreen(),
    const Supportscreen(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: pages[currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomAppBar(
          color: const Color.fromARGB(255, 172, 31, 37),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildBottomNavItem("assets/nav1.png", 'Home', 0),
                _buildBottomNavItem("assets/nav2.png", 'Feeds', 1),
                
                GestureDetector(
                  onTap: () {
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 15,
                        child: Image.asset(
                          "assets/navQR.png",
                          height: 24,
                        ),
                      ),
                      const Text(
                        "Scan QR",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                _buildBottomNavItem("assets/nav3.png", 'Support', 2),
                _buildBottomNavItem("assets/nav4.png", 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String image, String label, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Dashboardscreen()),
            (route) => false,
          );
        }
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 24),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
