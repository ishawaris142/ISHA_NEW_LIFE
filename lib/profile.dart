// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
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
                 Image(image: AssetImage("assets/profilelogout.png"),)
                ],
              ),
            ),
            SizedBox(height: 17,),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/Kid.png"),
              ),
              title: Text("Ahmad Hassan",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
              subtitle: Row(
                children: [
                  Icon(Icons.access_time_filled,color: Colors.white,),
                  Text("Mechanics Account",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.white))
                ],
              ),
              
              trailing: Image.asset("assets/BiSolidEditAlt.png")
              ),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.only(left: 25),
                child: Column(
                 
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mail_outline,color: const Color.fromARGB(255, 211, 35, 23),),
                        SizedBox(width: 3,),
                        Text("ahmahhassan123@gmail.com",style: TextStyle(color: Colors.white,fontSize: 16),)
                      ],
                    ),
                    SizedBox(height: 15),
                     Row(
                      children: [
                        Icon(Icons.phone,color: const Color.fromARGB(255, 211, 35, 23),),
                        SizedBox(width: 3,),
                        Text("0301 1234 567",style: TextStyle(color: Colors.white,fontSize: 16),)
                      ],
                    ),
                     SizedBox(height: 15),
                     Row(
                      children: [
                        Icon(Icons.credit_card_rounded,color: const Color.fromARGB(255, 211, 35, 23),),
                        SizedBox(width: 3,),
                        Text("35123-1234567-8",style: TextStyle(color: Colors.white,fontSize: 16),)
                      ],
                    ),
                     SizedBox(height: 15),
                     Row(
                      children: [
                        Icon(Icons.location_on_outlined,color: const Color.fromARGB(255, 211, 35, 23),),
                        SizedBox(width: 3,),
                        Text("39-CCA,DHAPhase 8-Ex Park View, Lahore",style: TextStyle(color: Colors.white,fontSize: 16),)
                      ],
                    )
                  ],
                ),
              )
          ],
       )
     )
    );
  }
}