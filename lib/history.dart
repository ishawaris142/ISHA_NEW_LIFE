import 'package:flutter/material.dart';
import 'package:red_coprative/account.dart';

class Historyscreen extends StatefulWidget {
  const Historyscreen({super.key});

  @override
  State<Historyscreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,

        children: [
          Container(
            height: 368,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.cyan,borderRadius: BorderRadius.only(bottomRight: Radius.circular(115))),
          ),
          Container(
            height: 430,
            width: double.infinity,

            decoration: BoxDecoration( color: Colors.cyan,borderRadius: BorderRadius.only(bottomRight: Radius.circular(250))),
            child: Column(

              children: [
                SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () {
                        // Navigate to the Accountscreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Accountscreen()),
                        );
                      },
                    ),
                    Icon(Icons.commit,size: 30,)
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("My Profile",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
                  ],
                ),
                SizedBox(height: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(color: Color.fromARGB(255, 187, 44, 25),borderRadius: BorderRadius.circular(13) ),
                      child: Image.asset("assets/Kid.png"),

                    ),
                    SizedBox(height: 15),
                    Text("Florance Katy",style: TextStyle(
                        fontSize: 17,fontWeight: FontWeight.bold,
                        color: Colors.white),),
                    SizedBox(height: 10),
                    Text("Team Leader",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 218, 203, 7)),)

                  ],
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("Folders",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                        Text("67",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.amber),)
                      ],
                    ),
                    Column(
                      children: [
                        Text("Itame",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                        Text("986",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.amber),)
                      ],
                    ),
                    Column(
                      children: [
                        Text("Used",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                        Text("10GB",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.amber),)
                      ],
                    ),
                  ],
                ),

              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 280,

              decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.only(topLeft: Radius.circular(200))),
            ),
          )
        ],
      ),
    );
  }
}