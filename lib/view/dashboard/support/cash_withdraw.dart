import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/view/dashboard/dashboard.dart';
import 'package:red_coprative/view/dashboard/homescreen/homescreen.dart';

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
  bool _showExitConfirmation = false;
  // List of banks
  final List<String> _banks = [
    'Habib Bank Limited',
    'Meezan Bank',
    'Allied Bank',
    'Askari Bank',
    'Bank Alfalah',
    'NCB',
    "Bank AL-Habib",
    "Bank of Punjab",
    "HBL",
    "HBL KONNECT",
    'Habib Metro',
    'MCB',
    'MCB Islamic',
    'UBL',
    'JS Bank',
    'EasyPaisa-Telenor Bank',
    'NayaPay',
    'PayMax',
    'SadaPay',
    'uBank/UPaisa',
    'Mobilink Bank/JazzCash',
    'Bank of Khyber',

  ];
  String? _selectedBank; // Variable to store the selected bank

  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // Fetch user points when the screen initializes
  }

  Future<void> _fetchUserPoints() async {
    try {
      User? user =
          FirebaseAuth.instance.currentUser; // Get the currently logged-in user

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          totalPoints =
              data['totalPoints'] ?? 0; // Fetch totalPoints from the document

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
            body: Stack(children: [
              GestureDetector(
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

                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                      margin: EdgeInsets.only(bottom: 170),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white,),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Dashboardscreen()),
                                        (Route) => false,
                                  ); // This will navigate back to the previous screen
                                },
                              ),
                              Text("Convert Points",
                                  style: TextStyle(fontSize: 19.sp, color: Colors.white)),
                            ],
                          ),
                          SizedBox(height: 25),
                          // Wallet balance section
                          Container(
                            width: double.infinity,
                            height: 190.h,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 165, 6, 13),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color.fromARGB(255, 8, 8, 8),)
                              //  color: const Color.fromARGB(255, 8, 8, 8),

                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 19.w, vertical: 14.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "Cash Value",
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: Colors.white),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Rs",style: TextStyle(fontSize: 32.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                _walletBalance.toStringAsFixed(2),
                                                style: TextStyle(fontSize: 32.sp,color: Colors.white,
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
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            "0",
                                            style: TextStyle(
                                                fontSize: 32.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
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
                                          _showTopSnackBar(context,
                                              'Viewing account history...');
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
                            "Request Cash Withdraw",
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
                                  "Select Bank Account",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true, // Align dropdown with the button
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color.fromARGB(255, 8, 8, 8),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white54),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color.fromARGB(255, 165, 6, 13)),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      dropdownColor: Color(0xFF2C2C2C), // Dropdown background color
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                      value: _selectedBank, // Initial value (can be null)
                                      hint: Text(
                                        'Select a Bank',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      menuMaxHeight: 230.h, // Height of dropdown
                                      items: _banks.map((bank) {
                                        return DropdownMenuItem<String>(
                                          value: bank,
                                          child: SizedBox(
                                            width: 150.0, // Set custom width here
                                            child: Text(bank),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedBank = value; // Update the selected bank
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a bank';
                                        }
                                        return null; // No validation error
                                      },
                                    ),
                                  ),
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
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final accountTitle =
                                            _accountTitleController.text;
                                        final mobileNumber =
                                            _mobileNumberController.text;
                                        final amount = _amountController.text;

                                        if (accountTitle.isNotEmpty &&
                                            mobileNumber.isNotEmpty &&
                                            amount.isNotEmpty) {
                                          double withdrawAmount =
                                          double.parse(amount);
                                          if (withdrawAmount <= _walletBalance) {
                                            setState(() {
                                              _walletBalance -= withdrawAmount;
                                            });

                                            double remainingRupees =
                                                _walletBalance;
                                            _updateRemainingPoints(
                                                remainingRupees);

                                            _showTopSnackBar(context,
                                                'Withdrawing Rs. $withdrawAmount via $_selectedAccountType');
                                          } else {
                                            _showTopSnackBar(context,
                                                'Insufficient balance. Your balance is Rs. $_walletBalance');
                                          }
                                        } else {
                                          _showTopSnackBar(context,
                                              'Please fill in all fields.');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color.fromARGB(255, 165, 6, 13),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15
                                                .h), // Keep vertical padding only to control the button's height
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                          side: BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      child: Text(
                                        'Request Cash Withdraw',
                                        style: TextStyle(
                                            fontSize: 16.sp, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ])));
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
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
