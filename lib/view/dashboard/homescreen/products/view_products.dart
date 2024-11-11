import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/models/homescreengrid.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import 'package:red_coprative/view/dashboard/support/product_description.dart';
import '../../../../data/services/cart_data_service.dart';

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
        imageUrls[product.id] = getDownloadUrl(product['imageUrl']);
      });
    }
  }

  // Fetch public download URL for image stored in Firebase Storage
  Future<String> getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error fetching download URL: $e");
      return '';
    }
  }

  void _addToCart(
      String productId,
      String category,
      List<String> selectedModel,
      List<String> selectedDescription,
      List<int> selectedPrice,
      String imageUrl,
      int quantity,
      ) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      print("🥩 Image URL before resolving: $imageUrl"); // Debugging line added here
      String resolvedImageUrl = await getDownloadUrl(imageUrl);
      print("Resolved Image URL: $resolvedImageUrl"); // More specific debugging
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add({
        'productId': productId,
        'category': category,
        'models': selectedModel,
        'descriptions': selectedDescription,
        'prices': selectedPrice,
        'quantity': quantity,
        'imageUrl': resolvedImageUrl,
      })
          .then((value) {
        _showTopSnackBar(context, '$category (${selectedModel[0]}) added to cart with $quantity items.');
      })
          .catchError((error) {
        _showTopSnackBar(context, 'Failed to add $category (${selectedModel[0]}) to cart');
      });
    }
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Dashboardscreen()),
                                (Route) => false,
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                      SizedBox(width: 5.w), // Responsive width
                      Text(
                        "View Products",
                        style: TextStyle(fontSize: 19.sp, color: Colors.white), // Responsive font size
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w), // Responsive padding
                          child: Container(
                            height: 37.h, // Responsive height
                            margin: EdgeInsets.only(left: 15.w, right: 10.w), // Responsive margins
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
                                    controller: searchbar,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: "Search",
                                      hintStyle: const TextStyle(
                                        color: Color.fromARGB(128, 255, 255, 255),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w), // Responsive padding
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
                            margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w), // Responsive margins
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w), // Responsive padding
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 8, 8, 8),
                              borderRadius: BorderRadius.circular(15.r), // Responsive border radius
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
                                            height: 119.w, // Responsive height
                                            width: 119.w, // Responsive width
                                            child: const Center(child: CircularProgressIndicator()),
                                          );
                                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Container(
                                            height: 119.w,
                                            width: 119.w,
                                            color: Colors.grey,
                                            child: const Icon(Icons.error, color: Colors.red),
                                          );
                                        } else {
                                          return Container(
                                            height: 130.w, // Responsive height
                                            width: 130.w, // Responsive width
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.r), // Responsive radius
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
                                        padding: EdgeInsets.only(left: 10.w, top: 5.h), // Responsive padding
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['category'],
                                              style: TextStyle(
                                                fontSize: 14.sp, // Responsive font size
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              selectedDescription,
                                              style: TextStyle(
                                                fontSize: 12.sp, // Responsive font size
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Select Model",
                                                  style: TextStyle(
                                                    fontSize: 10.sp, // Responsive font size
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(width: 75.w), // Responsive width
                                                Text(
                                                  "Price (Rs.)",
                                                  style: TextStyle(
                                                    fontSize: 8.sp, // Responsive font size
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
                                                  width: 125.w, // Responsive width
                                                  height: 38.h, // Responsive height
                                                  padding: EdgeInsets.symmetric(horizontal: 5.w), // Responsive padding
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius: BorderRadius.circular(6.r), // Responsive radius
                                                    border: Border.all(color: const Color.fromARGB(255, 97, 92, 86), width: 1),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child:
                                                    DropdownButton<int>(
                                                      value: selectedIndex,
                                                      dropdownColor: Color(0xFF2C2C2C),
                                                      icon: const Icon(
                                                        Icons.keyboard_arrow_down,
                                                        color: Colors.white,
                                                      ),
                                                      isExpanded: true,
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13.sp, // Responsive font size
                                                      ),
                                                      // Remove itemHeight or set to a valid height like 48
                                                      menuMaxHeight: 150.h, // Responsive max height
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
                                                SizedBox(width: 7.w), // Responsive width
                                                Expanded(
                                                  child: CustomButton(
                                                    padding: EdgeInsets.symmetric(vertical: 9.h), // Responsive vertical padding
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color.fromARGB(255, 97, 92, 86),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius.circular(5.r), // Responsive radius
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "${pricePerUnit * quantity}",
                                                        style: TextStyle(fontSize: 12.sp, color: Colors.white), // Responsive font size
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.h), // Responsive height
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (availableQuantity > 0)
                                                  CustomButton(
                                                    height: 38.h, // Responsive height
                                                    width: 99.w, // Responsive width
                                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0), // Responsive padding
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(6.r), // Responsive radius
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
                                                          child: Image.asset(
                                                            "assets/negative.png",
                                                            height: 22.h, // Responsive height
                                                          ),
                                                        ),
                                                        Text(
                                                          '$quantity',
                                                          style: TextStyle(fontSize: 14.sp, color: Colors.white), // Responsive font size
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (quantity < availableQuantity) {
                                                              setState(() {
                                                                quantities[product.id] = quantity + 1;
                                                              });
                                                            }
                                                          },
                                                          child: Image.asset(
                                                            "assets/positive.png",
                                                            height: 22.h, // Responsive height
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
                                                      color: const Color.fromARGB(255, 172, 31, 37),
                                                      borderRadius: BorderRadius.circular(6.r), // Responsive radius
                                                    ),
                                                    child: TextButton(
                                                      onPressed:  () async  {
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
                                                          String imageUrl = await imageUrls[product.id] ?? 'not found 404';
                                                          _addToCart(
                                                            product.id,
                                                            product['category'],
                                                            [descriptions[selectedIndex]],  // Single-element array containing only the selected description
                                                            [models[selectedIndex]],         // Single-element array containing only the selected model
                                                            [prices[selectedIndex]],         // Single-element array containing only the selected price
                                                            imageUrl,
                                                            quantity,
                                                          );
                                                          setState(() {
                                                            quantities[product.id] = 1;
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        "Add to Cart",
                                                        style: TextStyle(color: Colors.white, fontSize: 10.sp), // Responsive font size
                                                      ),
                                                    ),
                                                  ),
                                                if (availableQuantity <= 0)
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 8.w), // Responsive padding
                                                      child: Text(
                                                        "Out of Stock",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14.sp, // Responsive font size
                                                        ),
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