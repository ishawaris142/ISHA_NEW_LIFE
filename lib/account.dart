// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:red_coprative/models/accountgridmodelclass.dart';

class Accountscreen extends StatefulWidget {
  const Accountscreen({super.key});

  @override
  State<Accountscreen> createState() => _AccountscreenState();
}

class _AccountscreenState extends State<Accountscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 6),
        margin: EdgeInsets.only(top: 25),
        child: Column(
          children: [
            // Top section with app name and QR code icon
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 Icon(Icons.arrow_back,color: Colors.white,size: 32,),
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
                  const Row(
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
                                  color: Color.fromARGB(255, 165, 6, 13), 
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Lahore",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 12, 12, 12), 
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Mechanics Account",
                              style: TextStyle(
                                color: Color.fromARGB(255, 12, 12, 12), 
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 27),
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
                                  color: Color.fromARGB(255, 165, 6, 13), 
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

            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Cash Withdraw button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade900, 
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
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
                 
                  Container(
                    height: 45, 
                    width: 1,
                    color: Colors.white, 
                  ),
                  // History button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade900, 
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
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

            const SizedBox(height: 24),
            Text(
              "More From ISH",
              style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255)),
            ),

                                   // GridView with Expanded
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 2), 
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 15, 
                  mainAxisSpacing: 1, 
                ),
                itemCount: accountgridmodelclasslist.length,
                itemBuilder: (context, index) {
                  return Container(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  margin: EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(38, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Image.asset("${accountgridmodelclasslist[index].image}"),
                        Text("${accountgridmodelclasslist[index].text}",style: TextStyle(fontSize: 15,color: Colors.white),)
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}