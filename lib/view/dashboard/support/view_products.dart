// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/homescreen.dart';

class Prodectview extends StatefulWidget {
  const Prodectview({super.key});

  @override
  State<Prodectview> createState() => _ProdectviewState();
}

class _ProdectviewState extends State<Prodectview> {
  var dropdownvalue = 'Honda City';   

  
  var items = [    
    'Honda City',
    'Yahama',
    'Suzuki',
    'Alto',
    'Waganar',
  ];
  @override
  Widget build(BuildContext context) {
   
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backk.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            
            
              
             
               Row(
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Products",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                ],
              ),
            
           
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  // return ListTile(
                  //   leading: CustomButton(
                  //     height: height * 0.2,
                  //     width: 100,
                  //     decoration: BoxDecoration(
                  //       image: DecorationImage(
                  //         image: AssetImage("assets/airfilter.png"),
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //   ),
                  //   title: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text("Air Filter"),
                  //       SizedBox(height: 4),
                  //       Text("View More"),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text("Select Model"),
                  //           Text("Price (Rs.)"),
                  //         ],
                  //       ),
                  //       SizedBox(height: 10),
                  //       Row(
                  //         children: [
                  //           Expanded(
                  //             child: TextField(
                  //               controller: searchbar,
                  //               style: const TextStyle(color: Colors.white),
                  //               decoration: InputDecoration(
                  //                 hintText: "Search",
                  //                 hintStyle: const TextStyle(
                  //                   color: Color.fromARGB(128, 255, 255, 255),
                  //                 ),
                  //                 contentPadding: const EdgeInsets.symmetric(
                  //                   vertical: 10,
                  //                   horizontal: 10,
                  //                 ),
                  //                 border: OutlineInputBorder(
                  //                   borderRadius: BorderRadius.circular(10),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           IconButton(
                  //             onPressed: () {
                  //               print("Search");
                  //             },
                  //             icon: const Icon(
                  //               Icons.search,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //           CustomButton(
                  //             height: height * 0.1,
                  //             width: 80,
                  //             decoration: BoxDecoration(
                  //               color: Colors.amber,
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             child: Center(child: Text("850")),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 10),
                  //       Row(
                  //         children: [
                  //           Container(
                  //             height: 40,
                  //             width: 100,
                  //             decoration: BoxDecoration(
                  //               color: Colors.amber,
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //               children: [
                  //                 GestureDetector(
                  //                   onTap: () {
                  //                     print("Decrease quantity");
                  //                   },
                  //                   child: Image.asset(
                  //                     "assets/negative.png",
                  //                     height: 18,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   "1",
                  //                   style: TextStyle(color: Colors.white),
                  //                 ),
                  //                 GestureDetector(
                  //                   onTap: () {
                  //                     print("Increase quantity");
                  //                   },
                  //                   child: Image.asset(
                  //                     "assets/positive.png",
                  //                     height: 18,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //           SizedBox(width: 10),
                  //           CustomButton(
                  //             onTap: () {
                  //               print("Add to Cart Clicked");
                  //             },
                  //             decoration: BoxDecoration(
                  //               image: DecorationImage(
                  //                 image: AssetImage("assets/add cart.png"),
                  //               ),
                  //             ),
                  //             height: 40,
                  //             width: 40,
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // );
                   return CustomButton(
                     
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                      padding: EdgeInsets.symmetric(vertical: 7,horizontal: 8),
                      decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: 119,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/airfilter.png"),fit: BoxFit.fill)),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                           crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Air Filter",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),),
                             Text("View more",style: TextStyle(fontSize: 8,fontWeight: FontWeight.w400,color: const Color.fromARGB(255, 172, 31, 37)),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              
                                children: [
                                  Text("Select Model",style: TextStyle(fontSize: 8,color: Colors.white,fontWeight: FontWeight.w400)),
                                SizedBox(width: 130),
                                   Text("Price (Rs.)",style: TextStyle(fontSize: 8,color: Colors.white,fontWeight: FontWeight.w400),),
                                ],
                              ),
                              Row(
                                
                                children: [
                                  SizedBox(
                                   width: 140,
                                    //flex: 2,
                                   height: 50,
                                    child: DropdownButtonFormField(
                                      
                                      value: dropdownvalue,
                                      dropdownColor: Colors.red,
                                      focusColor: Colors.black,
                                      icon: const Icon(Icons.keyboard_arrow_down), 
                                     decoration: InputDecoration(
                                      fillColor: Colors.black,
                                      
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(width: 2,color: Colors.black)
                                      )
                                     ),
                                      items: items.map((String items) {
                                                     return DropdownMenuItem(
                                                     value: items,
                                                     
                                                                  child: Text(items,style: TextStyle(color: Colors.white),),
                                            );
                                          }).toList(),
                                         
                                          onChanged: (String? newValue) { 
                                            setState(() {
                                              dropdownvalue = newValue!;
                                             });
                                           },
                                           ),
                                  ),
                                         CustomButton(
                                          
                                          margin: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                           padding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                                          decoration: BoxDecoration(border: Border.all(color: Colors.white,width: 1),borderRadius: BorderRadius.circular(10)),
                                          child: Text("850",style: TextStyle(fontSize: 14,color: Colors.white),),
                                         )
                                ],
                              ),
                              Row(
                               
                                children: [
                                  CustomButton(
                                    height: 32,
                                    // width: 105,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(1)),
                                    child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               
                                      children: [
                                        CustomButton(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/negative.png"),fit: BoxFit.fill)),
                                        ),
                                        SizedBox(width: 17,),
                                        Text("1",style: TextStyle(fontSize: 10,color: Colors.white),),
                                          SizedBox(width: 17,),
                                       CustomButton(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/positive.png"),fit: BoxFit.fill)),
                                        ),
                                      ],
                                     ),
                                   ),
                                   SizedBox(width: 10),
                                  CustomButton(
                                    margin: EdgeInsets.symmetric(horizontal: 0),
                                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 6),
                          
                                   decoration: BoxDecoration(color: Colors.red),
                                   child: Text("Add to cart",style: TextStyle(color: Colors.white),),
                          
                                  )
                                 ],
                               )
                            ],
                          )
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
