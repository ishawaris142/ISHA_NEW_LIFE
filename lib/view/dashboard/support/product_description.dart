import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/services/cart_data_service.dart';

class ProductDescriptionPage extends StatefulWidget {
  final String categoryName;
  final String modelName;
  final String imageUrl; // Assuming this is a gsUrl
  final int price;
  final int availableQuantity;
  final String selectedDescription;
  final int points;
  final String productid;


  const ProductDescriptionPage({
    Key? key,
    required this.categoryName,
    required this.modelName,
    required this.imageUrl,
    required this.price,
    required this.availableQuantity,
    required this.selectedDescription,
    required this.productid,  // Add this line
    required this.points,  // Add this line
  }) : super(key: key);

  @override
  _ProductDescriptionPageState createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  final CartService cartService = CartService();
  int _quantity = 1; // Default quantity is 1
  bool _isAddingToCart = false; // To handle loading state
  String? _resolvedImageUrl; // To store the resolved image URL
  bool _isLoadingImage = true; // To track image loading state

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }

  Future<void> _fetchImageUrl() async {
    try {
      String url = await cartService.getDownloadUrl(widget.imageUrl);
      setState(() {
        _resolvedImageUrl = url;
        _isLoadingImage = false;
      });
    } catch (e) {
      print('Error fetching image URL: $e');
      setState(() {
        _resolvedImageUrl = '';
        _isLoadingImage = false;
      });
    }
  }

  void _showTopSnackBar(String message, {Color color = Colors.green}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color,
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

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      if (_resolvedImageUrl == null || _resolvedImageUrl!.isEmpty) {
        throw Exception("Image URL not available.");
      }

      print('😎Debug: Adding to cart with the following details:');
      print('🤦‍♀️Model Name: ${widget.modelName}');
      print('🐱‍👤Category: ${widget.categoryName}');
      print('😂Selected Description: ${widget.selectedDescription}');
      print('😊Selected Model: ${widget.modelName}');
      print('🎶🙌Price: ${widget.price}');
      print('🤦‍♂️Quantity: $_quantity');
      print('✔✔Resolved Image URL: $_resolvedImageUrl');

      await cartService.addToCart(
        productid: widget.productid,  // Pass productId as int
        category: widget.categoryName,
        selectedDescription: [widget.selectedDescription],
        selectedModel: [widget.modelName],
        selectedPrice: [widget.price],
        imageUrl: _resolvedImageUrl!,
        quantity: _quantity,
        selectedPoints: [widget.points],
      );

      print('Debug: Item added to cart successfully');
      _showTopSnackBar('${widget.modelName} added to cart, Quantity: $_quantity');
    } catch (e) {
      print('Error: Failed to add to cart: $e');
      _showTopSnackBar('Failed to add to cart: $e', color: Colors.red);
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
      print('Debug: _isAddingToCart set to false');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backk.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding:
            const EdgeInsets.only(top: 30, bottom: 100, left: 13, right: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.categoryName,
                      style: const TextStyle(fontSize: 19, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _isLoadingImage
                    ? const Center(child: CircularProgressIndicator())
                    : _resolvedImageUrl == null || _resolvedImageUrl!.isEmpty
                    ? Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                )
                    : AspectRatio(
                  aspectRatio: 80 / 70,
                  child: Image.network(
                    _resolvedImageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.modelName,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: Rs. ${widget.price * _quantity}', // Update price dynamically
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Available Quantity: ${widget.availableQuantity}',
                  style: TextStyle(
                    color:
                    widget.availableQuantity > 0 ? Colors.white : Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Description: '
                      'Cars are a vital part of modern transportation, offering convenience, efficiency, '
                      'and comfort for daily commutes and long journeys...',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                widget.availableQuantity > 0
                    ? Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_quantity > 1) _quantity--;
                                });
                              },
                              child: Container(
                                height: 37.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 172, 31, 37),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: const Center(
                                  child: Icon(Icons.remove, color: Colors.white),
                                ),
                              ),
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_quantity < widget.availableQuantity)
                                    _quantity++;
                                });
                              },
                              child: Container(
                                height: 37.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 172, 31, 37),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA5060D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                          const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Sold Out',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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
