import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../values/values.dart';

//factcheck,rule
List<PersistentBottomNavBarItem> navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(Icons.home),
    title: ("Home"),
    activeColor: Color(0xFF6b3600),
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.category),
    title: ("Categories"),
    activeColor: Color(0xFF6b3600),
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.search),
    title: ("Search"),
    activeColor: Color(0xFF6b3600),
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.notifications),
    title: ("Notifications"),
    activeColor: Color(0xFF6b3600),
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.person),
    title: ("Settings"),
    activeColor: Color(0xFF6b3600),
    inactiveColor: Colors.white,
  ),
];
