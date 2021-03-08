import 'dart:io';

import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/quantity.dart';
import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:angadi/widgets/foody_bite_card_2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/cart.dart';
import '../routes/router.dart';
import '../routes/router.gr.dart';
import '../services/database_helper.dart';
import 'filtered_search.dart';
import 'restaurant_details_screen.dart';
import 'search_results.dart';

class CategoryDetailScreen extends StatefulWidget {
  CategoryDetailScreen({
    @required this.categoryName,
    @required this.imagePath,
    @required this.numberOfCategories,
    @required this.selectedCategory,
    @required this.gradient,
    @required this.sCat,
  });

  final String categoryName;
  final String sCat;
  final int numberOfCategories;
  final int selectedCategory;
  final String imagePath;
  final Gradient gradient;

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

String listType = 'Grid';

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
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

  String whatsappMessage = '';
  void initState() {
    getOrderCount();
    setState(() {
      final firestoreInstance = Firestore.instance;

      firestoreInstance
          .collection("WhatsappMessage")
          .getDocuments()
          .then((querySnapshot) {
        querySnapshot.documents.forEach((result) {
          whatsappMessage = result.data['WhatsappMessage'];
          print('Whatsapp Message ${result.data['WhatsappMessage']}');
        });
      });
    });
    super.initState();
  }

  int orderCount;

  void getOrderCount() async {
    await Firestore.instance
        .collection('Ordercount')
        .document('ordercount')
        .snapshots()
        .listen((event) {
      print(event['Numberoforders'].toString());
      orderCount = event['Numberoforders'];
    });
    print('Checked');
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var widthOfScreen = MediaQuery.of(context).size.width;
    var marginBetweenPills = 4;
    var marginAroundPills = 92;
    var margin = marginAroundPills +
        ((widget.numberOfCategories - 1) * marginBetweenPills);
    var widthOfEachPill = (widthOfScreen - margin) / widget.numberOfCategories;
    List<Dish> dishes = new List<Dish>();

    return Scaffold(
//      floatingActionButton: CustomFloatingButton(CurrentScreen(
//          tab_no: 7,
//          currentScreen: CategoryDetailScreen(
//              categoryName: widget.categoryName,
//              numberOfCategories: widget.numberOfCategories,
//              selectedCategory: widget.selectedCategory,
//              imagePath: widget.imagePath,
//              gradient: widget.gradient))),
//      appBar: PreferredSize(
//        preferredSize: Size.fromHeight(80.0),
//        child: AppBar(
//          automaticallyImplyLeading: false,
//          flexibleSpace: Stack(
//            children: <Widget>[
//              Positioned(
//                child: Image.network(
//                  widget.imagePath,
//                  width: MediaQuery.of(context).size.width,
//                  height: 130,
//                  fit: BoxFit.cover,
//                ),
//              ),
//              Positioned(
//                child: Opacity(
//                  opacity: 0.85,
//                  child: Container(
//                    decoration: BoxDecoration(
//                      gradient: widget.gradient,
//                    ),
//                  ),
//                ),
//              ),
//              Positioned(
//                child: SafeArea(
//                  child: Container(
//                    height: 80,
//                    width: MediaQuery.of(context).size.width,
//                    margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
//                    child: Column(
//                      children: <Widget>[
//                        Row(
//                          children: <Widget>[
//                            InkWell(
//                              onTap: () => R.Router.navigator
//                                  .pushNamed(R.Router.rootScreen),
//                              child: Image.asset(ImagePath.arrowBackIcon),
//                            ),
//                            Spacer(flex: 1),
//                            Text(
//                              widget.categoryName,
//                              style: textTheme.title.copyWith(
//                                fontSize: Sizes.TEXT_SIZE_22,
//                                color: AppColors.white,
//                              ),
//                            ),
//                            Spacer(flex: 1),
//                          ],
//                        ),
//                        SpaceH24(),
//                        Container(
//                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: generatePills(
//                              numberOfPills: widget.numberOfCategories,
//                              widthOfPill: widthOfEachPill,
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              )
//            ],
//          ),
//          backgroundColor: Colors.transparent,
//        ),
      floatingActionButton: CustomFloatingButton(CurrentScreen(
          tab_no: 9,
          currentScreen: CategoryDetailScreen(
            numberOfCategories: widget.numberOfCategories,
            selectedCategory: widget.selectedCategory,
            imagePath: widget.imagePath,
            categoryName: widget.categoryName,
            gradient: widget.gradient,
          ))),
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
                launchWhatsApp(phone: '+971 50 7175405', message: whatsappMessage);
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
                    'mailto:info@angadi.ae?subject=Complaint/Feedback&body=Type your views here.');
              },
              child: Icon(Icons.mail, color: Color(0xFF6b3600))),
          SizedBox(
            width: 10,
          )
        ],
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: Styles.customTitleTextStyle(
            color: Color(0xFF6b3600),
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_18,
          ),
        ),
      ),
