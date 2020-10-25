import 'package:flutter/material.dart';

import '../routes/router.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/home_screen.dart';
import '../values/values.dart';

class CustomFloatingButton extends StatefulWidget {
  final CurrentScreen currentScreen;
  CustomFloatingButton(this.currentScreen);
  @override
  _CustomFloatingButtonState createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton>
    with SingleTickerProviderStateMixin {
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen;
  int currentTab;
  AnimationController _controller;

//  final double pi = math.pi;
  final double tilt90Degrees = 360;
  double angle = 0;

  bool get _isPanelVisible {
    return angle == tilt90Degrees ? true : false;
  }

  @override
  initState() {
    super.initState();
    print("init runs");
    currentScreen = widget.currentScreen?.currentScreen ?? HomeScreen();
    currentTab = widget.currentScreen?.tab_no ?? 0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
//      value: 1,
      vsync: this,
    );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  changeScreen({
    @required Widget currentScreen,
    @required int currentTab,
  }) {
    setState(() {
      this.currentScreen = currentScreen;
      this.currentTab = currentTab;
    });
  }

  void changeAngle() {
    if (angle == 0) {
      setState(() {
        angle = tilt90Degrees;
      });
    } else {
      setState(() {
        angle = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: AnimatedBuilder(
        animation: _controller,
        child: angle == 0
            ? Icon(
                Icons.shopping_cart,
                size: 36,
                color: AppColors.white,
              )
            : Icon(
                Icons.shopping_cart,
                size: 36,
                color: AppColors.white,
              ),
        builder: (context, child) => Transform.rotate(
          angle: angle,
          child: child,
        ),
      ),
      backgroundColor: AppColors.secondaryElement,
      elevation: 8.0,
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return BookmarksScreen();
        }));
      },
    );
  }
}
