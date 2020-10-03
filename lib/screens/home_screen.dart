import 'package:angadi/widgets/offer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/values/data.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/search_input_field.dart';

import '../routes/router.gr.dart';
import '../values/values.dart';

class HomeScreen extends StatefulWidget {
  static const int TAB_NO = 0;

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();

  List<Widget> trending = new List();
  @override
  void initState() {
    // TODO: implement initState
    for (int i = 0; i < 4; i++) {
      trending.add(Container(
        margin: EdgeInsets.only(right: 4.0),
        child: FoodyBiteCard(
          onTap: () => R.Router.navigator.pushNamed(
            R.Router.restaurantDetailsScreen,
            arguments: RestaurantDetails(
              imagePath: 'https://picsum.photos/200',
              restaurantName: 'Hamburger',
              restaurantAddress: 'Created with exotic ingredients',
              rating: ratings[i],
              category: category[i],
              distance: distance[i],
            ),
          ),
          imagePath: imagePaths[i],
          status: '90% OFF',
          cardTitle: 'Hamburger',
          rating: ratings[i],
          category: category[i],
          distance: '',
          address: 'Created with exotic ingredients',
        ),
      ));
    }
    super.initState();
  }

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
        body: Container(
          margin: EdgeInsets.symmetric(
            horizontal: Sizes.MARGIN_16,
            vertical: Sizes.MARGIN_8,
          ),
          child: ListView(
            children: <Widget>[
              FoodyBiteSearchInputField(
                ImagePath.searchIcon,
                controller: controller,
                textFormFieldStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                hintText: StringConst.HINT_TEXT_HOME_SEARCH_BAR,
                hintTextStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                suffixIconImagePath: ImagePath.settingsIcon,
                borderWidth: 0.0,
                onTapOfLeadingIcon: () => R.Router.navigator.pushNamed(
                  R.Router.searchResultsScreen,
                  arguments: SearchValue(
                    controller.text,
                  ),
                ),
                onTapOfSuffixIcon: () =>
                    R.Router.navigator.pushNamed(R.Router.filterScreen),
                borderStyle: BorderStyle.solid,
              ),
              SizedBox(height: 16.0),
              HeadingRow(
                title: StringConst.OFFERS,
                number: '',
                onTapOfNumber: () => R.Router.navigator
                    .pushNamed(R.Router.trendingRestaurantsScreen),
              ),
              SizedBox(height: 16.0),
              Container(
                height: 280,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 4.0),
                        child: OfferCard(
                          onTap: () {},
                          imagePath: 'https://picsum.photos/200',
                          // status: '90% OFF',
                          cardTitle: '25% Off',
                          // rating: ratings[index],
                          // category: category[index],
                          // distance: '',
                          details: 'Get 25% off on all the dishes',
                        ),
                      );
                    }),
              ),
              SizedBox(height: 16.0),
              HeadingRow(
                title: StringConst.CATEGORY,
                number: StringConst.SEE_ALL_9,
                onTapOfNumber: () =>
                    R.Router.navigator.pushNamed(R.Router.categoriesScreen),
              ),
              SizedBox(height: 16.0),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryImagePaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 8.0),
                      child: FoodyBiteCategoryCard(
                        imagePath: categoryImagePaths[index],
                        gradient: gradients[index],
                        category: category[index],
                        onTap: () => R.Router.navigator.pushNamed(
                          R.Router.categoryDetailScreen,
                          arguments: CategoryDetailScreenArguments(
                            categoryName: category[index],
                            imagePath: categoryListImagePaths[index],
                            selectedCategory: index,
                            numberOfCategories: categoryListImagePaths.length,
                            gradient: gradients[index],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // SizedBox(height: 16.0),
              // HeadingRow(
              //   title: StringConst.FRIENDS,
              //   number: StringConst.SEE_ALL_56,
              //   onTapOfNumber: () => R.Router.navigator.pushNamed(
              //     R.Router.findFriendsScreen,
              //   ),
              // ),
              // SizedBox(height: 16.0),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: createUserProfilePhotos(numberOfProfilePhotos: 6),
              // ),
              SizedBox(height: 16.0),
              HeadingRow(
                title: StringConst.DISHES,
                number: StringConst.SEE_ALL_45,
                onTapOfNumber: () => R.Router.navigator
                    .pushNamed(R.Router.trendingRestaurantsScreen),
              ),
              SizedBox(height: 16.0),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView(
                  children: trending,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> createUserProfilePhotos({@required numberOfProfilePhotos}) {
    List<Widget> profilePhotos = [];
    List<String> imagePaths = [
      ImagePath.profile1,
      ImagePath.profile2,
      ImagePath.profile3,
      ImagePath.profile4,
      ImagePath.profile1,
      ImagePath.profile2,
    ];

    List<int> list = List<int>.generate(numberOfProfilePhotos, (i) => i + 1);

    list.forEach((i) {
      profilePhotos
          .add(CircleAvatar(backgroundImage: AssetImage(imagePaths[i - 1])));
    });
    return profilePhotos;
  }
}
