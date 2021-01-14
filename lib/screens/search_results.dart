import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/quantity.dart';
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

import '../routes/router.dart';
import 'filter_screen.dart';
import 'restaurant_details_screen.dart';

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
                Icons.search,
                controller: controller,
                textFormFieldStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                hintText: StringConst.HINT_TEXT_TRENDING_SEARCH_BAR,
                hintTextStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                suffixIconImagePath: Icons.sort,
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
                                boughtTogetherDiscount: snap.data.documents[i]
                                    ['boughtTogetherDiscount'],
                                id: snap.data.documents[i].documentID,
                                name: snap.data.documents[i]['name'],
                                category: snap.data.documents[i]['category'],
                                rating: snap.data.documents[i]['rating'],
                                price: snap.data.documents[i]['price'],
                                desc: snap.data.documents[i]['description'],
                                url: snap.data.documents[i]['url'],
                                boughtTogetherID: snap.data.documents[i]
                                    ['boughtTogether']));
                            print(snap.data.documents[i]['name']);

                            trending.add(Container(
                              margin: EdgeInsets.only(right: 4.0),
                              child: FoodyBiteCard(
                                onTap: () async {
                                  Dish boughtTogether;
                                  for (int ind = 0;
                                      ind < snap.data.documents.length;
                                      ind++) {
                                    if (snap.data.documents[ind].documentID ==
                                        snap.data.documents[i]
                                            ['boughtTogether']) {
                                      boughtTogether = await dishes[ind];
                                    }
                                  }
                                  R.Router.navigator.pushNamed(
                                      R.Router.restaurantDetailsScreen,
                                      arguments: RestaurantDetails(
                                        boughtTogetherDiscount:
                                            snap.data.documents[i]
                                                ['boughtTogetherDiscount'],
                                        boughtTogether: boughtTogether,
                                        url: snap.data.documents[i]['url'],
                                        name: snap.data.documents[i]['name'],
                                        desc: snap.data.documents[i]
                                            ['description'],
                                        category: snap.data.documents[i]
                                            ['category'],
                                        rating: snap.data.documents[i]
                                            ['rating'],
                                        price: snap.data.documents[i]['price'],
                                        allquantities: dishes[i].allquantities,
                                        quantities:dishes[i].quantities
                                      ));
                                },
                                imagePath: snap.data.documents[i]['url'],
                                cardTitle: snap.data.documents[i]['name'],
                                rating: snap.data.documents[i]['rating'],
                                category: snap.data.documents[i]['category'],
                                price: snap.data.documents[i]['price'],
                                iPrice: snap.data.documents[i]['iPrice'],
                                address: snap.data.documents[i]['description'],
                                allquantities: dishes[i].allquantities,
                                quantities:dishes[i].quantities,
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
                Icons.search,
                controller: controller,
                textFormFieldStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                hintText: StringConst.HINT_TEXT_HOME_SEARCH_BAR,
                hintTextStyle:
                    Styles.customNormalTextStyle(color: AppColors.accentText),
                suffixIconImagePath: Icons.sort,
                borderWidth: 0.0,
                onTapOfLeadingIcon: () => R.Router.navigator.pushNamed(
                  R.Router.searchResultsScreen,
                  arguments: SearchValue(
                    controller.text,
                  ),
                ),
                onTapOfSuffixIcon: () => Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return FilterScreen();
                })),
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
                            List<Quantity> allquantities = [];
                            List<String> quantities = [];

                            allquantities.clear();
                            quantities.clear();

                            for (int j = 0;
                            j < snap.data.documents[i]['Quantity'].length;
                            j++) {
                              Quantity qu = Quantity(
                                  snap.data.documents[i]['Quantity'][j]['iPrice'],
                                  snap.data.documents[i]['Quantity'][j]['price'],
                                  snap.data.documents[i]['Quantity'][j]['productId'],
                                  '${ snap.data.documents[i]['Quantity'][j]['quantity']} ML');

                              allquantities.add(qu);
                              quantities.add(
                                  '${snap.data.documents[i]['Quantity'][j]['quantity']} ML');
                            }
//              print(snap.data.documents[i]['url']);
                            dishes.add(Dish(
                                boughtTogetherDiscount: snap.data.documents[i]
                                    ['boughtTogetherDiscount'],
                                boughtTogetherQuantity: snap.data.documents[i]['boughtTogetherQuantity'],
                                id: snap.data.documents[i].documentID,
                                name: snap.data.documents[i]['name'],
                                category: snap.data.documents[i]['category'],
                                rating: snap.data.documents[i]['rating'],
                                price: snap.data.documents[i]['price'],
                                desc: snap.data.documents[i]['description'],
                                url: snap.data.documents[i]['url'],
                                boughtTogetherID: snap.data.documents[i]
                                    ['boughtTogether']));
                            print(snap.data.documents[i]['name']);

                            trending.add(Container(
                              margin: EdgeInsets.only(right: 4.0),
                              child: FoodyBiteCard(
                                onTap: () async {
                                  Dish boughtTogether;
                                  for (int ind = 0;
                                      ind < snap.data.documents.length;
                                      ind++) {
                                    if (snap.data.documents[ind].documentID ==
                                        snap.data.documents[i]
                                            ['boughtTogether']) {
                                      boughtTogether = await dishes[ind];
                                    }
                                  }
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return RestaurantDetailsScreen(
                                        RestaurantDetails(
                                            boughtTogetherDiscount: snap
                                                        .data.documents[i]
                                                    ['boughtTogetherDiscount'] *
                                                1.0,
                                            url: snap.data.documents[i]['url'],
                                            boughtTogetherQuantity: snap.data.documents[i]['boughtTogetherQuantity'],
                                            name: snap.data.documents[i]
                                                ['name'],
                                            desc: snap.data.documents[i]
                                                ['description'],
                                            category: snap.data.documents[i]
                                                ['category'],
                                            rating: snap.data.documents[i]
                                                ['rating'],
                                            price: snap.data.documents[i]
                                                ['price'],
                                            boughtTogether: boughtTogether,
                                        allquantities:allquantities,
                                        quantities: quantities));
                                  }));
                                },
                                imagePath: snap.data.documents[i]['url'],
                                cardTitle: snap.data.documents[i]['name'],
                                rating: snap.data.documents[i]['rating'],
                                category: snap.data.documents[i]['category'],
                                price: snap.data.documents[i]['price'],
                                iPrice: snap.data.documents[i]['iPrice'],
                                address: snap.data.documents[i]['description'],
                                allquantities: dishes[i].allquantities,
                                quantities: dishes[i].quantities,
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
