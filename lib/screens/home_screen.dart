import 'dart:io';

import 'package:angadi/classes/cart.dart';
import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/offer.dart';
import 'package:angadi/classes/quantity.dart';
import 'package:angadi/screens/filtered_search.dart';
import 'package:angadi/screens/settings_screen.dart';
import 'package:angadi/screens/trending_restaurant_screen.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/nav_drawer.dart';
import 'package:angadi/widgets/offer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
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
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/router.gr.dart';
import '../values/values.dart';
import '../values/values.dart';
import 'categories_screen.dart';
import 'category_detail_screen.dart';
import 'checkout.dart';
import 'filter_screen.dart';
import 'order_placed.dart';
import 'restaurant_details_screen.dart';

var cat, money, rat;
bool showStatus = true;

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
  List<Widget> categoriesGrocery = new List();
  List<Widget> categoriesTop = new List();
  List<Cart> cartItems = [];
  var location = 'Dubai';
  var deliveryDate = '23 October';
  var deliveryTime = '6 pm';
  DateTime date;
  DateTime selectedDate;
  String selectedTime = '9 AM';
  FirebaseUser user;
  List<String> quantities = [];
  getUser() async {
    user = await FirebaseAuth.instance.currentUser();
  }

  final dbHelper = DatabaseHelper.instance;
  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?   phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  var showGrocery;
  void Checkgrocery() {
    Firestore.instance
        .collection('AppSettings')
        .getDocuments()
        .then((val) => val.documents.forEach((element) {
              print(element['showGrocery']);
              showGrocery = element['showGrocery'];
            }));
  }

  var id = '';
  void address() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var email = user.email;
    Firestore.instance
        .collection('Users')
        .where('mail', isEqualTo: email)
        .snapshots()
        .listen((event) {
      setState(() {
        id = event.documents[0].documentID;
      });
      print(event.documents[0].documentID);
    });
  }

  void removeAll() async {
    List items = [];
    List prices = [];
    List quantities = [];
    for (var v in cartItems) {
      print(v.productName);
      items.add(v.productName);
      prices.add(v.price);
      quantities.add(v.qty);
    }
    // Assuming that the number of rows is the id for the last row.
    for (var v in cartItems) {
      final rowsDeleted = await dbHelper.delete(v.productName, v.qtyTag);
    }
  }

  @override
  void initState() {
//    addDishParams();
    getUser();
    getBanners();
    Checkgrocery();
    getSharedPrefs();
    address();
    date = DateTime.now();
    _getCurrentLocation();
    super.initState();
  }

  int orderCount;
  getSharedPrefs() async {
    await Firestore.instance
        .collection('Ordercount')
        .document('ordercount')
        .snapshots()
        .listen((event) {
      print(event['Numberoforders'].toString());

      orderCount = event['Numberoforders'];
    });
    print('Checked');
    prefs = await SharedPreferences.getInstance();
    orderStatus = prefs.getString('Status');
    idorder = prefs.getString('Orderid');
  }

  SliverGridDelegate gd;

  List<Dish> dishes = new List<Dish>();
  List<Dish> dishesTop = new List<Dish>();
  List<Dish> dishesSpecial = new List<Dish>();
  List<Offer> offers = new List<Offer>();
  SharedPreferences prefs;

  var orderStatus, idorder;
  @override
  Widget build(BuildContext context) {
//    print(MediaQuery.of(context).size.width);

    _pickTime() async {
      var today = DateTime.now();
      DateTime t = await showDatePicker(
        context: context,
        initialDate: DateTime(today.year, today.month, today.day + 1),
        lastDate: DateTime(today.year, today.month, today.day + 6),
        firstDate: DateTime(today.year, DateTime.now().month, today.day + 1),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark(),
            child: child,
          );
        },
      );
      if (t != null)
        setState(() {
          date = t;
        });
      return date;
    }

    id() async {
      if (orderStatus != null) {
        if (orderStatus == 'Placed') {
          print('Function run');
          Firestore.instance
              .collection('Orders')
              .snapshots()
              .forEach((element) {
            element.documents.forEach((element) {
              if (idorder == element.documentID) {
                removeAll();
                prefs.setString('Status', 'Not Placed');
              }
            });
          });
        }
      }
    }

    id();

    return Scaffold(
      floatingActionButton: CustomFloatingButton(CurrentScreen(
          currentScreen: HomeScreen(), tab_no: HomeScreen.TAB_NO)),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppColors.secondaryElement,
        actions: [
          InkWell(
              onTap: () {
                launch('tel:+919027553376');
              },
              child: Icon(Icons.phone, color: Color(0xFF6b3600))),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                launchWhatsApp(
                    phone: '7060222315', message: 'Check out this awesome app');
              },
              child: Container(
                  alignment: Alignment.center,
                  child: FaIcon(FontAwesomeIcons.whatsapp,
                      color: Color(0xFF6b3600)))),
          SizedBox(width: 8),
          InkWell(
              onTap: () {
//                print(1);
                launch(
                    'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
              },
              child: Icon(Icons.mail, color: Color(0xFF6b3600))),
          SizedBox(
            width: 10,
          )
        ],
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Angadi.ae',
          style: Styles.customTitleTextStyle(
            color: Color(0xFF6b3600),
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
//                print('&&&&&&&&&&&&&&&&&&&&&&');Chalake dekh map hai aesa nai aayega
//               print(quantities.length);
                // print('Imp ${snap.data.documents[i]['boughtTogether']}');
                dishes.add(Dish(
                    name: snap.data.documents[i]['name'],
                    boughtTogetherDiscount: snap.data.documents[i]
                        ['boughtTogetherDiscount'],
                    boughtTogetherQuantity: snap.data.documents[i]
                        ['boughtTogetherQuantity'],
                    id: snap.data.documents[i].documentID,
                    category: snap.data.documents[i]['category'],
                    rating: snap.data.documents[i]['rating'].toString(),
                    price: snap.data.documents[i]['price'],
                    desc: snap.data.documents[i]['description'],
                    url: snap.data.documents[i]['url'],
                    boughtTogetherID: snap.data.documents[i]['boughtTogether'],
                    allquantities: allquantities,
                    quantities: quantities));

                if (snap.data.documents[i]['special']) {
                  dishesSpecial.add(Dish(
                      boughtTogetherDiscount: snap.data.documents[i]
                          ['boughtTogetherDiscount'],
                      boughtTogetherQuantity: snap.data.documents[i]
                          ['boughtTogetherQuantity'],
                      id: snap.data.documents[i].documentID,
                      name: snap.data.documents[i]['name'],
                      category: snap.data.documents[i][
                          'category'], //Still same SS bhej whatsapp pe mere Ek kaam kr....code push krde...main ispe dekhta tu hamro dekhle ok bupppppppppppppppp done bossppppppppp bhupppppppp
                      rating: snap.data.documents[i]['rating'].toString(),
                      price: snap.data.documents[i]['price'],
                      desc: snap.data.documents[i]['description'],
                      url: snap.data.documents[i]['url'],
                      boughtTogetherID: snap.data.documents[i]
                          ['boughtTogether'],
                      allquantities: snap.data.documents[i]['Quantity'],
                      quantities: dishes[i].quantities));
//                  print('Checkinggggg${dishes[i].quantities}');
//                  print(snap.data.documents[i]['name']);
                  special.add(Container(
                    margin: EdgeInsets.only(right: 4.0),
                    child: FoodyBiteCard(
                      onTap: () async {
                        Dish boughtTogether;
                        for (int ind = 0; ind < dishes.length; ind++) {
                          if (dishes[ind].id == dishes[i].boughtTogetherID) {
                            boughtTogether = await dishes[ind];
                          }
                        }
                        pushNewScreen(
                          context,
                          screen: RestaurantDetailsScreen(
                            RestaurantDetails(
                                boughtTogetherDiscount:
                                    dishes[i].boughtTogetherDiscount,
                                boughtTogetherQuantity:
                                    dishes[i].boughtTogetherQuantity,
                                url: dishes[i].url,
                                name: dishes[i].name,
                                desc: dishes[i].desc,
                                category: dishes[i].category,
                                rating: dishes[i].rating,
                                price: dishes[i].price,
                                boughtTogether: boughtTogether,
                                allquantities: dishes[i].allquantities,
                                quantities: dishes[i].quantities),
                          ),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      imagePath: snap.data.documents[i]['url'],
                      cardTitle: snap.data.documents[i]['name'],
                      rating: snap.data.documents[i]['rating'].toString(),
                      category: snap.data.documents[i]['category'],
                      price: snap.data.documents[i]['price'].toString(),
                      iPrice: snap.data.documents[i]['iPrice'].toString(),
                      orderCount: orderCount,
                      allquantities: dishes[i].allquantities,
                      quantities: dishes[i].quantities,
                    ),
                  ));
//                  print('++++++++++++++');
//                  print(quantities);
//                  print(dishes[i].quantities);
                }
                if (snap.data.documents[i]['top']) {
                  dishesTop.add(Dish(
                      boughtTogetherDiscount: snap.data.documents[i]
                          ['boughtTogetherDiscount'],
                      boughtTogetherQuantity: snap.data.documents[i]
                          ['boughtTogetherQuantity'],
                      id: snap.data.documents[i].documentID,
                      name: snap.data.documents[i]['name'],
                      category: snap.data.documents[i]['category'],
                      rating: snap.data.documents[i]['rating'].toString(),
                      price: snap.data.documents[i]['price'],
                      desc: snap.data.documents[i]['description'],
                      url: snap.data.documents[i]['url'],
                      boughtTogetherID: snap.data.documents[i]
                          ['boughtTogether'],
                      allquantities: dishes[i].allquantities,
                      quantities: dishes[i].quantities));
//                  print(snap.data.documents[i]['name']);
                  top.add(Container(
                    margin: EdgeInsets.only(right: 4.0),
                    child: FoodyBiteCard(
                      onTap: () async {
                        Dish boughtTogether;
                        await print(dishes.length);
                        for (int ind = 0; ind < dishes.length; ind++) {
                          print('Checking $ind');
                          print(dishes[ind].id);
                          print(dishes[i].boughtTogetherID);
                          if (dishes[ind].id == dishes[i].boughtTogetherID) {
                            boughtTogether = await dishes[ind];
                            print('Got it');
                          }
                        }
                        await print('-------------$boughtTogether');
                        print('Checkkk${dishes[i].quantities}');
                        pushNewScreen(
                          context,
                          screen: RestaurantDetailsScreen(
                            RestaurantDetails(
                                boughtTogetherDiscount:
                                    dishes[i].boughtTogetherDiscount,
                                boughtTogetherQuantity:
                                    dishes[i].boughtTogetherQuantity,
                                url: dishes[i].url,
                                name: dishes[i].name,
                                desc: dishes[i].desc,
                                category: dishes[i].category,
                                rating: dishes[i].rating,
                                price: dishes[i].price,
                                boughtTogether: boughtTogether,
                                allquantities: dishes[i].allquantities,
                                quantities: dishes[i].quantities),
                          ),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      imagePath: snap.data.documents[i]['url'],
                      cardTitle: snap.data.documents[i]['name'],
                      rating: snap.data.documents[i]['rating'].toString(),
                      category: snap.data.documents[i]['category'],
                      price: snap.data.documents[i]['price'].toString(),
                      iPrice: snap.data.documents[i]['iPrice'].toString(),
                      orderCount: orderCount,
                      allquantities: dishes[i].allquantities,
                      quantities: dishes[i].quantities,
                    ),
                  ));
                }

                if (i < 5)
                  trending.add(Container(
                    margin: EdgeInsets.only(right: 4.0),
                    child: FoodyBiteCard(
                      orderCount: orderCount,
                      onTap: () async {
                        Dish boughtTogether;
                        for (int ind = 0; ind < dishes.length; ind++) {
                          if (dishes[ind].id == dishes[i].boughtTogetherID) {
                            boughtTogether = await dishes[ind];
                          }
                        }
                        pushNewScreen(
                          context,
                          screen: RestaurantDetailsScreen(
                            RestaurantDetails(
                                boughtTogetherDiscount:
                                    dishes[i].boughtTogetherDiscount,
                                boughtTogetherQuantity:
                                    dishes[i].boughtTogetherQuantity,
                                url: dishes[i].url,
                                name: dishes[i].name,
                                desc: dishes[i].desc,
                                category: dishes[i].category,
                                rating: dishes[i].rating,
                                price: dishes[i].price,
                                boughtTogether: boughtTogether,
                                allquantities: dishes[i].allquantities,
                                quantities: dishes[i].quantities),
                          ),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ));
              }

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: Sizes.MARGIN_8,
                ),
                child: ListView(
                  children: <Widget>[
                    user != null
                        ? StreamBuilder(
                            stream: Firestore.instance
                                .collection('Orders')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snap) {
                              var orderID, status;
                              if (snap.hasData &&
                                  !snap.hasError &&
                                  snap.data != null) {
                                for (int i = 0;
                                    i < snap.data.documents.length;
                                    i++) {
                                  if (snap.data.documents[i]['UserID'] ==
                                          user?.uid &&
                                      snap.data.documents[i]['Status'] ==
                                          'Awaiting Confirmation') {
                                    orderID = snap.data.documents[i].documentID;
                                    status = snap.data.documents[i]['Status'];
                                  }
                                }
                                fetchOrderDetail(orderID);
                              }
                              return status != null
                                  ? showStatus
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.secondaryElement,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 70,
                                              child: Row(
//                                                crossAxisAlignment:
//                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Spacer(),
                                                      Text('$status!',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('ID: $orderID',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          InkWell(
                                                            onTap: () async {
                                                              String status;
                                                              Timestamp
                                                                  deliveryDate;
                                                              await Firestore
                                                                  .instance
                                                                  .collection(
                                                                      'Orders')
                                                                  .getDocuments()
                                                                  .then(
                                                                      (value) {
                                                                value.documents
                                                                    .forEach(
                                                                        (element) {
                                                                  if (element
                                                                          .documentID ==
                                                                      orderID) {
                                                                    status =
                                                                        element[
                                                                            'Status'];
                                                                    deliveryDate =
                                                                        element[
                                                                            'DeliveryDate'];

                                                                    print(
                                                                        status);
                                                                  }
                                                                });
                                                              });
                                                              print(status);
                                                              print(orderID);
                                                              DateTime
                                                                  myDateTime =
                                                                  await deliveryDate
                                                                      .toDate();

                                                              // Timestamp
                                                              //     myTimeStamp =
                                                              //     Timestamp
                                                              //         .fromDate(
                                                              //             selectedDate);

                                                              pushNewScreen(
                                                                  context,
                                                                  screen: OrderPlaced(
                                                                      bill(),
                                                                      orderID,
                                                                      status,
                                                                      myDateTime));
                                                            },
                                                            child: Text(
                                                                'View Details',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF6b3600))),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  InkWell(
                                                    onTap: () {
                                                      showStatus = false;
                                                    },
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: Color(0xFF6b3600),
                                                      size: 30,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                ],
                                              ),
                                            ),
                                          ))
                                      : Container()
                                  : Container();
                            })
                        : Container(),
                    SizedBox(
                      height: 2,
                    ),
                    FoodyBiteSearchInputField(
                      Icons.search,
                      controller: controller,
                      textFormFieldStyle: Styles.customNormalTextStyle(
                          color: AppColors.accentText),
                      hintText: StringConst.HINT_TEXT_HOME_SEARCH_BAR,
                      hintTextStyle: Styles.customNormalTextStyle(
                          color: AppColors.accentText),
                      suffixIconImagePath: Icons.sort,
                      borderWidth: 0.0,
                      onTapOfLeadingIcon: () => Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return FilteredSearch();
                      })),
                      // onTapOfLeadingIcon: () => R.Router.navigator.pushNamed(
                      //   R.Router.searchResultsScreen,
                      //   arguments: SearchValue(
                      //     controller.text,
                      //   ),
                      // ),
                      onTapOfSuffixIcon: () => Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return FilterScreen();
                      })),
                      borderStyle: BorderStyle.solid,
                    ),
                    SizedBox(height: 1.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: AppColors.secondaryElement,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text('Deliver to $location',
                                    style: TextStyle(color: Colors.white))),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                                onTap: () {
//                                  _locationDialog(context);
                                  showPlacePicker();

//
                                },
                                child: Icon(Icons.edit, color: Colors.white)),
