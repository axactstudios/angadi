import 'package:angadi/classes/cart.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'card_tags.dart';

class CartCard extends StatefulWidget {
//  final String status;
  final String price;
  final String imagePath;
  final String cardTitle;
  final int qty;
  final int id;

//  final String category;
//  final String distance;
//  final String address;
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

  CartCard({
    this.id,
    this.qty,
    this.imagePath,
    this.cardTitle,
    this.price,
//    this.distance,
//    this.address,
    this.width = 340.0,
    this.cardHeight = 280.0,
    this.imageHeight = 180.0,
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
  _CartCardState createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  final dbHelper = DatabaseHelper.instance;

  void removeItem(String name) async {
    final rowsDeleted = await dbHelper.delete(name);
//    getAllItems();
    Fluttertoast.showToast(
        msg: 'Removed from cart', toastLength: Toast.LENGTH_SHORT);
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
    Fluttertoast.showToast(msg: 'Updated', toastLength: Toast.LENGTH_SHORT);
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
                        vertical: Sizes.MARGIN_16,
                      ),
                      child: Column(
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
                          SizedBox(height: 12.0),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.add_box,
                                    color: Colors.white,
                                    size: widget.width * 0.07,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      widget.qty.toString(),
                                      textAlign: TextAlign.left,
                                      style: Styles.customNormalTextStyle(
                                        color: AppColors.accentText,
                                        fontSize: Sizes.TEXT_SIZE_14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (widget.qty == 1) {
                                      removeItem(widget.cardTitle);
                                    } else {
                                      var newQty = widget.qty - 1;
                                      updateItem(
                                          id: widget.id,
                                          name: widget.cardTitle,
                                          imgUrl: widget.imagePath,
                                          price: widget.price,
                                          qty: newQty);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.indeterminate_check_box,
                                      color: Colors.white,
                                      size: widget.width * 0.07,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                              child: Text(
                                'Rs. ${widget.price}',
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.headingText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.TEXT_SIZE_14,
                                ),
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
