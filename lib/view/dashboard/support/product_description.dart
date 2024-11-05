import 'package:flutter/material.dart';
import '../../../data/services/cart_data_service.dart';

class ProductDescriptionPage extends StatefulWidget {
  final String categoryName;
  final String modelName;
  final String imageUrl;
  final int price;
  final int availableQuantity;

  const ProductDescriptionPage({
    Key? key,
    required this.categoryName,
    required this.modelName,
    required this.imageUrl,
    required this.price,
    required this.availableQuantity,
  }) : super(key: key);

  @override
  _ProductDescriptionPageState createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  final CartService cartService = CartService();
  int _quantity = 1; // Default quantity is 1

  void _showTopSnackBar(String message) {
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

  @override
  Widget build(BuildContext context) {
     var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     widget.categoryName,
      //     style: const TextStyle(color: Colors.white),
      //   ),
      
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ),
      body: Container(
                height: height,
      width: width,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/backk.png"),fit: BoxFit.fill)),
        child: FutureBuilder<String>(
          future: cartService.getDownloadUrl(widget.imageUrl),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Container(
               
                padding: const EdgeInsets.only(top: 30, bottom: 100, left: 13, right: 13),
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
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty)
                      Container(
                        height: 200,
                        color: Colors.grey,
                        child: const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      )
                    else
                      AspectRatio(
                        aspectRatio: 80 / 70,
                        child: Image.network(
                          snapshot.data!,
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
                        color: widget.availableQuantity > 0 ? Colors.white : Colors.red,
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
                              border: Border.all(color: Colors.white),
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
                                  child: const Icon(Icons.remove, color: Colors.white),
                                ),
                                Text(
                                  '$_quantity',
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_quantity < widget.availableQuantity) _quantity++;
                                    });
                                  },
                                  child: const Icon(Icons.add, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              _showTopSnackBar('${widget.modelName} added to cart, Quantity: $_quantity');
                            },
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA5060D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
            );
          },
             ),
      )
  );
 }
}