//                            InkWell(
//                                onTap: () {
//                                  showPlacePicker();
//
////                              _locationDialog(context);
//                                },
//                                child: Icon(Icons.map, color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.secondaryElement),
                          borderRadius: BorderRadius.all(Radius.zero)),
                      child: Row(
                        children: [
                          Text('    Next Delivery: '),
                          Icon(
                            Icons.delivery_dining,
                            color: AppColors.secondaryElement,
                          ),
                          SizedBox(width: 5),
                          InkWell(
                              onTap: () {
                                _pickTime().then((value) {
                                  setState(() {
                                    selectedDate = value;
                                  });
                                });
                              },
                              child: selectedDate != null
                                  ? Text(
                                      '${selectedDate.day.toString()}/${selectedDate.month.toString()}/20 ',
                                      style:
                                          TextStyle(color: Color(0xFF6b3600)),
                                    )
                                  : Text(
                                      '${date.day.toString()}/${date.month.toString()}/20 ',
                                      style:
                                          TextStyle(color: Color(0xFF6b3600)),
                                    )),
                          Text(' at '),
                          Icon(
                            Icons.timer,
                            size: 19,
                            color: AppColors.secondaryElement,
                          ),
                          SizedBox(width: 5),
                          InkWell(
                              onTap: () {
                                _timeDialog(context);
                              },
                              child: Text(
                                '$selectedTime ',
                                style: TextStyle(color: Color(0xFF6b3600)),
                              )),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                        ],
                      ),
                    ),

