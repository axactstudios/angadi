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
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'home_screen.dart';
import 'restaurant_details_screen.dart';

class TrendingRestaurantsScreen extends StatefulWidget {
  @override
  _TrendingRestaurantsScreenState createState() =>
      _TrendingRestaurantsScreenState();
}

class _TrendingRestaurantsScreenState extends State<TrendingRestaurantsScreen> {
  List<Widget> trending = new List();

  List<Dish> dishes = new List<Dish>();
  @override
  void initState() {
    super.initState();
    print(cat);
    print(rat);
    print(money);
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
          floatingActionButton: CustomFloatingButton(
            CurrentScreen(
                tab_no: 10, currentScreen: TrendingRestaurantsScreen()),
          ),
          appBar: AppBar(
            elevation: 0.0,
            leading: InkWell(
              // onTap: () => R.Router.navigator.pushNamed(R.Router.rootScreen),
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                ImagePath.arrowBackIcon,
                color: AppColors.headingText,
              ),
            ),
            centerTitle: true,
            title: Text(
              'Results',
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
            child: StreamBuilder(
                stream: Firestore.instance.collection('Dishes').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                  if (snap.hasData && !snap.hasError && snap.data != null) {
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
                            '${snap.data.documents[i]['Quantity'][j]['quantity']}');

                        allquantities.add(qu);
                        quantities.add(
                            '${snap.data.documents[i]['Quantity'][j]['quantity']}');
                      }

//              print(snap.data.documents[i]['url']);
                      if ((money != null
                              ? double.parse(snap.data.documents[i]['price']) <=
                                  money
                              : 1 == 1) &&
                          (rat != null
                              ? double.parse(snap.data.documents[i]['rating'])
                                      .ceil() >=
                                  rat
                              : 1 == 1) &&
                          (cat != null
                              ? snap.data.documents[i]['category'] == cat
                              : 1 == 1)) {
                        print(snap.data.documents[i]['price']);
                        print(money);
                        dishes.add(Dish(
                            boughtTogetherDiscount: snap.data.documents[i]
                                ['boughtTogetherDiscount'],
                            id: snap.data.documents[i]['productId'],
                            name: snap.data.documents[i]['name'],
                            category: snap.data.documents[i]['category'],
                            rating: snap.data.documents[i]['rating'],
                            price: snap.data.documents[i]['price'],
                            desc: snap.data.documents[i]['description'],
                            url: snap.data.documents[i]['url'],
                            quantities: quantities,
                            allquantities: allquantities,
                            boughtTogetherID: snap.data.documents[i]
                                ['boughtTogether'],
                        stock: snap.data.documents[i]['stock']));
                      }
                      print(dishes);

                      // trending.add(Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     // height: 100,100
                      //     width: 100,
                      //     // color: Colors.black,
                      //     child:
                      //         Text(snap.data.documents[i]['url'].toString()),
                      //   ),
                      // ));

                      // trending.add(Container(
                      //   margin: EdgeInsets.only(right: 4.0),
                      //   child: FoodyBiteCard(
                      //     // onTap: () async {
                      //     //   Dish boughtTogether;
                      //     //   for (int ind = 0; ind < dishes.length; ind++) {
                      //     //     if (dishes[ind].id ==
                      //     //         dishes[i].boughtTogetherID) {
                      //     //       boughtTogether = await dishes[ind];
                      //     //     }
                      //     //   }
                      //     //
                      //     //   pushNewScreen(
                      //     //     context,
                      //     //     screen: RestaurantDetailsScreen(
                      //     //       RestaurantDetails(
                      //     //           boughtTogetherDiscount:
                      //     //               dishes[i].boughtTogetherDiscount,
                      //     //           url: dishes[i].url,
                      //     //           name: dishes[i].name,
                      //     //           desc: dishes[i].desc,
                      //     //           category: dishes[i].category,
                      //     //           rating: dishes[i].rating,
                      //     //           price: dishes[i].price,
                      //     //           boughtTogether: boughtTogether,
                      //     //           allquantities: dishes[i].allquantities,
                      //     //           quantities: dishes[i].quantities,
                      //     //           boughtTogetherQuantity:
                      //     //               dishes[i].boughtTogetherQuantity),
                      //     //     ),
                      //     //     withNavBar:
                      //     //         true, // OPTIONAL VALUE. True by default.
                      //     //     pageTransitionAnimation:
                      //     //         PageTransitionAnimation.cupertino,
                      //     //   );
                      //     // },
                      //     imagePath: snap.data.documents[i]['url'],
                      //     cardTitle: snap.data.documents[i]['name'],
                      //     rating: snap.data.documents[i]['rating'],
                      //     category: snap.data.documents[i]['category'],
                      //     price: snap.data.documents[i]['price'],
                      //     iPrice: snap.data.documents[i]['iPrice'],
                      //     address: snap.data.documents[i]['description'],
                      //     // allquantities: dishes[i].allquantities,
                      //     // quantities: dishes[i].quantities,
                      //   ),
                      // ));
                    }
                  }
                  return dishes.length != 0
                      ? ListView.separated(
                          itemCount: dishes.length,
                          separatorBuilder: (context, index) {
                            return SpaceH8();
                          },
                          itemBuilder: (context, index) {
                            print(
                                '============${dishes[index].boughtTogetherID}');
                            return Container(
                              // color: Colors.black,
                              margin: EdgeInsets.only(right: 4.0),
                              child: FoodyBiteCard(
                                  onTap: () async {
                                    Dish boughtTogether;
                                    if (dishes[index].boughtTogetherID !=
                                        null) {
                                      for (int i = 0; i < dishes.length; i++) {
                                        if (dishes[i].id ==
                                            dishes[index].boughtTogetherID) {
                                          boughtTogether = await dishes[i];
                                        }
                                      }
                                    }
                                    pushNewScreen(
                                      context,
                                      screen: RestaurantDetailsScreen(
                                        RestaurantDetails(
                                            url: dishes[index].url,
                                            name: dishes[index].name,
                                            desc: dishes[index].desc,
                                            productID: dishes[index].id,
                                            category: dishes[index].category,
                                            rating: dishes[index].rating,
                                            price: dishes[index].price,
                                            boughtTogetherDiscount:
                                                dishes[index]
                                                    .boughtTogetherDiscount,
                                            boughtTogether: boughtTogether,
                                            allquantities:
                                                dishes[index].allquantities,
                                            quantities:
                                                dishes[index].quantities,
                                        stock: dishes[index].stock),
                                      ),
                                      withNavBar:
                                          true, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  imagePath: dishes[index].url,
//                            status: status[index],
                                  cardTitle: dishes[index].name,
                                  rating: dishes[index].rating,
                                  price: dishes[index].price,
                                  iPrice: dishes[index].iPrice,
                                  category: dishes[index].category,
                                  // orderCount: orderCount,
//                            distance: distance[index],
                                  address: dishes[index].desc,
                                  allquantities: dishes[index].allquantities,
                                  quantities: dishes[index].quantities,
                              stock:dishes[index].stock),
                            );
                          },
                        )
                      : Container(
                          child: Center(child: Text('No items to show')));
                }),
          )),
    );
  }
}
//ListView.separated(
//scrollDirection: Axis.vertical,
//itemCount: 4,
//separatorBuilder: (context, index) {
//return SpaceH8();
//},
//itemBuilder: (context, index) {
//return Container(
//child: FoodyBiteCard(
//onTap: () => R.Router.navigator.pushNamed(
//R.Router.restaurantDetailsScreen,
//arguments: RestaurantDetails(
//url: 'snap.data.documents[i][',
//name: 'Hamburger',
//desc: 'Description',
//category: 'Category',
//rating: 'Rating',
//price: 'Price',
//),
//),
//imagePath: imagePaths[index],
//status: '20% OFF',
//cardTitle: 'Hamburger',
//rating: ratings[index],
//category: category[index],
//distance: '',
//address: 'Made with exotic ingredients',
//),
//);
//},
//),

