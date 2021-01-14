import 'package:angadi/classes/cart.dart';
import 'package:angadi/classes/quantity.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_tags.dart';

//TODO:Enter Qty Tag
class FoodyBiteCard extends StatefulWidget {
  final String status;
  final String rating;
  final String imagePath;
  final String cardTitle;
  final String category;
  final String distance;
  final String address;
  final String price;
  final String iPrice;
  final GestureTapCallback onTap;
  final bool bookmark;
  final bool isThereStatus;
  final bool isThereRatings;
  final double tagRadius;
  final double width;
  final double cardHeight;
  final double imageHeight;
  final double cardElevation;
  final double ratingsAndStatusCardElevation;
  final List<String> followersImagePath;
  final int orderCount;
  List<Quantity>allquantities=[];
  List<String>quantities=[];

  FoodyBiteCard(
      {this.status = "OPEN",
      this.rating = "4.5",
      this.imagePath,
      this.cardTitle,
      this.category,
      this.distance,
      this.address,
      this.price,
      this.iPrice,
      this.width = 320,
      this.cardHeight = 305.0,
      this.imageHeight = 169.0,
      this.tagRadius = 8.0,
      this.onTap,
      this.isThereStatus = true,
      this.isThereRatings = true,
      this.bookmark = false,
      this.cardElevation = 4.0,
      this.ratingsAndStatusCardElevation = 8.0,
      this.followersImagePath,
      this.orderCount,this.allquantities,this.quantities});

  @override
  _FoodyBiteCardState createState() => _FoodyBiteCardState();
}

class _FoodyBiteCardState extends State<FoodyBiteCard> {
  final dbHelper = DatabaseHelper.instance;
  Cart item;
  var length;
  var qty = 1;
  int choice = 0;
  var proprice;
  var prodisprice;

  List<String>allqan=[];
  List<Cart> cartItems = [];
  static List<bool> check = [false, false, false, false, false];
  void updateItem(
      {int id,
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
    setState(() {
      check[choice] = false;
      qty = 0;
    });
    Fluttertoast.showToast(
        msg: 'Removed from cart', toastLength: Toast.LENGTH_SHORT);
  }

  void getAllItems() async {
    final allRows = await dbHelper.queryAllRows();
    cartItems.clear();
    await allRows.forEach((row) => cartItems.add(Cart.fromMap(row)));
    setState(() {
      for (var v in cartItems) {
        if (v.productName == widget.cardTitle &&
           v.qtyTag == widget.quantities[choice]) {
          qty = v.qty;
        }
      }
//      print(cartItems[1]);
    });
  }

  String orderid;

  void addToCart(
      {String name,
      String imgUrl,
      String price,
      int qty,
      String qtyTag}) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnProductName: name,
      DatabaseHelper.columnImageUrl: imgUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty,
      DatabaseHelper.columnQuantityTag: qtyTag
    };
    if (cartItems.length == 0) {
      await print('----------------$widget.orderCount');
      if (widget.orderCount + 1 < 9) {
        await setState(() {
          orderid = 'ANG0000${widget.orderCount + 1}';
        });
      }
      if (widget.orderCount + 1 > 10 && widget.orderCount + 1 < 99) {
        await setState(() {
          orderid = 'ANG000${widget.orderCount + 1}';
        });
      }
      if (widget.orderCount + 1 > 99 && widget.orderCount + 1 < 999) {
        await setState(() {
          orderid = 'ANG00${widget.orderCount + 1}';
        });
      }
      if (widget.orderCount + 1 > 999 && widget.orderCount + 1 < 9999) {
        await setState(() {
          orderid = 'ANG0${widget.orderCount + 1}';
        });
      }
      if (widget.orderCount + 1 > 9999 && widget.orderCount + 1 < 99999) {
        await setState(() {
          orderid = 'ANG${widget.orderCount + 1}';
        });
      }
      if (widget.orderCount + 1 > 99999) {
        await setState(() {
          orderid = 'ANG${widget.orderCount + 1}';
        });
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Orderid', orderid);
      print(orderid);

      prefs.setString('Status', 'Not placed');
      await Firestore.instance
          .collection('Ordercount')
          .document('ordercount')
          .updateData({
        'Numberoforders': widget.orderCount + 1,
      });
    }

    Cart item = Cart.fromMap(row);
    final id = await dbHelper.insert(item);
    Fluttertoast.showToast(
        msg: 'Added to cart', toastLength: Toast.LENGTH_SHORT);
    setState(() {
      check[choice] = true;
    });
    await getAllItems();
    getCartLength();
  }

