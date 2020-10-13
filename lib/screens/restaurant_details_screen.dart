import 'dart:ui';

import 'package:angadi/classes/cart.dart';
import 'package:angadi/routes/router.gr.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/card_tags.dart';
import 'package:angadi/widgets/dark_overlay.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/ratings_widget.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  RestaurantDetails restaurantDetail;
  RestaurantDetailsScreen(this.restaurantDetail);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final dbHelper = DatabaseHelper.instance;
  Cart item;
  int newQty, length = 0;

  getCartLength() async {
    int x = await dbHelper.queryRowCount();
    length = x;
    setState(() {
      print('Length Updated');
      length;
    });
  }

  List<Widget> reviews = [];
  List<Widget> recents = [];

  TextStyle addressTextStyle = Styles.customNormalTextStyle(
    color: AppColors.accentText,
    fontSize: Sizes.TEXT_SIZE_14,
  );

  TextStyle openingTimeTextStyle = Styles.customNormalTextStyle(
    color: Colors.red,
    fontSize: Sizes.TEXT_SIZE_14,
  );

  TextStyle subHeadingTextStyle = Styles.customTitleTextStyle(
    color: AppColors.headingText,
    fontWeight: FontWeight.w600,
    fontSize: Sizes.TEXT_SIZE_18,
  );

  BoxDecoration fullDecorations = Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topleftRadius: 24,
    bottomleftRadius: 24,
    topRightRadius: 24,
    bottomRightRadius: 24,
  );

  BoxDecoration leftSideDecorations =
      Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topleftRadius: 24,
    bottomleftRadius: 24,
  );
  bool check = false;
  BoxDecoration rightSideDecorations =
      Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topRightRadius: 24,
    bottomRightRadius: 24,
  );
  void checkInCart() async {
    var temp = await _query(widget.restaurantDetail.name);
    print(temp);
    if (temp == null)
      setState(() {
        check = false;
      });
    else
      setState(() {
        print('Item already exists');
        check = true;
      });
  }

  @override
  void initState() {
    getCartLength();
    checkInCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    final RestaurantDetails args = ModalRoute.of(context).settings.arguments;
    var heightOfStack = MediaQuery.of(context).size.height / 2.8;
    var aPieceOfTheHeightOfStack = heightOfStack - heightOfStack / 3.5;
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Positioned(
                          child: Image.network(
                            widget.restaurantDetail.url,
                            width: MediaQuery.of(context).size.width,
                            height: heightOfStack,
                            fit: BoxFit.cover,
                          ),
                        ),
                        DarkOverLay(
                            gradient: Gradients.restaurantDetailsGradient),
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.only(
                              right: Sizes.MARGIN_16,
                              top: Sizes.MARGIN_16,
                            ),
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  onTap: () => R.Router.navigator.pop(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: Sizes.MARGIN_16,
                                      right: Sizes.MARGIN_16,
                                    ),
                                    child: Image.asset(ImagePath.arrowBackIcon),
                                  ),
                                ),
                                Spacer(flex: 1),
                                InkWell(
                                  child: Icon(
                                    FeatherIcons.share2,
                                    color: AppColors.white,
                                  ),
                                ),
                                SpaceW20(),
                                InkWell(
                                  child: Image.asset(ImagePath.bookmarksIcon,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
//                         Positioned(
//                           top: aPieceOfTheHeightOfStack,
//                           left: 24,
//                           right: 24 - 0.5,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(24.0),
//                             child: BackdropFilter(
//                               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(vertical: 4.0),
//                                 decoration: fullDecorations,
//                                 child: Row(
//                                   children: <Widget>[
//                                     Container(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 8.0, vertical: 8.0),
//                                       width:
//                                           (MediaQuery.of(context).size.width /
//                                                   2) -
//                                               24,
// //                                      decoration: leftSideDecorations,
//                                       child: Row(
//                                         children: <Widget>[
//                                           SizedBox(width: 4.0),
//                                           Image.asset(ImagePath.callIcon),
//                                           SizedBox(width: 8.0),
//                                           Text(
//                                             '+233 549546967',
//                                             style: Styles.normalTextStyle,
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     IntrinsicHeight(
//                                       child: VerticalDivider(
//                                         width: 0.5,
//                                         thickness: 3.0,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 8.0, vertical: 8.0),
// //                                      width:
// //                                      (MediaQuery
// //                                          .of(context)
// //                                          .size
// //                                          .width /
// //                                          2) -
// //                                          24,
// //                                      decoration: rightSideDecorations,
//                                       child: Row(
//                                         children: <Widget>[
//                                           SizedBox(width: 4.0),
//                                           Image.asset(ImagePath.directionIcon),
//                                           SizedBox(width: 8.0),
//                                           Text(
//                                             'Direction',
//                                             style: Styles.normalTextStyle,
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    widget.restaurantDetail.name,
                                    textAlign: TextAlign.left,
                                    style: Styles.customTitleTextStyle(
                                      color: AppColors.headingText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Sizes.TEXT_SIZE_20,
                                    ),
                                  ),
                                  SizedBox(width: 4.0),
                                  CardTags(
                                    title: widget.restaurantDetail.category,
                                    decoration: BoxDecoration(
                                      gradient: Gradients.secondaryGradient,
                                      boxShadow: [
                                        Shadows.secondaryShadow,
                                      ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                  ),
                                  Spacer(flex: 1),
                                  Ratings(widget.restaurantDetail.rating)
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                widget.restaurantDetail.desc,
                                style: addressTextStyle,
                              ),
                              // SizedBox(height: 8.0),
                              // RichText(
                              //   text: TextSpan(
                              //     style: openingTimeTextStyle,
                              //     children: [
                              //       TextSpan(text: "Open Now "),
                              //       TextSpan(
                              //           text: "daily time ",
                              //           style: addressTextStyle),
                              //       TextSpan(text: "9:30 am to 11:30 am "),
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                          // SpaceH24(),
                          // HeadingRow(
                          //   title: StringConst.MENU_AND_PHOTOS,
                          //   number: StringConst.SEE_ALL_32,
                          //   onTapOfNumber: () => R.Router.navigator
                          //       .pushNamed(R.Router.menuPhotosScreen),
                          // ),
                          // SizedBox(height: 16.0),
                          // Container(
                          //   height: 120,
                          //   width: MediaQuery.of(context).size.width,
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: 4,
                          //     itemBuilder: (context, index) {
                          //       return Container(
                          //         margin: EdgeInsets.only(right: 12.0),
                          //         decoration: BoxDecoration(
                          //             borderRadius:
                          //                 BorderRadius.all(Radius.circular(8))),
                          //         child: Image.asset(
                          //           menuPhotosImagePaths[index],
                          //           fit: BoxFit.fill,
                          //           width: 160,
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // ),
                          SpaceH24(),
                          HeadingRow(
                            title: StringConst.REVIEWS_AND_RATINGS,
                            number: 'See All (${reviews.length})',
                            onTapOfNumber: () => R.Router.navigator.pushNamed(
                                R.Router.reviewRatingScreen,
                                arguments:
                                    ReviewRating(widget.restaurantDetail.name)),
                          ),
                          SizedBox(height: 16.0),
                          StreamBuilder(
                            stream: Firestore.instance
                                .collection('Reviews')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snap) {
                              if (snap.hasData &&
                                  !snap.hasError &&
                                  snap.data != null) {
                                reviews.clear();
                                recents.clear();

                                for (int i = 0;
                                    i < snap.data.documents.length;
                                    i++) {
                                  if (snap.data.documents[i]['dishName'] ==
                                      widget.restaurantDetail.name) {
                                    reviews.add(ListTile(
                                      leading: Image.network(
                                          snap.data.documents[i]['userImage']),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            snap.data.documents[i]['userName'],
                                            style: subHeadingTextStyle,
                                          ),
                                          Ratings(
                                              snap.data.documents[i]['rating']),
                                        ],
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      subtitle: Text(
                                        snap.data.documents[i]['details'],
                                        style: addressTextStyle,
                                      ),
                                    ));
                                    if (i < 5) {
                                      recents.add(ListTile(
                                        leading: Image.network(snap
                                            .data.documents[i]['userImage']),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              snap.data.documents[i]
                                                  ['userName'],
                                              style: subHeadingTextStyle,
                                            ),
                                            Ratings(snap.data.documents[i]
                                                ['rating']),
                                          ],
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        subtitle: Text(
                                          snap.data.documents[i]['details'],
                                          style: addressTextStyle,
                                        ),
                                      ));
                                    }
                                  }
                                }
                                return recents.length != 0
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: recents,
                                      )
                                    : Container();
                              } else
                                return Container(
                                    child: Center(
                                        child: Text(
                                  "No Data",
                                  style: TextStyle(color: Colors.black),
                                )));
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              check == false
                  ? angadiButton(
                      'Add to Cart ',
                      onTap: () async {
//                  await dbHelper.onCreate();
//                  int l = await dbHelper.check(widget.restaurantDetail.name);
//                  print(l);
                        var temp = await _query(widget.restaurantDetail.name);
                        print(temp);
                        if (temp == null)
                          addToCart(
                              name: widget.restaurantDetail.name,
                              imgUrl: widget.restaurantDetail.url,
                              price: widget.restaurantDetail.price,
                              qty: 1);
                        else
                          setState(() {
                            print('Item already exists');
                            check = true;
                          });
                      },
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                      buttonHeight: 65,
                      buttonWidth: MediaQuery.of(context).size.width,
                      decoration: Decorations.customHalfCurvedButtonDecoration(
                        topleftRadius: Sizes.RADIUS_14,
                        topRightRadius: Sizes.RADIUS_14,
                      ),
                    )
                  : angadiButton(
                      'Already in Cart ',
                      onTap: () async {
//                  await dbHelper.onCreate();
//                  int l = await dbHelper.check(widget.restaurantDetail.name);
//                  print(l);
//               var temp = await _query(widget.restaurantDetail.name);
//               print(temp);
//               if (temp == null)
//
//               else
//                 setState(() {
//                   print('Item already exists');
//                   check = true;
//                 });
                      },
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                      buttonHeight: 65,
                      buttonWidth: MediaQuery.of(context).size.width,
                      decoration:
                          Decorations.customHalfCurvedButtonDecorationGrey(
                        topleftRadius: Sizes.RADIUS_14,
                        topRightRadius: Sizes.RADIUS_14,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> createUserListTiles({@required numberOfUsers}) {
    List<Widget> userListTiles = [];
    List<String> imagePaths = [
      ImagePath.profile1,
      ImagePath.profile4,
      ImagePath.profile3,
      ImagePath.profile4,
      ImagePath.profile1,
    ];
    List<String> userNames = [
      "Collin Fields",
      "Sherita Burns",
      "Bill Sacks",
      "Romeo Folie",
      "Pauline Cobbina",
    ];
    List<String> description = [
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
    ];
    List<String> ratings = [
      "4.0",
      "3.0",
      "5.0",
      "2.0",
      "4.0",
    ];

    List<int> list = List<int>.generate(numberOfUsers, (i) => i + 1);

    list.forEach((i) {
      userListTiles.add(ListTile(
        leading: Image.asset(imagePaths[i - 1]),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              userNames[i - 1],
              style: subHeadingTextStyle,
            ),
            Ratings(ratings[i - 1]),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        subtitle: Text(
          description[i - 1],
          style: addressTextStyle,
        ),
      ));
    });
    return userListTiles;
  }

  void addToCart({String name, String imgUrl, String price, int qty}) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnProductName: name,
      DatabaseHelper.columnImageUrl: imgUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty
    };
    Cart item = Cart.fromMap(row);
    final id = await dbHelper.insert(item);
    Fluttertoast.showToast(
        msg: 'Added to cart', toastLength: Toast.LENGTH_SHORT);
    setState(() {
      check = true;
    });
    getCartLength();
  }

  Future<Cart> _query(String name) async {
    final allRows = await dbHelper.queryRows(name);
    print(allRows);
    allRows.forEach((row) => item = Cart.fromMap(row));
    setState(() {
      item;
      print(item);
      print('Updated');
    });
    return item;
  }

  void updateItem(
      {int id,
      String name,
      String imgUrl,
      String price,
      int qty,
      String details}) async {
    // row to update
    Cart item = Cart(id, name, imgUrl, price, qty);
    final rowsAffected = await dbHelper.update(item);
    _query(name);
    Fluttertoast.showToast(msg: 'Updated', toastLength: Toast.LENGTH_SHORT);
    setState(() {
      _query(item.productName);
      print('Updated');
      item;
    });
    getCartLength();
  }

  void removeItem(String name) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name);
    _query(name);
    setState(() {
      print('Updated');
      item;
    });
    getCartLength();
  }
}
