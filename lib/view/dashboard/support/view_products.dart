import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/account.dart';
import 'package:red_coprative/models/homescreengrid.dart';
import '../../../data/services/cart_data_service.dart';

class ProductView extends StatefulWidget {
  final Homescreenmodelclass? productData;

  const ProductView({Key? key, this.productData}) : super(key: key);

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final CartService _cartService = CartService();
  List<QueryDocumentSnapshot> products = [];
  Map<String, int> selectedIndexes = {}; // Track selected model index for each product
  Map<String, int> quantities = {}; // Track quantity for each product
  Map<String, Future<String>?> imageUrls = {}; // Track image URLs for each product

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    List<QueryDocumentSnapshot> fetchedProducts = await _cartService.getProducts();
    setState(() {
      products = fetchedProducts;
    });

    for (var product in fetchedProducts) {
      setState(() {
        selectedIndexes[product.id] = 0; // Default to the first model
        quantities[product.id] = 1; // Initialize quantity to 1
        imageUrls[product.id] = _getDownloadUrl(product['imageUrl']);
      });
    }
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error fetching download URL: $e");
      return '';
    }
  }

  void _addToCart(String productId, String name, int price, int points, String imageUrl, int quantity) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).collection('cart').add({
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'totalPrice': price * quantity,
        'points': points,
        'imageUrl': imageUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added to cart with $points points')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     var searchbar = TextEditingController();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backk.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 30),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                             IconButton(
                    onPressed: () {
                      Navigator.pop(context, MaterialPageRoute(builder: (context) => const Accountscreen()));
                    },
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Products",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 45),
                                  child: Container(
                                    height: 37,
                                    margin: const EdgeInsets.only(left: 15, right: 10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 32, 32, 32),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color.fromARGB(255, 97, 92, 86)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: searchbar,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(
                                              hintText: "Search",
                                              hintStyle: TextStyle(
                                                  color: Color.fromARGB(128, 255, 255, 255)),
                                              contentPadding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 10),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
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
                             
                            ],
                          ),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  itemBuilder: (context, index) {
                    var product = products[index];
                    
                    // Handle nested lists (if product['price'], product['quantity'], and product['description'] are nested)
                    var models = List<String>.from(product['models']);
                    var prices = product['price'] is List<dynamic> 
                        ? List<int>.from(product['price'].map((e) => (e as num).toInt()))
                        : [product['price']]; // Fallback if price is not a list
                    var quantitiesAvailable = product['quantity'] is List<dynamic>
                        ? List<int>.from(product['quantity'].map((e) => (e as num).toInt()))
                        : [product['quantity']]; // Fallback if quantity is not a list
                    var descriptions = product['description'] is List<dynamic>
                        ? List<String>.from(product['description'])
                        : [product['description']]; // Fallback if description is not a list

                    int selectedIndex = selectedIndexes[product.id] ?? 0;
                    int quantity = quantities[product.id] ?? 1;
                    int pricePerUnit = prices[selectedIndex];
                    int availableQuantity = quantitiesAvailable[selectedIndex];
                    int totalPrice = pricePerUnit * quantity;
                    String selectedDescription = descriptions[selectedIndex];

                    return CustomButton(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 8, 8, 8),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color.fromARGB(255, 97, 92, 86),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display the image with a 10px border radius
                          FutureBuilder<String>(
                            future: imageUrls[product.id],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: 133,
                                  width: 123,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Container(
                                  height: 133,
                                  width: 123,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error, color: Colors.red),
                                );
                              } else {
                                return Container(
                                  height: 133,
                                  width: 123,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(snapshot.data!),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['category'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    selectedDescription, // Display selected description
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Select Model",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 88),
                                      Text(
                                        "Price (Rs.)",
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 38,
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color.fromARGB(255, 97, 92, 86), width: 1),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: selectedIndex,
                                            dropdownColor: const Color.fromARGB(255, 8, 8, 8),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                            ),
                                            isExpanded: true,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(255, 97, 92, 86),
                                            ),
                                            items: List.generate(models.length, (modelIndex) {
                                              return DropdownMenuItem<int>(
                                                value: modelIndex,
                                                child: Text(
                                                  models[modelIndex],
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 97, 92, 86),
                                                  ),
                                                ),
                                              );
                                            }),
                                            onChanged: (newIndex) {
                                              setState(() {
                                                selectedIndexes[product.id] = newIndex!;
                                                quantities[product.id] = 1; // Reset quantity to 1 when model changes
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 7,),
                                      Expanded(
                                        child: CustomButton(
                                          padding: const EdgeInsets.symmetric( vertical: 9),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(255, 97, 92, 86),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$totalPrice", // Display dynamic price based on quantity
                                              style: const TextStyle(fontSize: 12, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CustomButton(
                                        height: 38,
                                        width: 99,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color.fromARGB(255, 97, 92, 86),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (quantity > 1) {
                                                  setState(() {
                                                    quantities[product.id] = quantity - 1;
                                                  });
                                                }
                                              },
                                              child: const Icon(Icons.remove, color: Colors.white),
                                            ),
                                            Text(
                                              '$quantity',
                                              style: const TextStyle(fontSize: 14, color: Colors.white),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (quantity < availableQuantity) {
                                                  setState(() {
                                                    quantities[product.id] = quantity + 1;
                                                  });
                                                }
                                              },
                                              child: const Icon(Icons.add, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CustomButton(
                                        height: 36,
                                        width: 99,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 172, 31, 37),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            if (quantity > 0) {
                                              int points = (pricePerUnit * quantity / 1000).floor();
                                              _addToCart(
                                                product.id,
                                                product['category'],
                                                pricePerUnit,
                                                points,
                                                imageUrls[product.id]?.toString() ?? '',
                                                quantity,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Please select some quantity')),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            "Add to cart",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