  getCartLength() async {
    int x = await dbHelper.queryRowCount();
    length = x;
    setState(() {
      print('Length Updated');
      length;
    });
  }

  Future<Cart> _query(String name, String qtyTag) async {
    final allRows = await dbHelper.queryRows(name, qtyTag);
    print(allRows);

    allRows.forEach((row) => item = Cart.fromMap(row));
    setState(() {
      item;
//      print(item.qtyTag);
      print('-------------Updated');
    });
    return item;
  }

  var factor = 1;
  String qtyTag;
  List<String> listOfQuantities = [

  ];

  Future<int> getQuantity(String name, String qtyTag) async {
    var temp = await _query(name, qtyTag);
    if (temp != null) {
      if (temp.productName == name && temp.qtyTag == qtyTag) {
        print('item found');
        qty = temp.qty;
        return temp.qty;
      } else {
        return 0;
      }
    }
  }

  void checkInCart(String qtyTag) async {
    var temp = await _query(widget.cardTitle, qtyTag);
    print(temp);
    if (temp != null) {
      if (temp.productName == widget.cardTitle && temp.qtyTag == qtyTag) {
        setState(() {
          print('Item already exists');
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

  first() async {
    qty = await getQuantity(widget.cardTitle, '${widget.quantities[0]}');
  }
  void getquantities(){
    listOfQuantities.clear();
    for(int i=0;i<widget.allquantities.length;i++){

      }}

  @override
  void initState() {
    choice = 0;
    qtyTag=widget.quantities[0];
    first();
    proprice=widget.allquantities[0].iPrice;
    prodisprice=widget.allquantities[0].price;
    checkInCart('${widget.quantities[0]}');
    getAllItems();
    print('@@@@@@@${widget.quantities}');
    getquantities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.91;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: width,
        child: Card(
          elevation: widget.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Stack(children: [
                  Positioned(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: FancyShimmerImage(
                        shimmerDuration: Duration(seconds: 2),
                        imageUrl: widget.imagePath,
                        height: 180,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    // right: 16.0,
                    top: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        widget.isThereRatings
                            ? Card(
                                elevation: widget.ratingsAndStatusCardElevation,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
//                                  Image.asset(
//                                    ImagePath.starIcon,
//                                    height: Sizes.WIDTH_14,
//                                    width: Sizes.WIDTH_14,
//                                  ),

                                      Text(
                                        ('${((int.parse(proprice) - int.parse(prodisprice)) / int.parse(proprice) * 100).toStringAsFixed(0)} % off'),
                                        style: Styles.customTitleTextStyle(
                                          color: Colors.deepOrangeAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        widget.cardTitle,
                        textAlign: TextAlign.left,
                        style: Styles.customTitleTextStyle(
                          color: AppColors.headingText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CardTags(
                      title: widget.category,
                      decoration: BoxDecoration(
                        gradient: Gradients.secondaryGradient,
                        boxShadow: [
                          Shadows.secondaryShadow,
                        ],
                        borderRadius: BorderRadius.all(
                          Radius.circular(widget.tagRadius),
                        ),
                      ),
                    ),
                    DropDown<String>(

//                      items: <String>[
//
//                        '500 ML',
//                        '1 Ltr:  Rs.${(int.parse(widget.price) * 2).toString()}',
//                        '2 Ltr:  Rs.${(int.parse(widget.price) * 4).toString()}',
//                        '5 Ltr:  Rs.${(int.parse(widget.price) * 10).toString()}',
//                        '10 Ltr:   Rs.${(int.parse(widget.price) * 20).toString()}'
//                      ],
                    items: widget.quantities,

                      hint: Text("Select quantity"),
                      onChanged: (value) async {
                        await getAllItems();

//                        if (value == '500 ML') {
//                          factor = await 1;
//                          qtyTag = await '500 ML';
//                          choice = await 0;
                          await checkInCart(value);
                          qty = await getQuantity(widget.cardTitle, value);
                          for(int i =0;i<widget.allquantities.length;i++){
                            if(value=='${widget.allquantities[i].quantity}'){
                              setState(() {
                                qtyTag='${widget.allquantities[i].quantity}';
                                proprice=widget.allquantities[i].iPrice;
                                prodisprice=widget.allquantities[i].price;
                              });
                            }
                          }
//                        }
//                        if (value ==
//                            '1 Ltr:  Rs.${(int.parse(widget.price) * 2).toString()}') {
//                          factor = await 2;
//                          qtyTag = await '1 Ltr';
//                          choice = await 1;
//                          await checkInCart('1 Ltr');
//                          qty = await getQuantity(widget.cardTitle, '1 Ltr');
//                        }
//                        if (value ==
//                            '2 Ltr:  Rs.${(int.parse(widget.price) * 4).toString()}') {
//                          factor = await 4;
//                          choice = await 2;
//                          qtyTag = await '2 Ltr';
//                          await checkInCart('2 Ltr');
//                          qty = await getQuantity(widget.cardTitle, '2 Ltr');
//                        }
//                        if (value ==
//                            '5 Ltr:  Rs.${(int.parse(widget.price) * 10).toString()}') {
//                          factor = await 10;
//                          choice = await 3;
//                          qtyTag = await '5 Ltr';
//                          await checkInCart('5 Ltr');
//                          qty = await getQuantity(widget.cardTitle, '5 Ltr');
//                        }
//                        if (value ==
//                            '10 Ltr:   Rs.${(int.parse(widget.price) * 20).toString()}') {
//                          factor = await 20;
//                          choice = await 4;
//                          qtyTag = await '10 Ltr';
//                          await checkInCart('10 Ltr');
//                          qty = await getQuantity(widget.cardTitle, '10 Ltr');
//                        }
                        setState(() {
                          print(factor);
                          print(choice);
                          print(qtyTag);
                          print(qty);
                        });
                      },
                    ),
                    SizedBox(height: 6.0),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            'Rs. ${(int.parse(prodisprice).toString())}  ',
                            textAlign: TextAlign.left,
                            style: Styles.customMediumTextStyle(
                              color: AppColors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                              'Rs. ${(int.parse(proprice).toString())}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.lineThrough)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
//                              color: AppColors.accentText,
//                              fontSize: Sizes.TEXT_SIZE_22,
                    qty == 0 || qty == null
                        ? InkWell(
                            onTap: () {
                              print('===========$qtyTag=======');
                              addToCart(
                                  name: widget.cardTitle,
                                  imgUrl: widget.imagePath,
                                  price: prodisprice,
                                  qty: 1,
                                  qtyTag: qtyTag);
                            },
                            child: angadiButton(
                              'Add',
                              buttonHeight: 25,
                              buttonWidth: 90,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: AppColors.secondaryElement),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await getAllItems();
                                    for (var v in cartItems) {
                                      if (v.productName == widget.cardTitle) {
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
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                Text(
                                  qty.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await getAllItems();

                                    for (var v in cartItems) {
                                      if (v.productName == widget.cardTitle) {
                                        if (v.qty == 1) {
                                          removeItem(v.productName, qtyTag);
                                        } else {
                                          var newQty = v.qty - 1;
                                          updateItem(
                                              id: v.id,
                                              name: v.productName,
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
                                    color: AppColors.secondaryColor,
                                  ),
                                )
                              ],
                            ),
                            height: 25,
                            width: 90,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
