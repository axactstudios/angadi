import 'package:angadi/widgets/potbelly_button.dart';
import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';

import 'card_tags.dart';

class FoodyBiteCard extends StatelessWidget {
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
    this.cardHeight = 280.0,
    this.imageHeight = 174.0,
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: cardHeight,
        child: Card(
          elevation: cardElevation,
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
                        imagePath,
                        width: MediaQuery.of(context).size.width,
                        height: imageHeight,
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
                          Row(
                            children: <Widget>[
                              Text(
                                cardTitle,
                                textAlign: TextAlign.left,
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.headingText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.TEXT_SIZE_20,
                                ),
                              ),
                              SizedBox(width: Sizes.WIDTH_4),
                              CardTags(
                                title: category,
                                decoration: BoxDecoration(
                                  gradient: Gradients.secondaryGradient,
                                  boxShadow: [
                                    Shadows.secondaryShadow,
                                  ],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(tagRadius),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Container(
                                      child: Text(
                                        'Rs. $price',
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
                                          'Rs. ${(int.parse(price) + (int.parse(price) * 0.12)).toStringAsFixed(2)}',
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
                              angadiButton(
                                'Add',
                                buttonHeight: 40,
                                buttonWidth: 100,
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
                    isThereRatings
                        ? Card(
                            elevation: ratingsAndStatusCardElevation,
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
                                    rating,
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

//  Widget cardTags({String title, BoxDecoration decoration}) {
//    return Opacity(
//      opacity: 0.8,
//      child: Container(
//        width: 40,
//        height: 14,
//        decoration: decoration,
//        child: Center(
//          child: Text(
//            title,
//            textAlign: TextAlign.center,
//            style: Styles.customNormalTextStyle(
//              fontSize: Sizes.TEXT_SIZE_10,
//            ),
//          ),
//        ),
//      ),
//    );
//  }
}
