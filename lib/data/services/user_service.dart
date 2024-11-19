import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  // Fetch and cache user data
  Future<Map<String, dynamic>?> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedUserData = prefs.getString('userData');

    if (cachedUserData != null) {
      return jsonDecode(cachedUserData);
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          await prefs.setString('userData', jsonEncode(userData));
          return userData;
        }
      }
    }
    return null;
  }

  // Fetch and cache user total points
  Future<num> fetchTotalPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedTotalPoints = prefs.getString('points');

    if (cachedTotalPoints != null) {
      return num.tryParse(cachedTotalPoints) ?? 0;
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          num points = userData['points'] ?? 0;

          await prefs.setString('points', points.toString());
          return points;
        }
      }
    }
    return 0;
  }

  // Deduct points based on the withdrawn amount (convert currency to points)
  Future<void> deductPointsForWithdrawal(double withdrawAmount) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int pointsToDeduct = (withdrawAmount * 10).toInt();
    num updatedPoints = await fetchTotalPoints() - pointsToDeduct;

    if (updatedPoints < 0) {
      updatedPoints = 0; // Ensure points don't go below zero
    }

    // Update Firestore and cache
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('points', updatedPoints.toString());
  }

  // Clear cache
  Future<void> clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove('points');
  }
}