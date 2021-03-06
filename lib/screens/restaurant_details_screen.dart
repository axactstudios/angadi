import 'dart:ui';

import 'package:angadi/classes/cart.dart';
import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/quantity.dart';
import 'package:angadi/classes/wishlist.dart';
import 'package:angadi/routes/router.gr.dart';
import 'package:angadi/screens/review_rating_screen.dart';
import 'package:angadi/screens/wishlist_screen.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/services/database_helper_wishlist.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bookmarks_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  RestaurantDetails restaurantDetail;

  RestaurantDetailsScreen(this.restaurantDetail);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}
//TODO:Enter Qty Tag

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  static List<bool> check = [false, false, false, false, false];
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

  BoxDecoration rightSideDecorations =
      Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topRightRadius: 24,
    bottomRightRadius: 24,
  );

  final dbHelper = DatabaseHelper.instance;
  final dbHelperWishlist = DatabaseHelper2.instance;
  Cart item;
  Wishlist itemWishlist;
  var length;
  var lengthWishlist;
  var qty = 1;
  bool present = false;
  int choice = 0;
  String tag;
  var proprice;
  var prodisprice;
  String productID;
  List<Cart> cartItems = [];
  List<Wishlist> wishlistItems = [];
  List<Widget> youMayAlsoLike = new List();
  List<Widget> similarProducts = new List();
  List<Widget> dishesLike = new List<Widget>();
  List<Widget> dishesBought = new List<Widget>();
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

  void updateItemWishlist(
      {int id,
      String name,
      String imgUrl,
      String price,
      String qtyTag,
      String details}) async {
    // row to update
    Wishlist item = Wishlist(id, name, imgUrl, price);
    final rowsAffected = await dbHelperWishlist.update(item);
    Fluttertoast.showToast(
        msg: 'Updated Wishlist', toastLength: Toast.LENGTH_SHORT);
    getAllItemsWishlist();
  }

  void removeItem(String name, String qtyTag) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name, qtyTag);
    getAllItems();
    setState(() {
      check[choice] = false;
      qty = 0;
    });
    Fluttertoast.showToast(
        msg: 'Removed from cart', toastLength: Toast.LENGTH_SHORT);
  }

  void removeItemWishlist(String name, String qtyTag) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelperWishlist.delete(name);
    getAllItemsWishlist();
    setState(() {});
    Fluttertoast.showToast(
        msg: 'Removed from Wishlist', toastLength: Toast.LENGTH_SHORT);
  }

  void getAllItems() async {
    final allRows = await dbHelper.queryAllRows();
    cartItems.clear();
    await allRows.forEach((row) => cartItems.add(Cart.fromMap(row)));
    setState(() {
      total = cartItems.length;

      for (var v in cartItems) {
        // print('######${v.productName}');
        if (v.productName == widget.restaurantDetail.name &&
            v.qtyTag == qtyTag) {
          qty = v.qty;
        }
      }
//      print(cartItems[1]);
    });
  }

  void getAllItemsWishlist() async {
    final allRows = await dbHelperWishlist.queryAllRows();
    wishlistItems.clear();
    await allRows.forEach((row) => wishlistItems.add(Wishlist.fromMap(row)));
    setState(() {
      totalWishlist = wishlistItems.length;

      for (var v in wishlistItems) {
        // print('######${v.productName}');
        if (v.productName == widget.restaurantDetail.name) {
          present = true;
        }
      }
//      print(cartItems[1]);
    });
  }

  int total;
  int totalWishlist;
  void addToWishlist(ctxt, {String name, String imgUrl, String price}) async {
    Map<String, dynamic> row = {
      DatabaseHelper2.columnProductName: name,
      DatabaseHelper2.columnImageUrl: imgUrl,
      DatabaseHelper2.columnPrice: price
    };
    Wishlist item = Wishlist.fromMap(row);
    final id = await dbHelperWishlist.insert(item);
    final snackBar = SnackBar(
        content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Added to Wishlist'),
          InkWell(
            onTap: () {
              pushNewScreen(context,
                  screen: WishlistScreen(), withNavBar: true);
            },
            child: Text(
              'View Wishlist',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    ));
    setState(() {
      present = true;
    });
// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(ctxt).showSnackBar(snackBar);
//    Fluttertoast.showToast(
//        msg: 'Added to cart', toastLength: Toast.LENGTH_SHORT);

    await getAllItemsWishlist();
    getWishlistLength();
  }

  void addToCart(ctxt,
      {String productId,
      String name,
      String imgUrl,
      String price,
      int qty,
      String qtyTag}) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: productId,
      DatabaseHelper.columnProductName: name,
      DatabaseHelper.columnImageUrl: imgUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty,
      DatabaseHelper.columnQuantityTag: qtyTag
    };

    if (cartItems.length == 0) {
      // await print('----------------$order');
      if (order + 1 < 9) {
        await setState(() {
          orderid = 'ANG0000${order + 1}';
        });
      }
      if (order + 1 > 10 && order + 1 < 99) {
        await setState(() {
          orderid = 'ANG000${order + 1}';
        });
      }
      if (order + 1 > 99 && order + 1 < 999) {
        await setState(() {
          orderid = 'ANG00${order + 1}';
        });
      }
      if (order + 1 > 999 && order + 1 < 9999) {
        await setState(() {
          orderid = 'ANG0${order + 1}';
        });
      }
      if (order + 1 > 9999 && order + 1 < 99999) {
        await setState(() {
          orderid = 'ANG${order + 1}';
        });
      }
      if (order + 1 > 99999) {
        await setState(() {
          orderid = 'ANG${order + 1}';
        });
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Orderid', orderid);
      // print(orderid);

      prefs.setString('Status', 'Not placed');
      await Firestore.instance
          .collection('Ordercount')
          .document('ordercount')
          .updateData({
        'Numberoforders': order + 1,
      });
    }
    Cart item = Cart.fromMap(row);
    final id = await dbHelper.insert(item);
    final snackBar = SnackBar(
        content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Added to Cart'),
          InkWell(
            onTap: () {
              pushNewScreen(context,
                  screen: BookmarksScreen(), withNavBar: true);
            },
            child: Text(
              'View Cart',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    ));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(ctxt).showSnackBar(snackBar);
//    Fluttertoast.showToast(
//        msg: 'Added to cart', toastLength: Toast.LENGTH_SHORT);
    setState(() {
      check[choice] = true;
    });
    await getAllItems();
    getCartLength();
  }

  getWishlistLength() async {
    int x = await dbHelperWishlist.queryRowCount();
    length = x;
    setState(() {
      // print('Length Updated');
      length;
    });
  }

  getCartLength() async {
    int x = await dbHelper.queryRowCount();
    lengthWishlist = x;
    setState(() {
      // print('Length Updated');
      lengthWishlist;
    });
  }

  Future<Cart> _query(String name, String qtyTag) async {
    final allRows = await dbHelper.queryRows(name, qtyTag);
    // print(allRows);

    allRows.forEach((row) => item = Cart.fromMap(row));
    setState(() {
      item;
//      print(item.qtyTag);
//       print('-------------Updated');
    });
    return item;
  }

  Future<Wishlist> _queryWishlist(String name) async {
    final allRows = await dbHelperWishlist.queryRows(name);
    // print(allRows);

    allRows.forEach((row) => itemWishlist = Wishlist.fromMap(row));
    setState(() {
      itemWishlist;
//      print(item.qtyTag);
//       print('-------------Updated');
    });
    return itemWishlist;
  }

  var factor = 1;

//  List<String> listOfQuantities = [
//    '500 ML',
//    '1 Ltr',
//    '2 Ltr',
//    '5 Ltr',
//    '10 Ltr'
//  ];

  Future<int> getQuantity(String name, String qtyTag) async {
    var temp = await _query(name, qtyTag);
    if (temp != null) {
      if (temp.productName == name && temp.qtyTag == qtyTag) {
        // print('item found');
        qty = temp.qty;
        return temp.qty;
      } else {
        return 0;
      }
    }
  }

  void checkInCart(String qtyTag) async {
    var temp = await _query(widget.restaurantDetail.name, qtyTag);
    // print(temp);
    if (temp != null) {
      if (temp.productName == widget.restaurantDetail.name &&
          temp.qtyTag == qtyTag) {
        setState(() {
          // print('Item already exists');
          check[choice] = true;
          qty = temp.qty;
        });
        return;
      } else
        setState(() {
          check[choice] = false;
        });
    }
  }

  Future<bool> checkInWishlist() async {
    // print('called');
    var temp = await _queryWishlist(widget.restaurantDetail.name);
    // print(temp);
    if (temp != null) {
      if (temp.productName == widget.restaurantDetail.name) {
        setState(() {
          // print('Item already exists ${temp.productName}');
        });
        return true;
      } else {
        setState(() {});
        return false;
      }
    }
  }

  var l = 0;
  first() async {
    await Firestore.instance
        .collection('Ordercount')
        .document('ordercount')
        .snapshots()
        .listen((event) {
      // print(event['Numberoforders'].toString());

      order = event['Numberoforders'];
    });
    // print('Checked');
    qty = await getQuantity(widget.restaurantDetail.name, '500');
    present = await checkInWishlist();
    // print('-------------%%%%%$present');
  }

  String urlUniv;
  String url2 =
          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FBajji%20Bonda%20Butter%2F1-2.JPG?alt=media&token=1363302b-3013-4cd4-aebf-d2f04c25a764',
      url3 =
          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FBajji%20Bonda%20Butter%2F1-2.JPG?alt=media&token=1363302b-3013-4cd4-aebf-d2f04c25a764';
  var order, orderid;
  String qtyTag;
  @override
  void initState() {
    setState(() {
      urlUniv = widget.restaurantDetail.url;
      qtyTag = '${widget.restaurantDetail.quantities[0]} ';
    });
    prodisprice = widget.restaurantDetail.allquantities[0].price;
    proprice = widget.restaurantDetail.allquantities[0].iPrice;
    productID = widget.restaurantDetail.allquantities[0].productId;
    choice = 0;
    first();
    checkInCart('${widget.restaurantDetail.quantities[0]} ');
    // print(
    //     '---------------------------------------${widget.restaurantDetail.boughtTogetherQuantity}');
    getAllItems();
    super.initState();
  }

//  List sizes = ['500 ML', '1 Ltr', '2 Ltr', '5 Ltr', '10 Ltr'];
  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
  @override
  Widget build(BuildContext context) {
//    final RestaurantDetails args = ModalRoute.of(context).settings.arguments;
    List priceFactors = [1, 2, 4, 10, 20];
    var heightOfStack = MediaQuery.of(context).size.height / 2.8;
    var aPieceOfTheHeightOfStack = heightOfStack - heightOfStack / 3.5;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryElement,
        elevation: 0.0,
        title: Text(
          'Angadi.ae',
          style: Styles.customTitleTextStyle(
            color: Color(0xFF6b3600),
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
        centerTitle: true,
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        actions: [
          InkWell(
              onTap: () {
                // launch('tel:+919027553376');
              },
              child: Icon(
                Icons.share,
                color: Color(0xFF6b3600),
              )),
          SizedBox(
            width: 8,
          ),
          InkWell(
            onTap: () {
              // print(1);
              R.Router.navigator.pushNamed(
                R.Router.bookmarksScreen2,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF6b3600),
                  ),
                  total != null
                      ? total > 0
                          ? Positioned(
                              bottom: MediaQuery.of(context).size.height * 0.04,
                              left: MediaQuery.of(context).size.height * 0.013,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: CircleAvatar(
                                  radius: 6.0,
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    total.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container()
                      : Container(),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 14,
          )
        ],
        // centerTitle: true,
        // title: Text(
        //   'Product',
        //   style: Styles.customTitleTextStyle(
        //     color: AppColors.headingText,
        //     fontWeight: FontWeight.w600,
        //     fontSize: Sizes.TEXT_SIZE_22,
        //   ),
        // ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('Dishes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (snap.hasData && !snap.hasError && snap.data != null) {
            youMayAlsoLike.clear();
            similarProducts.clear();

            for (int i = 0; i < snap.data.documents.length; i++) {
              List<Quantity> allquantities = [];
              List<String> quantities = [];

              allquantities.clear();
              quantities.clear();
              for (int j = 0;
                  j < snap.data.documents[i]['Quantity'].length;
                  j++) {
                Quantity qu = Quantity(
                    snap.data.documents[i]['Quantity'][j]['iPrice'],
                    snap.data.documents[i]['Quantity'][j]['price'],
                    snap.data.documents[i]['Quantity'][j]['productId'],
                    snap.data.documents[i]['Quantity'][j]['quantity']);

                allquantities.add(qu);
                quantities.add(
                    '${snap.data.documents[i]['Quantity'][j]['quantity']}');
              }
              if (snap.data.documents[i]['name'] ==
                  widget.restaurantDetail.name) {
                if (snap.data.documents[i]['url2'] != null) {
                  url2 = snap.data.documents[i]['url2'];
                  url3 = snap.data.documents[i]['url3'];
                } else {
                  url2 =
                      'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FBajji%20Bonda%20Butter%2F1-2.JPG?alt=media&token=1363302b-3013-4cd4-aebf-d2f04c25a764';
                  url3 =
                      'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FBajji%20Bonda%20Butter%2F1-2.JPG?alt=media&token=1363302b-3013-4cd4-aebf-d2f04c25a764';
                }
              }
              if (snap.data.documents[i]['category'] ==
                  widget.restaurantDetail.category) {
                dishesBought.add(Container(
                  margin: EdgeInsets.only(right: 4.0),
                  child: FoodyBiteCard(
                    onTap: () async {
                      Dish boughtTogether;
                      for (int ind = 0;
                          ind < snap.data.documents.length;
                          ind++) {
                        if (snap.data.documents[ind].documentID ==
                            snap.data.documents[i]['boughtTogether']) {
                          // print(
                          //     '999999999999999999${snap.data.documents[i]['boughtTogether']}');
                          boughtTogether = await Dish(
                              boughtTogetherDiscount: snap.data.documents[ind]
                                  ['boughtTogetherDiscount'],
                              boughtTogetherQuantity: snap.data.documents[ind]
                                  ['boughtTogetherQuantity'],
                              id: snap.data.documents[ind]['productId'],
                              name: snap.data.documents[ind]['name'],
                              category: snap.data.documents[ind]['category'],
                              rating:
                                  snap.data.documents[ind]['rating'].toString(),
                              price: snap.data.documents[ind]['price'],
                              desc: snap.data.documents[ind]['description'],
                              url: snap.data.documents[ind]['url'],
                              boughtTogetherID: snap.data.documents[ind]
                                  ['boughtTogether'],
                              allquantities: allquantities,
                              quantities: quantities,
                              stock: snap.data.documents[ind]['stock']);
                        }
                      }
                      R.Router.navigator.pushNamed(
                          R.Router.restaurantDetailsScreen,
                          arguments: RestaurantDetails(
                              boughtTogether: boughtTogether,
                              boughtTogetherDiscount: snap.data.documents[i]
                                  ['boughtTogetherDiscount'],
                              boughtTogetherQuantity: snap.data.documents[i]
                                  ['boughtTogetherQuantity'],
                              productID: snap.data.documents[i]['productId'],
                              url: snap.data.documents[i]['url'],
                              name: snap.data.documents[i]['name'],
                              desc: snap.data.documents[i]['description'],
                              category: snap.data.documents[i]['category'],
                              rating: snap.data.documents[i]['rating'],
                              price: snap.data.documents[i]['price'],
                              allquantities: allquantities,
                              quantities: quantities,
                              stock: snap.data.documents[i]['stock']));
                    },
                    imagePath: snap.data.documents[i]['url'],
                    cardTitle: snap.data.documents[i]['name'],
                    rating: snap.data.documents[i]['rating'],
                    category: snap.data.documents[i]['category'],
                    price: snap.data.documents[i]['price'].toString(),
                    iPrice: snap.data.documents[i]['iPrice'].toString(),
                    allquantities: allquantities,
                    quantities: quantities,
                    stock: snap.data.documents[i]['stock'],
                  ),
                ));
              }

              if (double.parse(snap.data.documents[i]['rating']) >
                  double.parse(widget.restaurantDetail.rating)) {
                dishesLike.add(Container(
                  margin: EdgeInsets.only(right: 4.0),
                  child: FoodyBiteCard(
                      onTap: () async {
                        Dish boughtTogether;
                        for (int ind = 0;
                            ind < snap.data.documents.length;
                            ind++) {
                          if (snap.data.documents[ind].documentID ==
                              snap.data.documents[i]['boughtTogether']) {
                            boughtTogether = await Dish(
                                boughtTogetherDiscount: snap.data.documents[ind]
                                    ['boughtTogetherDiscount'],
                                boughtTogetherQuantity: snap.data.documents[ind]
                                    ['boughtTogetherQuantity'],
                                id: snap.data.documents[ind]['productId'],
                                name: snap.data.documents[ind]['name'],
                                category: snap.data.documents[ind]['category'],
                                rating: snap.data.documents[ind]['rating']
                                    .toString(),
                                price: snap.data.documents[ind]['price'],
                                desc: snap.data.documents[ind]['description'],
                                url: snap.data.documents[ind]['url'],
                                boughtTogetherID: snap.data.documents[ind]
                                    ['boughtTogether'],
                                allquantities: allquantities,
                                quantities: quantities,
                                stock: snap.data.documents[ind]['stock']);
                          }
                        }
                        R.Router.navigator.pushNamed(
                            R.Router.restaurantDetailsScreen,
                            arguments: RestaurantDetails(
                                boughtTogetherDiscount: snap.data.documents[i]
                                    ['boughtTogetherDiscount'],
                                boughtTogetherQuantity: snap.data.documents[i]
                                    ['boughtTogetherQuantity'],
                                boughtTogether: boughtTogether,
                                productID: snap.data.documents[i]['productId'],
                                url: snap.data.documents[i]['url'],
                                name: snap.data.documents[i]['name'],
                                desc: snap.data.documents[i]['description'],
                                category: snap.data.documents[i]['category'],
                                rating: snap.data.documents[i]['rating'],
                                price: snap.data.documents[i]['price'],
                                allquantities: allquantities,
                                quantities: quantities,
                                stock: snap.data.documents[i]['stock']));
                      },
                      imagePath: snap.data.documents[i]['url'],
                      cardTitle: snap.data.documents[i]['name'],
                      rating: snap.data.documents[i]['rating'],
                      category: snap.data.documents[i]['category'],
                      price: snap.data.documents[i]['price'].toString(),
                      iPrice: snap.data.documents[i]['iPrice'].toString(),
                      allquantities: allquantities,
                      quantities: quantities,
                      stock: snap.data.documents[i]['stock']),
                ));
              }
            }

            return SafeArea(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 8, 8, 2),
                            child: Text(
                              widget.restaurantDetail.name,
                              textAlign: TextAlign.left,
                              style: Styles.customMediumTextStyle(
                                color: AppColors.headingText,
                                // fontWeight: FontWeight.w600,
                                fontSize: Sizes.TEXT_SIZE_20,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0, 8, 8),
                            child: Text(
                              widget.restaurantDetail.category,
                              style: addressTextStyle,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(8.0, 3, 8, 2),
                          //   child: Text(
                          //     'Rs. ${widget.restaurantDetail.price}',
                          //     style: Styles.customMediumTextStyle(
                          //       color: AppColors.headingText,
                          //       // fontWeight: FontWeight.w600,
                          //       fontSize: 15,
                          //     ),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                          //   child: Text(
                          //     '(Inclusive of all taxes)',
                          //     style: TextStyle(
                          //       color: AppColors.accentText,
                          //       fontSize: 10,
                          //     ),
                          //   ),
                          // ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  child: FancyShimmerImage(
                                    shimmerDuration: Duration(seconds: 2),
                                    imageUrl: urlUniv,
                                    width: MediaQuery.of(context).size.width,
                                    height: heightOfStack,
                                    boxFit: BoxFit.cover,
                                  ),
                                ),
                                DarkOverLay(
                                    gradient:
                                        Gradients.restaurantDetailsGradient),
                                Positioned(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      right: Sizes.MARGIN_16,
                                      top: Sizes.MARGIN_16,
                                    ),
//                            child: Row(
//                              children: <Widget>[
//                                InkWell(
//                                  onTap: () => R.Router.navigator.pop(),
//                                  child: Padding(
//                                    padding: const EdgeInsets.only(
//                                      left: Sizes.MARGIN_16,
//                                      right: Sizes.MARGIN_16,
//                                    ),
//                                    child: Image.asset(ImagePath.arrowBackIcon),
//                                  ),
//                                ),
//                                Spacer(flex: 1),
//                                InkWell(
//                                  child: Icon(
//                                    FeatherIcons.share2,
//                                    color: AppColors.white,
//                                  ),
//                                ),
//                                SpaceW20(),
//                                InkWell(
//                                  child: Image.asset(ImagePath.bookmarksIcon,
//                                      color: Colors.white),
//                                ),
//                              ],
//                            ),
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
                          ),
                          Container(
                            height: 100,
                            child: Row(
                              children: [
                                SizedBox(width: 14),
                                Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          urlUniv = widget.restaurantDetail.url;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          height: 65,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              border: Border.all(
                                                width: 2,
                                                color: urlUniv !=
                                                        widget.restaurantDetail
                                                            .url
                                                    ? Color.fromRGBO(
                                                        255, 176, 0, 0.7)
                                                    : Color.fromRGBO(
                                                        101, 54, 7, 1),
                                              )),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            child: FancyShimmerImage(
                                              shimmerDuration:
                                                  Duration(seconds: 2),
                                              imageUrl:
                                                  widget.restaurantDetail.url,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )), //just to push
                                Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          urlUniv = url2;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            height: 65,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                border: Border.all(
                                                  width: 2,
                                                  color: urlUniv != url2
                                                      ? Color.fromRGBO(
                                                          255, 176, 0, 0.7)
                                                      : Color.fromRGBO(
                                                          101, 54, 7, 1),
                                                )),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              child: FancyShimmerImage(
                                                shimmerDuration:
                                                    Duration(seconds: 2),
                                                // height: 80,
                                                imageUrl: url2,
                                              ),
                                            )),
                                      ),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          urlUniv = url3;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            height: 65,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                border: Border.all(
                                                  width: 2,
                                                  color: urlUniv != url3
                                                      ? Color.fromRGBO(
                                                          255, 176, 0, 0.7)
                                                      : Color.fromRGBO(
                                                          101, 54, 7, 1),
                                                )),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              child: FancyShimmerImage(
                                                imageUrl: url3,
                                                shimmerDuration:
                                                    Duration(seconds: 2),
                                              ),
                                            )),
                                      ),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.secondaryElement,
                                              border: Border.all(
                                                width: 2,
                                                color:
                                                    AppColors.secondaryElement,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10))),
                                          child: Center(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              (prodisprice == proprice)
                                                  ? Text(
                                                      'AED. ${double.parse(prodisprice).toString()}',
                                                      textAlign: TextAlign.left,
                                                      style: Styles
                                                          .customMediumTextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF6b3600),
                                                        // fontWeight: FontWeight.w600,
                                                        fontSize: 24,
                                                      ),
                                                    )
                                                  : Row(
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            'AED. ${(double.parse(prodisprice).toString())}  ',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: Styles
                                                                .customMediumTextStyle(
                                                              color: AppColors
                                                                  .black,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Text(
                                                              'AED. ${(double.parse(proprice).toString())}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough)),
                                                        ),
                                                      ],
                                                    ),
                                              Text(
                                                '(${qtyTag})',
                                                textAlign: TextAlign.left,
                                                style: Styles
                                                    .customMediumTextStyle(
                                                  color: Color(0xFF6b3600),
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: Sizes.TEXT_SIZE_18,
                                                ),
                                              ),
                                            ],
                                          ))),
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0, 8, 8),
                            child: Text(
                              'Product ID: ${widget.restaurantDetail.productID}',
                              style: addressTextStyle,
                            ),
                          ),
                          (widget.restaurantDetail.stock)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16.0, 0, 8, 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                      Text(
                                        'in stock',
                                        style: Styles.customTitleTextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16.0, 0, 8, 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.cancel,
                                          color: Colors.red, size: 12),
                                      Text('Out of stock',
                                          style: Styles.customTitleTextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                          ))
                                    ],
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 3, 8, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Ratings(widget.restaurantDetail.rating),
                                InkWell(
                                  onTap: () {
                                    R.Router.navigator.pushNamed(
                                        R.Router.reviewRatingScreen,
                                        arguments: ReviewRating(
                                            widget.restaurantDetail.name));
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                                    child: Text(
                                      'See All Reviews',
                                      style: TextStyle(
                                        color: AppColors.accentText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 120),
                                (proprice != prodisprice)
                                    ? Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          ('${((double.parse(proprice) - double.parse(prodisprice)) / double.parse(proprice) * 100).toStringAsFixed(0)} % off'),
                                          style: Styles.customTitleTextStyle(
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Spacer(flex: 1),
                              ],
                            ),
                          ),
                          // Container(
                          //   height: 5,
                          //   width: MediaQuery.of(context).size.width,
                          //   color: Colors.grey.withOpacity(0.5),
                          // ),
                          // Row(
                          //   children: [
                          //     SizedBox(
                          //       width: 8,
                          //     ),
                          //     Image.asset(
                          //       'assets/images/truck',
                          //       height: 30,
                          //       width: 30,
                          //     ),
                          //     SizedBox(
                          //       width: 8,
                          //     ),
                          //     Text(
                          //       'Delivers in 13 hrs',
                          //       style: TextStyle(fontSize: 14),
                          //     ),
                          //   ],
                          // ),
                          Container(
                            height: 5,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 2),
                            child: Text(
                              'Pack Sizes',
                            ),
                          ),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount:
                                  widget.restaurantDetail.allquantities.length,
                              itemBuilder: (context, index) {
                                var item = widget
                                    .restaurantDetail.allquantities[index];
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: InkWell(
                                    onTap: () async {
                                      await getAllItems();
                                      factor = await 1;
                                      qtyTag = await item.quantity;
                                      choice = await index;

                                      await checkInCart(item.quantity);
                                      qty = await getQuantity(
                                          widget.restaurantDetail.name,
                                          item.quantity);
                                      setState(() {
                                        choice = index;
                                        prodisprice = item.price;
                                        productID = item.productId;
                                        proprice = item.iPrice;
                                        tag = '${item.quantity}';
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: choice == index
                                              ? AppColors.secondaryElement
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3)),
                                          border: Border.all(width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(item.quantity.toString()),
                                            (item.iPrice == item.price)
                                                ? Text(
                                                    'AED. ${double.parse(item.price)}')
                                                : Row(
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          'AED. ${(double.parse(item.price).toString())}  ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: Styles
                                                              .customMediumTextStyle(
                                                            color:
                                                                AppColors.black,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                            'AED. ${(double.parse(item.iPrice).toString())}',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough)),
                                                      ),
                                                    ],
                                                  )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 2),
                            child: Text(
                              'About this product',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 2, 8, 2),
                            child: Text(
                              widget.restaurantDetail.desc,
                              style: addressTextStyle,
                            ),
                          ),

                          // Container(
                          //   margin: EdgeInsets.fromLTRB(10, 2, 10, 5),
                          //   child: Column(
                          //     children: <Widget>[
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: <Widget>[
                          //           // SizedBox(height: 8.0),
                          //           // RichText(
                          //           //   text: TextSpan(
                          //           //     style: openingTimeTextStyle,
                          //           //     children: [
                          //           //       TextSpan(text: "Open Now "),
                          //           //       TextSpan(
                          //           //           text: "daily time ",
                          //           //           style: addressTextStyle),
                          //           //       TextSpan(text: "9:30 am to 11:30 am "),
                          //           //     ],
                          //           //   ),
                          //           // )
                          //         ],
                          //       ),
                          //       // SpaceH24(),
                          //       // HeadingRow(
                          //       //   title: StringConst.MENU_AND_PHOTOS,
                          //       //   number: StringConst.SEE_ALL_32,
                          //       //   onTapOfNumber: () => R.Router.navigator
                          //       //       .pushNamed(R.Router.menuPhotosScreen),
                          //       // ),
                          //       // SizedBox(height: 16.0),
                          //       // Container(
                          //       //   height: 120,
                          //       //   width: MediaQuery.of(context).size.width,
                          //       //   child: ListView.builder(
                          //       //     scrollDirection: Axis.horizontal,
                          //       //     itemCount: 4,
                          //       //     itemBuilder: (context, index) {
                          //       //       return Container(
                          //       //         margin: EdgeInsets.only(right: 12.0),
                          //       //         decoration: BoxDecoration(
                          //       //             borderRadius:
                          //       //                 BorderRadius.all(Radius.circular(8))),
                          //       //         child: Image.asset(
                          //       //           menuPhotosImagePaths[index],
                          //       //           fit: BoxFit.fill,
                          //       //           width: 160,
                          //       //         ),
                          //       //       );
                          //       //     },
                          //       //   ),
                          //       // ),
                          //       SpaceH24(),
                          //       HeadingRow(
                          //         title: StringConst.REVIEWS_AND_RATINGS,
                          //         number: 'See All Reviews',
                          //         onTapOfNumber: () => R.Router.navigator.pushNamed(
                          //             R.Router.reviewRatingScreen,
                          //             arguments:
                          //                 ReviewRating(widget.restaurantDetail.name)),
                          //       ),
                          //       SizedBox(height: 16.0),
                          //       StreamBuilder(
                          //         stream: Firestore.instance
                          //             .collection('Reviews')
                          //             .snapshots(),
                          //         builder: (BuildContext context,
                          //             AsyncSnapshot<QuerySnapshot> snap) {
                          //           if (snap.hasData &&
                          //               !snap.hasError &&
                          //               snap.data != null) {
                          //             reviews.clear();
                          //             recents.clear();
                          //
                          //             for (int i = 0;
                          //                 i < snap.data.documents.length;
                          //                 i++) {
                          //               if (snap.data.documents[i]['dishName'] ==
                          //                   widget.restaurantDetail.name) {
                          //                 reviews.add(ListTile(
                          //                   leading: Image.network(
                          //                       snap.data.documents[i]['userImage']),
                          //                   title: Row(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment.spaceBetween,
                          //                     children: <Widget>[
                          //                       Text(
                          //                         snap.data.documents[i]['userName'],
                          //                         style: subHeadingTextStyle,
                          //                       ),
                          //                       Ratings(
                          //                           snap.data.documents[i]['rating']),
                          //                     ],
                          //                   ),
                          //                   contentPadding:
                          //                       EdgeInsets.symmetric(horizontal: 0),
                          //                   subtitle: Text(
                          //                     snap.data.documents[i]['details'],
                          //                     style: addressTextStyle,
                          //                   ),
                          //                 ));
                          //                 l = reviews.length;
                          //                 if (i < 5) {
                          //                   recents.add(ListTile(
                          //                     leading: Image.network(snap
                          //                         .data.documents[i]['userImage']),
                          //                     title: Row(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment.spaceBetween,
                          //                       children: <Widget>[
                          //                         Text(
                          //                           snap.data.documents[i]
                          //                               ['userName'],
                          //                           style: subHeadingTextStyle,
                          //                         ),
                          //                         Ratings(snap.data.documents[i]
                          //                             ['rating']),
                          //                       ],
                          //                     ),
                          //                     contentPadding:
                          //                         EdgeInsets.symmetric(horizontal: 0),
                          //                     subtitle: Text(
                          //                       snap.data.documents[i]['details'],
                          //                       style: addressTextStyle,
                          //                     ),
                          //                   ));
                          //                 }
                          //               }
                          //             }
                          //             return recents.length != 0
                          //                 ? Column(
                          //                     crossAxisAlignment:
                          //                         CrossAxisAlignment.start,
                          //                     children: recents,
                          //                   )
                          //                 : Container();
                          //           } else
                          //             return Container(
                          //                 child: Center(
                          //                     child: Text(
                          //               "No Data",
                          //               style: TextStyle(color: Colors.black),
                          //             )));
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // )
                          widget.restaurantDetail.boughtTogether != null &&
                                  widget.restaurantDetail.boughtTogether != ''
                              ? Container(
                                  height: 205,
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      GestureDetector(
                                        child: Container(
                                          margin: EdgeInsets.all(5.0),
                                          width: 110.0,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.08),
                                                  offset: Offset(0, 10),
                                                  blurRadius: 10,
                                                  spreadRadius: 0),
                                            ],
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    image: widget
                                                        .restaurantDetail.url,
                                                    fit: BoxFit.fill,
                                                    height: 90,
                                                    placeholder:
                                                        "assets/images/placeholder.jpg",
                                                    placeholderScale:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              (widget.restaurantDetail
                                                              .boughtTogetherQuantity !=
                                                          null &&
                                                      widget.restaurantDetail
                                                              .boughtTogetherQuantity !=
                                                          '')
                                                  ? Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Container(
                                                        child: Text(
                                                          " ${widget.restaurantDetail.name} (${widget.restaurantDetail.boughtTogetherQuantity})",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Styles
                                                              .customNormalTextStyle(
                                                                  color: Color(
                                                                      0xFF6b3600)),
                                                        ),
                                                      ),
                                                    )
                                                  : Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Container(
                                                        child: Text(
                                                          "${widget.restaurantDetail.name}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Styles
                                                              .customNormalTextStyle(
                                                                  color: Color(
                                                                      0xFF6b3600)),
                                                        ),
                                                      ),
                                                    ),
                                              Spacer(),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  child: Text(
                                                    'AED ${widget.restaurantDetail.price}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Styles
                                                        .customNormalTextStyle(
                                                            color: Color(
                                                                0xFF6b3600)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.add,
                                        color: Color(0xFF6b3600),
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          margin: EdgeInsets.all(5.0),
                                          width: 110.0,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.08),
                                                  offset: Offset(0, 10),
                                                  blurRadius: 10,
                                                  spreadRadius: 0),
                                            ],
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    image: widget
                                                        .restaurantDetail
                                                        .boughtTogether
                                                        .url,
                                                    fit: BoxFit.fill,
                                                    height: 90,
                                                    placeholder:
                                                        "assets/images/placeholder.jpg",
                                                    placeholderScale:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  child: Text(
                                                    ' ${widget.restaurantDetail.boughtTogether.name},(${widget.restaurantDetail.boughtTogetherQuantity})',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Styles
                                                        .customNormalTextStyle(
                                                            color: Color(
                                                                0xFF6b3600)),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  child: Text(
                                                    'AED ${widget.restaurantDetail.boughtTogether.price}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Styles
                                                        .customNormalTextStyle(
                                                            color: Color(
                                                                0xFF6b3600)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.drag_handle,
                                        color: Color(0xFF6b3600),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(5.0),
                                        width: 110.0,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.08),
                                                offset: Offset(0, 10),
                                                blurRadius: 10,
                                                spreadRadius: 0),
                                          ],
                                        ),
                                        child: (widget
                                                        .restaurantDetail
                                                        .boughtTogether
                                                        .boughtTogetherDiscount !=
                                                    null &&
                                                widget.restaurantDetail
                                                        .boughtTogetherDiscount !=
                                                    '')
                                            ? Column(
                                                children: <Widget>[
                                                  Spacer(),
                                                  Container(
                                                    child: Text(
                                                      "AED ${double.parse(widget.restaurantDetail.price) + double.parse(widget.restaurantDetail.boughtTogether.price)}",
                                                      style: GoogleFonts.poppins(
                                                          color:
                                                              Color(0xFF6b3600),
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_downward_rounded,
                                                    color: Color(0xFF6b3600),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "AED ${(double.parse(widget.restaurantDetail.price) + double.parse(widget.restaurantDetail.boughtTogether.price)) * ((100.0 - double.parse(widget.restaurantDetail.boughtTogetherDiscount)) / 100)}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color:
                                                            Color(0xFF6b3600),
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  angadiButton(
                                                    'Add',
                                                    buttonWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    buttonHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.04,
                                                    onTap: () {
                                                      addToCart(context,
                                                          productId: widget
                                                              .restaurantDetail
                                                              .productID,
                                                          name: widget
                                                              .restaurantDetail
                                                              .name,
                                                          imgUrl: widget
                                                              .restaurantDetail
                                                              .url,
                                                          price:
                                                              '${((double.parse(widget.restaurantDetail.price)) * ((100.0 - double.parse(widget.restaurantDetail.boughtTogetherDiscount)) / 100))}',
                                                          qty: 1,
                                                          qtyTag: widget
                                                              .restaurantDetail
                                                              .boughtTogetherQuantity);
                                                      addToCart(context,
                                                          productId: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .id,
                                                          name: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .name,
                                                          imgUrl: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .url,
                                                          price:
                                                              '${((double.parse(widget.restaurantDetail.boughtTogether.price)) * ((100.0 - double.parse(widget.restaurantDetail.boughtTogetherDiscount)) / 100))}',
                                                          qty: 1,
                                                          qtyTag: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .boughtTogetherQuantity);
                                                    },
                                                  )
                                                  // GestureDetector(
                                                  //   child: Container(
                                                  //       width: 100.0,
                                                  //       height: 25.0,
                                                  //       padding: const EdgeInsets.all(4.0),
                                                  //       decoration: BoxDecoration(
                                                  //         color: Color(0xFF6b3600),
                                                  //         borderRadius:
                                                  //             BorderRadius.circular(8.0),
                                                  //       ),
                                                  //       child: FaIcon(
                                                  //         FontAwesomeIcons.cartArrowDown,
                                                  //         size: 20,
                                                  //         color: Colors.white,
                                                  //       )),
                                                  // ),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  Spacer(),
                                                  Container(
                                                    child: Text(
                                                      "AED ${double.parse(widget.restaurantDetail.price) + double.parse(widget.restaurantDetail.boughtTogether.price)}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color:
                                                            Color(0xFF6b3600),
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
//                                            Icon(
//                                              Icons.arrow_downward_rounded,
//                                              color: Color(0xFF6b3600),
//                                            ),
//                                            Container(
//                                              child: Text(
//                                                "AED ${(double.parse(widget.restaurantDetail.price) + double.parse(widget.restaurantDetail.boughtTogether.price)) * ((100.0 - double.parse(widget.restaurantDetail.boughtTogetherDiscount)) / 100)}",
//                                                style: GoogleFonts.poppins(
//                                                  color: Color(0xFF6b3600),
//                                                  fontSize: 15,
//                                                  fontWeight: FontWeight.w600,
//                                                ),
//                                                textAlign: TextAlign.center,
//                                              ),
//                                            ),
                                                  Spacer(),
                                                  angadiButton(
                                                    'Add',
                                                    buttonWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    buttonHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.04,
                                                    onTap: () {
                                                      addToCart(context,
                                                          productId: widget
                                                              .restaurantDetail
                                                              .productID,
                                                          name: widget
                                                              .restaurantDetail
                                                              .name,
                                                          imgUrl: widget
                                                              .restaurantDetail
                                                              .url,
                                                          price:
                                                              '${((double.parse(widget.restaurantDetail.price)) * ((100.0 - double.parse(widget.restaurantDetail.boughtTogetherDiscount)) / 100))}',
                                                          qty: 1,
                                                          qtyTag: widget
                                                              .restaurantDetail
                                                              .boughtTogetherQuantity);
                                                      addToCart(context,
                                                          productId: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .id,
                                                          name: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .name,
                                                          imgUrl: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .url,
                                                          price:
                                                              '${((double.parse(widget.restaurantDetail.boughtTogether.price)) * ((100.0 - double.parse(widget.restaurantDetail.boughtTogetherDiscount)) / 100))}',
                                                          qty: 1,
                                                          qtyTag: widget
                                                              .restaurantDetail
                                                              .boughtTogether
                                                              .boughtTogetherQuantity);
                                                    },
                                                  )
                                                  // GestureDetector(
                                                  //   child: Container(
                                                  //       width: 100.0,
                                                  //       height: 25.0,
                                                  //       padding: const EdgeInsets.all(4.0),
                                                  //       decoration: BoxDecoration(
                                                  //         color: Color(0xFF6b3600),
                                                  //         borderRadius:
                                                  //             BorderRadius.circular(8.0),
                                                  //       ),
                                                  //       child: FaIcon(
                                                  //         FontAwesomeIcons.cartArrowDown,
                                                  //         size: 20,
                                                  //         color: Colors.white,
                                                  //       )),
                                                  // ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),

                          dishesLike.length != 0
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: HeadingRow(
                                    title: 'You May Also Like',
                                    number: '',
                                    // onTapOfNumber: () {
                                    //   Navigator.push(context,
                                    //       MaterialPageRoute(builder: (BuildContext context) {
                                    //         return TrendingRestaurantsScreen1("top");
                                    //       }));
                                    // },
                                  ),
                                )
                              : Container(),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: dishesLike.length != 0
                                ? Container(
                                    height: 450,
                                    child: GridView(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 5.0,
                                              mainAxisSpacing: 5.0,
                                              childAspectRatio: 0.59),
                                      children: dishesLike,
                                    ),
                                  )
                                : Container(),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: HeadingRow(
                          //     title: 'People Also Bought',
                          //     number: '',
                          //     // onTapOfNumber: () {
                          //     //   Navigator.push(context,
                          //     //       MaterialPageRoute(builder: (BuildContext context) {
                          //     //         return TrendingRestaurantsScreen1("top");
                          //     //       }));
                          //     // },
                          //   ),
                          // ),
                          //
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Container(
                          //     height: 180,
                          //     child: dishesLike.length != 0
                          //         ? ListView(
                          //             scrollDirection: Axis.horizontal,
                          //             children: dishesBought,
                          //           )
                          //         : Container(),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    (widget.restaurantDetail.stock)
                        ? Row(
                            children: [
                              present == false || present == null
                                  ? angadiButton(
                                      'Save For Later',
                                      buttonTextStyle: addressTextStyle,
                                      onTap: () async {
                                        var temp = await _queryWishlist(
                                            widget.restaurantDetail.name);
                                        // print(temp);
                                        if (temp == null)
                                          addToWishlist(
                                            context,
                                            name: widget.restaurantDetail.name,
                                            imgUrl: widget.restaurantDetail.url,
                                            price: prodisprice,
                                          );
                                        else
                                          setState(() {
                                            // print('Item already exists');
                                            present = true;
                                          });
                                      },
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                                      buttonHeight: 65,
                                      buttonWidth:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                      decoration: Decorations
                                          .customHalfCurvedButtonDecoration(
                                        color: AppColors.secondaryColor,
                                        topleftRadius: Sizes.RADIUS_14,
                                        topRightRadius: Sizes.RADIUS_14,
                                      ),
                                    )
                                  : angadiButton(
                                      'Saved In Wishlist',
                                      buttonTextStyle: addressTextStyle,
                                      onTap: () async {},
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                                      buttonHeight: 65,
                                      buttonWidth:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                      decoration: Decorations
                                          .customHalfCurvedButtonDecoration(
                                        color: AppColors.secondaryColor,
                                        topleftRadius: Sizes.RADIUS_14,
                                        topRightRadius: Sizes.RADIUS_14,
                                      ),
                                    ),

                              qty == 0 || qty == null
                                  ? angadiButton(
                                      'Add to Cart ',

                                      onTap: () async {
//                  await dbHelper.onCreate();
//                  int l = await dbHelper.check(widget.restaurantDetail.name);
//                  print(l);
//                                   var temp = await _query(
//                                       widget.restaurantDetail.name,
//                                       sizes[choice]);
//                                   print(temp);
//                                   if (temp == null)
                                        addToCart(context,
                                            name: widget.restaurantDetail.name,
                                            imgUrl: widget.restaurantDetail.url,
                                            productId: productID,
                                            price: prodisprice,
//                                      price: (int.parse(widget
//                                                  .restaurantDetail.price) *
//                                              priceFactors[choice])
//                                          .toString(),
                                            qty: 1,
                                            qtyTag: qtyTag);
                                        // else
                                        //   setState(() {
                                        //     print('Item already exists');
                                        //     check[choice] = true;
                                        //   });
                                      },
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                                      buttonHeight: 65,
                                      buttonWidth:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                      decoration: Decorations
                                          .customHalfCurvedButtonDecoration(
                                        color: Color(0xFF6b3600),
                                        topleftRadius: Sizes.RADIUS_14,
                                        topRightRadius: Sizes.RADIUS_14,
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              color: Color(0xFF6b3600)),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    await getAllItems();
                                                    for (var v in cartItems) {
                                                      if (v.productName ==
                                                          widget
                                                              .restaurantDetail
                                                              .name) {
                                                        var newQty = v.qty + 1;
                                                        updateItem(
                                                            id: v.id,
                                                            name: v.productName,
                                                            imgUrl: v.imgUrl,
                                                            price: v.price,
                                                            qty: newQty,
                                                            qtyTag: qtyTag);
                                                      }
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  qty.toString(),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    await getAllItems();

                                                    for (var v in cartItems) {
                                                      if (v.productName ==
                                                          widget
                                                              .restaurantDetail
                                                              .name) {
                                                        if (v.qty == 1) {
                                                          removeItem(
                                                              v.productName,
                                                              qtyTag);
                                                        } else {
                                                          var newQty =
                                                              v.qty - 1;
                                                          updateItem(
                                                              id: v.id,
                                                              name:
                                                                  v.productName,
                                                              imgUrl: v.imgUrl,
                                                              price: v.price,
                                                              qty: newQty,
                                                              qtyTag: qtyTag);
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          height: 30,
                                          width: 100,
                                        ),
                                      )),
//                              ): angadiButton(
//                          'Unavailable ',
//
//                          onTap: () async {
////                  await dbHelper.onCreate();
////                  int l = await dbHelper.check(widget.restaurantDetail.name);
////                  print(l);
////                                   var temp = await _query(
////                                       widget.restaurantDetail.name,
////                                       sizes[choice]);
////                                   print(temp);
//////                                   if (temp == null)
////                            addToCart(context,
////                                name: widget.restaurantDetail.name,
////                                imgUrl: widget.restaurantDetail.url,
////                                productId: productID,
////                                price: prodisprice,
//////                                      price: (int.parse(widget
//////                                                  .restaurantDetail.price) *
//////                                              priceFactors[choice])
//////                                          .toString(),
////                                qty: 1,
////                                qtyTag: qtyTag);
////                            // else
////                            //   setState(() {
////                            //     print('Item already exists');
////                            //     check[choice] = true;
////                            //   });
//                          },
////                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
//                          buttonHeight: 65,
//                          buttonWidth:
//                          MediaQuery.of(context).size.width * 0.5,
//                          decoration: Decorations
//                              .customHalfCurvedButtonDecoration(
//                            color: Color(0xFF6b3600),
//                            topleftRadius: Sizes.RADIUS_14,
//                            topRightRadius: Sizes.RADIUS_14,
//                          ),
//                        )
                            ],
                          )
                        : present == false || present == null
                            ? angadiButton(
                                'Save For Later',
                                buttonTextStyle: addressTextStyle,
                                onTap: () async {
                                  var temp = await _queryWishlist(
                                      widget.restaurantDetail.name);
                                  // print(temp);
                                  if (temp == null)
                                    addToWishlist(
                                      context,
                                      name: widget.restaurantDetail.name,
                                      imgUrl: widget.restaurantDetail.url,
                                      price: prodisprice,
                                    );
                                  else
                                    setState(() {
                                      // print('Item already exists');
                                      present = true;
                                    });
                                },
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                                buttonHeight: 65,
                                buttonWidth: MediaQuery.of(context).size.width,
                                decoration: Decorations
                                    .customHalfCurvedButtonDecoration(
                                  color: AppColors.secondaryColor,
                                  topleftRadius: Sizes.RADIUS_14,
                                  topRightRadius: Sizes.RADIUS_14,
                                ),
                              )
                            : angadiButton(
                                'Saved In Wishlist',
                                buttonTextStyle: addressTextStyle,
                                onTap: () async {},
//                    R.Router.navigator.pushNamed(R.Router.addRatingsScreen),
                                buttonHeight: 65,
                                buttonWidth: MediaQuery.of(context).size.width,
                                decoration: Decorations
                                    .customHalfCurvedButtonDecoration(
                                  color: AppColors.secondaryColor,
                                  topleftRadius: Sizes.RADIUS_14,
                                  topRightRadius: Sizes.RADIUS_14,
                                ),
                              ),
                  ],
                ),
              ),
            );
          } else
            return Container(
                child: Center(
                    child: Text(
              "No Data",
              style: TextStyle(color: Colors.black),
            )));
        },
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
}
