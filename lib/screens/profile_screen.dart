import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';

class ProfileScreen extends StatefulWidget {
  static const int TAB_NO = 3;

  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  List<Order> orders = List<Order>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: Sizes.ELEVATION_0,
          centerTitle: true,
          title: Text(
            'Profile',
            style: Styles.customTitleTextStyle(
              color: AppColors.headingText,
              fontWeight: FontWeight.w600,
              fontSize: Sizes.TEXT_SIZE_22,
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: Sizes.MARGIN_8),
          child: ListView(
            children: <Widget>[
              Column(
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
                    onTap: () => R.Router.navigator
                        .pushNamed(R.Router.editProfileScreen),
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
              // Column(
              //   children: <Widget>[
              //     FoodyBiteCard(
              //       imagePath: ImagePath.dinnerIsServed,
              //       status: StringConst.STATUS_OPEN,
              //       cardTitle: "Gramercy Tavern",
              //       category: StringConst.ITALIAN,
              //       distance: "12 km",
              //       address: "394 Broome St, New York, NY 10013, USA",
              //       isThereStatus: false,
              //       onTap: () {},
              //     ),
              //     SpaceH16(),
              //     FoodyBiteCard(
              //       imagePath: ImagePath.breakfastInBed,
              //       status: StringConst.STATUS_OPEN,
              //       cardTitle: "Happy Bones",
              //       category: StringConst.ITALIAN,
              //       distance: "12 km",
              //       address: "394 Broome St, New York, NY 10013, USA",
              //       isThereStatus: false,
              //       onTap: () {},
              //     ),
              //   ],
              // ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: StreamBuilder(
                  stream: Firestore.instance.collection('Orders').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snap) {
                    if (snap.hasData && !snap.hasError && snap.data != null) {
                      orders.clear();

                      for (int i = 0; i < snap.data.documents.length; i++) {
                        print(snap.data.documents[i]['Prices'].toString());
                        orders.add(Order(
                            prices: snap.data.documents[i]['Price'],
                            items: snap.data.documents[i]['Items'],
                            total: snap.data.documents[i]['GrandTotal'],
                            quantities: snap.data.documents[i]['Qty'],
                            status: snap.data.documents[i]['Status'],
                            timestamp:
                                snap.data.documents[i]['TimeStamp'].toString(),
                            type: snap.data.documents[i]['Type']));
                      }
                      return orders.length != 0
                          ? ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Center(
                                                      child: Text('Name'))),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Center(
                                                      child: Text('Quantity'))),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Center(
                                                      child: Text('Price'))),
                                            ],
                                          ),
                                          Container(
                                            height: 40.0 *
                                                orders[index].items.length,
                                            child: ListView.builder(
                                                itemCount:
                                                    orders[index].items.length,
                                                itemBuilder: (context, i) {
                                                  return Row(
                                                    // mainAxisAlignment:
                                                    //     MainAxisAlignment
                                                    //         .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        child: Center(
                                                          child: Text(
                                                            orders[index]
                                                                .items[i]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        child: Center(
                                                          child: Text(
                                                              orders[index]
                                                                  .quantities[i]
                                                                  .toString()),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        child: Center(
                                                          child: Text(
                                                              orders[index]
                                                                  .prices[i]
                                                                  .toString()),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Center(
                                                      child: Text('Amount-'))),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Center(
                                                    child: Text(
                                                        orders[index].total),
                                                  )),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Center(
                                                      child: Text('Status-'))),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                child: Center(
                                                  child: Text(orders[index]
                                                      .status
                                                      .toString()),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
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

  String name, email, url;
  getUserDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
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
  String total, type, status, timestamp;
  List items, prices, quantities;
  Order(
      {this.prices,
      this.quantities,
      this.items,
      this.type,
      this.status,
      this.total,
      this.timestamp});
}
