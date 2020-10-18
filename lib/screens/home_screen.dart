import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/offer.dart';
import 'package:angadi/widgets/offer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'checkout.dart';

var cat, money, rat;

class HomeScreen extends StatefulWidget {
  static const int TAB_NO = 0;

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();

  List<Widget> trending = new List();
  List<Widget> categories = new List();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  List<Dish> dishes = new List<Dish>();
  List<Offer> offers = new List<Offer>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: StreamBuilder(
          stream: Firestore.instance.collection('Dishes').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            if (snap.hasData && !snap.hasError && snap.data != null) {
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
                if (i < 5)
                  trending.add(Container(
                    margin: EdgeInsets.only(right: 4.0),
                    child: FoodyBiteCard(
                      onTap: () => R.Router.navigator
                          .pushNamed(R.Router.restaurantDetailsScreen,
                              arguments: RestaurantDetails(
                                url: snap.data.documents[i]['url'],
                                name: snap.data.documents[i]['name'],
                                desc: snap.data.documents[i]['description'],
                                category: snap.data.documents[i]['category'],
                                rating: snap.data.documents[i]['rating'],
                                price: snap.data.documents[i]['price'],
                              )),
                      imagePath: snap.data.documents[i]['url'],
                      cardTitle: snap.data.documents[i]['name'],
                      rating: snap.data.documents[i]['rating'],
                      category: snap.data.documents[i]['category'],
                      address: snap.data.documents[i]['description'],
                    ),
                  ));
              }

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Sizes.MARGIN_16,
                  vertical: Sizes.MARGIN_8,
                ),
                child: ListView(
                  children: <Widget>[
                    FoodyBiteSearchInputField(
                      ImagePath.searchIcon,
                      controller: controller,
                      textFormFieldStyle: Styles.customNormalTextStyle(
                          color: AppColors.accentText),
                      hintText: StringConst.HINT_TEXT_HOME_SEARCH_BAR,
                      hintTextStyle: Styles.customNormalTextStyle(
                          color: AppColors.accentText),
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
                    StreamBuilder(
                        stream:
                            Firestore.instance.collection('Offers').snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snap) {
                          if (snap.hasData &&
                              !snap.hasError &&
                              snap.data != null) {
                            offers.clear();
                            for (int i = 0;
                                i < snap.data.documents.length;
                                i++) {
                              offers.add(Offer(
                                  snap.data.documents[i]['Title'],
                                  snap.data.documents[i]['Subtitle'],
                                  snap.data.documents[i]['ImageURL'],
                                  snap.data.documents[i]
                                      ['discountPercentage']));
                            }

                            return Container(
                              height: 280,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: offers.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(right: 4.0),
                                      child: OfferCard(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return Checkout();
                                          }));
                                        },
                                        imagePath: offers[index].imageURL,
                                        // status: '90% OFF',
                                        cardTitle: offers[index].title,
                                        // rating: ratings[index],
                                        // category: category[index],
                                        // distance: '',
                                        details: offers[index].subtitle,
                                      ),
                                    );
                                  }),
                            );
                          } else {
                            return Container();
                          }
                        }),
                    SizedBox(height: 16.0),
                    HeadingRow(
                      title: StringConst.CATEGORY,
                      number: '',
                      onTapOfNumber: () => R.Router.navigator
                          .pushNamed(R.Router.categoriesScreen),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: 100,
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('Categories')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snap) {
                          if (snap.hasData &&
                              !snap.hasError &&
                              snap.data != null) {
                            categories.clear();

                            for (int i = 0;
                                i < snap.data.documents.length;
                                i++) {
                              categories.add(Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: FoodyBiteCategoryCard(
                                  imagePath: snap.data.documents[i]['imageURL'],
                                  gradient: gradients[i],
                                  category: snap.data.documents[i]['catName'],
                                  onTap: () {
                                    print(
                                        '---------==========${snap.data.documents[i]['imageURL']}');
                                    R.Router.navigator.pushNamed(
                                      R.Router.categoryDetailScreen,
                                      arguments: CategoryDetailScreenArguments(
                                        categoryName: snap.data.documents[i]
                                            ['catName'],
                                        imagePath: snap.data.documents[i]
                                            ['imageURL'],
                                        selectedCategory: i,
                                        numberOfCategories:
                                            snap.data.documents.length,
                                        gradient: gradients[i],
                                      ),
                                    );
                                  },
                                ),
                              ));
                            }
                            return categories.length != 0
                                ? ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: categories,
                                  )
                                : Container();
                          } else
                            return Container(
                                child: Center(
                                    child: Text(
                              "No Data",
                              style: TextStyle(color: Colors.black),
                            )));
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
                      number: '',
                      onTapOfNumber: () => R.Router.navigator
                          .pushNamed(R.Router.trendingRestaurantsScreen),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: trending.length != 0
                          ? ListView(
                              children: trending,
                            )
                          : Container(),
                    )
                  ],
                ),
              );
            } else
              return Container(
                  child: Center(
                      child: Text(
                "No Data",
                style: TextStyle(color: Colors.black),
              )));
          },
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
