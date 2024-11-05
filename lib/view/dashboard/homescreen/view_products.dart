import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/account.dart';
import 'package:red_coprative/models/homescreengrid.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import 'package:red_coprative/view/dashboard/support/product_description.dart';
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
  List<QueryDocumentSnapshot> filteredProducts = [];
  Map<String, int> selectedIndexes = {};
  Map<String, int> quantities = {};
  Map<String, Future<String>?> imageUrls = {};
  TextEditingController searchbar = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    List<QueryDocumentSnapshot> fetchedProducts = await _cartService.getProducts();
    setState(() {
      products = fetchedProducts;
      filteredProducts = fetchedProducts;
    });

    for (var product in fetchedProducts) {
      setState(() {
        selectedIndexes[product.id] = 0;
        quantities[product.id] = 1;
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

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          String category = product['category'].toString().toLowerCase();
          return category.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      searchbar.clear();
      filteredProducts = products;
    });
  }

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
                                          height: 123,
                                          width: 119,
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
                                          const SizedBox(height: 2),
                                          Text(
                                            selectedDescription,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
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
                                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (availableQuantity > 0)
                                    CustomButton(
                                     height: 38,
                                     width: 99,
                                      padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 7),
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
                                            style: TextStyle(color: Colors.white,fontSize: 14),
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
      ));}}