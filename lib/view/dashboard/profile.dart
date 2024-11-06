import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:red_coprative/view/dashboard/account.dart';
import 'package:red_coprative/view/auth/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../auth/edit_profile_screen.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>?;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: 1.sh,
        width: 1.sw,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backk.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Image.asset("assets/profilelogout.png"),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 17.h),
            userData != null
                ? ListTile(
                    leading: CircleAvatar(
                      radius: 30.r,
                      backgroundImage: AssetImage("assets/Kid.png"),
                    ),
                    title: Text(
                      userData?['full_name'] ?? "Name not available",
                      style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    subtitle: Row(
                      children: [
                        Image.asset("assets/mechanic.png", height: 20.h, width: 20.w),
                        SizedBox(width: 4.w),
                        Text(
                          userData?['account_type'] ?? "Account type not available",
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        )
                      ],
                    ),
                    trailing: IconButton(
                      icon: Image.asset("assets/BiSolidEditAlt.png", height: 24.h, width: 24.w),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(userData: userData!),
                          ),
                        );
                      },
                    ),
                  )
                : const CircularProgressIndicator(),
            SizedBox(height: 40.h),
            if (userData != null)
              Container(
                margin: EdgeInsets.only(left: 25.w),
                child: Column(
                  children: [
                    _buildUserInfoRow(Icons.mail_outline, userData?['email'] ?? "Email not available"),
                    SizedBox(height: 15.h),
                    _buildUserInfoRow(Icons.phone, userData?['phone'] ?? "Phone not available"),
                    SizedBox(height: 15.h),
                    _buildUserInfoRow(Icons.credit_card_rounded, userData?['cnic'] ?? "CNIC not available"),
                    SizedBox(height: 15.h),
                    _buildUserInfoRow(Icons.location_on_outlined, userData?['address'] ?? "Address not available"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color.fromARGB(255, 211, 35, 23),
          size: 20.w,
        ),
        SizedBox(width: 3.w),
        Text(
          info,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        )
      ],
    );
  }
}
