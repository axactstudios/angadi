import 'dart:io';

import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes/router.dart';
import '../routes/router.gr.dart';
import 'category_detail_screen.dart';
import 'home_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const int TAB_NO = 1;
  String sCat;
  CategoriesScreen(this.sCat);
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Widget> categoriesTop = new List();
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
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      floatingActionButton: CustomFloatingButton(CurrentScreen(
          tab_no: CategoriesScreen.TAB_NO,
          currentScreen: CategoriesScreen('Both'))),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppColors.secondaryElement,
        actions: [
          InkWell(
              onTap: () {
                launch('tel:+971 50 7175406');
              },
              child: Icon(Icons.phone, color: Color(0xFF6b3600))),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+971 50 7175406", "");
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
          'Angadi.ae',
          style: Styles.customTitleTextStyle(
            color: Color(0xFF6b3600),
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
//      appBar: AppBar(
//        elevation: 0.0,
////        leading: InkWell(
////          onTap: () => R.Router.navigator.pop(),
////          child: Image.asset(
////            ImagePath.arrowBackIcon,
////            color: AppColors.headingText,
////          ),
////        ),
//        centerTitle: true,
//        title:
//          ),
//        ),
////        actions: <Widget>[
////          InkWell(
////            onTap: () {},
////            child: Image.asset(
////              ImagePath.searchIcon,
////              color: AppColors.headingText,
////            ),
////          )
////        ],
//      ),
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: Sizes.MARGIN_16, vertical: Sizes.MARGIN_16),
        child: StreamBuilder(
            stream: Firestore.instance.collection('Categories').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
              if (snap.hasData && !snap.hasError && snap.data != null) {
                categoriesTop.clear();

                for (int i = 0; i < snap.data.documents.length; i++) {
                  if (widget.sCat == 'Food' || widget.sCat == 'Grocery') {
                    if (snap.data.documents[i]['sCat'] == widget.sCat) {
                      categoriesTop.add(Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CategoryDetailScreen(
                                categoryName: snap.data.documents[i]['catName'],
                                imagePath: snap.data.documents[i]['imageURL'],
                                selectedCategory: i,
                                numberOfCategories: categoriesTop.length,
                                gradient: gradients[i],
                                sCat: widget.sCat,
                              );
                            }));
                          },
                          child: Column(
                            children: [
                              Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.35,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    child: FancyShimmerImage(
                                      shimmerDuration: Duration(seconds: 2),
                                      imageUrl: snap.data.documents[i]
                                          ['liveImageURL'],
                                      boxFit: BoxFit.fill,
                                    ),
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    snap.data.documents[i]['catName'],
                                    style: TextStyle(
                                        color: Color(0xFF6b3600),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                  SizedBox(
                                    height: 2.5,
                                  ),
                                  Container(
                                    height: 2,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    color: AppColors.secondaryElement,
                                  ),
                                  SizedBox(
                                    height: 2.5,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ));
                    }
                  } else if (showGrocery == true) {
                    categoriesTop.add(Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return CategoryDetailScreen(
                              categoryName: snap.data.documents[i]['catName'],
                              imagePath: snap.data.documents[i]['imageURL'],
                              selectedCategory: i,
                              numberOfCategories: categoriesTop.length,
                              gradient: gradients[i],
                              sCat: widget.sCat,
                            );
                          }));
                        },
                        child: Column(
                          children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.35,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  child: FancyShimmerImage(
                                    shimmerDuration: Duration(seconds: 2),
                                    imageUrl: snap.data.documents[i]
                                        ['liveImageURL'],
                                    boxFit: BoxFit.fill,
                                  ),
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            Column(
                              children: [
                                Text(
                                  snap.data.documents[i]['catName'],
                                  style: TextStyle(
                                      color: Color(0xFF6b3600),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  height: 2.5,
                                ),
                                Container(
                                  height: 2,
                                  width: snap.data.documents[i]['catName']
                                          .toString()
                                          .length *
                                      0.5,
                                  color: AppColors.secondaryElement,
                                ),
                                SizedBox(
                                  height: 2.5,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ));
                  } else {
                    if (snap.data.documents[i]['sCat'] == 'Food') {
                      categoriesTop.add(Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CategoryDetailScreen(
                                categoryName: snap.data.documents[i]['catName'],
                                imagePath: snap.data.documents[i]['imageURL'],
                                selectedCategory: i,
                                numberOfCategories: categoriesTop.length,
                                gradient: gradients[i],
                                sCat: widget.sCat,
                              );
                            }));
                          },
                          child: Column(
                            children: [
                              Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.35,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    child: FancyShimmerImage(
                                      shimmerDuration: Duration(seconds: 2),
                                      imageUrl: snap.data.documents[i]
                                          ['liveImageURL'],
                                      boxFit: BoxFit.fill,
                                    ),
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    snap.data.documents[i]['catName'],
                                    style: TextStyle(
                                        color: Color(0xFF6b3600),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                  SizedBox(
                                    height: 2.5,
                                  ),
                                  Container(
                                    height: 2,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    color: AppColors.secondaryElement,
                                  ),
                                  SizedBox(
                                    height: 2.5,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ));
                    }
                  }
                }
              }
              return categoriesTop.length != 0
                  ? Column(
                      children: [
                        Text(StringConst.CATEGORY.toUpperCase(),
                            style: Styles.customTitleTextStyle(
                              color: Color(0xFF6b3600),
                              fontWeight: FontWeight.w600,
                              fontSize: Sizes.TEXT_SIZE_20,
                            )),
                        widget.sCat != 'Both'
                            ? Text('${widget.sCat} ITEMS'.toUpperCase(),
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.secondaryElement,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.TEXT_SIZE_28,
                                ))
                            : Container(),
                        SizedBox(height: 20),
                        Expanded(
                          child: GridView.count(
                            childAspectRatio: 0.87,
                            crossAxisCount: 2,
                            scrollDirection: Axis.vertical,
                            children: categoriesTop,
                          ),
                        ),
                      ],
                    )
                  : Container();
            }),
      ),
    );
  }
}
