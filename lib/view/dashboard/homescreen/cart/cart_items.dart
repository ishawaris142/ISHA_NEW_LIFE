import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../../../../data/services/cart_data_service.dart';
import '../../../../data/services/cart_items_fetching.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final CartItemsFetching _cartItemsFetching = CartItemsFetching();

  double _totalAmount = 0.0;
  Map<String, int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    await _cartItemsFetching.fetchCartItems();
    setState(() {
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    double totalAmount = 0.0;
    for (var item in _cartItemsFetching.cartItems) {
      int price = (item['prices'] as List<dynamic>?)?.first as int? ?? 0;
      int quantity = _cartItemsFetching.quantities[item.id] ?? 1;
      totalAmount += price * quantity;
    }
    setState(() {
      _totalAmount = totalAmount;
    });
  }

  void _incrementQuantity(String itemId) {
    int availableQuantity = _cartItemsFetching.availableQuantities[itemId] ?? 1;
    setState(() {
      if ((_cartItemsFetching.quantities[itemId] ?? 1) < availableQuantity) {
        _cartItemsFetching.quantities[itemId] =
            (_cartItemsFetching.quantities[itemId] ?? 1) + 1;
        _calculateTotals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Maximum available quantity reached")),
        );
      }
    });
  }

  void _decrementQuantity(String itemId) {
    setState(() {
      if ((_cartItemsFetching.quantities[itemId] ?? 1) > 1) {
        _cartItemsFetching.quantities[itemId] =
            (_cartItemsFetching.quantities[itemId] ?? 1) - 1;
      } else {
        _showDeletionPopup(context, itemId);
      }
      _calculateTotals();
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
              foregroundColor: Colors.black, backgroundColor: Colors.white,
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
              backgroundColor:const Color.fromARGB(255, 172, 31, 37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
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
                // Top bar with back button and "Cart" title
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Dashboardscreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Cart",
                      style: TextStyle(fontSize: 19.sp, color: Colors.white),
                    ),
                  ],
                ),

                // Cart items list
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItemsFetching.cartItems.length + 1,
                    padding: const EdgeInsets.only(top: 5),
                    itemBuilder: (context, index) {
                      if (index == _cartItemsFetching.cartItems.length) {
                        // Total Amount and Checkout button at the bottom
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 150),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  'Total Amount: Rs. ${_totalAmount.toStringAsFixed(2)}',
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
                                    color: const Color.fromARGB(255, 165, 6, 13),
                                    border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 18)),
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

                      // Regular cart item display
                      var item = _cartItemsFetching.cartItems[index];
                      String itemId = item.id;
                      int quantity = _cartItemsFetching.quantities[itemId] ?? 1;

                      var models = List<String>.from(item['models'] ?? ["Default Model"]);
                      var prices = item['prices'] is List<dynamic>
                          ? List<int>.from(item['prices'].map((e) => (e as num).toInt()))
                          : [item['prices'] ?? 0];
                      var descriptions = item['descriptions'] is List<dynamic>
                          ? List<String>.from(item['descriptions'])
                          : [item['descriptions'] ?? "No description available"];

                      int selectedIndex = selectedIndexes[item.id] ?? 0;
                      int pricePerUnit = (prices.length > selectedIndex) ? prices[selectedIndex] : 0;
                      String selectedModel = (models.length > selectedIndex) ? models[selectedIndex] : "Default Model";
                      String selectedDescription = (descriptions.length > selectedIndex) ? descriptions[selectedIndex] : "No description available";

                      return CustomButton(
                        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 8, 8, 8),
                          borderRadius: BorderRadius.circular(15.r),
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
                                  future: _cartItemsFetching.imageUrls[itemId],
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        height: 119.w,
                                        width: 119.w,
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
                                        height: 130.w,
                                        width: 130.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.r),
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
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['category'] ?? "Unnamed Product",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                                          margin: EdgeInsets.only(top: 8.h),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.r),
                                            border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                                            color: const Color.fromARGB(255, 32, 32, 32),
                                          ),
                                          child: Text(
                                            selectedModel,
                                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5.r),
                                                  border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                                                  color: const Color.fromARGB(255, 32, 32, 32),
                                                ),
                                                child: Text(
                                                  selectedDescription,
                                                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5.r),
                                                border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                                              ),
                                              child: Text(
                                                "Rs. ${pricePerUnit * quantity}",
                                                style: TextStyle(fontSize: 12.sp, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomButton(
                                              onTap: () => _decrementQuantity(itemId),
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: const Color.fromARGB(255, 172, 31, 37),
                                              ),
                                              child: Icon(Icons.remove, size: 16, color: Colors.white),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5.r),
                                                  border: Border.all(color: const Color.fromARGB(255, 97, 92, 86)),
                                                  color: const Color.fromARGB(255, 32, 32, 32),
                                                ),
                                                child: Text(
                                                  '$quantity',
                                                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            CustomButton(
                                              onTap: () {
                                                int availableQuantity = _cartItemsFetching.availableQuantities[itemId] ?? 1;
                                                if (quantity < availableQuantity) {
                                                  _incrementQuantity(itemId);
                                                }
                                              },
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: const Color.fromARGB(255, 172, 31, 37),
                                              ),
                                              child: Icon(Icons.add, size: 16, color: Colors.white),
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
