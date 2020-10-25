import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../values/values.dart';

//factcheck,rule
List<PersistentBottomNavBarItem> navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(Icons.home),
    title: ("Home"),
    activeColor: AppColors.secondaryElement,
    inactiveColor: Colors.black87,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.category_rounded),
    title: ("Categories"),
    activeColor: AppColors.secondaryElement,
    inactiveColor: Colors.black87,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.search),
    title: ("Search"),
    activeColor: AppColors.secondaryElement,
    inactiveColor: Colors.black87,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.notifications),
    title: ("Notifications"),
    activeColor: AppColors.secondaryElement,
    inactiveColor: Colors.black87,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.settings),
    title: ("Settings"),
    activeColor: AppColors.secondaryElement,
    inactiveColor: Colors.black87,
  ),
];
