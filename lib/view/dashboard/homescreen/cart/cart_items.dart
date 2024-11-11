import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../../../../data/services/cart_data_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  double _totalAmount = 0.0;
  List<QueryDocumentSnapshot> cartItems = [];
  Map<String, int> quantities = {}; // Tracks quantity for each item
  Map<String, int> availableQuantities = {
  }; // Tracks available quantity for each item
  List<QueryDocumentSnapshot> filteredCartItems = [];
  Map<String, Future<String>?> imageUrls = {}; // Holds image URLs for each item
  Map<String, int> selectedIndexes = {
  }; // Track selected model index for each product
  Map<String, bool> selectedItems = {}; // Track selection state of each item
  bool isAllSelected = false; // Track whether "Select All" is checked
  TextEditingController searchbarController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      List<QueryDocumentSnapshot> fetchedCartItems = snapshot.docs;
      Map<String, int> fetchedQuantities = {};
      Map<String, Future<String>?> fetchedImageUrls = {};
      Map<String, int> fetchedAvailableQuantities = {}; // New map for available quantities

      for (var item in fetchedCartItems) {
        String itemId = item.id;

        int availableQuantity = 1; // Default value
        final itemData = item.data() as Map<String, dynamic>?; // Cast to a map safely

        if (itemData != null && itemData.containsKey('availableQuantity')) {
          availableQuantity = itemData['availableQuantity'] as int;
        }

        fetchedAvailableQuantities[itemId] = availableQuantity;
        fetchedQuantities[itemId] = item.get('quantity') ?? 1;
        fetchedImageUrls[itemId] = item.get('imageUrl') != null
            ? _getDownloadUrl(item.get('imageUrl'))
            : Future.value('');
        selectedItems[itemId] = false; // Initialize each item as unselected
      }

      setState(() {
        cartItems = fetchedCartItems;
        filteredCartItems = fetchedCartItems; // Initialize filteredCartItems with all cart items
        quantities = fetchedQuantities;
        imageUrls = fetchedImageUrls;
        availableQuantities = fetchedAvailableQuantities;
        _calculateTotals();
      });
    }
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching download URL: $e");
      return '';
    }
  }

  void _calculateTotals() {
    double totalAmount = 0.0;
    for (var item in cartItems) {
      String itemId = item.id;
      if (selectedItems[itemId] ?? false) { // Only add selected items to total
        int price = (item['prices'] as List<dynamic>?)?.first as int? ?? 0;
        int quantity = quantities[item.id] ?? 1;
        totalAmount += price * quantity;
      }
    }
    setState(() {
      _totalAmount = totalAmount;
    });
  }

  void _toggleSelection(String itemId) {
    setState(() {
      selectedItems[itemId] =
      !(selectedItems[itemId] ?? false); // Toggle item selection
      isAllSelected =
      !selectedItems.containsValue(false); // Update "Select All" state
      _calculateTotals();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      isAllSelected = !isAllSelected; // Toggle "Select All" state
      selectedItems.updateAll((key,
          value) => isAllSelected); // Set all items based on "Select All"
      _calculateTotals();
    });
  }


  void _incrementQuantity(String itemId) {
    int availableQuantity = availableQuantities[itemId] ?? 1;
    print("Debug: Incrementing quantity for itemId: $itemId");
    print(
        "Current quantity: ${quantities[itemId]}, Available quantity: $availableQuantity");

    setState(() {
      if ((quantities[itemId] ?? 1) < availableQuantity) {
        quantities[itemId] = (quantities[itemId] ?? 1) + 1;
        print("Debug: Quantity incremented to ${quantities[itemId]}");
        _calculateTotals();
      } else {
        print("Debug: Maximum available quantity reached for itemId: $itemId");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Maximum available quantity reached")),
        );
      }
    });
  }

  void _decrementQuantity(String itemId) {
    setState(() {
      if ((quantities[itemId] ?? 1) > 1) {
        quantities[itemId] = (quantities[itemId] ?? 1) - 1;
      } else {
        _showDeletionPopup(context, itemId);
      }
      _calculateTotals();
    });
  }


  void _showDeletionPopup(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Center(
              child: Text(
                'Are you sure you want to remove this item?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 8.0),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
                onPressed: () {
                  _deleteItem(itemId);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }


  Future<void> _deleteItem(String docId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(docId)
          .delete();

      _fetchCartItems();
    }
  }

  void _filterCartItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCartItems = cartItems;
      } else {
        filteredCartItems = cartItems.where((item) {
          String category = item['category'].toString().toLowerCase();
          return category.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      searchbarController.clear();
      filteredCartItems = cartItems;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;

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
            padding: const EdgeInsets.only(left:4,right: 2),
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
                      "Cart",
                      style: TextStyle(fontSize: 19.sp, color: Colors.white), // Responsive font size
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 70.w), // Responsive padding
                        child: Container(
                          height: 37.h, // Responsive height
                          // width:10.w,
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
                                  controller: searchbarController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                    hintStyle: const TextStyle(
                                      color: Color.fromARGB(128, 255, 255, 255),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w), // Responsive padding
                                    border: InputBorder.none,
                                  ),
                                  onChanged: _filterCartItems,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select All',
                      style: TextStyle(color: Colors.white),
                    ),
                    Checkbox(
                      value: isAllSelected,
                      onChanged: (value) => _toggleSelectAll(),
                      activeColor: Colors.red,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCartItems.length + 1,
                    // Extra item for the Total Amount and Checkout
                    padding: const EdgeInsets.only(top: 5),
                    itemBuilder: (context, index) {
                      if (index == filteredCartItems.length) {
                        // This is the last item in the list, used for Total Amount and Checkout button
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 150),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  'Total Amount: Rs. ${_totalAmount
                                      .toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp),
                                ),
                                SizedBox(height: 10.h),
                                CustomButton(
                                  height: 50.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 165, 6, 13),
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 97, 92, 86)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text('Checkout', style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                  ),
                                  onTap: () {
                                    // Checkout logic
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Regular cart item
                      var item = filteredCartItems[index];
                      String itemId = item.id;

                      var models = List<String>.from(
                          item['models'] ?? ["Default Model"]);
                      var prices = item['prices'] is List<dynamic>
                          ? List<int>.from(item['prices'].map((e) =>
                          (e as num).toInt()))
                          : [item['prices'] ?? 0];
                      var quantitiesAvailable = item['quantity'] is List<
                          dynamic>
                          ? List<int>.from(item['quantity'].map((e) =>
                          (e as num).toInt()))
                          : [item['quantity'] ?? 0];
                      var descriptions = item['descriptions'] is List<dynamic>
                          ? List<String>.from(item['descriptions'])
                          : [
                        item['descriptions'] ?? "No description available"
                      ];

                      int selectedIndex = selectedIndexes[item.id] ?? 0;
                      int quantity = quantities[itemId] ?? 1;
                      int availableQuantity = (quantitiesAvailable.length >
                          selectedIndex)
                          ? quantitiesAvailable[selectedIndex]
                          : 1;
                      int pricePerUnit = (prices.length > selectedIndex)
                          ? prices[selectedIndex]
                          : 0;
                      String selectedDescription = (descriptions.length >
                          selectedIndex)
                          ? descriptions[selectedIndex]
                          : "No description available";

                      return CustomButton(
                        margin: EdgeInsets.symmetric(vertical: 6.h,
                            horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 12.h,
                            horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 8, 8, 8),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: const Color.fromARGB(255, 97, 92, 86),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Individual item checkbox inside the container
                            Checkbox(
                              value: selectedItems[itemId] ?? false,
                              onChanged: (value) => _toggleSelection(itemId),
                              activeColor: Colors.red,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      FutureBuilder<String>(
                                        future: imageUrls[itemId],
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container(
                                              height: 115.w,
                                              width: 115.w,
                                              child: const Center(
                                                  child: CircularProgressIndicator()),
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
                                              height: 130.w,
                                              width: 130.w,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius
                                                    .circular(10.r),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      snapshot.data!),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                item['category'] ??
                                                    "Unnamed Product",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4.w,vertical:2.w),
                                                // margin: EdgeInsets.only(
                                                //     top: 2.h),
                                                child: Text(
                                                  models[selectedIndex],
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              SizedBox(height: 3.h),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets
                                                          .symmetric(vertical: 6
                                                          .h, horizontal: 8.w),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(5.r),
                                                        border: Border.all(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 97, 92,
                                                                86)),
                                                        color:  Colors.black,
                                                      ),
                                                      child: Text(
                                                        selectedDescription,
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors
                                                                .white70),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  Container(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.h,
                                                        horizontal: 8.w),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(5.r),
                                                      border: Border.all(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 97, 92, 86)),
                                                    ),
                                                    child: Text(
                                                      "${pricePerUnit *
                                                          quantity}",
                                                      style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.h),
                                              Container(
                                                height: 37.h,
                                                width: 130.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .circular(5.r),
                                                  border: Border.all(
                                                      color: const Color
                                                          .fromARGB(
                                                          255, 97, 92, 86)),
                                                    color:  Colors.black,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    CustomButton(
                                                      onTap: () =>
                                                          _decrementQuantity(
                                                              itemId),
                                                      padding: EdgeInsets.all(
                                                          4),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(5),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 172, 31, 37),
                                                      ),
                                                      child: Icon(Icons.remove,
                                                          size: 16,
                                                          color: Colors.white),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12.0),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            vertical: 6.h,
                                                            horizontal: 12.w),
                                                        child: Text(
                                                          '$quantity',
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: Colors
                                                                  .white),
                                                        ),
                                                      ),
                                                    ),
                                                    CustomButton(
                                                      onTap: () {
                                                        if (quantity <
                                                            availableQuantity) {
                                                          _incrementQuantity(
                                                              itemId);
                                                        }
                                                      },
                                                      padding: EdgeInsets.all(
                                                          4),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(5),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 172, 31, 37),
                                                      ),
                                                      child: Icon(
                                                          Icons.add, size: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
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
      ),
    );
  }
}
