import 'package:flutter/material.dart';

void showPurchaseDetails(BuildContext context, Map<String, dynamic> purchaseData) {
  // Extract the list of items from the purchaseData
  List<dynamic> names = purchaseData['names'];
  List<dynamic> descriptions = purchaseData['descriptions'];
  List<dynamic> imageUrls = purchaseData['imageUrls'];
  List<dynamic> points = purchaseData['points'];
  List<dynamic> prices = purchaseData['prices'];
  List<dynamic> quantities = purchaseData['quantities'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black, // Set background color to black
        title: const Text(
          "Purchase Details",
          style: TextStyle(fontSize: 18, color: Colors.white), // Set title text to white
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              return Card(
                color: const Color.fromARGB(38, 255, 255, 255), // Set card background color
                child: ListTile(
                  leading: Image.network(
                    imageUrls[index],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    names[index],
                    style: const TextStyle(color: Colors.white), // Set item name text to white
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(descriptions[index], style: const TextStyle(color: Colors.white)), // Set description text to white
                      Text('Price: \$${prices[index]}', style: const TextStyle(color: Colors.white)), // Set price text to white
                      Text('Points: ${points[index]}', style: const TextStyle(color: Colors.white)), // Set points text to white
                      Text('Quantity: ${quantities[index]}', style: const TextStyle(color: Colors.white)), // Set quantity text to white
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red, // Set button background color to red
            ),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ),
        ],
      );
    },
  );
}
