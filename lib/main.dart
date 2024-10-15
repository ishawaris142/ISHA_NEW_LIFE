import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_to_cart.dart';
import 'viewproducts.dart';
import 'logoscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 61, 25, 124)),
        useMaterial3: true,
      ),
      // Use the home property instead of the initial route
      home: Logoscreen(),
      routes: {
        '/viewproducts': (context) => ViewproductScreen(),
        '/cart': (context) => AddToCart(),
      },
    );
  }
}
