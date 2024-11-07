import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddToCart extends StatelessWidget {
  const AddToCart({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments using ModalRoute
    final Map<String, dynamic> productData =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String productName = productData['name'];
    int productPrice = productData['price'];
    String productDescription = productData['description'];
    List<String> productImages = List<String>.from(productData['images'] ?? []);
    List<String> productModels = List<String>.from(productData['models'] ?? []);
    List<int> productQuantities = List<int>.from(productData['quantities'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200.h,
              width: double.infinity,
              child: productImages.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: Image.network(
                      productImages[index],
                      fit: BoxFit.cover,
                      width: 180.w,
                      height: 180.h,
                    ),
                  );
                },
              )
                  : const Text(
                'No images available',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              productName,
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Price: Rs ${productPrice.toString()}",
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              productDescription,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            // Display array-based data like models and quantities
            productModels.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Available Models:",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                ...productModels.asMap().entries.map((entry) {
                  int index = entry.key;
                  String model = entry.value;
                  int quantity = productQuantities[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          model,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "Quantity: $quantity",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            )
                : const Text(
              'No models available',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
