import 'package:angadi/classes/dish.dart';
import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Widget> trending = new List();

  List<Dish> dishes = new List<Dish>();
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
                  child: StreamBuilder(
                      stream:
                          Firestore.instance.collection('Dishes').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snap) {
                        if (snap.hasData &&
                            !snap.hasError &&
                            snap.data != null) {
                          dishes.clear();
                          trending.clear();
                          for (int i = 0; i < snap.data.documents.length; i++) {
//              print(snap.data.documents[i]['url']);
                            dishes.add(Dish(
                                name: snap.data.documents[i]['name'],
                                category: snap.data.documents[i]['category'],
                                rating: snap.data.documents[i]['rating'],
                                price: snap.data.documents[i]['price'],
                                desc: snap.data.documents[i]['description'],
                                url: snap.data.documents[i]['url']));
                            print(snap.data.documents[i]['name']);

                            trending.add(Container(
                              margin: EdgeInsets.only(right: 4.0),
                              child: FoodyBiteCard(
                                onTap: () => R.Router.navigator.pushNamed(
                                    R.Router.restaurantDetailsScreen,
                                    arguments: RestaurantDetails(
                                      url: snap.data.documents[i]['url'],
                                      name: snap.data.documents[i]['name'],
                                      desc: snap.data.documents[i]
                                          ['description'],
                                      category: snap.data.documents[i]
                                          ['category'],
                                      rating: snap.data.documents[i]['rating'],
                                      price: snap.data.documents[i]['price'],
                                    )),
                                imagePath: snap.data.documents[i]['url'],
                                cardTitle: snap.data.documents[i]['name'],
                                rating: snap.data.documents[i]['rating'],
                                category: snap.data.documents[i]['category'],
                                price: snap.data.documents[i]['price'],
                                iPrice: snap.data.documents[i]['iPrice'],
                                address: snap.data.documents[i]['description'],
                              ),
                            ));
                          }
                        }
                        return trending.length != 0
                            ? ListView(
                                children: trending,
                              )
                            : Container();
                      })),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  static const int TAB_NO = 2;

  List<Widget> trending = new List();

  List<Dish> dishes = new List<Dish>();
  @override
  Widget build(BuildContext context) {
    void navigateToDetailScreen() {
      R.Router.navigator.pushNamed(R.Router.restaurantDetailsScreen);
    }

    var controller = TextEditingController();

    return Scaffold(
      floatingActionButton: CustomFloatingButton(CurrentScreen(
          tab_no: SearchScreen.TAB_NO, currentScreen: SearchScreen())),
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
              SizedBox(height: Sizes.WIDTH_16),
              Expanded(
                  child: StreamBuilder(
                      stream:
                          Firestore.instance.collection('Dishes').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snap) {
                        if (snap.hasData &&
                            !snap.hasError &&
                            snap.data != null) {
                          dishes.clear();
                          trending.clear();
                          for (int i = 0; i < snap.data.documents.length; i++) {
//              print(snap.data.documents[i]['url']);
                            dishes.add(Dish(
                                name: snap.data.documents[i]['name'],
                                category: snap.data.documents[i]['category'],
                                rating: snap.data.documents[i]['rating'],
                                price: snap.data.documents[i]['price'],
                                desc: snap.data.documents[i]['description'],
                                url: snap.data.documents[i]['url']));
                            print(snap.data.documents[i]['name']);

                            trending.add(Container(
                              margin: EdgeInsets.only(right: 4.0),
                              child: FoodyBiteCard(
                                onTap: () => R.Router.navigator.pushNamed(
                                    R.Router.restaurantDetailsScreen,
                                    arguments: RestaurantDetails(
                                      url: snap.data.documents[i]['url'],
                                      name: snap.data.documents[i]['name'],
                                      desc: snap.data.documents[i]
                                          ['description'],
                                      category: snap.data.documents[i]
                                          ['category'],
                                      rating: snap.data.documents[i]['rating'],
                                      price: snap.data.documents[i]['price'],
                                    )),
                                imagePath: snap.data.documents[i]['url'],
                                cardTitle: snap.data.documents[i]['name'],
                                rating: snap.data.documents[i]['rating'],
                                category: snap.data.documents[i]['category'],
                                price: snap.data.documents[i]['price'],
                                iPrice: snap.data.documents[i]['iPrice'],
                                address: snap.data.documents[i]['description'],
                              ),
                            ));
                          }
                        }
                        return trending.length != 0
                            ? ListView(
                                children: trending,
                              )
                            : Container();
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
