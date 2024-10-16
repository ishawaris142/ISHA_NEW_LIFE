import 'package:flutter/material.dart';

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
  double _walletBalance = 1599.0; // Storing the wallet balance here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      resizeToAvoidBottomInset: true, // Allow screen to resize when keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            // Top section with app name and QR code icon
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
            const SizedBox(height: 20),

            // Wallet balance section
            Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 165, 6, 13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 2),
                        Text(
                          _walletBalance.toString(), // Use the variable here
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50), // Adjusted for better spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSmallButton(
                          icon: Icons.send,
                          label: "Send",
                          onPressed: () {
                            print('Sending cash...');
                          },
                        ),
                        _buildSmallButton(
                          icon: Icons.branding_watermark_sharp,
                          label: "Withdraw",
                          onPressed: () {
                            print('Cash Withdraw...');
                          },
                        ),
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
            const SizedBox(height: 20),

            const Text(
              "Withdraw Cash",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Withdraw Form
            Form(
              child: Column(
                children: [
                  // Account Title
                  _buildTextField(
                    controller: _accountTitleController,
                    label: 'Account Title',
                    hintText: 'eg Ahmad Hassan',
                  ),
                  const SizedBox(height: 10),

                  // Mobile Number
                  _buildTextField(
                    controller: _mobileNumberController,
                    label: 'Mobile Number',
                    hintText: '0300 1234567',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),

                  // Account Type Label
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
                  const SizedBox(height: 10),

                  // Account Type with Radio Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAccountTypeOption('EasyPaisa'),
                      const SizedBox(width: 20),
                      _buildAccountTypeOption('JazzCash'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Amount
                  _buildTextField(
                    controller: _amountController,
                    label: 'Amount (Rs)',
                    hintText: 'eg 1200',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Withdraw Button
                  ElevatedButton(
                    onPressed: () {
                      final accountTitle = _accountTitleController.text;
                      final mobileNumber = _mobileNumberController.text;
                      final amount = _amountController.text;

                      if (accountTitle.isNotEmpty && mobileNumber.isNotEmpty && amount.isNotEmpty) {
                        double withdrawAmount = double.parse(amount);
                        if (withdrawAmount <= _walletBalance) {
                          setState(() {
                            _walletBalance -= withdrawAmount; // Deduct the amount from the balance
                          });
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
                      backgroundColor: const Color.fromARGB(255, 165, 6, 13),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
    );
  }

  // Helper methods for text fields, account type options, and buttons
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
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 165, 6, 13)),
          borderRadius: BorderRadius.circular(10),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedAccountType == type ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            Text(
              type,
              style: TextStyle(
                color: _selectedAccountType == type ? Colors.white : Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.circle,
              color: _selectedAccountType == type ? Colors.white : Colors.red,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton(
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Button background color
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 18), // Smaller icon
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}