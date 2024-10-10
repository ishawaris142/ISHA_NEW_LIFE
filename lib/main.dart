// ignore_for_file: unused_import, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:red_coprative/logoscreen.dart';


void main() {
  runApp(const MyApp());
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
      home: Logoscreen(),
    );
  }
}
