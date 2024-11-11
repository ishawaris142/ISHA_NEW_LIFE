import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:red_coprative/models/homescreengrid.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/auth/edit_profile_screen.dart';
import 'package:red_coprative/view/dashboard/homescreen/new_updates.dart';
import 'package:red_coprative/view/dashboard/homescreen/products/bundles_product.dart';
import 'package:red_coprative/view/dashboard/homescreen/products/points_products.dart';
import 'package:red_coprative/view/dashboard/homescreen/products/popular_products.dart';
import 'package:red_coprative/view/dashboard/homescreen/products/view_products.dart';
import 'package:red_coprative/view/dashboard/support/add_to_cart.dart';
import 'package:red_coprative/view/dashboard/support/cash_withdraw.dart';
import 'package:red_coprative/view/dashboard/support/history.dart';
import '../../../data/services/user_service.dart';
import '../../../view/dashboard/homescreen/cart/cart_items.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final UserDataService userDataService = UserDataService();
  Map<String, dynamic>? userData;
  num totalPoints = 0;
  bool isLoading = true;
  bool _isViewProduct = false;
  bool _isPopularProduct = false;
  bool _isPointProduct = false;
  bool _isBundleProduct = false;
  bool _isNewupdateProduct = false;
  bool _isConvertpoints = false;
  bool _isCash_withdraw = false;
  bool _isHistoryScreen = false;
  bool _isAddtocart = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    userData = await userDataService.fetchUserData();
    totalPoints = await userDataService.fetchTotalPoints();
    setState(() => isLoading = false);
  }

  Future<void> refreshPoints() async {
    totalPoints = await userDataService.fetchTotalPoints();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var searchbar = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 0.32.sh,
                        width: 1.sw,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 172, 31, 37),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25.r),
                            bottomRight: Radius.circular(25.r),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color.fromARGB(255, 8, 8, 8),
                              width: 1.w,
                            ),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(top: 20.h),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset("assets/smalllogo.png", height: 60.h),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 50.w),
                                      child: Container(
                                        height: 37.h,
                                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 32, 32, 32),
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(
                                            color: const Color.fromARGB(255, 97, 92, 86),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: searchbar,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "Search",
                                                  hintStyle: TextStyle(
                                                    color: Color.fromARGB(128, 255, 255, 255),
                                                    fontSize: 12.sp,
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 10.h,
                                                    horizontal: 14.w,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                print("Search");
                                              },
                                              icon: Icon(Icons.search, color: Colors.white, size: 20.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAddtocart = true;
                                      });
                                    },
                                    child: Image.asset("assets/cartpic.png", height: 34.h),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Divider(color: Colors.black, thickness: 1.h),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${userData?['full_name'] ?? 'User'}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Image(image: AssetImage("assets/mechanic.png")),
                                          SizedBox(width: 5.w),
                                          Text(
                                            "${userData?['account_type'] ?? 'Account'}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 9.h),
                              Divider(color: Colors.black, thickness: 1.h),
                              SizedBox(height: 9.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "My Points",
                                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                      ),
                                      Text(
                                        totalPoints.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  CustomButton(
                                    onTap: () {
                                      setState(() {
                                        _isCash_withdraw = true;
                                      });
                                      refreshPoints();
                                    },
                                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Color.fromARGB(255, 32, 32, 32),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset("assets/coins.png", height: 22.h),
                                        Text(
                                          "Convert Points",
                                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomButton(
                                    onTap: () {
                                      setState(() {
                                        _isHistoryScreen = true;
                                      });
                                    },
                                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                                    child: Text(
                                      "History",
                                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Color.fromARGB(255, 32, 32, 32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Explore ISH",
                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        ),
                        GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 13.h,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: homescreenmodelclasslist.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isViewProduct = index == 0;
                                  _isPopularProduct = index == 1;
                                  _isPointProduct = index == 2;
                                  _isBundleProduct = index == 3;
                                  _isNewupdateProduct = index == 4;
                                  _isConvertpoints = index == 5;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 30, 28, 27),
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 97, 92, 86),
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "${homescreenmodelclasslist[index].image}",
                                        height: 55.h,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        "${homescreenmodelclasslist[index].text}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          "Promotions",
                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 180.h,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/homelist.png"),
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
          if (_isViewProduct) const ProductView(),
          if (_isPopularProduct) const PopularProductsView(),
          if (_isPointProduct) const Pointsproduct(),
          if (_isBundleProduct) const BundlesProduct(),
          if (_isNewupdateProduct) const Newupdates(),
          if (_isConvertpoints) const CashWithdrawScreen(),
          if (_isCash_withdraw) const CashWithdrawScreen(),
          if (_isHistoryScreen) const Historyscreen(),
          if (_isAddtocart) const CartScreen(),
        ],
      ),
    );
  }
}





// _isViewProduct? const ProductView(): SizedBox.shrink(),
//     _isPopularProduct? const PopularProductsView(): SizedBox.shrink(),
//     _isPointProduct? const Pointsproduct(): SizedBox.shrink(),
//     _isBundleProduct? const BundlesProduct():SizedBox.shrink(),
//     _isNewupdateProduct? const Newupdates():SizedBox.shrink(),
//     _isConvertpoints? const Convertpoints():SizedBox.shrink(),
//     _isCash_withdraw? const CashWithdrawScreen():SizedBox.shrink(),
//     _isHistoryScreen? const Historyscreen(): SizedBox.shrink(),
//       _isAddtocart? const CartScreen():SizedBox.shrink(),