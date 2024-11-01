import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/account.dart';
import 'package:red_coprative/view/dashboard/feeds.dart';
import 'package:red_coprative/view/dashboard/homescreen.dart';
import 'package:red_coprative/view/dashboard/profile.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({Key? key}) : super(key: key);

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  int currentIndex = 0;
  final pages = [
    const Homescreen(),
    const Feedsscreen(),
    const Accountscreen(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, // Extends body behind BottomAppBar for transparency
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: FloatingActionButton(
          onPressed: () {
            print('Center QR button tapped');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Image.asset(
              "assets/navQR.png",
              height: 40,
            ),
          ),
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), // Rounded top corners
              topRight: Radius.circular(30),
            ),
            child: BottomAppBar(
              elevation: 0,
              color: const Color.fromARGB(255, 172, 31,37), // Set the color of BottomAppBar directly
              shape: const CircularNotchedRectangle(),
              notchMargin: 5.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildBottomNavItem("assets/nav1.png", 'Home', 0),
                    _buildBottomNavItem("assets/nav2.png", 'Feeds', 1),
                    const SizedBox(width: 65), // Space for the floating button
                    _buildBottomNavItem("assets/nav3.png", 'Support', 2),
                    _buildBottomNavItem("assets/nav4.png", 'Profile', 3),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 19, // Adjust for QR Code text position
            child: const Text(
              "Scan QR Code",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(String image, String label, int index) {
    // ignore: unused_local_variable
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 24),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
