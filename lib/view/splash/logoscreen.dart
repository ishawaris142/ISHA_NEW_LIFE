import 'package:flutter/material.dart';
import 'package:red_coprative/view/auth/login.dart';

class Logoscreen extends StatefulWidget {
  const Logoscreen({super.key});

  @override
  State<Logoscreen> createState() => _LogoscreenState();
}

class _LogoscreenState extends State<Logoscreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and then navigate to the login screen
    Future.delayed(const Duration(seconds: 3), () async {
      //   SharedPreferences _pref =await SharedPreferences.getInstance();
      // final token =  _pref.getString("token");
      // if(token!=null){
      //   Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Dashboardscreen()),
      // );
      // }else{
      //     Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const LoginScreen()),
      // );

      // }
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen(),));
    
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 172, 31, 37),
      body: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/ish logo.png"),fit: BoxFit.cover)),
      )
    );
  }
}
