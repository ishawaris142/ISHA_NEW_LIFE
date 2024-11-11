import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';

class CashWithdrawScreen extends StatefulWidget {
  const CashWithdrawScreen({super.key});

  @override
  State<CashWithdrawScreen> createState() => _CashWithdrawScreenState();
}

class _CashWithdrawScreenState extends State<CashWithdrawScreen> {
  final TextEditingController _accountTitleController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedAccountType = 'JazzCash'; // Default selected option
  double _walletBalance = 0.0; // Initialize the wallet balance in rupees
  num totalPoints = 0; // Variable to hold total points from Firestore

  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // Fetch user points when the screen initializes
  }

  Future<void> _fetchUserPoints() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          totalPoints = data['totalPoints'] ?? 0; // Fetch totalPoints from the document

          setState(() {
            _walletBalance = totalPoints / 10; // Update the wallet balance
          });
        }
      }
    } catch (e) {
      print("Error fetching user points: $e");
    }
  }

  Future<void> _updateRemainingPoints(double remainingRupees) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      int remainingPoints = (remainingRupees * 10).toInt();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'totalPoints': remainingPoints});

      setState(() {
        totalPoints = remainingPoints;
      });
    }
  }

  // Custom method to show a SnackBar at the top of the screen
  void _showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0,
        left: 10.0,
        right: 10.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: 1.sh,
          width: 1.sw,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backk.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 40.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 32.sp),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Dashboardscreen()),
                              (Route)=>false,
                        );
                      },
                    ),
                    Text("Cash Withdraw", style: TextStyle(color: Colors.white, fontSize: 16.sp))
                  ],
                ),

                // Wallet balance section
                Container(
                  width: double.infinity,
                  height: 190.h,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 165, 6, 13),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Cash Wallet",
                                  style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Rs",
                                      style: TextStyle(
                                          fontSize: 32.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      _walletBalance.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 32.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Points",
                                  style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                ),
                                Text(
                                  "0",
                                  style: TextStyle(
                                      fontSize: 32.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 35.h),
                        Row(
                          children: [
                            _buildSmallButton(
                              icon: Icons.contact_page,
                              label: "View History",
                              onPressed: () {
                                _showTopSnackBar(context, 'Viewing account history...');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Text(
                  "Withdraw Cash",
                  style: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                // Withdraw Form
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Title',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      _buildTextField(
                        controller: _accountTitleController,
                        hintText: 'eg Ahmad Hassan',
                      ),
                      SizedBox(height: 10.h),

                      Text(
                        'Mobile Number',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      _buildTextField(
                        controller: _mobileNumberController,
                        hintText: '0300 1234567',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10.h),

                      Text(
                        'Account Type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAccountTypeOption('EasyPaisa'),
                          SizedBox(width: 20.w),
                          _buildAccountTypeOption('JazzCash'),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      Text(
                        'Amount (Rs)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      _buildTextField(
                        controller: _amountController,
                        hintText: 'eg 1200',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12.h),

                      Center(
                        child: Container(
                          width: double.infinity, // This ensures it matches the width of the parent, which should be the form width.
                          // padding: EdgeInsets.symmetric(horizontal: 20.w), // This padding controls the width indirectly.
                          child: ElevatedButton(
                            onPressed: () {
                              final accountTitle = _accountTitleController.text;
                              final mobileNumber = _mobileNumberController.text;
                              final amount = _amountController.text;

                              if (accountTitle.isNotEmpty && mobileNumber.isNotEmpty && amount.isNotEmpty) {
                                double withdrawAmount = double.parse(amount);
                                if (withdrawAmount <= _walletBalance) {
                                  setState(() {
                                    _walletBalance -= withdrawAmount;
                                  });

                                  double remainingRupees = _walletBalance;
                                  _updateRemainingPoints(remainingRupees);

                                  _showTopSnackBar(context, 'Withdrawing Rs. $withdrawAmount via $_selectedAccountType');
                                } else {
                                  _showTopSnackBar(context, 'Insufficient balance. Your balance is Rs. $_walletBalance');
                                }
                              } else {
                                _showTopSnackBar(context, 'Please fill in all fields.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 165, 6, 13),
                              padding: EdgeInsets.symmetric(vertical: 15.h), // Keep vertical padding only to control the button's height
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                side: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Text(
                              'Withdraw Cash',
                              style: TextStyle(fontSize: 16.sp, color: Colors.white),
                            ),
                          ),
                        ),
                      ),],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 8, 8, 8),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 165, 6, 13)),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Widget _buildAccountTypeOption(String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _selectedAccountType == type
              ? Color.fromARGB(255, 198, 28, 28)
              : Color.fromARGB(255, 18, 18, 18),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white54),
        ),
        child: Row(
          children: [
            Text(
              type,
              style: TextStyle(
                color: _selectedAccountType == type ? Colors.white : const Color.fromARGB(255, 230, 227, 227),
                fontSize: 16.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              Icons.circle,
              color: _selectedAccountType == type ? Colors.white : Colors.red,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: BorderSide(color: Colors.white54),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18.r),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}