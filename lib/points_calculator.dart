import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsCalculator {
  // Function to calculate total points based on the user's purchases
  Future<int> calculateTotalPoints() async {
    int totalPoints = 0;

    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user's purchase history from the 'history' collection
        QuerySnapshot historySnapshot = await FirebaseFirestore.instance
            .collection('history')
            .where('userId', isEqualTo: user.uid) // Ensure the user's history is fetched
            .get();

        // Check if there are any history records
        if (historySnapshot.docs.isEmpty) {
          print("No purchase history found for the user.");
          return 0; // No points if there's no history
        }

        // Loop through each purchase and sum up the points
        for (var doc in historySnapshot.docs) {
          int points = doc['totalPoints'] ?? 0; // Default to 0 if totalPoints is missing
          totalPoints += points;
        }
      }
    } catch (e) {
      print("Error calculating total points: $e");
    }

    return totalPoints;
  }
}
