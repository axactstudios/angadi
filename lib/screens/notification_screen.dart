import 'package:flutter/material.dart';
import 'package:angadi/values/values.dart';

class NotificationsScreen extends StatefulWidget {
  static const int TAB_NO = 2;

  NotificationsScreen({Key key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationInfo> notifications = [
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
    NotificationInfo(
      // imageUrl: ImagePath.branson,
      title: "Order No:- 23465",
      time: "5:30 am",
      subtitle: "Order is being Prepared",
    ),
  ];

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
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: Sizes.MARGIN_8, vertical: Sizes.MARGIN_16),
        child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                // leading: Image.asset(notifications[index].imageUrl),
                onTap: () {},
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      notifications[index].title,
                      style: Styles.customTitleTextStyle(
                        color: AppColors.headingText,
                        fontWeight: FontWeight.w400,
                        fontSize: Sizes.TEXT_SIZE_20,
                      ),
                    ),
                    Text(
                      notifications[index].time,
                      style: Styles.customNormalTextStyle(
                        color: AppColors.accentText,
                        fontSize: Sizes.TEXT_SIZE_14,
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(top: 8.0),
                  child: Text(
                    notifications[index].subtitle,
                    style: Styles.customNormalTextStyle(
                      color: AppColors.accentText,
                      fontSize: Sizes.TEXT_SIZE_14,
                    ),
                  ),
                ),
              );
            }),
      ),
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
