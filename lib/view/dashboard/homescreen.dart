import 'package:flutter/material.dart';
import 'package:red_coprative/models/homescreengrid.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/support/cash_withdraw.dart';
import 'package:red_coprative/view/dashboard/support/history.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    var searchbar = TextEditingController();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Stack(
          children: [
            Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backk.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: height * 0.312,
              width: width,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 172, 31, 37),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromARGB(255, 8, 8, 8),
                    width: 1,
                  )
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row with Logo, Search, and Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Logo on the left
                        Image.asset("assets/smalllogo.png", height: 60),
                        // Center search bar
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Container(
                              
                              height: 40,
                              margin: const EdgeInsets.only(left: 15, right: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 32, 32, 32),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color.fromARGB(255, 97, 92, 86))
                              ),
                              child: Row(
                                children: [
                                  // Text Field for Search
                                  Expanded(
                                    child: Container(
                                      child: TextField(
  controller: searchbar,
  style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(
    hintText: "Search",
    hintStyle: const TextStyle(color: Color.fromARGB(128, 255, 255, 255)),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    border: InputBorder.none,
  ),
),
                                    ),
                                  ),
                                  // Search Icon
                                  IconButton(
                                    onPressed: () {
                                      print("Search");
                                    },
                                    icon: const Icon(Icons.search, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Menu Icon on the right side
                        Image.asset("assets/homeicon.png"),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Divider above greeting and buttons
                    const Divider(color: Colors.black),
                    const SizedBox(height: 10),
            
                    // Greeting Row with Withdraw and History Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Greeting Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, Talha Zahid",
                              style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                Image(image: AssetImage("assets/mechanic.png")),
                                SizedBox(width: 5),
                                Text(
                                  "Mechanics Account",
                                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 17), // Adjusted spacing
                        // Withdraw Button
                        CustomButton(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CashWithdrawScreen(),));
                          },
                         
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          padding: EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                          
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color.fromARGB(255, 32, 32, 32)),
                           child: Row(
                             children: [
                              Image.asset("assets/coins.png",height: 22,),
                               Text("Withdraw",style:TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12),),
                             ],
                           ),
                        ),
                        
                       
                       CustomButton(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Historyscreen(),));
                        },
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 11),
                        child: Text("History",style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12),),
                        
                           
                           decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color.fromARGB(255, 32, 32, 32),),
                           
                       ),
                       


                        
                       const SizedBox(width: 5), 
                       
                       Image.asset("assets/again.png",height: 20,),
                      ],
                    ),
                    const SizedBox(height: 10),
                   
                    const Divider(color: Colors.black),
                    const SizedBox(height: 10),
            
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "My Points",
                              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 8),
                            ),
                            Text(
                              "490.00",
                              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 24, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CustomButton(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CashWithdrawScreen(),));
                          },
                         
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          padding: EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                          
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color.fromARGB(255, 32, 32, 32)),
                           child: Row(
                             children: [
                              Image.asset("assets/coins.png",height: 22,),
                               Text("Convert Points",style:TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12),),
                             ],
                           ),
                        ),
                            //const SizedBox(width: 5),
                            CustomButton(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Historyscreen(),));
                        },
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 11),
                        child: Text("History",style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12),),
                        
                           
                           decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color.fromARGB(255, 32, 32, 32),),
                           
                       ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
            Positioned(
              top: height * 0.325, // Adjusted positioning to move items higher
              left: 10,
              right: 10,
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Explore ISH",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 12,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                 
                  GridView.builder(
                   
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 13,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: homescreenmodelclasslist.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 30, 28, 27),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color.fromARGB(255, 97, 92, 86))
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("${homescreenmodelclasslist[index].image}",height: 55,),
                                  SizedBox(height: 3),
                                  Text(
                                    "${homescreenmodelclasslist[index].text}",
                                    style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
               
                ],
              ),
            ),
           
            Positioned(
              top: height * 0.630,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Promotions",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 12,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("assets/homelist.png")),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
