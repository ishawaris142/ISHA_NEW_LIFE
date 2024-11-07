import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../../../data/services/popular_product_service.dart';
import 'package:red_coprative/view/dashboard/support/product_description.dart';

class PopularProductsView extends StatefulWidget {
  const PopularProductsView({super.key});

  @override
  _PopularProductsViewState createState() => _PopularProductsViewState();
}

class _PopularProductsViewState extends State<PopularProductsView> {
  final PopularProductsService _popularProductsService = PopularProductsService();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> products = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredProducts = [];
  Map<String, Future<String>?> imageUrls = {};
  Map<String, int> selectedIndexes = {}; // Track selected model index for each product
  TextEditingController searchController = TextEditingController();
  Map<String, int> quantities = {};
  TextEditingController searchbar = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchPopularProducts();
  }
  
  void _showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // Adjust the top position as needed
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _addToCart(String productId, String name, int price, int points, String imageUrl, int quantity) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Reference to the user's cart collection
      CollectionReference cartRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('cart');

      try {
        // Check if the product is already in the cart
        QuerySnapshot existingProduct = await cartRef.where('productId', isEqualTo: productId).get();

        if (existingProduct.docs.isNotEmpty) {
          // If the product already exists in the cart, update the quantity and total price
          DocumentReference existingDoc = existingProduct.docs.first.reference;
          int newQuantity = existingProduct.docs.first['quantity'] + quantity;
          await existingDoc.update({
            'quantity': newQuantity,
            'totalPrice': newQuantity * price,
          });
          _showTopSnackBar(context, '$name quantity updated in cart');
        } else {
          // If the product doesn't exist in the cart, add it as a new item
          await cartRef.add({
            'productId': productId,
            'name': name,
            'price': price,
            'quantity': quantity,
            'totalPrice': price * quantity,
            'points': points,
            'imageUrl': imageUrl,
          });
          _showTopSnackBar(context, '$name added to cart with $points points');
        }
      } catch (error) {
        _showTopSnackBar(context, 'Failed to add $name to cart: $error');
      }
    }
  }

  Future<void> _fetchPopularProducts() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> fetchedProducts =
    await _popularProductsService.getPopularProducts();
    setState(() {
      products = fetchedProducts;
      filteredProducts = fetchedProducts;
    });

    for (var product in fetchedProducts) {
      setState(() {
        imageUrls[product.id] = _getDownloadUrl(product.data()['imageUrl']);
        selectedIndexes[product.id] = 0; // Default to first model
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

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) =>
            product['category'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      filteredProducts = products;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
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
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Dashboardscreen()),
                                (Route)=>false,
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Popular Products",
                        style: TextStyle(fontSize: 19, color: Colors.white),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            height: 37,
                            margin: const EdgeInsets.only(left: 15, right: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 32, 32, 32),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color.fromARGB(255, 97, 92, 86),
                              ),
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
                                    onChanged: _filterProducts,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(child: Text('No products found', style: TextStyle(color: Colors.white)))
                        : ListView.builder(
                      itemCount: filteredProducts.length,
                      padding: const EdgeInsets.only(top: 5, bottom: 200),
                      itemBuilder: (context, index) {
                        var product = filteredProducts[index];

                        var models = List<String>.from(product['models']);
                        var prices = product['price'] is List<dynamic>
                            ? List<int>.from(product['price'].map((e) => (e as num).toInt()))
                            : [product['price']];
                        var quantitiesAvailable = product['quantity'] is List<dynamic>
                            ? List<int>.from(product['quantity'].map((e) => (e as num).toInt()))
                            : [product['quantity']];
                        var descriptions = product['description'] is List<dynamic>
                            ? List<String>.from(product['description'])
                            : [product['description']];

                        int selectedIndex = selectedIndexes[product.id] ?? 0;
                        int quantity = quantities[product.id] ?? 1;
                        int pricePerUnit = prices[selectedIndex];
                        int availableQuantity = quantitiesAvailable[selectedIndex];
                        String selectedDescription = descriptions[selectedIndex];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FutureBuilder<String>(
                                  future: imageUrls[product.id],
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Scaffold(
                                        appBar: AppBar(
                                          title: Text('Loading...'),
                                        ),
                                        body: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Scaffold(
                                        appBar: AppBar(
                                          title: Text('Error'),
                                        ),
                                        body: Center(
                                          child: Text('Error loading image'),
                                        ),
                                      );
                                    } else {
                                      return ProductDescriptionPage(
                                        categoryName: product['category'],
                                        modelName: models[selectedIndex],
                                        imageUrl: snapshot.data!,
                                        price: pricePerUnit,
                                        availableQuantity: availableQuantity,
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 8, 8, 8),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color.fromARGB(255, 97, 92, 86),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    FutureBuilder<String>(
                                      future: imageUrls[product.id],
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Container(
                                            height: 119,
                                            width: 119,
                                            child: const Center(child: CircularProgressIndicator()),
                                          );
                                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Container(
                                            height: 119,
                                            width: 119,
                                            color: Colors.grey,
                                            child: const Icon(Icons.error, color: Colors.red),
                                          );
                                        } else {
                                          return Container(
                                          height: 137,
                                          width: 137,
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
                                            // const SizedBox(height: 1),
                                            Text(
                                              selectedDescription,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            // const SizedBox(height: 2),
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
                                                      dropdownColor: Color(0xFF2C2C2C),
                                                      icon: const Icon(
                                                        Icons.keyboard_arrow_down,
                                                        color: Colors.white,
                                                      ),
                                                      isExpanded: true,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                      ),
                                                      itemHeight: 50,
                                                      menuMaxHeight: 150,
                                                      items: models.asMap().entries.map((entry) {
                                                        int idx = entry.key;
                                                        String model = entry.value;
                                                        return DropdownMenuItem<int>(
                                                          value: idx,
                                                          child: Text(model),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newIndex) {
                                                        setState(() {
                                                          selectedIndexes[product.id] = newIndex!;
                                                          quantities[product.id] = 1;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 7),
                                                Expanded(
                                                  child: CustomButton(
                                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color.fromARGB(255, 97, 92, 86),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "${pricePerUnit * quantity}",
                                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (availableQuantity > 0)
                                                  CustomButton(
                                                    height: 38,
                                                    width: 99,
                                                    padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: const Color.fromARGB(255, 97, 92, 86),
                                                      ),
                                                    ),

                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () {
                                                              if (quantity > 1) {
                                                                setState(() {
                                                                  quantities[product.id] = quantity - 1;
                                                                });
                                                              }
                                                            },
                                                            child: Image.asset("assets/negative.png",height: 22,)
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
                                                            child:  Image.asset("assets/positive.png",height: 22,)
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (availableQuantity > 0)
                                                  CustomButton(
                                                   height: 37,
                                                    width: 85,
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromARGB(255, 172, 31, 37),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        if (availableQuantity <= 0) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Out of Stock')),
                                                          );
                                                        } else {
                                                          if (quantity > availableQuantity) {
                                                            setState(() {
                                                              quantities[product.id] = availableQuantity;
                                                            });
                                                          }
                                                          int points = (pricePerUnit * quantity / 1000).floor();
                                                          _addToCart(
                                                            product.id,
                                                            product['category'],
                                                            pricePerUnit,
                                                            points,
                                                            imageUrls[product.id]?.toString() ?? '',
                                                            quantity,
                                                          );
                                                          setState(() {
                                                            quantities[product.id] = 1;
                                                          });
                                                        }
                                                      },
                                                      child: Container(

                                                        child: const Text(
                                                          "Add to cart",
                                                          style: TextStyle(color: Colors.white,fontSize: 11),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (availableQuantity <= 0)
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: Text(
                                                        "Out of Stock",
                                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.right,
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
          ),
        )
        );
        }
        }
