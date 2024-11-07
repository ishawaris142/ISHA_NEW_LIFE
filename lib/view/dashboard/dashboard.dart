import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:red_coprative/constant/static_veriable.dart';
import 'package:red_coprative/view/dashboard/account.dart';
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
    const Accountscreen(),
    const Profilescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FloatingActionButton(
          onPressed: () {
            // // Navigate to ProductView with dummy productData
            // final productData = Homescreenmodelclass(
            //   image: "assets/sample_image.png",
            //   text: "Sample Product",
            // );
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => ProductView(productData: productData),
            // ));
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: Image.asset(
              "assets/navQR.png",
              height: 48,
            ),
          ),
        ),
      ),
      body:pages[currentIndex],
      //  Navigator(
      //   onGenerateRoute: (settings) {
      //     return MaterialPageRoute(
      //       builder: (context) => 
      //     );
      //   },
      // ),
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomAppBar(
              elevation: 0,
              color: const Color.fromARGB(255, 172, 31, 37),
              shape: const CircularNotchedRectangle(),
              notchMargin: 5.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildBottomNavItem("assets/nav1.png", 'Home', 0),
                    _buildBottomNavItem("assets/nav2.png", 'Feeds', 1),
                    const SizedBox(width: 65),
                    _buildBottomNavItem("assets/nav3.png", 'Support', 2),
                    _buildBottomNavItem("assets/nav4.png", 'Profile', 3),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 19,
            child: const Text(
              "Scan QR Code",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(String image, String label, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
         
   if(index==0){
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Dashboardscreen()),
                        (Route)=>false,
                        );
   }
      setState(() {
        
                               currentIndex = index;
      } );},
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
