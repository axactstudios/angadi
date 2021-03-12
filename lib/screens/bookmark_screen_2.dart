import 'package:angadi/classes/cart.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/widgets/cart_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'checkout.dart';

class BookmarksScreen2 extends StatefulWidget {
  @override
  _BookmarksScreen2State createState() => _BookmarksScreen2State();
}

//TODO:Enter Qty Tag
class _BookmarksScreen2State extends State<BookmarksScreen2> {
  List<Cart> cartItems = [];
  double total;
  final dbHelper = DatabaseHelper.instance;
//  final dbRef = FirebaseDatabase.instance.reference();
  FirebaseAuth mAuth = FirebaseAuth.instance;
  int newQty;
  void getAllItems() async {
    final allRows = await dbHelper.queryAllRows();
    cartItems.clear();
    allRows.forEach((row) => cartItems.add(Cart.fromMap(row)));
    setState(() {
//      print(cartItems[1]);
    });
  }

  void updateItem(
      {String id,
      String name,
      String imgUrl,
      String price,
      int qty,
      String qtyTag,
      String details}) async {
    // row to update
    Cart item = Cart(id, name, imgUrl, price, qty, qtyTag);
    final rowsAffected = await dbHelper.update(item);
    Fluttertoast.showToast(msg: 'Updated', toastLength: Toast.LENGTH_SHORT);
    getAllItems();
  }

  void removeItem(String name, String qtyTag) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name, qtyTag);
    getAllItems();
    Fluttertoast.showToast(
        msg: 'Removed from cart', toastLength: Toast.LENGTH_SHORT);
  }

  double totalAmount() {
    double sum = 0;
    getAllItems();
    for (int i = 0; i < cartItems.length; i++) {
      sum += (double.parse(cartItems[i].price) * cartItems[i].qty);
    }
    return sum;
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
          'My Cart',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.secondaryElement,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                margin: EdgeInsets.only(right: Sizes.MARGIN_16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Checkout('', 'orderid', '', '');
                    }));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(
                left: Sizes.MARGIN_16,
                right: Sizes.MARGIN_16,
                top: Sizes.MARGIN_16,
              ),
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: cartItems.length,
                separatorBuilder: (context, index) {
                  return SpaceH8();
                },
                itemBuilder: (context, index) {
                  print(cartItems[index].qtyTag);
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
                                    cartItems[index].imgUrl,
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
                                              '${cartItems[index].productName} ${cartItems[index].qtyTag}',
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
                                            InkWell(
                                              onTap: () {
                                                newQty =
                                                    cartItems[index].qty + 1;
                                                updateItem(
                                                    id: cartItems[index].id,
                                                    name: cartItems[index]
                                                        .productName,
                                                    imgUrl:
                                                        cartItems[index].imgUrl,
                                                    price:
                                                        cartItems[index].price,
                                                    qty: newQty,
                                                    qtyTag: cartItems[index]
                                                        .qtyTag);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
//                                                  color: Colors.yellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.black)),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.black,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 1)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 8),
                                                child: Text(
                                                  cartItems[index]
                                                      .qty
                                                      .toString(),
                                                  textAlign: TextAlign.left,
                                                  style: Styles
                                                      .customNormalTextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        Sizes.TEXT_SIZE_14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (cartItems[index].qty == 1) {
                                                  removeItem(
                                                      cartItems[index]
                                                          .productName,
                                                      cartItems[index].qtyTag);
                                                } else {
                                                  var newQty =
                                                      cartItems[index].qty - 1;
                                                  updateItem(
                                                      id: cartItems[index].id,
                                                      name: cartItems[index]
                                                          .productName,
                                                      imgUrl: cartItems[index]
                                                          .imgUrl,
                                                      price: cartItems[index]
                                                          .price,
                                                      qty: newQty,
                                                      qtyTag: cartItems[index]
                                                          .qtyTag);
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
//                                                  color: Colors.yellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.black)),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: Colors.black,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            removeItem(
                                                cartItems[index].productName,
                                                cartItems[index].qtyTag);
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
                                      'AED ${cartItems[index].price}',
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
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            decoration: BoxDecoration(color: AppColors.accentElement),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Amount- '),
                Text('AED. ${totalAmount()}(+taxes)'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
