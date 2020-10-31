import 'package:angadi/classes/cart.dart';
import 'package:angadi/classes/wishlist.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/services/database_helper_wishlist.dart';
import 'package:angadi/widgets/cart_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'checkout.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

//TODO:Enter Qty Tag
class _WishlistScreenState extends State<WishlistScreen> {
  List<Wishlist> wishlistItems = [];
  double total;
  final dbHelperWishlist = DatabaseHelper2.instance;
//  final dbRef = FirebaseDatabase.instance.reference();
  FirebaseAuth mAuth = FirebaseAuth.instance;
  int newQty;
  void getAllItems() async {
    final allRows = await dbHelperWishlist.queryAllRows();
    wishlistItems.clear();
    allRows.forEach((row) => wishlistItems.add(Wishlist.fromMap(row)));
    setState(() {
//      print(cartItems[1]);
    });
  }

  void removeItem(String name) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelperWishlist.delete(name);
    getAllItems();
    Fluttertoast.showToast(
        msg: 'Removed from Wishlist', toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void initState() {
    getAllItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios),
        ),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'My Wishlist',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(
                left: Sizes.MARGIN_16,
                right: Sizes.MARGIN_16,
                top: Sizes.MARGIN_16,
              ),
              height: MediaQuery.of(context).size.height * 0.75,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: wishlistItems.length,
                separatorBuilder: (context, index) {
                  return SpaceH8();
                },
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    // height: 250,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    wishlistItems[index].imgUrl,
                                    width: MediaQuery.of(context).size.width,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: Sizes.MARGIN_16,
                                    vertical: Sizes.MARGIN_16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            child: Text(
                                              '${wishlistItems[index].productName}',
                                              textAlign: TextAlign.left,
                                              style:
                                                  Styles.customTitleTextStyle(
                                                color: AppColors.headingText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: Sizes.TEXT_SIZE_20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            removeItem(
                                              wishlistItems[index].productName,
                                            );
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            size: 28,
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16.0,
                            right: 16.0,
                            top: 8.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Card(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Sizes.WIDTH_8,
                                      vertical: Sizes.WIDTH_4,
                                    ),
                                    child: Text(
                                      'Rs. ${wishlistItems[index].price}',
                                      style: Styles.customTitleTextStyle(
                                        color: AppColors.headingText,
                                        fontWeight: FontWeight.w600,
                                        fontSize: Sizes.TEXT_SIZE_14,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )

//        ListView(
//          scrollDirection: Axis.vertical,
//          children: <Widget>[
//            FoodyBiteCard(
//              imagePath: ImagePath.breakfastInBed,
//              status: StringConst.STATUS_OPEN,
//              cardTitle: "Happy Bones",
//              category: StringConst.ITALIAN,
//              distance: "12 km",
//              address: "394 Broome St, New York, NY 10013, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//            SizedBox(height: Sizes.WIDTH_16),
//            FoodyBiteCard(
//              imagePath: ImagePath.dinnerIsServed,
//              status: StringConst.STATUS_OPEN,
//              rating: "4.8",
//              cardTitle: "Pappas Pizza",
//              category: StringConst.CHINESE,
//              distance: "2 km",
//              address: "917 Zoom St, California, CA 20093, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//            SizedBox(height: Sizes.WIDTH_16),
//            FoodyBiteCard(
//              imagePath: ImagePath.breakfastInBed,
//              status: StringConst.STATUS_CLOSE,
//              rating: "3.7",
//              cardTitle: "Shantell's",
//              category: StringConst.ITALIAN,
//              distance: "4 km",
//              address: "34 Devil St, New York, NY 11013, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//            SizedBox(height: Sizes.WIDTH_16),
//            FoodyBiteCard(
//              imagePath: ImagePath.dinnerIsServed,
//              status: StringConst.STATUS_CLOSE,
//              rating: "2.3",
//              cardTitle: "Dragon Heart",
//              category: StringConst.CHINESE,
//              distance: "5 km",
//              address: "417 Doom St, California, CA 90013, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//          ],
//        ),
              ),
        ],
      ),
    );
  }
}