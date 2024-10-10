// ignore_for_file: unused_import, prefer_const_constructors


import 'package:red_coprative/logoscreen.dart';

// Modify main() to initialize Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 61, 25, 124)),
        useMaterial3: true,
      ),
      home: Logoscreen(), // Loads your logoscreen widget
    );
  }
}
