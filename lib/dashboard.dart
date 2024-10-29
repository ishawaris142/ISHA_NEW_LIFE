import 'package:flutter/material.dart';
import 'package:red_coprative/account.dart';
import 'package:red_coprative/feeds.dart';
import 'package:red_coprative/homescreen.dart';
import 'package:red_coprative/profile.dart';

import 'package:red_coprative/qrcodescreen.dart'; // Import your QR screen

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  int currentIndex = 0;

  // Pages to be displayed in PageView
  final pages = [
    Homescreen(),
    Feedsscreen(),
    Qrscreen(), // Add your QR screen here in the middle
    Accountscreen(),
    Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          // Custom bottom navigation bar with concave shape
          CustomPaint(
            painter: BottomNavPainter(),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                selectedItemColor: Colors.red,
                unselectedItemColor: Colors.white,
                backgroundColor: Colors.red[700],
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: _buildNavItem("assets/nav1.png", 0),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItem("assets/nav2.png", 1),
                    label: "Feeds",
                  ),
                  BottomNavigationBarItem(
                    icon: _buildQrNavItem(), // Middle QR item
                    label: "Scan QR Code",
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItem("assets/nav3.png", 3),
                    label: "Support",
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItem("assets/nav4.png", 4),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each navigation item
  Widget _buildNavItem(String asset, int index) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentIndex == index ? const Color.fromARGB(255, 165, 54, 54).withOpacity(0.2) : Colors.transparent,
      ),
      padding: EdgeInsets.all(8),
      child: Image.asset(
        asset,
        width: 28,
        height: 25,
        fit: BoxFit.contain,
      ),
    );
  }

  // Helper method to build the QR navigation item with unique styling
  Widget _buildQrNavItem() {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = 2; // Navigate to QR screen
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Image.asset(
          "assets/navQR.png",
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}

// Custom painter for concave shape in bottom navigation bar
class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red[700]!;
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width * 0.35, 0);

    // Concave curve under QR code
    path.quadraticBezierTo(
      size.width * 0.5, -30, // Control point
      size.width * 0.65, 0,  // End point
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
