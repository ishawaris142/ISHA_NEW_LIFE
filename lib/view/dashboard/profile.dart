import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_coprative/data/services/cart_provider.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import '../auth/edit_profile_screen.dart';
import '../auth/login.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  void didChangeDependencies() {
    super.didChangeDependencies();
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
            userData = doc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboardscreen()),
              (Route) => false,
        );
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backk.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 28.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Image.asset("assets/profilelogout.png",height: 30,),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 17.0),
                    userData.isNotEmpty
                        ? ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundImage: AssetImage("assets/Kid.png"),
                      ),
                      title: Text(
                        userData['full_name'] ?? "Name not available",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Image.asset("assets/mechanic.png",
                              height: 20.0, width: 20.0),
                          SizedBox(width: 4.0),
                          Text(
                            userData['account_type'] ??
                                "Account type not available",
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Image.asset("assets/BiSolidEditAlt.png",
                            height: 24.0, width: 24.0),
                        onPressed: () {
                          // Call the provider method to update state
                          context.read<CartProvider>().onisEdit(true);
                        },
                      ),
                    )
                        : const CircularProgressIndicator(),
                    SizedBox(height: 40.0),
                    if (userData.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Column(

                          children: [
                            _buildUserInfoRow(Icons.mail_outline,
                                userData['email'] ?? "Email not available"),
                            SizedBox(height: 15.0),
                            _buildUserInfoRow(Icons.phone,
                                userData['phone'] ?? "Phone not available"),
                            SizedBox(height: 15.0),
                            _buildUserInfoRow(Icons.credit_card_rounded,
                                userData['cnic'] ?? "CNIC not available"),
                            SizedBox(height: 15.0),
                            _buildUserInfoRow(Icons.location_on_outlined,
                                userData['address'] ?? "Address not available"),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Rebuilds to show EditProfileScreen when iseditScreen is true
            Consumer<CartProvider>(builder: (context, value, child) {
              return value.iseditScreen
                  ? EditProfileScreen(userData: userData)
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, color: Color.fromARGB(255, 211, 35, 23), size: 20.0),
        SizedBox(width: 3.0),
        Text(info, style: TextStyle(color: Colors.white, fontSize: 16.0)),
      ],
    );
  }
}
