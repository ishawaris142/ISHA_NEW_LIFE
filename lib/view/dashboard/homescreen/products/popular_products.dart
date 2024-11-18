import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../../../../data/services/popular_product_service.dart';
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
  Map<String, int> quantities = {};
  Map<String, int> points = {}; // Points map for each product based on quantity
  TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode searchFocusNode = FocusNode();

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

  void _addToCart(
      String productid,
      String category,
      List<String> selectedModel,
      List<String> selectedDescription,
      List<int> selectedPrice,
      String imageUrl,
      int quantity,
      int points,
      ) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      String resolvedImageUrl = await getDownloadUrl(imageUrl);
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add({
        'productid': productid,
        'category': category,
        'models': selectedModel,
        'descriptions': selectedDescription,
        'prices': selectedPrice,
        'quantity': quantity,
        'points': quantity * 10,
        'imageUrl': resolvedImageUrl,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      }).then((value) {
        print('Product added to cart with ID: $productid, quantity: $quantity, points: ${quantity * 10}');
        _showTopSnackBar(
            context,
            '$category (${selectedModel[0]}) added to cart with $quantity items and ${quantity * 10} points.');
      }).catchError((error) {
        print('Failed to add product to cart: $error');
        _showTopSnackBar(context, 'Failed to add $category (${selectedModel[0]}) to cart');
      });
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
        imageUrls[product.id] = getDownloadUrl(product.data()['imageUrl']);
        print("imageUrl  ${imageUrls[product.id]}");
        selectedIndexes[product.id] = 0; // Default to first model
        quantities[product.id] = 1; // Initialize quantity to 1
        points[product.id] = 10; // Initialize points to 10
      });
    }
  }

  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL();
      print("DownloadURL in getDownloadUrl function");
      print(downloadUrl);
      return downloadUrl;
    } catch (e) {
      print("🥠 Error fetching download URL: $e");

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
            product['category']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
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

  void _updatePoints(String productId) {
    setState(() {
      points[productId] = 10 * quantities[productId]!; // Points calculated as 10 * quantity
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
                // Search Bar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Dashboardscreen()),
                              (Route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                    ),
                    SizedBox(width: 5.w), // Responsive width
                    Text(
                      "Popular Products",
                      style: TextStyle(
                          fontSize: 19.sp, color: Colors.white), // Responsive font size
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w), // Responsive padding
                        child: Container(
                          height: 37.h, // Responsive height
                          margin: EdgeInsets.only(
                              left: 15.w, right: 10.w), // Responsive margins
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 32, 32, 32),
                            borderRadius: BorderRadius.circular(10.r), // Responsive border radius
                            border: Border.all(
                              color: const Color.fromARGB(255, 97, 92, 86),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  focusNode:
                                  searchFocusNode, // Use the FocusNode here
                                  onTap: () {
                                    setState(() {
                                      _isSearching = true;
                                    });
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(128, 255, 255, 255),
                                      fontSize: 12.sp,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: -17,
                                      horizontal: 4.w,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: _filterProducts,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (searchController.text.isEmpty) {
                                    FocusScope.of(context)
                                        .unfocus(); // Close the keyboard if the text field is empty
                                    setState(() {
                                      _isSearching =
                                      false; // Hide the cross icon if not in search mode
                                      filteredProducts =
                                          products; // Reset the filtered data
                                    });
                                  } else {
                                    searchController.clear(); // Clear text only
                                    searchFocusNode
                                        .requestFocus(); // Keep the keyboard open by requesting focus
                                    setState(() {
                                      _isSearching =
                                      true; // Ensure search mode remains active
                                    });
                                  }
                                },
                                icon: Icon(
                                  _isSearching ? Icons.close : Icons.search,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Product List
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                      child: Text('No products found',
                          style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                    itemCount: filteredProducts.length,
                    padding: const EdgeInsets.only(top: 5, bottom: 200),
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];

                      var models = List<String>.from(product['models']);
                      print("🐱‍👤 ");
                      print(product['models']);
                      var prices = product['price'] is List<dynamic>
                          ? List<int>.from(
                          product['price'].map((e) => (e as num).toInt()))
                          : [product['price']];
                      var pointsList = product['points'] is List<dynamic>
                          ? List<int>.from(
                          product['points'].map((e) => (e as num).toInt()))
                          : [product['points']];
                      var quantitiesAvailable =
                      product['quantity'] is List<dynamic>
                          ? List<int>.from(product['quantity']
                          .map((e) => (e as num).toInt()))
                          : [product['quantity']];
                      var descriptions = product['description'] is List<dynamic>
                          ? List<String>.from(product['description'])
                          : [product['description']];

                      int selectedIndex = selectedIndexes[product.id] ?? 0;
                      int quantity = quantities[product.id] ?? 1;
                      int pricePerUnit = prices[selectedIndex];
                      int availableQuantity = quantitiesAvailable[selectedIndex];
                      String selectedDescription = descriptions[selectedIndex];
                      int selectedPoints = points[product.id] ?? 10;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FutureBuilder<String>(
                                future: imageUrls[product.id],
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Scaffold(
                                      appBar: AppBar(
                                        title: Text('Loading...'),
                                      ),
                                      body: Center(
                                        child:
                                        CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.hasError ||
                                      !snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
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
                                      productid: product.id,
                                      categoryName: product['category'],
                                      points: selectedPoints,
                                      modelName: models[selectedIndex],
                                      imageUrl: snapshot.data!,
                                      price: pricePerUnit,
                                      availableQuantity: availableQuantity,
                                      selectedDescription:
                                      selectedDescription,
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        child: CustomButton(
                          margin: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 4.w), // Responsive margins
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 10.w), // Responsive padding
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 8, 8, 8),
                            borderRadius:
                            BorderRadius.circular(15.r), // Responsive border radius
                            border: Border.all(
                              color: const Color.fromARGB(255, 97, 92, 86),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image and Details Row
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  FutureBuilder<String>(
                                    future: imageUrls[product.id],
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          height: 119.w, // Responsive height
                                          width: 119.w, // Responsive width
                                          child: const Center(
                                              child:
                                              CircularProgressIndicator()),
                                        );
                                      } else if (snapshot.hasError ||
                                          !snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Container(
                                          height: 119.w,
                                          width: 119.w,
                                          color: Colors.grey,
                                          child: const Icon(Icons.error,
                                              color: Colors.red),
                                        );
                                      } else {
                                        return Container(
                                          height: 130.w, // Responsive height
                                          width: 130.w, // Responsive width
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                10.r), // Responsive radius
                                            image: DecorationImage(
                                              image:
                                              NetworkImage(snapshot.data!),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.w, top: 5.h), // Responsive padding
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Category and Points Row
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                height: 36.h, // Responsive height
                                                width: 130.w, // Responsive width
                                                child: Text(
                                                  product['category'],
                                                  style: TextStyle(
                                                    fontSize: 14.sp, // Responsive font size
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    "Points",
                                                    style: TextStyle(
                                                      fontSize:
                                                      8.sp, // Responsive font size
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                    ),
                                                  ),
                                                  CustomButton(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 7.w), // Responsive horizontal padding
                                                    child: Text(
                                                      "$selectedPoints",
                                                      style: TextStyle(
                                                        fontSize: 12.sp, // Responsive font size
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color
                                                            .fromARGB(
                                                            255,
                                                            97,
                                                            92,
                                                            86),
                                                      ),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5.r), // Responsive border radius
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height:
                                              5.h), // Add responsive spacing if needed
                                          // Description
                                          Text(
                                            selectedDescription,
                                            style: TextStyle(
                                              fontSize: 12.sp, // Responsive font size
                                              color: Colors.white70,
                                            ),
                                          ),
                                          // Labels Row
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Select Model",
                                                style: TextStyle(
                                                  fontSize: 10.sp, // Responsive font size
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                  75.w), // Responsive width
                                              Text(
                                                "Price (Rs.)",
                                                style: TextStyle(
                                                  fontSize: 8.sp, // Responsive font size
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Dropdown and Price Row
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                width: 125.w, // Responsive width
                                                height: 38.h, // Responsive height
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                    5.w), // Responsive padding
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      6.r), // Responsive radius
                                                  border: Border.all(
                                                      color: const Color
                                                          .fromARGB(
                                                          255,
                                                          97,
                                                          92,
                                                          86),
                                                      width: 1),
                                                ),
                                                child:
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<int>(
                                                    value: selectedIndex,
                                                    dropdownColor:
                                                    Color(0xFF2C2C2C),
                                                    icon: const Icon(
                                                      Icons
                                                          .keyboard_arrow_down,
                                                      color: Colors.white,
                                                    ),
                                                    isExpanded: true,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize:
                                                      13.sp, // Responsive font size
                                                    ),
                                                    menuMaxHeight:
                                                    150.h, // Responsive max height
                                                    items: models
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int idx = entry.key;
                                                      String model = entry.value;
                                                      return DropdownMenuItem<int>(
                                                        value: idx,
                                                        child: Text(model),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newIndex) {
                                                      setState(() {
                                                        selectedIndexes[product.id] =
                                                        newIndex!;
                                                        quantities[product.id] =
                                                        1;
                                                        points[product.id] =
                                                        10; // Reset points to 10 for new model selection
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 7.w), // Responsive width
                                              Expanded(
                                                child: CustomButton(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                      9.h), // Responsive vertical padding
                                                  decoration:
                                                  BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color
                                                          .fromARGB(
                                                          255,
                                                          97,
                                                          92,
                                                          86),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        5.r), // Responsive radius
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${pricePerUnit * quantity}",
                                                      style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: Colors
                                                              .white), // Responsive font size
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.h), // Responsive height
                                          // Quantity and Add to Cart Row
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              if (availableQuantity > 0)
                                                CustomButton(
                                                  height: 38.h, // Responsive height
                                                  width: 99.w, // Responsive width
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      2.w, // Responsive padding
                                                      vertical: 0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        6.r), // Responsive radius
                                                    border: Border.all(
                                                      color: const Color
                                                          .fromARGB(
                                                          255,
                                                          97,
                                                          92,
                                                          86),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (quantity > 1) {
                                                            setState(() {
                                                              quantities[product.id] =
                                                                  quantity -
                                                                      1;
                                                              _updatePoints(
                                                                  product.id); // Update points on decrement
                                                            });
                                                          }
                                                        },
                                                        child: Image.asset(
                                                          "assets/negative.png",
                                                          height:
                                                          22.h, // Responsive height
                                                        ),
                                                      ),
                                                      Text(
                                                        '$quantity',
                                                        style: TextStyle(
                                                            fontSize:
                                                            14.sp,
                                                            color: Colors
                                                                .white), // Responsive font size
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (quantity <
                                                              availableQuantity) {
                                                            setState(() {
                                                              quantities[product.id] =
                                                                  quantity +
                                                                      1;
                                                              _updatePoints(
                                                                  product.id); // Update points on increment
                                                            });
                                                          }
                                                        },
                                                        child: Image.asset(
                                                          "assets/positive.png",
                                                          height:
                                                          22.h, // Responsive height
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (availableQuantity > 0)
                                                CustomButton(
                                                  height: 37.h, // Responsive height
                                                  width: 77.w, // Responsive width
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 172, 31, 37),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        6.r), // Responsive radius
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      if (availableQuantity <= 0) {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  'Out of Stock')),
                                                        );
                                                      } else {
                                                        if (quantity >
                                                            availableQuantity) {
                                                          setState(() {
                                                            quantities[product.id] =
                                                                availableQuantity;
                                                            _updatePoints(
                                                                product.id); // Update points if quantity adjusted
                                                          });
                                                        }
                                                        int calculatedPoints =
                                                            10 *
                                                                quantity; // Points calculated as 10 * quantity
                                                        String imageUrl =
                                                            await imageUrls[
                                                            product.id] ??
                                                                'not found 404';
                                                        _addToCart(
                                                          product.id,
                                                          product['category'],
                                                          [
                                                            descriptions[
                                                            selectedIndex]
                                                          ], // Single-element array containing only the selected description
                                                          [
                                                            models[
                                                            selectedIndex]
                                                          ], // Single-element array containing only the selected model
                                                          [
                                                            prices[
                                                            selectedIndex]
                                                          ], // Single-element array containing only the selected price
                                                          imageUrl,
                                                          quantity,
                                                          calculatedPoints, // Pass calculated points
                                                        );
                                                        setState(() {
                                                          quantities[product.id] =
                                                          1;
                                                          points[product.id] =
                                                          10; // Reset points after adding to cart
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      "Add to Cart",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .white,
                                                          fontSize:
                                                          10.sp), // Responsive font size
                                                    ),
                                                  ),
                                                ),
                                              if (availableQuantity <= 0)
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left:
                                                        8.w), // Responsive padding
                                                    child: Text(
                                                      "Out of Stock",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize:
                                                        14.sp, // Responsive font size
                                                      ),
                                                      textAlign:
                                                      TextAlign.right,
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
      ),
    );
  }
}
