import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/dark_overlay.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:location/location.dart';
import 'dart:io' show Platform;

class SetLocationScreen extends StatefulWidget {
  final String name;
  SetLocationScreen(this.name);
  @override
  _SetLocationScreenState createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  Location location = new Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    print(_serviceEnabled);
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.GRANTED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var heightOfScreen = MediaQuery.of(context).size.height;
    var widthOfScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: Decorations.regularDecoration,
        child: Stack(
          children: [
            Positioned(
              child: Image.asset(
                ImagePath.splashImage,
                fit: BoxFit.cover,
                height: heightOfScreen,
                width: widthOfScreen,
              ),
            ),
            DarkOverLay(
              gradient: Gradients.fullScreenOverGradient,
            ),
            Positioned(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: Sizes.MARGIN_16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SpaceH40(),
                    Align(
                      alignment: Alignment.topRight,
                      child: !Platform.isIOS
                          ? _serviceEnabled
                              ? _buildSkipButton('Next')
                              : Container()
                          : _buildSkipButton('Skip'),
                    ),
                    SpaceH200(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Hi there,',
                          textAlign: TextAlign.left,
                          style: Styles.customTitleTextStyle(
                            fontSize: Sizes.TEXT_SIZE_32,
                          ),
                        ),
                        SpaceH16(),
                        RichText(
                          text: TextSpan(
                            style: Styles.customTitleTextStyle(
                              fontSize: Sizes.TEXT_SIZE_32,
                            ),
                            children: [
                              TextSpan(text: StringConst.WELCOME_MESSAGE + " "),
                              TextSpan(
                                text: StringConst.FOODY_BITE,
                                style: Styles.customTitleTextStyle(
                                  fontSize: 32,
                                  color: AppColors.kFoodyBiteYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      child: Text(
                        StringConst.TURN_GPS_DESCRIPTION,
                        textAlign: TextAlign.left,
                        style: Styles.customMediumTextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Spacer(),
                    angadiButton(
                      StringConst.TURN_GPS,
                      buttonWidth: widthOfScreen,
                      onTap: () async {
                        await getLocation();

                        R.Router.navigator.pushNamedAndRemoveUntil(
                          R.Router.rootScreen,
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(btnText) {
    return InkWell(
      onTap: () {
        R.Router.navigator.pushNamedAndRemoveUntil(
          R.Router.rootScreen,
          (Route<dynamic> route) => false,
        );
      },
      child: Container(
        width: 80,
        height: 40,
        decoration: Decorations.customDecoration(
          color: AppColors.fillColor,
        ),
        child: Center(
          child: Text(
            btnText,
            textAlign: TextAlign.center,
            style: Styles.customNormalTextStyle(),
          ),
        ),
      ),
    );
  }
}
