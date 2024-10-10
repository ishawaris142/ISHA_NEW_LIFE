// ignore_for_file: prefer_const_constructors

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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
                      // pageController.jumpToPage(currentIndex);

        },
        selectedItemColor: Colors.red,  // Color when selected
        unselectedItemColor: Colors.white,  // Color when not selected
        backgroundColor: Colors.black, // Background color of bottom bar
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        items: [
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == 0 ? Colors.red : Colors.transparent,
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "assets/Home.png", // Replace with your Home icon
                width: 28,  // Ensure the size fits the container
                height: 28, // Adjust the size to fit within the circle
                fit: BoxFit.contain, // Ensures the icon fits well
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
              child: Text("F",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
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
                "assets/Group 2.png",  // Replace with your Account icon
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
                "assets/TbListDetails.png",  // Replace with your Profile icon
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),

      // Body of the page to show the pages in PageView
      body:
         pages[currentIndex],
      //  PageView(
      //   controller: pageController,
      //   onPageChanged: (value) {
      //     setState(() {
      //       currentIndex = value;
      //     });
      //   },
      //   children: pages,
      // ),
      backgroundColor: Colors.amber,
    );
  }
}