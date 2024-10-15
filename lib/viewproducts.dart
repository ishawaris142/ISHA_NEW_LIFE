import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_coprative/account.dart';
import 'package:red_coprative/login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ViewproductScreen extends StatefulWidget {
  const ViewproductScreen({super.key});

  @override
  State<ViewproductScreen> createState() => _ViewproductScreenState();
}

class _ViewproductScreenState extends State<ViewproductScreen> {
  final CollectionReference productsCollection = FirebaseFirestore.instance.collection('cart_data');

  // Function to convert gs:// URL to HTTP(S) download URL
  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error fetching download URL: $e");
      // Return a placeholder image URL or an empty string if there's an error
      return '';
    }
  }

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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Accountscreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset("assets/profilelogout.png"),
                    onPressed: () async {
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
              child: StreamBuilder<QuerySnapshot>(
                stream: productsCollection.snapshots(), // Stream from Firestore
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return const Center(child: Text("No products available", style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      int quantity = product['quantity'];
                      String gsUrl = product['imageUrl']; // Assuming this is a gs:// URL

                      return FutureBuilder<String>(
                        future: getDownloadUrl(gsUrl),
                        builder: (context, AsyncSnapshot<String> downloadSnapshot) {
                          if (downloadSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (downloadSnapshot.hasError || !downloadSnapshot.hasData || downloadSnapshot.data!.isEmpty) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.error, color: Colors.red, size: 50),
                                title: Text(
                                  product['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  "Failed to load image",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }

                          String downloadUrl = downloadSnapshot.data!;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: SizedBox(
                                height: 100,
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: downloadUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    product['description'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\$${product['price']}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      const Icon(
                                        Icons.blur_circular_rounded,
                                        size: 16,
                                        color: Color.fromARGB(255, 165, 6, 13),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${product['points']} pts",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Image.asset(
                                "assets/Add to cart.png",
                                width: 40,
                                height: 40,
                                color: Colors.amber,
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                    onPressed: () {
                                      if (quantity > 1) {
                                        productsCollection.doc(product.id).update({'quantity': quantity - 1});
                                      }
                                    },
                                  ),
                                  Text(
                                    "$quantity",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                    onPressed: () {
                                      productsCollection.doc(product.id).update({'quantity': quantity + 1});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
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
