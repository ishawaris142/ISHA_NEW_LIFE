// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // PageController to keep track of the current page
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6),
          margin: EdgeInsets.only(top: 25),
          child: Column(
            children: [
              // Top section with app name and QR code icon
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ISH NEW LIFE",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_scanner_sharp,
                      size: 28,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // Profile info card
              Container(
                width: double.infinity,
                color: Colors.white, // Background color of the profile section
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile info row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ahmad Hassan",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 12, 12, 12), // Dark color for the text
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Color.fromARGB(255, 165, 6, 13), // Location icon color
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Lahore",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 12, 12, 12), // Text color
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Mechanics Account",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 12, 12, 12), // Text color
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 27),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "490",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.blur_circular_rounded,
                                    size: 16,
                                    color: Color.fromARGB(255, 165, 6, 13), // Icon color
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "points",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cash Withdraw and History buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(10), // Rounded outer corners
                ),
                child: Row(
                  children: [
                    // Cash Withdraw button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade900, // Same red color
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10), // Rounded left corners
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Cash Withdraw",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Vertical divider
                    Container(
                      height: 45, // Same height as the buttons
                      width: 1,
                      color: Colors.white, // Divider color
                    ),
                    // History button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade900, // Same red color
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10), // Rounded right corners
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "History",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView with Dots Indicator
              const SizedBox(height: 16),
              Container(
                height: 400, // Set a fixed height for the page view
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    Image.asset(
                      "assets/technology.jpg", // First image
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/technology.jpg", // Second image
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      "assets/technology.jpg", // Third image
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Dot Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.red // Active dot color
                          : Colors.grey, // Inactive dot color
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}