import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'add_to_cart.dart';
import 'dashboard.dart';
import 'viewproducts.dart';
import 'logoscreen.dart';
import 'cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()), // Initialize CartProvider here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 61, 25, 124)),
        useMaterial3: true,
      ),
      home: const Logoscreen(), // You can keep the logo screen here
      routes: {
        '/dashboard': (context) => const Dashboardscreen(), // Navigate to Dashboard first
        '/viewproducts': (context) => const ViewproductScreen(),
        '/cart': (context) => const AddToCart(),
      },
    );
  }
}

