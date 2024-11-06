import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Icon(
                      Icons.qr_code_scanner_sharp,
                      size: 28,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Wallet balance section
                Container(
                  width: double.infinity,
                  height: 210.h,
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
                                const Text(
                                  "Cash Wallet",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Rs",
                                      style: TextStyle(
                                          fontSize: 32,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      _walletBalance.toStringAsFixed(2),
                                      style: const TextStyle(
                                          fontSize: 32,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Points",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                                const Text(
                                  "130",
                                  style: TextStyle(
                                      fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
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
                                print('Viewing account history...');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                const Text(
                  "Withdraw Cash",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20.h),

                // Withdraw Form
                Form(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _accountTitleController,
                        label: 'Account Title',
                        hintText: 'eg Ahmad Hassan',
                      ),
                      SizedBox(height: 10.h),

                      _buildTextField(
                        controller: _mobileNumberController,
                        label: 'Mobile Number',
                        hintText: '0300 1234567',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10.h),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Account Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAccountTypeOption('EasyPaisa'),
                          SizedBox(width: 20.w),
                          _buildAccountTypeOption('JazzCash'),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      _buildTextField(
                        controller: _amountController,
                        label: 'Amount (Rs)',
                        hintText: 'eg 1200',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),

                      ElevatedButton(
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Withdrawing Rs. $withdrawAmount via $_selectedAccountType',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Insufficient balance. Your balance is Rs. $_walletBalance'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields.'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 18, 18, 18),
                          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: BorderSide(color: Colors.white54),
                          ),
                        ),
                        child: const Text(
                          'Withdraw Cash',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color.fromARGB(255, 8, 8, 8),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
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
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
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
