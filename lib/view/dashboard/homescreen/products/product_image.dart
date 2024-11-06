import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final Future<String>? imageUrl;

  const ProductImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 132,
            width: 132,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 132,
            width: 132,
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.red),
          );
        } else {
          return Container(
            height: 132,
            width: 132,
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
    );
  }
}