//                    HeadingRow(
//                      title: StringConst.OFFERS,
//                      number: '',
//                      onTapOfNumber: () => R.Router.navigator
//                          .pushNamed(R.Router.trendingRestaurantsScreen),
//                    ),
                    SizedBox(height: 15),
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
                              height: 170,
                              width: MediaQuery.of(context).size.width,
                              child: GFCarousel(
                                items: imageList.map(
                                  (url) {
                                    return Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: FancyShimmerImage(
                                          shimmerDuration: Duration(seconds: 2),
                                          imageUrl: '$url',
                                          width: 10000.0,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                                onPageChanged: (index) {
                                  setState(() {
//                                    print('change');
                                  });
                                },
                                viewportFraction: 1.0,
                                aspectRatio:
                                    (MediaQuery.of(context).size.width / 18) /
                                        (MediaQuery.of(context).size.width /
                                            40),
                                autoPlay: true,
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
                    SizedBox(height: 0.0),
                    HeadingRow(
                      title: StringConst.CATEGORY,
                      number: '',
                      onTapOfNumber: () => Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return CategoriesScreen('Both');
                      })),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CategoriesScreen('Food');
                            }));
                          },
                          child: Stack(
                            children: [
                              Container(
                                  height: 130,
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: FancyShimmerImage(
                                      shimmerDuration: Duration(seconds: 2),
                                      imageUrl:
                                          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FUlundu%20Vada%20Mix%2F1-4.JPG?alt=media&token=f3955753-5fd0-43a6-914c-d7a6a560834e',
                                    ),
                                  )),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  height: 25,
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                      color: AppColors.secondaryElement,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(8))),
                                  child: Text(
                                    'Food Items',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xFF6b3600),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CategoriesScreen('Food');
                            }));
                          },
                          child: Stack(
                            children: [
                              Container(
                                  height: 130,
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: FancyShimmerImage(
                                      shimmerDuration: Duration(seconds: 2),
                                      imageUrl:
                                          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FPuliyodarai%20Paste%2F1-2.JPG?alt=media&token=7cd79faf-090f-4537-99fd-74fbcb86458b',
                                    ),
                                  )),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  height: 25,
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                      color: AppColors.secondaryElement,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(8))),
                                  child: Text(
                                    'Grocery Items',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xFF6b3600),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                // right: 16.0,
                                top: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Card(
                                      // elevation: widget.ratingsAndStatusCardElevation,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
//                                  Image.asset(
//                                    ImagePath.starIcon,
//                                    height: Sizes.WIDTH_14,
//                                    width: Sizes.WIDTH_14,
//                                  ),

                                            Text(
                                              ('Coming Soon'),
                                              style:
                                                  Styles.customTitleTextStyle(
                                                color: Colors.deepOrangeAccent,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
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
                    SizedBox(height: 16.0),
                    HeadingRow(
                      title: 'Shop Food Items',
                      number: 'All Categories ',
                      onTapOfNumber: () => Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return CategoriesScreen('Food');
                      })),
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
                              if (snap.data.documents[i]['sCat'] == 'Food')
                                categories.add(InkWell(
                                  onTap: () {
//                                    print(
//                                        '---------==========${snap.data.documents[i]['imageURL']}');
                                    pushNewScreen(
                                      context,
                                      screen: CategoryDetailScreen(
                                        categoryName: snap.data.documents[i]
                                            ['catName'],
                                        imagePath: snap.data.documents[i]
                                            ['liveImageURL'],
                                        selectedCategory: i,
                                        numberOfCategories:
                                            snap.data.documents.length,
                                        gradient: gradients[i],
                                        sCat: 'Food',
                                      ),
                                      withNavBar:
                                          true, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
//
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: foodCard(
                                      snap.data.documents[i]['imageURL'],
                                      snap.data.documents[i]['catName'],
                                    ),
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
                                height: 100,
                                width: 100,
                                child:
                                    Center(child: CircularProgressIndicator()));
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
                      height: 300,
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
                                // categoriesTop.add(Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Container(
                                //     height: 200,
                                //     width: 200,
                                //     color: Colors.red,
                                //   ),
                                // ));

                                categoriesTop.add(InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return CategoryDetailScreen(
                                        categoryName: snap.data.documents[i]
                                            ['catName'],
                                        imagePath: snap.data.documents[i]
                                            ['imageURL'],
                                        selectedCategory: i,
                                        numberOfCategories:
                                            categoriesTop.length,
                                        gradient: gradients[i],
                                        sCat: snap.data.documents[i]['sCat'],
                                      );
                                    }));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                          height: 140,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              child: FancyShimmerImage(
                                                shimmerDuration:
                                                    Duration(seconds: 2),
                                                imageUrl: snap.data.documents[i]
                                                    ['liveImageURL'],
                                                boxFit: BoxFit.fill,
                                              ))),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          height: 25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          decoration: BoxDecoration(
                                              color: AppColors.secondaryElement,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  bottomLeft:
                                                      Radius.circular(8))),
                                          child: Text(
                                            snap.data.documents[i]['catName'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFF6b3600),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ));

