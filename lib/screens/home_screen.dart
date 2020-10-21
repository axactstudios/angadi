import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/offer.dart';
import 'package:angadi/screens/settings_screen.dart';
import 'package:angadi/screens/trending_restaurant_screen.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/nav_drawer.dart';
import 'package:angadi/widgets/offer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
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
  List<String> imageList = List();
  List<Widget> trending = new List();
  List<Widget> special = new List();
  List<Widget> top = new List();
  List<Widget> categories = new List();
  List<Widget> categoriesTop = new List();
  var location = 'Dubai';
  var delivery = '6 Hrs';
  @override
  void initState() {
    getBanners();
    _getCurrentLocation();

    super.initState();
  }

  List<Dish> dishes = new List<Dish>();
  List<Dish> dishesTop = new List<Dish>();
  List<Dish> dishesSpecial = new List<Dish>();
  List<Offer> offers = new List<Offer>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () {
                launch('tel:+919027553376');
              },
              child: Icon(Icons.phone)),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                print(1);
                launch(
                    'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
              },
              child: Icon(Icons.person)),
          SizedBox(
            width: 14,
          )
        ],
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Angadi.ae',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
      drawer: CustomDrawer(),
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
              top.clear();
              special.clear();
              dishesSpecial.clear();
              dishesTop.clear();
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
                if (snap.data.documents[i]['special']) {
                  dishesSpecial.add(Dish(
                      name: snap.data.documents[i]['name'],
                      category: snap.data.documents[i]['category'],
                      rating: snap.data.documents[i]['rating'],
                      price: snap.data.documents[i]['price'],
                      desc: snap.data.documents[i]['description'],
                      url: snap.data.documents[i]['url']));
                  print(snap.data.documents[i]['name']);
                  special.add(Container(
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
                      price: snap.data.documents[i]['price'].toString(),
                      iPrice: snap.data.documents[i]['iPrice'].toString(),
                    ),
                  ));
                }
                if (snap.data.documents[i]['top']) {
                  dishesTop.add(Dish(
                      name: snap.data.documents[i]['name'],
                      category: snap.data.documents[i]['category'],
                      rating: snap.data.documents[i]['rating'],
                      price: snap.data.documents[i]['price'],
                      desc: snap.data.documents[i]['description'],
                      url: snap.data.documents[i]['url']));
                  print(snap.data.documents[i]['name']);
                  top.add(Container(
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
                      price: snap.data.documents[i]['price'].toString(),
                      iPrice: snap.data.documents[i]['iPrice'].toString(),
                    ),
                  ));
                }
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
                      price: snap.data.documents[i]['price'].toString(),
                      iPrice: snap.data.documents[i]['iPrice'].toString(),
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
                    Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Deliver to $location'),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: () {
                              _locationDialog(context);
                            },
                            child: Icon(Icons.edit))
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.local_dining),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Estimated Delivery by $delivery'),
                        SizedBox(
                          width: 10,
                        ),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                      ],
                    ),

