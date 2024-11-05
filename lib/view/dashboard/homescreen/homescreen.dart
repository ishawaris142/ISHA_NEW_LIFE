import 'package:flutter/material.dart';
import 'package:red_coprative/models/homescreengrid.dart';
import 'package:red_coprative/utils/custom_button.dart';
import 'package:red_coprative/view/dashboard/homescreen/bundles_product.dart';
import 'package:red_coprative/view/dashboard/homescreen/convert_point_products.dart';
import 'package:red_coprative/view/dashboard/homescreen/new_updates.dart';
import 'package:red_coprative/view/dashboard/support/cash_withdraw.dart';
import 'package:red_coprative/view/dashboard/support/history.dart';
import 'package:red_coprative/view/dashboard/homescreen/poits_products.dart';
import 'package:red_coprative/view/dashboard/homescreen/popular_product.dart';
import 'package:red_coprative/view/dashboard/homescreen/view_products.dart';
import '../../../data/services/user_service.dart';



class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final UserDataService userDataService = UserDataService(); // Initialize the UserDataService
  Map<String, dynamic>? userData;
  num totalPoints = 0;
  bool isLoading = true;
    bool _isViewProduct = false;
    bool _isPopularProduct= false;
    bool _isPointProduct= false;
    bool _isBundleProduct= false;
    bool _isNewupdateProduct=false;
    bool _isConvertpoints=false;
                             /////////////////////////////////////////////////////////////////////
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
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    body: Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Unfocus to dismiss the keyboard
          },
          child: Container(
            height: height,
            width: width,
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
                      height: height * 0.302,
                      width: width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 172, 31, 37),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color.fromARGB(255, 8, 8, 8),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset("assets/smalllogo.png", height: 60),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                      height: 37,
                                      margin: const EdgeInsets.only(left: 15, right: 10),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 32, 32, 32),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color.fromARGB(255, 97, 92, 86),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: searchbar,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: "Search",
                                                hintStyle: const TextStyle(
                                                  color: Color.fromARGB(128, 255, 255, 255),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 10,
                                                ),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              print("Search");
                                            },
                                            icon: const Icon(Icons.search, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Image.asset("assets/cartpic.png", height: 34),
                                SizedBox(width: 10),
                                Image.asset("assets/homeicon.png", height: 34),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: Colors.black),
                            const SizedBox(height: 10),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Image(image: AssetImage("assets/mechanic.png")),
                                        SizedBox(width: 5),
                                        Text(
                                          "${userData?['account_type'] ?? 'Account'}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                CustomButton(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CashWithdrawScreen(),
                                      ),
                                    );
                                  },
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromARGB(255, 32, 32, 32),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset("assets/coins.png", height: 22),
                                      Text(
                                        "Withdraw",
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomButton(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Historyscreen(),
                                      ),
                                    );
                                  },
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                  child: Text(
                                    "History",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromARGB(255, 32, 32, 32),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Image.asset("assets/again.png", height: 20),
                              ],
                            ),
                            const SizedBox(height: 9),
                            const Divider(color: Colors.black),
                            const SizedBox(height: 9),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "My Points",
                                      style: TextStyle(color: Colors.white, fontSize: 8),
                                    ),
                                    Text(
                                      totalPoints.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                CustomButton(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CashWithdrawScreen(),
                                      ),
                                    );
                                    await refreshPoints();
                                  },
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromARGB(255, 32, 32, 32),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset("assets/coins.png", height: 22),
                                      Text(
                                        "Convert Points",
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomButton(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Historyscreen(),
                                      ),
                                    );
                                  },
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                  child: Text(
                                    "History",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Explore ISH",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      GridView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 13,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: homescreenmodelclasslist.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _isViewProduct = true;
                                _isPopularProduct=true;
                                _isPointProduct=true;
                                _isBundleProduct=true;
                                _isNewupdateProduct=true;
                                _isConvertpoints=true;
                              });
                          setState(() {
                            
                            if (index == 0) {
                                _isViewProduct=true;
                                ////////////////////////////////
                                _isPopularProduct=false;
                                _isPointProduct=false;
                                _isBundleProduct=false;
                                _isNewupdateProduct=false;
                                _isConvertpoints=false;
                              } else if(index==1){
                                _isViewProduct=false;
                                _isPopularProduct=true;
                                //////////////////////////////////////
                                _isPointProduct=false;
                                _isBundleProduct=false;
                                _isNewupdateProduct=false;
                                _isConvertpoints=false;
                              } else if(index==2){
                                _isViewProduct=false;
                                _isPopularProduct=false;
                                _isPointProduct=true;
                                /////////////////////////////////////
                                _isBundleProduct=false;
                                _isNewupdateProduct=false;
                                _isConvertpoints=false;
                              } else if(index==3){
                                _isViewProduct=false;
                                _isPopularProduct=false;
                                _isPointProduct=false;
                                _isBundleProduct=true;
                                //////////////////////////////////////////
                                _isNewupdateProduct=false;
                                _isConvertpoints=false;
                              } else if(index==4){
                                _isViewProduct=false;
                                _isPopularProduct=false;
                                _isPointProduct=false;
                                _isBundleProduct=false;
                                _isNewupdateProduct=true;
                                ////////////////////////////////////////
                                _isConvertpoints=false;
                              } else if(index==5){
                                _isViewProduct=false;
                                _isPopularProduct=false;
                                _isPointProduct=false;
                                _isBundleProduct=false;
                                _isNewupdateProduct=false;
                                _isConvertpoints=true;
                              } });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 30, 28, 27),
                                borderRadius: BorderRadius.circular(15),
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
                                      height: 55,
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "${homescreenmodelclasslist[index].text}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 180,
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
     
      _isViewProduct ? const ProductView(): SizedBox.shrink(),
      _isPopularProduct? const Popularproduct(): SizedBox.shrink(),
      _isPointProduct? const Pointsproduct(): SizedBox.shrink(),
      _isBundleProduct? const BundlesProduct():SizedBox.shrink(),
      _isNewupdateProduct? const Newupdates():SizedBox.shrink(),
      _isConvertpoints? const Convertpoints():SizedBox.shrink()
      
      ////////////////////////////////////////////////////////////////////////////////////////
      ],
    ),
  );
}
}