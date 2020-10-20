import 'package:angadi/classes/cart.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'card_tags.dart';

class FoodyBiteCard extends StatefulWidget {
  final String status;
  final String rating;
  final String imagePath;
  final String cardTitle;
  final String category;
  final String distance;
  final String address;
  final String price;
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

  FoodyBiteCard({
    this.status = "OPEN",
    this.rating = "4.5",
    this.imagePath,
    this.cardTitle,
    this.category,
    this.distance,
    this.address,
    this.price,
    this.width = 340.0,
    this.cardHeight = 255.0,
    this.imageHeight = 169.0,
    this.tagRadius = 8.0,
    this.onTap,
    this.isThereStatus = true,
    this.isThereRatings = true,
    this.bookmark = false,
    this.cardElevation = 4.0,
    this.ratingsAndStatusCardElevation = 8.0,
    this.followersImagePath,
  });

  @override
  _FoodyBiteCardState createState() => _FoodyBiteCardState();
}

class _FoodyBiteCardState extends State<FoodyBiteCard> {
  final dbHelper = DatabaseHelper.instance;
  Cart item;
  var length;
  var qty;
  List<Cart> cartItems = [];

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
    Fluttertoast.showToast(msg: 'Updated', toastLength: Toast.LENGTH_SHORT);
    getAllItems();
  }

  void removeItem(String name) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name);
    getAllItems();
    setState(() {
      check = false;
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
        if (v.productName == widget.cardTitle) qty = v.qty;
      }
//      print(cartItems[1]);
    });
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

  getCartLength() async {
    int x = await dbHelper.queryRowCount();
    length = x;
    setState(() {
      print('Length Updated');
      length;
    });
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

  bool check = false;

  void checkInCart() async {
    var temp = await _query(widget.cardTitle);
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
    // TODO: implement initState
    checkInCart();
    getAllItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.cardHeight,
        child: Card(
          elevation: widget.cardElevation,
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
                        widget.imagePath,
                        width: MediaQuery.of(context).size.width,
                        height: widget.imageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Sizes.MARGIN_16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                widget.cardTitle,
                                textAlign: TextAlign.left,
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.headingText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.TEXT_SIZE_20,
                                ),
                              ),
                              SizedBox(width: Sizes.WIDTH_4),
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
                            ],
                          ),
                          SizedBox(height: 6.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Container(
                                      child: Text(
                                        'Rs. ${widget.price}',
                                        textAlign: TextAlign.left,
                                        style: Styles.customMediumTextStyle(
                                          color: AppColors.black,
                                          fontSize: Sizes.TEXT_SIZE_22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      child: Text(
                                          'Rs. ${(int.parse(widget.price) + (int.parse(widget.price) * 0.12)).toStringAsFixed(2)}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 20,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                    ),
                                  ],
                                ),
                              ),

//                              color: AppColors.accentText,
//                              fontSize: Sizes.TEXT_SIZE_22,
                              check == false
                                  ? InkWell(
                                      onTap: () {
                                        addToCart(
                                            name: widget.cardTitle,
                                            imgUrl: widget.imagePath,
                                            price: widget.price,
                                            qty: 1);
                                      },
                                      child: angadiButton(
                                        'Add',
                                        buttonHeight: 30,
                                        buttonWidth: 100,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: AppColors.secondaryElement),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Cart x;
                                              for (var v in cartItems) {
                                                if (v.productName ==
                                                    widget.cardTitle) x = v;
                                              }
                                              var newQty = x.qty + 1;
                                              updateItem(
                                                  id: x.id,
                                                  name: x.productName,
                                                  imgUrl: x.imgUrl,
                                                  price: x.price,
                                                  qty: newQty);
                                            },
                                            child: Icon(
                                              Icons.add,
                                              color: AppColors.secondaryColor,
                                            ),
                                          ),
                                          Text(qty.toString()),
                                          InkWell(
                                            onTap: () {
                                              Cart x;
                                              for (var v in cartItems) {
                                                if (v.productName ==
                                                    widget.cardTitle) x = v;
                                              }
                                              if (x.qty == 1) {
                                                removeItem(x.productName);
                                              } else {
                                                var newQty = x.qty - 1;
                                                updateItem(
                                                    id: x.id,
                                                    name: x.productName,
                                                    imgUrl: x.imgUrl,
                                                    price: x.price,
                                                    qty: newQty);
                                              }
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              color: AppColors.secondaryColor,
                                            ),
                                          )
                                        ],
                                      ),
                                      height: 30,
                                      width: 100,
                                    )
                            ],
                          ),
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
                    widget.isThereRatings
                        ? Card(
                            elevation: widget.ratingsAndStatusCardElevation,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizes.WIDTH_8,
                                vertical: Sizes.WIDTH_4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Image.asset(
                                    ImagePath.starIcon,
                                    height: Sizes.WIDTH_14,
                                    width: Sizes.WIDTH_14,
                                  ),
                                  SizedBox(width: Sizes.WIDTH_4),
                                  Text(
                                    widget.rating,
                                    style: Styles.customTitleTextStyle(
                                      color: AppColors.headingText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Sizes.TEXT_SIZE_14,
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
            ],
          ),
        ),
      ),
    );
  }
}