class TrendingRestaurantsScreen1 extends StatefulWidget {
  String type;
  TrendingRestaurantsScreen1(this.type);
  @override
  _TrendingRestaurantsScreen1State createState() =>
      _TrendingRestaurantsScreen1State();
}

class _TrendingRestaurantsScreen1State
    extends State<TrendingRestaurantsScreen1> {
  List<Widget> trending = new List();

  List<Dish> dishes = new List<Dish>();
  @override
  void initState() {
    super.initState();
    print(cat);
    print(rat);
    print(money);
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
          floatingActionButton: CustomFloatingButton(CurrentScreen(
              tab_no: 6,
              currentScreen: TrendingRestaurantsScreen1(widget.type))),
          appBar: AppBar(
            elevation: 0.0,
            leading: InkWell(
              onTap: () => R.Router.navigator.pushNamed(R.Router.rootScreen),
              child: Image.asset(
                ImagePath.arrowBackIcon,
                color: AppColors.headingText,
              ),
            ),
            centerTitle: true,
            title: Text(
              'All Dishes',
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
//                FoodyBiteSearchInputField(
//                  ImagePath.searchIcon,
//                  textFormFieldStyle:
//                      Styles.customNormalTextStyle(color: AppColors.accentText),
//                  hintText: StringConst.HINT_TEXT_TRENDING_SEARCH_BAR,
//                  hintTextStyle:
//                      Styles.customNormalTextStyle(color: AppColors.accentText),
//                  suffixIconImagePath: ImagePath.settingsIcon,
//                  borderWidth: 0.0,
//                  borderStyle: BorderStyle.solid,
//                ),
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
                            for (int i = 0;
                                i < snap.data.documents.length;
                                i++) {
                              List<Quantity> allquantities = [];
                              List<String> quantities = [];

                              allquantities.clear();
                              quantities.clear();

                              for (int j = 0;
                                  j < snap.data.documents[i]['Quantity'].length;
                                  j++) {
                                Quantity qu = Quantity(
                                    snap.data.documents[i]['Quantity'][j]
                                        ['iPrice'],
                                    snap.data.documents[i]['Quantity'][j]
                                        ['price'],
                                    snap.data.documents[i]['Quantity'][j]
                                        ['productId'],
                                    '${snap.data.documents[i]['Quantity'][j]['quantity']}');

                                allquantities.add(qu);
                                quantities.add(
                                    '${snap.data.documents[i]['Quantity'][j]['quantity']}');
                              }
//              print(snap.data.documents[i]['url']);
                              dishes.add(Dish(
                                  boughtTogetherDiscount: snap.data.documents[i]
                                      ['boughtTogetherDiscount'],
                                  id: snap.data.documents[i]['productId'],
                                  name: snap.data.documents[i]['name'],
                                  category: snap.data.documents[i]['category'],
                                  rating: snap.data.documents[i]['rating'],
                                  price: snap.data.documents[i]['price'],
                                  desc: snap.data.documents[i]['description'],
                                  url: snap.data.documents[i]['url'],
                                  boughtTogetherID: snap.data.documents[i]
                                      ['boughtTogether'],
                                  allquantities: allquantities,
                                  quantities: quantities));
                              print(
                                snap.data.documents[i]['name'],
                              );
                              if (snap.data.documents[i][widget.type])
                                trending.add(Container(
                                  margin: EdgeInsets.only(right: 4.0),
                                  child: FoodyBiteCard(
                                    onTap: () async {
                                      Dish boughtTogether;
                                      for (int ind = 0;
                                          ind < dishes.length;
                                          ind++) {
                                        if (dishes[ind].id ==
                                            dishes[i].boughtTogetherID) {
                                          boughtTogether = await dishes[ind];
                                        }
                                      }
                                      pushNewScreen(
                                        context,
                                        screen: RestaurantDetailsScreen(
                                          RestaurantDetails(
                                            boughtTogetherDiscount: dishes[i]
                                                .boughtTogetherDiscount,
                                            url: dishes[i].url,
                                            productID: dishes[i].id,
                                            name: dishes[i].name,
                                            desc: dishes[i].desc,
                                            category: dishes[i].category,
                                            rating: dishes[i].rating,
                                            price: dishes[i].price,
                                            boughtTogether: boughtTogether,
                                            allquantities:
                                                dishes[i].allquantities,
                                            quantities: dishes[i].quantities,
                                            boughtTogetherQuantity: dishes[i]
                                                .boughtTogetherQuantity,
                                          ),
                                        ),
                                        withNavBar:
                                            true, // OPTIONAL VALUE. True by default.
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                      );
                                    },
                                    imagePath: snap.data.documents[i]['url'],
                                    cardTitle: snap.data.documents[i]['name'],
                                    rating: snap.data.documents[i]['rating'],
                                    category: snap.data.documents[i]
                                        ['category'],
                                    price: snap.data.documents[i]['price'],
                                    iPrice: snap.data.documents[i]['iPrice'],
                                    address: snap.data.documents[i]
                                        ['description'],
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
          )),
    );
  }
}
//ListView.separated(
//scrollDirection: Axis.vertical,
//itemCount: 4,
//separatorBuilder: (context, index) {
//return SpaceH8();
//},
//itemBuilder: (context, index) {
//return Container(
//child: FoodyBiteCard(
//onTap: () => R.Router.navigator.pushNamed(
//R.Router.restaurantDetailsScreen,
//arguments: RestaurantDetails(
//url: 'snap.data.documents[i][',
//name: 'Hamburger',
//desc: 'Description',
//category: 'Category',
//rating: 'Rating',
//price: 'Price',
//),
//),
//imagePath: imagePaths[index],
//status: '20% OFF',
//cardTitle: 'Hamburger',
//rating: ratings[index],
//category: category[index],
//distance: '',
//address: 'Made with exotic ingredients',
//),
//);
//},
//),
