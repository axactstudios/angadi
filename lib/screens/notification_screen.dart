import 'dart:io';

import 'package:angadi/widgets/nav_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_placed.dart';

class NotificationsScreen extends StatefulWidget {
  static const int TAB_NO = 3;

  NotificationsScreen({Key key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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

//  List<NotificationInfo> notifications = [
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//    NotificationInfo(
//      // imageUrl: ImagePath.branson,
//      title: "Order No:- 23465",
//      time: "5:30 am",
//      subtitle: "Order is being Prepared",
//    ),
//  ];
  FirebaseUser user;
  getUser() async {
    user = await FirebaseAuth.instance.currentUser();
  }

  List<NotificationInfo> notifications = List();
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
                  child: FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF6b3600)))),
          SizedBox(width:8),
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
            fontSize: Sizes.TEXT_SIZE_18,
          ),
        ),
      ),
      drawer: CustomDrawer(),
//      appBar: AppBar(
//        elevation: 0.0,
//        centerTitle: true,
//        title:
//      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('Notifications').snapshots(),
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            getUser();
            if (snap.hasData && !snap.hasError && snap.data != null) {
              notifications.clear();
              for (int i = 0; i < snap.data.documents.length; i++) {
                if (snap.data.documents[i]['UserID'] == user?.uid) {
                  notifications.add(NotificationInfo(
                      imageUrl: 'null',
                      title: 'Order ID - ${snap.data.documents[i]['OrderID']}',
                      time: snap.data.documents[i]['TimeStamp'].toString(),
                      subtitle:
                          '${snap.data.documents[i]['Notification']}\nOrder Type - ${snap.data.documents[i]['Type']}\nAmount - Rs. ${snap.data.documents[i]['GrandTotal']}'));
                }
              }
              return Container(
                margin: EdgeInsets.symmetric(
                    horizontal: Sizes.MARGIN_8, vertical: Sizes.MARGIN_16),
                child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          index == 0
                              ? Text(
                                  'NOTIFICATIONS',
                                  style: Styles.customTitleTextStyle(
                                    color: Color(0xFF6b3600),
                                    fontWeight: FontWeight.w600,
                                    fontSize: Sizes.TEXT_SIZE_22,
                                  ),
                                )
                              : Container(),
                          index == 0
                              ? SizedBox(
                                  height: 20,
                                )
                              : Container(),
                          Card(
                            child: ListTile(
// leading: Image.asset(notifications[index].imageUrl),
                              onTap: () async {
                                await fetchOrderDetail(
                                    snap.data.documents[index]['OrderID']);
                                String status;
                                Firestore.instance
                                    .collection('Orders')
                                    .getDocuments()
                                    .then((value) {
                                  value.documents.forEach((element) {
                                    if (element.documentID ==
                                        snap.data.documents[index]['OrderID']) {
                                      status = element['Status'];
                                    }
                                  });
                                });

                                pushNewScreen(context,
                                    screen: OrderPlaced(
                                        bill(),
                                        snap.data.documents[index]['OrderID'],
                                        status));
                              },
                              title: Row(
                                children: <Widget>[
                                  Text(
                                    '${(index + 1).toString()}. ${notifications[index].subtitle}',
                                    style: Styles.customTitleTextStyle(
                                      color: AppColors.headingText,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              subtitle: Container(
                                margin: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  notifications[index].title,
                                  style: Styles.customNormalTextStyle(
                                    color: AppColors.accentText,
                                    fontSize: Sizes.TEXT_SIZE_14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              );
            } else {
              return Center(child: Text('No New Notifications'));
            }
          }),
    );
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

  var str = '', timestamp, status, total, id1;
  fetchOrderDetail(id) {
    Firestore.instance.collection('Orders').document(id).get().then((value) {
      setState(() {
        id1 = id;
        str = '';
        for (int it = 0; it < value['Items'].length; it++) {
          it != value['Items'].length - 1
              ? str = str + '${value['Qty'][it]} x ${value['Items'][it]}, '
              : str = str + '${value['Qty'][it]} x ${value['Items'][it]}';
        }
        timestamp = value['TimeStamp'];
        status = value["Status"];
        total = value["GrandTotal"];
      });
    });
  }
}

class NotificationInfo {
  final String imageUrl;
  final String title;
  final String time;
  final String subtitle;

  NotificationInfo({
    @required this.imageUrl,
    @required this.title,
    @required this.time,
    @required this.subtitle,
  });
}
