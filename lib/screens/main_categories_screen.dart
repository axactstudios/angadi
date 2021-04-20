import 'dart:io';

import 'package:angadi/routes/router.dart';
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:angadi/widgets/nav_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'categories_screen.dart';
import 'home_screen.dart';

class MainCategoriesScreen extends StatefulWidget {
  @override
  _MainCategoriesScreenState createState() => _MainCategoriesScreenState();
}

class _MainCategoriesScreenState extends State<MainCategoriesScreen> {
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

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: CustomFloatingButton(
            CurrentScreen(tab_no: 12, currentScreen: MainCategoriesScreen())),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.secondaryElement,
          actions: [
            InkWell(
                onTap: () {
                  launch(Uri.encodeFull('tel:+971 50 7175406'));
                },
                child: Icon(Icons.phone, color: Color(0xFF6b3600))),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
                  if (Platform.isIOS) {
                    launch(Uri.encodeFull(
                        "whatsapp://wa.me/+971 50 7175406/?text= Hi"));
                  } else {
                    launch(Uri.encodeFull(
                        "whatsapp://send?   phone=+971 50 7175406&text= Hi"));
                  }
                },
                child: Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.whatsapp,
                        color: Color(0xFF6b3600)))),
            SizedBox(width: 8),
            InkWell(
                onTap: () {
                  launch(Uri.encodeFull(
                      "mailto:info@angadi.ae?subject=Complaint/Feedback&body=Type your views here."));
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
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: Sizes.MARGIN_16, vertical: Sizes.MARGIN_16),
            child: Column(
              children: [
                Text(StringConst.CATEGORY.toUpperCase(),
                    style: Styles.customTitleTextStyle(
                      color: Color(0xFF6b3600),
                      fontWeight: FontWeight.w600,
                      fontSize: Sizes.TEXT_SIZE_20,
                    )),
                SizedBox(height: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CategoriesScreen('Food');
                            }));
                          },
                          child: Column(
                            children: [
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
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
                                      boxFit: BoxFit.cover,
                                    ),
                                  )),
                              Container(
                                height: 25,
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8))),
                                child: Text(
                                  'Food Items',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF6b3600),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width * 0.65,
                                color: AppColors.secondaryElement,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: showGrocery
                              ? () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return CategoriesScreen('Grocery');
                                  }));
                                }
                              : () {},
                          child: Column(
                            children: [
                              Stack(children: [
                                Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                        boxFit: BoxFit.cover,
                                      ),
                                    )),
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
                                                  color:
                                                      Colors.deepOrangeAccent,
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
                              ]),
                              Container(
                                height: 25,
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8))),
                                child: Text(
                                  'Grocery Items',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF6b3600),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width * 0.65,
                                color: AppColors.secondaryElement,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
