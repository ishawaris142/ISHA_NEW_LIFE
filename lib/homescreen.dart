import 'package:flutter/material.dart';
import 'package:red_coprative/models/homescreengrid.dart';

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
              height: height * 0.321,
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
                                          hintText: "Search",fillColor: Colors.white,
                                          hintStyle: const TextStyle(color: Color.fromARGB(128, 255, 255, 255)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
                        const SizedBox(width: 15), // Adjusted spacing
                        // Withdraw Button
                        SizedBox(
                          height: 40, // Smaller height for the button
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Image.asset("assets/coins.png"),
                            label: const Text("Withdraw", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6), 
                       
                        SizedBox(
                          height: 40, 
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text("History", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                       // const SizedBox(width: 1), 
                        // Image Icon
                        IconButton(
                          onPressed: () {},
                          icon: Image(image: AssetImage("assets/again.png")),
                        ),
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
                            SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: Image.asset("assets/coins.png"),
                                label: const Text("Convert Points", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                                  minimumSize: const Size(90, 30),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text("History", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                ),
                              ),
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
              top: height * 0.333, // Adjusted positioning to move items higher
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
                      childAspectRatio: 1.2,
                    ),
                    itemCount: homescreenmodelclasslist.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color.fromARGB(255, 97, 92, 86))
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
              top: height * 0.620,
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
