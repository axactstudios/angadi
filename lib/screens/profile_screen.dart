import 'dart:io';

import 'package:angadi/screens/my_addresses.dart';
import 'package:angadi/screens/my_orders.dart';
import 'package:angadi/screens/wishlist_screen.dart';
import 'package:angadi/widgets/nav_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const int TAB_NO = 4;
  bool fromDrawer;

  ProfileScreen({Key key, this.fromDrawer}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String whatsappMessage = '';
  @override
  void initState() {
    getUserDetails();
    address();
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

  List<Order> orders = List<Order>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              fontSize: Sizes.TEXT_SIZE_18,
            ),
          ),
          leading: widget.fromDrawer == true
              ? InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_rounded))
              : null,
        ),
        drawer: widget.fromDrawer != true ? CustomDrawer() : null,
//        appBar: AppBar(
//          elevation: Sizes.ELEVATION_0,
//          centerTitle: true,
//          title:
//        ),
        body: Container(
          margin: EdgeInsets.only(top: Sizes.MARGIN_8),
          child: ListView(
            children: <Widget>[
              Center(
                child: Text(
                  'PROFILE',
                  style: Styles.customTitleTextStyle(
                    color: Color(0xFF6b3600),
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.TEXT_SIZE_22,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              user != null
                  ? Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: url == null
                              ? AssetImage(ImagePath.branson)
                              : NetworkImage(url),
                          minRadius: Sizes.RADIUS_60,
                          maxRadius: Sizes.RADIUS_60,
                        ),
                        SpaceH8(),
                        Text(name == null ? 'John Williams' : name,
                            style: Styles.foodyBiteTitleTextStyle),
                        SpaceH8(),
                        Text(email == null ? 'john.williams@gmail.com' : email,
                            style: Styles.foodyBiteSubtitleTextStyle),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          pushNewScreen(context,
                              screen: LoginScreen(), withNavBar: false);
                        },
                        child: Container(
                          color: AppColors.secondaryElement,
                          height: 80,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                ),
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Sign In/Sign Up',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              // SpaceH24(),
              // IntrinsicHeight(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       detail(number: "250", text: "Reviews"),
              //       VerticalDivider(
              //         width: Sizes.WIDTH_40,
              //         thickness: 1.0,
              //       ),
              //       detail(number: "100k", text: "Followers"),
              //       VerticalDivider(
              //         width: Sizes.WIDTH_40,
              //         thickness: 1.0,
              //       ),
              //       detail(number: "30", text: "Following"),
              //       SpaceH24(),
              //     ],
              //   ),
              // ),
              SpaceH24(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  angadiButton(
                    'Edit Profile',
                    onTap: () {
                      user != null
                          ? R.Router.navigator
                              .pushNamed(R.Router.editProfileScreen)
                          : Fluttertoast.showToast(msg: 'Log In First !');
                    },
                    buttonWidth: MediaQuery.of(context).size.width / 3,
                    buttonHeight: Sizes.HEIGHT_50,
                  ),
                  SpaceW16(),
                  angadiButton(
                    'Settings',
                    onTap: () =>
                        R.Router.navigator.pushNamed(R.Router.settingsScreen),
                    buttonWidth: MediaQuery.of(context).size.width / 3,
                    buttonHeight: Sizes.HEIGHT_50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      border: Border.all(color: AppColors.indigo),
                      borderRadius: BorderRadius.all(
                        Radius.circular(Sizes.RADIUS_8),
                      ),
                    ),
                    buttonTextStyle: Styles.customNormalTextStyle(
                      color: AppColors.accentText,
                      fontSize: Sizes.TEXT_SIZE_16,
                    ),
                  ),
                ],
              ),
              Divider(
                height: Sizes.HEIGHT_40,
                thickness: 3.0,
                color: Colors.grey[200],
              ),

              user != null
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: [
                            angadiButton(
                              'My orders',
                              onTap: () async {
                                FirebaseUser user =
                                    await FirebaseAuth.instance.currentUser();

                                pushNewScreen(context,
                                    screen: MyOrders(user), withNavBar: true);
                              },
                              buttonWidth:
                                  MediaQuery.of(context).size.width / 2,
                              buttonHeight: Sizes.HEIGHT_50,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            angadiButton(
                              'My Addresses',
                              onTap: () {
                                pushNewScreen(context,
                                    screen: MyAddresses(id), withNavBar: true);
                              },
                              buttonWidth:
                                  MediaQuery.of(context).size.width / 2,
                              buttonHeight: Sizes.HEIGHT_50,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            angadiButton(
                              'My Wishlist',
                              onTap: () {
                                pushNewScreen(context,
                                    screen: WishlistScreen(), withNavBar: true);
                              },
                              buttonWidth:
                                  MediaQuery.of(context).size.width / 2,
                              buttonHeight: Sizes.HEIGHT_50,
                            ),
                          ],
                        ),
                      ))
                  : Container(
                      child: Center(child: Text('Log In to view your orders.')),
                    )
            ],
          ),
        ));
  }

  Widget detail({@required String number, @required String text}) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            number,
            style: Styles.customNormalTextStyle(
                color: AppColors.secondaryElement,
                fontWeight: FontWeight.w600,
                fontSize: Sizes.TEXT_SIZE_18),
          ),
          SizedBox(height: 8.0),
          Text(text, style: Styles.foodyBiteSubtitleTextStyle),
        ],
      ),
    );
  }

  FirebaseUser user;
  String name,
      email,
      url =
          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FUlundu%20Vada%20Mix%2F1-4.JPG?alt=media&token=f3955753-5fd0-43a6-914c-d7a6a560834e';
  getUserDetails() async {
    user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('Users')
        .where('id', isEqualTo: user.uid)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          name = element['Name'];
          email = element['mail'];
          url = element['pUrl'];
        });
      });
    });
  }
}

class Order {
  String total, type, status, orderString, id;
  Timestamp timestamp;
  List items, prices, quantities;
  Order(
      {this.prices,
      this.quantities,
      this.items,
      this.type,
      this.status,
      this.total,
      this.timestamp,
      this.orderString,
      this.id});
}