//                                 categoriesTop.add(FoodyBiteCategoryCard(
//                                   width:
//                                       (MediaQuery.of(context).size.width - 52) /
//                                           2,
//                                   imagePath: snap.data.documents[i]
//                                       ['liveImageURL'],
//                                   gradient: gradients[i],
//                                   category: snap.data.documents[i]['catName'],
//                                   onTap: () {
// //                                    print(
// //                                        '---------==========${snap.data.documents[i]['imageURL']}');
//                                     pushNewScreen(
//                                       context,
//                                       screen: CategoryDetailScreen(
//                                         sCat: 'Food',
//                                         categoryName: snap.data.documents[i]
//                                             ['catName'],
//                                         imagePath: snap.data.documents[i]
//                                             ['liveImageURL'],
//                                         selectedCategory: i,
//                                         numberOfCategories:
//                                             snap.data.documents.length,
//                                         gradient: gradients[i],
//                                       ),
//                                       withNavBar:
//                                           true, // OPTIONAL VALUE. True by default.
//                                       pageTransitionAnimation:
//                                           PageTransitionAnimation.cupertino,
//                                     );
// //                                    R.Router.navigator.pushNamed(
// //                                      R.Router.categoryDetailScreen,
// //                                      arguments: CategoryDetailScreenArguments(
// //                                        categoryName: snap.data.documents[i]
// //                                            ['catName'],
// //                                        imagePath: snap.data.documents[i]
// //                                            ['imageURL'],
// //                                        selectedCategory: i,
// //                                        numberOfCategories:
// //                                            snap.data.documents.length,
// //                                        gradient: gradients[i],
// //                                      ),
// //                                    );
//                                   },
//                                 ));
                              }
                            }
                            return categoriesTop.length != 0
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          categoriesTop[0],
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                          ),
                                          categoriesTop[1]
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          categoriesTop[2],
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                          ),
                                          categoriesTop[3]
                                        ],
                                      )
                                    ],
                                  )
                                : Container();
                          } else
                            return Container(
                                child: Center(
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()))));
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    (showGrocery == true)
                        ? HeadingRow(
                            title: 'Shop Grocery Items',
                            number: 'All Categories ',
                            onTapOfNumber: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                              return CategoriesScreen('Grocery');
                            })),
                          )
                        : Container(),
                    SizedBox(height: 16.0),
                    (showGrocery == true)
                        ? Container(
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
                                  categoriesGrocery.clear();

                                  for (int i = 0;
                                      i < snap.data.documents.length;
                                      i++) {
                                    if (snap.data.documents[i]['sCat'] ==
                                        'Grocery')
                                      categoriesGrocery.add(InkWell(
                                        onTap: () {
//                                    print(
//                                        '---------==========${snap.data.documents[i]['imageURL']}');
                                          pushNewScreen(
                                            context,
                                            screen: CategoryDetailScreen(
                                              categoryName: snap
                                                  .data.documents[i]['catName'],
                                              imagePath: snap.data.documents[i]
                                                  ['liveImageURL'],
                                              selectedCategory: i,
                                              numberOfCategories:
                                                  snap.data.documents.length,
                                              gradient: gradients[i],
                                              sCat: 'Grocery',
                                            ),
                                            withNavBar:
                                                true, // OPTIONAL VALUE. True by default.
                                            pageTransitionAnimation:
                                                PageTransitionAnimation
                                                    .cupertino,
                                          );
//
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: foodCard(
                                            snap.data.documents[i]['imageURL'],
                                            snap.data.documents[i]['catName'],
                                          ),
                                        ),
                                      ));
                                  }
                                  return categoriesGrocery.length != 0
                                      ? ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: categoriesGrocery,
                                        )
                                      : Container();
                                } else
                                  return Container(
                                      child: Center(
                                          child: Container(
                                              height: 100,
                                              width: 100,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()))));
                              },
                            ),
                          )
                        : Container(),

                    SizedBox(height: 16.0),
                    Container(
                      height: 110,
                      child: FancyShimmerImage(
                        shimmerDuration: Duration(seconds: 2),
                        imageUrl: banner1Url,
                        boxFit: BoxFit.fitWidth,
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
                      height: 405,
                      child: top.length != 0
                          ? GridView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 5.0,
                                      childAspectRatio: 0.59),
                              children: top,
                            )
                          : Container(),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: 110,
                      child: FancyShimmerImage(
                        shimmerDuration: Duration(seconds: 2),
                        imageUrl: banner2Url,
                        boxFit: BoxFit.fitWidth,
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
                      height: 405,
                      child: special.length != 0
                          ? GridView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 5.0,
                                      childAspectRatio: 0.65),
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
                      child: Container(
                          height: 100,
                          width: 100,
                          child: Center(child: CircularProgressIndicator()))));
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
//      ${place.subLocality},
      setState(() {
        currentAddress = "${place.locality}, ${place.administrativeArea}";
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
                      fontSize: 17,
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
                    width: MediaQuery.of(context).size.width * 0.38,
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
                      width: MediaQuery.of(context).size.width * 0.38,
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

  Future<void> _timeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildTimeDialog(context);
      },
    );
  }

  Widget _buildTimeDialog(BuildContext context) {
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
                    'Change delivery time',
                    style: textTheme.title.copyWith(
                      fontSize: Sizes.TEXT_SIZE_20,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: DropDown<String>(
                  initialValue: '9 AM',
                  items: <String>['9 AM', '12 PM', '2 PM', '5 PM', '7 PM'],
                  hint: Text("Select quantity"),
                  onChanged: (value) async {
                    setState(() {
                      selectedTime = value;
                    });
                  },
                ),
              ),
              Spacer(flex: 1),
              AlertDialogButton(
                  buttonText: "Change",
                  width: 280,
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: AppColors.greyShade1,
                    ),
                  ),
                  textStyle: textTheme.button
                      .copyWith(color: AppColors.secondaryElement),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop(true);
                  })
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

  LocationResult result;

  void showPlacePicker() async {
    result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw")));
    setState(() {
      location = result.formattedAddress;
    });
    // Handle the result in your way
    print(location);
  }

  Widget bill() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Order Id- $id1',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                color: Colors.black.withOpacity(0.1),
                height: 1,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Items',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                str,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Ordered On',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                timestamp.toDate().day.toString() +
                    '-' +
                    timestamp.toDate().month.toString() +
                    '-' +
                    timestamp.toDate().year.toString() +
                    ' at ' +
                    timestamp.toDate().hour.toString() +
                    ':' +
                    timestamp.toDate().minute.toString(),
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Total',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. ' + total,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                color: Colors.black.withOpacity(0.1),
                height: 1,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                status,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addDishParams() {
    Firestore.instance.collection('Dishes').getDocuments().then((value) {
      value.documents.forEach((element) {
        Firestore.instance
            .collection('Dishes')
            .document(element.documentID)
            .updateData({
          'nameSearch': setSearchParam(element['name']),
          'categorySearch': setSearchParam(element['category']),
        });
      });
    });
  }

  setSearchParam(String caseString) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseString.length; i++) {
      temp = temp + caseString[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  var str = '', timestamp, status, total, id1;
  fetchOrderDetail(id) {
    Firestore.instance.collection('Orders').document(id).get().then((value) {
      setState(() {
        id1 = id;
        str = '';
        // print('===============${value.data}');
        if (value.data != null) {
          for (int it = 0; it < value['Items'].length; it++) {
            it != value['Items'].length - 1
                ? str = str + '${value['Qty'][it]} x ${value['Items'][it]}, '
                : str = str + '${value['Qty'][it]} x ${value['Items'][it]}';
          }
          timestamp = value['TimeStamp'];
          status = value["Status"];
          total = value["GrandTotal"];
        }
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

//5. On categories page two main categories are to be displayed and inside them other 8 categories are to be displayed.
//8. Product page needs to be made catchy and attractive in accordance to the photoshop design that will be provided.
