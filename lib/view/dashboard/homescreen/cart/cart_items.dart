import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../../../../data/services/cart_data_service.dart';
import 'dart:ui';

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
  Map<String, int> points = {}; // Points map for each cart item based on quantity
  Map<String, int> availableQuantities =
      {}; // Tracks available quantity for each item
  List<QueryDocumentSnapshot> filteredCartItems = [];
  Map<String, Future<String>?> imageUrls = {}; // Holds image URLs for each item
  Map<String, int> selectedIndexes =
      {}; // Track selected model index for each product
  Map<String, bool> selectedItems = {}; // Track selection state of each item
  bool isAllSelected = false; // Track whether "Select All" is checked
  TextEditingController searchbarController = TextEditingController();
  TextEditingController searchbar = TextEditingController();
  bool _isSearching = false;
  final FocusNode searchFocusNode = FocusNode(); // Add FocusNode for text field
  double _totalPoints = 0.0;  // Store total points of selected items
  int _userPoints = 0;
  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Widget _buildTopBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        // Uncomment these lines if rounded corners are needed
        // topLeft: Radius.circular(30.r),
        // topRight: Radius.circular(30.r),
      ),
      child: Container(
        height: 82.h,
        width: 1.sw,
        color: const Color.fromARGB(255, 172, 31, 37),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 10.h,
              child: Row(
                children: [
                  Checkbox(
                    fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.white.withOpacity(.32);
                      }
                      return Colors.white;
                    }),
                    checkColor: Colors.red,
                    value: isAllSelected,
                    onChanged: (value) => _toggleSelectAll(),
                    activeColor: Colors.red,
                  ),
                  Text("All", style: TextStyle(fontSize: 14, color: Colors.white)),
                  SizedBox(width: 22),
                  CustomButton(
                    height: 48.h,
                    width: 125.w,
                    onTap: _showDropdown, // Opens dropdown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs. ${_totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp),
                        ),
                        Row(
                          children: [
                            Text("total Points: ",
                                style: TextStyle(fontSize: 14, color: Colors.white)),
                            Text("$_totalPoints", // Show total points here
                                style: TextStyle(fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    onTap: _showDropdown,
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_down_outlined, color: Colors.white),
                      iconSize: 30,
                      onPressed: _showDropdown, // Opens dropdown
                    ),
                  ),
                  CustomButton(
                    height: 40.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    // onTap: _handleCheckout, // Call the checkout function
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String iconPath, String title, int index) {
    return IconButton(
      icon: Image.asset(iconPath),
      onPressed: () {
        // Implement navigation or functionality here
      },
    );
  }
  Future<int> _getMaxQuantityFromProductCollections(String productId, int index) async {
    int maxQuantity = 0;

    try {
      // Check in the `products` collection
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        // Fetch the quantity field and check if it's a list
        dynamic quantityField = productSnapshot.get('quantity');
        if (quantityField is List && index < quantityField.length) {
          maxQuantity = quantityField[index];
          print('Found max quantity in products collection for productId $productId at index $index: $maxQuantity');
        } else {
          maxQuantity = 1; // Default value if index is out of bounds or quantityField is not a list
        }
      }

      // If not found or maxQuantity is zero, check in the `popular_products` collection
      if (maxQuantity == 0) {
        DocumentSnapshot popularProductSnapshot = await FirebaseFirestore.instance
            .collection('popular_products')
            .doc(productId)
            .get();

        if (popularProductSnapshot.exists) {
          dynamic quantityField = popularProductSnapshot.get('quantity');
          if (quantityField is List && index < quantityField.length) {
            maxQuantity = quantityField[index];
            print('Found max quantity in popular_products collection for productId $productId at index $index: $maxQuantity');
          } else {
            maxQuantity = 1; // Default if index is out of bounds or quantityField is not a list
          }
        }
      }
    } catch (e) {
      print("Error fetching max quantity for productId $productId: $e");
    }

    return maxQuantity > 0 ? maxQuantity : 1; // Ensure at least 1
  }


  Future<void> _fetchCartItems() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User is not authenticated.");
      return;
    }

    try {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .orderBy('timestamp', descending: true)
          .get();

      List<QueryDocumentSnapshot> fetchedCartItems = cartSnapshot.docs;
      Map<String, int> fetchedQuantities = {};
      Map<String, int> fetchedAvailableQuantities = {};
      Map<String, int> fetchedPoints = {};

      for (var item in fetchedCartItems) {
        String itemId = item.id;
        final itemData = item.data() as Map<String, dynamic>?;

        if (itemData == null) continue;

        int initialQuantity = itemData['quantity'] as int? ?? 1;
        fetchedQuantities[itemId] = initialQuantity;
        fetchedPoints[itemId] = initialQuantity * 10;
        print('Initial quantity for itemId $itemId: ${fetchedQuantities[itemId]}');
        print('Max available quantity for itemId $itemId: ${fetchedAvailableQuantities[itemId]}');


        // Fetch the product ID and index to get the max quantity
        String productid = itemData['productid'] ?? '';
        int desiredIndex = 0; // Default to first model or update as needed
        int maxQuantity = await _getMaxQuantityFromProductCollections(productid, desiredIndex);

        fetchedAvailableQuantities[itemId] = maxQuantity > 0 ? maxQuantity : initialQuantity;

        imageUrls[itemId] = itemData['imageUrl'] != null
            ? _getDownloadUrl(itemData['imageUrl'])
            : Future.value('');
        selectedItems[itemId] = false;
      }

      setState(() {
        cartItems = fetchedCartItems;
        filteredCartItems = fetchedCartItems;
        quantities = fetchedQuantities;
        availableQuantities = fetchedAvailableQuantities;
        points = fetchedPoints;
        _calculateTotals();
      });
    } catch (e) {
      print("Error fetching cart items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load cart items. Please try again later.")),
      );
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

  Future<void> _deleteSelectedItems() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      for (String itemId in selectedItems.keys) {
        if (selectedItems[itemId] == true) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('cart')
              .doc(itemId)
              .delete();
        }
      }
      _fetchCartItems();
    }
  }

  void _calculateTotals() {
    double totalAmount = 0.0;
    double totalPoints = 0.0;  // Variable to store total points of selected items
    for (var item in cartItems) {
      String itemId = item.id;
      if (selectedItems[itemId] ?? false) {
        // Only add selected items to total
        int price = (item['prices'] as List<dynamic>?)?.first as int? ?? 0;
        int quantity = quantities[item.id] ?? 1;
        totalAmount += price * quantity;

        // Add points for selected items
        totalPoints += points[itemId] ?? 0;
      }
    }
    setState(() {
      _totalAmount = totalAmount;
      _totalPoints = totalPoints;  // Store total points
    });
  }

  void _toggleSelection(String itemId) {
    setState(() {
      selectedItems[itemId] = !(selectedItems[itemId] ?? false); // Toggle item selection
      isAllSelected = !selectedItems.containsValue(false); // Update "Select All" state
      _calculateTotals(); // Recalculate totals including points
    });
  }

  void _toggleSelectAll() {
    setState(() {
      isAllSelected = !isAllSelected; // Toggle "Select All" state
      selectedItems.updateAll(
          (key, value) => isAllSelected); // Set all items based on "Select All"
      _calculateTotals();
    });
  }

  void _showDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    minChildSize: 0.2,
                    maxChildSize: 0.75,
                    builder: (_, controller) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 172, 31, 37),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.r),
                            topRight: Radius.circular(15.r),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Summary",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: Colors.white),
                            // Summary items
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  _buildSummaryRow("Subtotal",
                                      "PKR ${_totalAmount.toStringAsFixed(0)}"),
                                  SizedBox(height: 12),
                                  _buildSummaryRow("Shipping fee", "PKR 553"),
                                  SizedBox(height: 12),
                                  _buildSummaryRow(
                                    "Saved",
                                    "- PKR 553",
                                    valueColor: Colors.red,
                                    showDropdownIcon: true,
                                  ),
                                  Divider(height: 24),
                                  _buildSummaryRow(
                                    "Total",
                                    "PKR ${_totalAmount.toStringAsFixed(0)}",
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            // Checkout button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add checkout logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(double.infinity, 50.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                ),
                                child: Text(
                                  "Checkout (${selectedItems.values.where((isSelected) => isSelected).length})",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// Helper method to build summary rows
  Widget _buildSummaryRow(
    String title,
    String value, {
    Color valueColor = Colors.white,
    bool isBold = false,
    bool showDropdownIcon = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
            ),
            if (showDropdownIcon) ...[
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white),
            ],
          ],
        ),
      ],
    );
  }

  void _incrementQuantity(String productId) {
    int currentQuantity = quantities[productId] ?? 1;
    int maxQuantity = availableQuantities[productId] ?? 1;

    setState(() {
      if (currentQuantity < maxQuantity) {
        quantities[productId] = currentQuantity + 1;
        points[productId] = quantities[productId]! * 10;
      } else {
        print('🐱‍👤🐱‍👤🐱‍👤🐱‍👤🎉🎉Cannot increment further. Reached max quantity for productId $productId');
        _showTopSnackBar(context, 'Cannot add more. Maximum quantity reached.');
      }
    });
  }

  void _decrementQuantity(String productId) {
    int currentQuantity = quantities[productId] ?? 1;

    print('Decrementing quantity for productId $productId. Current: $currentQuantity');

    setState(() {
      if (currentQuantity > 1) {
        quantities[productId] = currentQuantity - 1;
        points[productId] = quantities[productId]! * 10;
      } else {
        print('Cannot decrement below 1 for productId $productId');
        _showDeletionPopup(context, productId);
      }
    });
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



  void _showDeletionPopup(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  // Future<void> _handleCheckout() async {
  //   String? userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) {
  //     print("User is not authenticated.");
  //     return;
  //   }
  //
  //   try {
  //     // Step 1: Collect selected items
  //     List<Map<String, dynamic>> selectedProducts = [];
  //     int totalPointsEarned = 0;
  //
  //     for (var item in selectedItems.keys) {
  //       if (selectedItems[item] == true) {
  //         var cartItem = cartItems.firstWhere((element) => element.id == item);
  //         Map<String, dynamic> itemData = cartItem.data() as Map<String, dynamic>;
  //
  //         // Create the history entry for each selected item
  //         selectedProducts.add({
  //           "productId": itemData['productid'] ?? '',
  //           "model": itemData['models']?[selectedIndexes[item] ?? 0] ?? '',
  //           "price": itemData['prices']?[selectedIndexes[item] ?? 0] ?? 0,
  //           "quantity": quantities[item] ?? 1,
  //           "timestamp": FieldValue.serverTimestamp(),
  //         });
  //
  //         // Calculate total points earned from this item
  //         totalPointsEarned += points[item] ?? 0;
  //       }
  //     }
  //
  //     if (selectedProducts.isEmpty) {
  //       _showTopSnackBar(context, 'No items selected for checkout.');
  //       return;
  //     }
  //
  //     // Step 2: Add the products to the "history" collection
  //     for (var product in selectedProducts) {
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userId)
  //           .collection('history')
  //           .add(product);
  //     }
  //
  //     // Step 3: Update user points with conversion logic
  //     DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .get();
  //
  //     int currentPoints = userSnapshot['points'] ?? 0;
  //
  //     // Convert points to rupees
  //     double currentPointsInRupees = (currentPoints / 1000) * 10;
  //     double earnedPointsInRupees = (totalPointsEarned / 1000) * 10;
  //
  //     // Update the total points in rupees
  //     double updatedPointsInRupees = currentPointsInRupees + earnedPointsInRupees;
  //
  //     // Convert rupees back to points for storage
  //     int updatedPoints = ((updatedPointsInRupees / 10) * 1000).round();
  //
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .update({"points": updatedPoints});
  //
  //     // Step 4: Remove selected items from the cart
  //     for (var item in selectedItems.keys) {
  //       if (selectedItems[item] == true) {
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(userId)
  //             .collection('cart')
  //             .doc(item)
  //             .delete();
  //       }
  //     }
  //
  //     // Step 5: Update the UI
  //     _showTopSnackBar(context, 'Checkout Successfull');
  //
  //
  //     setState(() {
  //       selectedItems.clear();
  //       _fetchCartItems();
  //       _fetchUserPoints(); // Refresh user points
  //     });
  //   } catch (e) {
  //     print("Error during checkout: $e");
  //     _showTopSnackBar(context, 'Checkout failed. Please try again.');
  //   }
  // }
  Future<void> _fetchUserPoints() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        _userPoints = userSnapshot['points'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboardscreen()),
              (Route) => false,
        );
        return true;
      },
      child: Scaffold(
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
              margin: const EdgeInsets.only(top: 30, bottom: 52),
             // padding: const EdgeInsets.only(left: 4, right: 2),
              child: Column(
                children: [
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
                        "Cart",
                        style: TextStyle(
                            fontSize: 19.sp,
                            color: Colors.white), // Responsive font size
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 70.w), // Responsive padding
                          child: Container(
                            height: 37.h, // Responsive height
                            // width:10.w,
                            margin: EdgeInsets.only(
                                left: 15.w, right: 10.w), // Responsive margins
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 32, 32, 32),
                              borderRadius: BorderRadius.circular(
                                  10.r), // Responsive border radius
                              border: Border.all(
                                color: const Color.fromARGB(255, 97, 92, 86),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchbar,
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
                                    onChanged: _filterCartItems,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (searchbar.text.isEmpty) {
                                      FocusScope.of(context)
                                          .unfocus(); // Close the keyboard if the text field is empty
                                      setState(() {
                                        _isSearching =
                                            false; // Hide the cross icon if not in search mode
                                        filteredCartItems =
                                            cartItems; // Reset the filtered data
                                      });
                                    } else {
                                      searchbar.clear(); // Clear text only
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 190), // Add space between text and delete icon
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Color.fromARGB(255, 172, 31, 37)),
                        onPressed: () {
                          if (selectedItems.containsValue(true)) {
                            _deleteSelectedItems(); // Call function to delete selected items
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("No items selected to delete")),
                            );
                          }
                        },
                      ),
                      // Checkbox(
                      //   value: isAllSelected,
                      //   onChanged: (value) => _toggleSelectAll(),
                      //   activeColor: Color.fromARGB(255, 172, 31, 37),
                      // ),
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
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 150),
                              child: Container());
                        }

                        // Regular cart item
                        var item = filteredCartItems[index];
                        String itemId = item.id;

                        var models = List<String>.from(
                            item['models'] ?? ["Default Model"]);
                        var prices = item['prices'] is List<dynamic>
                            ? List<int>.from(
                                item['prices'].map((e) => (e as num).toInt()))
                            : [item['prices'] ?? 0];
                        var quantitiesAvailable = item['quantity']
                                is List<dynamic>
                            ? List<int>.from(
                                item['quantity'].map((e) => (e as num).toInt()))
                            : [item['quantity'] ?? 0];
                        var descriptions = item['descriptions'] is List<dynamic>
                            ? List<String>.from(item['descriptions'])
                            : [
                                item['descriptions'] ?? "No description available"
                              ];
                        var pointsList = item['points'] is List<dynamic>
                            ? List<int>.from(
                            item['points'].map((e) => (e as num).toInt()))
                            : [item['points']];
                        int selectedPoints = points[item.id] ?? 10;

                        int selectedIndex = selectedIndexes[item.id] ?? 0;
                        int quantity = quantities[itemId] ?? 1;
                        int availableQuantity =
                            (quantitiesAvailable.length > selectedIndex)
                                ? quantitiesAvailable[selectedIndex]
                                : 1;
                        int pricePerUnit = (prices.length > selectedIndex)
                            ? prices[selectedIndex]
                            : 0;
                        String selectedDescription =
                            (descriptions.length > selectedIndex)
                                ? descriptions[selectedIndex]
                                : "No description available";
                        return CustomButton(
                          margin: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 4.w),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 8, 8, 8),
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: const Color.fromARGB(255, 97, 92, 86),
                            ),
                          ),
                          child: Row(
                            children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.r),
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
                                            padding: EdgeInsets.only(
                                                left: 10.w, right: 5.w),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: 36.h, // Responsive height
                                                      width: 130.w, // Responsive width
                                                      child: Text(
                                                        item['category'],
                                                        style: TextStyle(
                                                          fontSize: 14.sp, // Responsive font size
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Points",
                                                          style: TextStyle(
                                                            fontSize: 8.sp,  // Responsive font size
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        CustomButton(
                                                          padding: EdgeInsets.symmetric(horizontal: 7.w), // Responsive horizontal padding
                                                          child: Text(
                                                            "$selectedPoints",
                                                            style: TextStyle(
                                                              fontSize: 11.sp, // Responsive font size
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: const Color.fromARGB(255, 97, 92, 86),
                                                            ),
                                                            borderRadius: BorderRadius.circular(5.r), // Responsive border radius
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4.w,
                                                      vertical: 2.w),
                                                  child: Text(
                                                    models[selectedIndex],
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 3.h),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 6.h,
                                                            horizontal: 8.w),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(5.r),
                                                          border: Border.all(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  97, 92, 86)),
                                                          color: Colors.black,
                                                        ),
                                                        child: Text(
                                                          selectedDescription,
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.white70,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Container(
                                                      padding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 6.h,
                                                          horizontal: 8.w),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5.r),
                                                        border: Border.all(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 97, 92, 86)),
                                                      ),
                                                      child: Text(
                                                        "${pricePerUnit * quantity}",
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: Colors.white,
                                                        ),
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
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        5.r),
                                                    border: Border.all(
                                                        color:
                                                        const Color.fromARGB(
                                                            255, 97, 92, 86)),
                                                    color: Colors.black,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      CustomButton(
                                                        onTap: () =>
                                                            _decrementQuantity(
                                                                itemId),
                                                        padding:
                                                        EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
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
                                                        padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.0),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              vertical: 6.h,
                                                              horizontal:
                                                              12.w),
                                                          child: Text(
                                                            '$quantity',
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: Colors.white,
                                                            ),
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
                                                        padding:
                                                        EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(5),
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 172, 31, 37),
                                                        ),
                                                        child: Icon(Icons.add,
                                                            size: 16,
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
                  _buildTopBar(), // Add the navigation bar here
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
