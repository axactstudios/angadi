import 'package:angadi/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/spaces.dart';

class Ratings extends StatelessWidget {
  final String rating;

  Ratings(this.rating);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.kFoodyBiteSkyBlue,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            ImagePath.starIcon,
            height: 10,
            width: 10,
          ),
          SizedBox(width: Sizes.WIDTH_4),
          Text(
            double.parse(rating).toStringAsFixed(1),
            style: Styles.customTitleTextStyle(
              color: AppColors.headingText,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          )
        ],
      ),
    );
  }
}

double initRat = 0;

class RatingsBar extends StatelessWidget {
  RatingsBar({
    this.title = "Rating",
    this.hasSubtitle = true,
    this.subtitle = "Rate your experience",
    this.hasTitle = true,
  });

  final String title;
  final bool hasTitle;
  final String subtitle;
  final bool hasSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        hasTitle
            ? Text(
                title,
                style: Styles.customTitleTextStyle(
                  color: AppColors.headingText,
                  fontWeight: FontWeight.w600,
                  fontSize: Sizes.TEXT_SIZE_20,
                ),
              )
            : Container(),
        hasTitle ? SpaceH16() : Container(),
        Container(
          width: MediaQuery.of(context).size.width - 60,
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: AppColors.kFoodyBiteSkyBlue,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Center(
            child: RatingBar(
              initialRating: initRat,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 48,
              unratedColor: AppColors.kFoodyBiteGreyRatingStar,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                rat = rating;
                print(rating);
              },
            ),
          ),
        ),
        SpaceH12(),
        hasSubtitle
            ? Text(
                subtitle,
                style: Styles.customNormalTextStyle(
                  color: AppColors.accentText,
                  fontSize: Sizes.TEXT_SIZE_16,
                ),
              )
            : Container(),
      ],
    );
  }
}