//      appBar: AppBar(
//        leading: InkWell(
//            onTap: () => Navigator.pop(context),
//            child: Icon(Icons.arrow_back_ios)),
//        title: Text(widget.categoryName),
//        actions: [
//          InkWell(
//              onTap: () {
//                print(1);
//                pushNewScreen(context,
//                    screen: SearchScreen(), withNavBar: true);
//              },
//              child: InkWell(
//                  onTap: () => Navigator.push(context,
//                          MaterialPageRoute(builder: (BuildContext context) {
//                        return FilteredSearch();
//                      })),
//                  child: Icon(Icons.search))),
//          SizedBox(
//            width: 14,
//          )
//        ],
//        elevation: 0,
//      ),
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(80.0),
      //   child: AppBar(
      //     automaticallyImplyLeading: false,
      //     flexibleSpace: Stack(
      //       children: <Widget>[
      //         Positioned(
      //           child: Image.network(
      //             widget.imagePath,
      //             width: MediaQuery.of(context).size.width,
      //             height: 130,
      //             fit: BoxFit.cover,
      //           ),
      //         ),
      //         Positioned(
      //           child: Opacity(
      //             opacity: 0.85,
      //             child: Container(
      //               decoration: BoxDecoration(
      //                 gradient: widget.gradient,
      //               ),
      //             ),
      //           ),
      //         ),
      //         Positioned(
      //           child: SafeArea(
      //             child: Container(
      //               height: 80,
      //               width: MediaQuery.of(context).size.width,
      //               margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
      //               child: Column(
      //                 children: <Widget>[
      //                   Row(
      //                     children: <Widget>[
      //                       InkWell(
      //                         onTap: () => R.Router.navigator.pop(),
      //                         child: Image.asset(ImagePath.arrowBackIcon),
      //                       ),
      //                       Spacer(flex: 1),
      //                       Text(
      //                         widget.categoryName,
      //                         style: textTheme.title.copyWith(
      //                           fontSize: Sizes.TEXT_SIZE_22,
      //                           color: AppColors.white,
      //                         ),
      //                       ),
      //                       Spacer(flex: 1),
      //                     ],
      //                   ),
      //                   SpaceH24(),
      //                   Container(
      //                     margin: const EdgeInsets.symmetric(horizontal: 30.0),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: generatePills(
      //                         numberOfPills: widget.numberOfCategories,
      //                         widthOfPill: widthOfEachPill,
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         )
      //       ],
      //     ),
      //     backgroundColor: Colors.transparent,
      //   ),
      // ),
      body: Container(
        margin: const EdgeInsets.only(
          left: Sizes.MARGIN_16,
          right: Sizes.MARGIN_16,
          // top: Sizes.MARGIN_16,
        ),
        child: StreamBuilder(
          stream: Firestore.instance.collection('Dishes').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            if (snap.hasData && !snap.hasError && snap.data != null) {
              dishes.clear();

              for (int i = 0; i < snap.data.documents.length; i++) {
//              print(snap.data.documents[i]['url']);
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

                if (snap.data.documents[i]['category'] == widget.categoryName)
                  dishes.add(Dish(
                      id: snap.data.documents[i]['productId'],
                      name: snap.data.documents[i]['name'],
                      category: snap.data.documents[i]['category'],
                      rating: snap.data.documents[i]['rating'],
                      price: snap.data.documents[i]['price'],
                      iPrice: snap.data.documents[i]['iPrice'],
                      desc: snap.data.documents[i]['description'],
                      url: snap.data.documents[i]['url'],
                      boughtTogetherDiscount: snap.data.documents[i]
                          ['boughtTogetherDiscount'],
                      boughtTogetherID: snap.data.documents[i]
                          ['boughtTogether'],
                      allquantities: allquantities,
                      quantities: quantities,
                  stock:snap.data.documents[i]['stock']));
                print(
                  snap.data.documents[i]['price'],
                );
              }

              return Column(
                children: <Widget>[
                  Container(
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.grid_on, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                listType = 'Grid';
                              });
                              print(listType);
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.list,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                listType = 'List';
                              });
                              print(listType);
                            },
                          ),
                          Spacer(),
                          InkWell(
                              onTap: () => R.Router.navigator
                                  .pushNamed(R.Router.filterScreen),
                              child: Icon(
                                Icons.filter_list,
                                color: Colors.black,
                              ))
                        ],
                      )),
                  listType == 'List'
                      ? Expanded(
                          child: ListView.separated(
                            itemCount: dishes.length,
                            separatorBuilder: (context, index) {
                              return SpaceH8();
                            },
                            itemBuilder: (context, index) {
                              print('============${dishes[index].price}');
                              return Container(
                                margin: EdgeInsets.only(right: 4.0),
                                child: FoodyBiteCard(
                                    onTap: () async {
                                      Dish boughtTogether;
                                      for (int i = 0; i < dishes.length; i++) {
                                        if (dishes[i].id ==
                                            dishes[index].boughtTogetherID) {
                                          boughtTogether = await dishes[i];
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
                                          stock:dishes[index].stock),
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
                                    orderCount: orderCount,
//                            distance: distance[index],
                                    address: dishes[index].desc,
                                    allquantities: dishes[index].allquantities,
                                    quantities: dishes[index].quantities,
                                stock: dishes[index].stock,),
                              );
                            },
                          ),
                        )
                      : Expanded(
                          child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 5.0,
                                      childAspectRatio: 0.58),
                              itemCount: dishes.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(right: 4.0),
                                  child: FoodyBiteCard2(
                                    onTap: () async {
                                      Dish boughtTogether;
                                      for (int i = 0; i < dishes.length; i++) {
                                        if (dishes[i].id ==
                                            dishes[index].boughtTogetherID) {
                                          boughtTogether = await dishes[i];
                                        }
                                      }
                                      pushNewScreen(
                                        context,
                                        screen: RestaurantDetailsScreen(
                                          RestaurantDetails(
                                              url: dishes[index].url,
                                              name: dishes[index].name,
                                              productID: dishes[index].id,
                                              desc: dishes[index].desc,
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
                                    orderCount: orderCount,
//                            distance: distance[index],
                                    address: dishes[index].desc,
                                    allquantities: dishes[index].allquantities,
                                    quantities: dishes[index].quantities,
                                    stock: dishes[index].stock,
                                  ),
                                );
                              })),
                ],
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

  List<Widget> generatePills({
    @required int numberOfPills,
    @required double widthOfPill,
  }) {
    List<Widget> pills = [];
    for (var index = 0; index < numberOfPills; index++) {
      pills.add(
        Pill(
          width: widthOfPill,
          color: (index == widget.selectedCategory)
              ? AppColors.white
              : AppColors.whiteShade_50,
          marginRight:
              (index == numberOfPills - 1) ? Sizes.MARGIN_0 : Sizes.MARGIN_4,
        ),
      );
    }

    return pills;
  }
}

class Pill extends StatelessWidget {
  Pill({
    this.width = 30,
    this.height = 4,
    this.marginRight = 4,
    this.color = AppColors.whiteShade_50,
    this.borderRadius = Sizes.RADIUS_30,
  });

  final double width;
  final double height;
  final double marginRight;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, //28,
      height: height,
      margin: EdgeInsets.only(right: marginRight),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
