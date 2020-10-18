import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';

import 'card_tags.dart';

class OfferCard extends StatelessWidget {
  // final String status;
  // final String rating;
  final String imagePath;
  final String cardTitle;
  // final String category;
  // final String distance;
  final String details;
  final GestureTapCallback onTap;
  // final bool bookmark;
  // final bool isThereStatus;
  // final bool isThereRatings;
  final double tagRadius;
  final double width;
  final double cardHeight;
  final double imageHeight;
  final double cardElevation;
  final double ratingsAndStatusCardElevation;
  // final List<String> followersImagePath;

  OfferCard({
    // this.status = "OPEN",
    // this.rating = "4.5",
    this.imagePath,
    this.cardTitle,
    // this.category,
    // this.distance,
    this.details,
    this.width = 340.0,
    this.cardHeight = 240.0,
    this.imageHeight = 190.0,
    this.tagRadius = 8.0,
    this.onTap,
    // this.isThereStatus = true,
    // this.isThereRatings = true,
    // this.bookmark = false,
    this.cardElevation = 4.0,
    this.ratingsAndStatusCardElevation = 8.0,
    // this.followersImagePath,
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
                              // CardTags(
                              //   title: category,
                              //   decoration: BoxDecoration(
                              //     gradient: Gradients.secondaryGradient,
                              //     boxShadow: [
                              //       Shadows.secondaryShadow,
                              //     ],
                              //     borderRadius: BorderRadius.all(
                              //       Radius.circular(tagRadius),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  width: width * 0.8,
                                  child: Text(
                                    details,
                                    textAlign: TextAlign.left,
                                    style: Styles.customNormalTextStyle(
                                      color: AppColors.accentText,
                                      fontSize: Sizes.TEXT_SIZE_14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

class OfferCardApply extends StatelessWidget {
  // final String status;
  // final String rating;
  final String imagePath;
  final String cardTitle;
  // final String category;
  // final String distance;
  final String details;
  final GestureTapCallback onTap;
  // final bool bookmark;
  // final bool isThereStatus;
  // final bool isThereRatings;
  final double tagRadius;
  final double width;
  final double cardHeight;
  final double imageHeight;
  final double cardElevation;
  final double ratingsAndStatusCardElevation;
  // final List<String> followersImagePath;

  OfferCardApply({
    // this.status = "OPEN",
    // this.rating = "4.5",
    this.imagePath,
    this.cardTitle,
    // this.category,
    // this.distance,
    this.details,
    this.width = 340.0,
    this.cardHeight = 240.0,
    this.imageHeight = 190.0,
    this.tagRadius = 8.0,
    this.onTap,
    // this.isThereStatus = true,
    // this.isThereRatings = true,
    // this.bookmark = false,
    this.cardElevation = 4.0,
    this.ratingsAndStatusCardElevation = 8.0,
    // this.followersImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    child: Row(
                      children: [
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      width: width * 0.8,
                                      child: Text(
                                        cardTitle,
                                        textAlign: TextAlign.left,
                                        style: Styles.customTitleTextStyle(
                                          color: AppColors.headingText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: Sizes.TEXT_SIZE_20,
                                        ),
                                      ),
                                    )),
                                SizedBox(width: Sizes.WIDTH_4),
                                // CardTags(
                                //   title: category,
                                //   decoration: BoxDecoration(
                                //     gradient: Gradients.secondaryGradient,
                                //     boxShadow: [
                                //       Shadows.secondaryShadow,
                                //     ],
                                //     borderRadius: BorderRadius.all(
                                //       Radius.circular(tagRadius),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 12.0),
                            Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: width * 0.8,
                                    child: Text(
                                      details,
                                      textAlign: TextAlign.left,
                                      style: Styles.customNormalTextStyle(
                                        color: AppColors.accentText,
                                        fontSize: Sizes.TEXT_SIZE_14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: onTap,
                          child: Text(
                            'Apply',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 23,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
