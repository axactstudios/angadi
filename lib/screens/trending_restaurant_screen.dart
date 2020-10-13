import 'package:flutter/material.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/search_input_field.dart';
import 'package:angadi/widgets/spaces.dart';

class TrendingRestaurantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            leading: InkWell(
              onTap: () => R.Router.navigator.pop(),
              child: Image.asset(
                ImagePath.arrowBackIcon,
                color: AppColors.headingText,
              ),
            ),
            centerTitle: true,
            title: Text(
              'Trending Restaurant',
              style: Styles.customTitleTextStyle(
                color: AppColors.headingText,
                fontWeight: FontWeight.w600,
                fontSize: Sizes.TEXT_SIZE_20,
              ),
            ),
          ),
          body: Container(
            margin: const EdgeInsets.only(
                left: Sizes.MARGIN_16,
                right: Sizes.MARGIN_16,
                top: Sizes.MARGIN_16),
            child: Column(
              children: <Widget>[
                FoodyBiteSearchInputField(
                  ImagePath.searchIcon,
                  textFormFieldStyle:
                      Styles.customNormalTextStyle(color: AppColors.accentText),
                  hintText: StringConst.HINT_TEXT_TRENDING_SEARCH_BAR,
                  hintTextStyle:
                      Styles.customNormalTextStyle(color: AppColors.accentText),
                  suffixIconImagePath: ImagePath.settingsIcon,
                  borderWidth: 0.0,
                  borderStyle: BorderStyle.solid,
                ),
                SizedBox(height: Sizes.WIDTH_16),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemCount: 4,
                    separatorBuilder: (context, index) {
                      return SpaceH8();
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        child: FoodyBiteCard(
                          onTap: () => R.Router.navigator.pushNamed(
                            R.Router.restaurantDetailsScreen,
                            arguments: RestaurantDetails(
                              url: 'snap.data.documents[i][',
                              name: 'Hamburger',
                              desc: 'Description',
                              category: 'Category',
                              rating: 'Rating',
                              price: 'Price',
                            ),
                          ),
                          imagePath: imagePaths[index],
                          status: '20% OFF',
                          cardTitle: 'Hamburger',
                          rating: ratings[index],
                          category: category[index],
                          distance: '',
                          address: 'Made with exotic ingredients',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
