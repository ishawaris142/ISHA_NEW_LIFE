import 'package:flutter/material.dart';
import 'package:red_coprative/account.dart';
import 'package:red_coprative/login.dart';
import 'package:red_coprative/models/viewproductmodelclass.dart';

class ViewproductScreen extends StatefulWidget {
  const ViewproductScreen({super.key});

  @override
  State<ViewproductScreen> createState() => _ViewproductScreenState();
}

class _ViewproductScreenState extends State<ViewproductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            // Top section with back and logout icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    onPressed: () {
                      // Navigate back to the Account screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Accountscreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset("assets/profilelogout.png"),
                    onPressed: () async {
                      // Handle logout
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Expanded widget to allow the ListView to take available space
            Expanded(
              child: ListView.builder(
                itemCount: viewproductmodelclasslist.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900], // Background color for each item
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        height: 100,
                        width: 80,

                        child: Container(
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage("${viewproductmodelclasslist[index].image}"),
                              fit: BoxFit.cover,

                            ),
                          ),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${viewproductmodelclasslist[index].name}",
                            style: const TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("${viewproductmodelclasslist[index].description}",style: const TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),),
                          Row(
                            children: [
                              Text("${viewproductmodelclasslist[index].price}",style: const TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),),
                              const SizedBox(width: 20,),
                              const Icon(
                                Icons.blur_circular_rounded,
                                size: 16,
                                color: Color.fromARGB(255, 165, 6, 13),
                              ),
                              Text("${viewproductmodelclasslist[index].points}",style: const TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                        ],
                      ),

                      trailing: Column(
                        children: [
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.asset(
                              "${viewproductmodelclasslist[index].cart}", // The cart image
                              fit: BoxFit.cover,
                              color: Colors.amber,
                            ),
                          ),


                        ],
                      ),
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