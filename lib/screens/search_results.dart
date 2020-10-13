import 'package:flutter/material.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/search_input_field.dart';
import 'package:angadi/widgets/spaces.dart';

class SearchResultsScreen extends StatelessWidget {
  final SearchValue searchValue;

  SearchResultsScreen(this.searchValue);

  @override
  Widget build(BuildContext context) {
    void navigateToDetailScreen() {
      R.Router.navigator.pushNamed(R.Router.restaurantDetailsScreen);
    }

    var controller = TextEditingController(text: searchValue.value);

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            left: Sizes.MARGIN_16,
            right: Sizes.MARGIN_16,
            top: Sizes.MARGIN_16,
          ),
          child: Column(
            children: <Widget>[
              FoodyBiteSearchInputField(
                ImagePath.searchIcon,
                controller: controller,
                textFormFieldStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                hintText: StringConst.HINT_TEXT_TRENDING_SEARCH_BAR,
                hintTextStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                suffixIconImagePath: ImagePath.closeIcon,
                onTapOfSuffixIcon: () => Navigator.pop(context),
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
                        status: status[index],
                        cardTitle: restaurantNames[index],
                        rating: ratings[index],
                        category: category[index],
                        distance: distance[index],
                        address: addresses[index],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
