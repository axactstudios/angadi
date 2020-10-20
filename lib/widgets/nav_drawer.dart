import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/components/drawer/gf_drawer.dart';

Widget retNavDrawer() {
  return GFDrawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          height: 50,
          child: Container(
              // color: Color(0xFF3871AD),
              ),
        ),
        // Container(
        //   margin: EdgeInsets.symmetric(horizontal: 20),
        //   height: 0.5,
        //   color: Colors.black26,
        // ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              'Home',
              style: TextStyle(
                fontSize: 20,
                // fontFamily: 'nunito',
              ),
            ),
          ),
          onTap: () {
            // UrlLauncher.launch(
            //     "https://www.youtube.com/playlist?list=PLKe-Zuux9p9vWWUVGyY5SPMO6MpRDjZ5x");
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 0.5,
          color: Colors.black26,
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              'Offers',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onTap: () {
            // UrlLauncher.launch(
            //     "https://www.youtube.com/playlist?list=PLKe-Zuux9p9vWWUVGyY5SPMO6MpRDjZ5x");
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 0.5,
          color: Colors.black26,
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              'Shop By Category',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onTap: () {
            // UrlLauncher.launch(
            //     "https://www.youtube.com/playlist?list=PLKe-Zuux9p9vWWUVGyY5SPMO6MpRDjZ5x");
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 0.5,
          color: Colors.black26,
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              'Customer Service',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onTap: () {
            // UrlLauncher.launch(
            //     "https://www.youtube.com/playlist?list=PLKe-Zuux9p9vWWUVGyY5SPMO6MpRDjZ5x");
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 0.5,
          color: Colors.black26,
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onTap: () {
            // UrlLauncher.launch(
            //     "https://www.youtube.com/playlist?list=PLKe-Zuux9p9vWWUVGyY5SPMO6MpRDjZ5x");
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 0.5,
          color: Colors.black26,
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              'FAQs',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          onTap: () {
            // UrlLauncher.launch(
            //     "https://www.youtube.com/playlist?list=PLKe-Zuux9p9vWWUVGyY5SPMO6MpRDjZ5x");
          },
        ),
      ],
    ),
  );
}