//                    HeadingRow(
//                      title: StringConst.OFFERS,
//                      number: '',
//                      onTapOfNumber: () => R.Router.navigator
//                          .pushNamed(R.Router.trendingRestaurantsScreen),
//                    ),

                    StreamBuilder(
                        stream:
                            Firestore.instance.collection('Offers').snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snap) {
                          if (snap.hasData &&
                              !snap.hasError &&
                              snap.data != null) {
                            offers.clear();
                            imageList.clear();
                            for (int i = 0;
                                i < snap.data.documents.length;
                                i++) {
                              imageList.add(snap.data.documents[i]['ImageURL']);
                              offers.add(Offer(
                                  snap.data.documents[i]['Title'],
                                  snap.data.documents[i]['Subtitle'],
                                  snap.data.documents[i]['ImageURL'],
                                  snap.data.documents[i]
                                      ['discountPercentage']));
                            }

                            return Container(
                              height: 220,
                              width: MediaQuery.of(context).size.width,
                              child: GFCarousel(
                                items: imageList.map(
                                  (url) {
                                    return Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Image.network('$url',
                                            fit: BoxFit.fitWidth,
                                            width: 10000.0),
                                      ),
                                    );
                                  },
                                ).toList(),
                                onPageChanged: (index) {
                                  setState(() {
                                    print('change');
                                  });
                                },
                                autoPlay: true,
                                enlargeMainPage: true,
                                pagination: true,
                                passiveIndicator: Colors.black,
                                activeIndicator: Colors.grey,
                                pauseAutoPlayOnTouch: Duration(seconds: 8),
                                pagerSize: 8,
                              ),
//                              ListView.builder(
//                                  scrollDirection: Axis.horizontal,
//                                  itemCount: offers.length,
//                                  itemBuilder: (context, index) {
//                                    return Container(
//                                      margin: EdgeInsets.only(right: 4.0),
//                                      child: OfferCard(
//                                        onTap: () {
//                                          Navigator.push(context,
//                                              MaterialPageRoute(builder:
//                                                  (BuildContext context) {
//                                            return Checkout();
//                                          }));
//                                        },
//                                        imagePath: offers[index].imageURL,
//                                        // status: '90% OFF',
//                                        cardTitle: offers[index].title,
//                                        // rating: ratings[index],
//                                        // category: category[index],
//                                        // distance: '',
//                                        details: offers[index].subtitle,
//                                      ),
//                                    );
//                                  }),
                            );
                          } else {
                            return Container();
                          }
                        }),
                    SizedBox(height: 16.0),
                    HeadingRow(
                      title: StringConst.CATEGORY,
                      number: 'All Categories ',
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
                    SizedBox(height: 16.0),
                    HeadingRow(
                      title: 'Top Categories',
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
                            categoriesTop.clear();

                            for (int i = 0;
                                i < snap.data.documents.length;
                                i++) {
                              if (snap.data.documents[i]['top']) {
                                categoriesTop.add(Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: FoodyBiteCategoryCard(
                                    imagePath: snap.data.documents[i]
                                        ['imageURL'],
                                    gradient: gradients[i],
                                    category: snap.data.documents[i]['catName'],
                                    onTap: () {
                                      print(
                                          '---------==========${snap.data.documents[i]['imageURL']}');
                                      R.Router.navigator.pushNamed(
                                        R.Router.categoryDetailScreen,
                                        arguments:
                                            CategoryDetailScreenArguments(
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
                            }
                            return categoriesTop.length != 0
                                ? ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: categoriesTop,
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

                    SizedBox(height: 16.0),
                    Container(
                      height: 110,
                      child: Image.network(
                        banner1Url,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    HeadingRow(
                      title: 'Top Deals',
                      number: 'View All',
                      onTapOfNumber: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return TrendingRestaurantsScreen1("top");
                        }));
                      },
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: 300,
                      child: top.length != 0
                          ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: top,
                            )
                          : Container(),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: 110,
                      child: Image.network(
                        banner2Url,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    HeadingRow(
                        title: 'Special on Angadi',
                        number: 'View All',
                        onTapOfNumber: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return TrendingRestaurantsScreen1("special");
                          }));
                        }),
                    SizedBox(height: 16.0),
                    Container(
                      height: 300,
                      child: special.length != 0
                          ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: special,
                            )
                          : Container(),
                    ),
                    SizedBox(height: 20.0),
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

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  LocationData _currentPosition;

  Location loc = new Location();
  String currentAddress = 'Enter Address';
  Future<Position> _getCurrentLocation() async {
    _currentPosition = await loc.getLocation();
//    Position position = await geolocator.getCurrentPosition(
//        desiredAccuracy: LocationAccuracy.high);
//    print(position);
//    geolocator
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//        .then((Position position) {
//      setState(() {
//        _currentPosition = position;
//      });
    print(_currentPosition);
    _getAddressFromLatLng();
    print(_currentPosition);
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        currentAddress = "${place.subLocality}, ${place.locality}";
        print(currentAddress);
        location = currentAddress;
        pass.text = currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  final pass = TextEditingController();
  Future<void> _locationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildAlertDialog(context);
      },
    );
  }

  Widget _buildAlertDialog(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var hintTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(Sizes.RADIUS_32),
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(
          Sizes.PADDING_0,
          Sizes.PADDING_36,
          Sizes.PADDING_0,
          Sizes.PADDING_0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
        ),
        elevation: Sizes.ELEVATION_4,
        content: Container(
          height: Sizes.HEIGHT_160,
          width: Sizes.WIDTH_300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: Text(
                    'Change location',
                    style: textTheme.title.copyWith(
                      fontSize: Sizes.TEXT_SIZE_20,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomTextFormField(
                  controller: pass,
                  textFormFieldStyle: textFormFieldTextStyle,
                  hintText: "New Location",
                  hintTextStyle: hintTextStyle,
                  borderStyle: BorderStyle.solid,
                  borderWidth: Sizes.WIDTH_1,
                ),
              ),
              Spacer(flex: 1),
              Row(
                children: <Widget>[
                  AlertDialogButton(
                    buttonText: "Cancel",
                    width: Sizes.WIDTH_150,
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: AppColors.greyShade1,
                      ),
                      right: BorderSide(
                        width: 1,
                        color: AppColors.greyShade1,
                      ),
                    ),
                    textStyle:
                        textTheme.button.copyWith(color: AppColors.accentText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  AlertDialogButton(
                      buttonText: "Change",
                      width: Sizes.WIDTH_150,
                      border: Border(
                        top: BorderSide(
                          width: 1,
                          color: AppColors.greyShade1,
                        ),
                      ),
                      textStyle: textTheme.button
                          .copyWith(color: AppColors.secondaryElement),
                      onPressed: () {
                        setState(() {
                          location = pass.text;
                        });
                        Navigator.of(context).pop(true);
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String banner1Url = 'acv', banner2Url = 'acv';
  getBanners() {
    Firestore.instance
        .collection('Backgrounds')
        .document('Banner1')
        .get()
        .then((value) {
      setState(() {
        banner1Url = value['url'];
      });
    });
    Firestore.instance
        .collection('Backgrounds')
        .document('Banner2')
        .get()
        .then((value) {
      setState(() {
        banner2Url = value['url'];
      });
    });
  }

  addFields() {
    Firestore.instance.collection('Dishes').getDocuments().then((value) {
      value.documents.forEach((element) {
        Firestore.instance
            .collection('Dishes')
            .document(element.documentID)
            .updateData({
          'special': false,
        });
      });
    });
  }
}
//url: snap.data.documents[i]['url'],
//name: snap.data.documents[i]['name'],
//desc: snap.data.documents[i]['description'],
//category: snap.data.documents[i]['category'],
//rating: snap.data.documents[i]['rating'],
//price: snap.data.documents[i]['price'],
