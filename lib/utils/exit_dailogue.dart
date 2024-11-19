import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowExitPopup {
  static DateTime? _lastBackPressed;

  static Future<bool> handleExit(BuildContext context) async {
    final currentTime = DateTime.now();
    if (_lastBackPressed == null ||
        currentTime.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = currentTime;

      // Show a custom overlay message in the middle of the screen
      _showCustomMessage(context, "Click again to Exit");
      return Future.value(false); // Do not exit
    }

    // Exit the app
    SystemNavigator.pop();
    return Future.value(true); // Exit
  }

  static void _showCustomMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - -110, // Center vertically
        left: MediaQuery.of(context).size.width / 2 - 85, // Center horizontally
        child: Material(
          color: Colors.transparent, // Transparent background
          child: Container(
            width: 170, // Fixed width
            height: 50, // Fixed height
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black45, // Background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    overlay?.insert(overlayEntry);

    // Remove the overlay after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}