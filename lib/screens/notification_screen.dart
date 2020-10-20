import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';

class NotificationsScreen extends StatefulWidget {
  static const int TAB_NO = 3;

  NotificationsScreen({Key key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('Notifications').snapshots(),
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            getUser();
            if (snap.hasData && !snap.hasError && snap.data != null) {
              notifications.clear();
              for (int i = 0; i < snap.data.documents.length; i++) {
                if (snap.data.documents[i]['UserID'] == user.uid) {
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
                      return Card(
                        child: ListTile(
// leading: Image.asset(notifications[index].imageUrl),
                          onTap: () {},
                          title: Row(
                            children: <Widget>[
                              Text(
                                '${(index + 1).toString()}. ${notifications[index].subtitle}',
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.headingText,
                                  fontWeight: FontWeight.w400,
                                  fontSize: Sizes.TEXT_SIZE_16,
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
                      );
                    }),
              );
            } else {
              return Center(child: Text('No New Notifications'));
            }
          }),
    );
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
