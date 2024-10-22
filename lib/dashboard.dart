import 'package:flutter/material.dart';
import 'package:red_coprative/account.dart';
import 'package:red_coprative/feeds.dart';
import 'package:red_coprative/homescreen.dart';
import 'package:red_coprative/profile.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  // Pages to be displayed in PageView
  final pages = [
    Homescreen(),
    Feedsscreen(),
    Accountscreen(),
    Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 0 ? Colors.red : Colors.transparent,
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "assets/Home.png",
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 1 ? Colors.red : Colors.transparent,
              ),
              padding: EdgeInsets.all(8),
              child: Text(
                "F",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            label: "Feeds",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 2 ? Colors.red : Colors.transparent,
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "assets/Group 2.png",
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            label: "Account",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 3 ? Colors.red : Colors.transparent,
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "assets/TbListDetails.png",
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}
