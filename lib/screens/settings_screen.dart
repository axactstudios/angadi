import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_app_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
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

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
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
                launch(Uri.encodeFull('tel:+971 50 7175406'));
              },
              child: Icon(Icons.phone, color: Color(0xFF6b3600))),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
  launch(Uri.encodeFull("https://wa.me/971507175406"));
},
              child: Container(
                  alignment: Alignment.center,
                  child: FaIcon(FontAwesomeIcons.whatsapp,
                      color: Color(0xFF6b3600)))),
          SizedBox(width: 8),
          InkWell(
              onTap: () {
                launch(Uri.encodeFull(
                    "mailto:info@angadi.ae?subject=Complaint/Feedback&body=Type your views here."));
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
      body: Column(
        children: <Widget>[
          _buildAccountSettings(context: context),
          _buildOtherSettings(context: context),
        ],
      ),
    );
  }

  Widget _buildAccountSettings({@required BuildContext context}) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.secondaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.MARGIN_16,
              vertical: Sizes.MARGIN_16,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  "Account",
                  style: textTheme.title.copyWith(
                    fontSize: Sizes.TEXT_SIZE_16,
                    color: AppColors.indigoShade1,
                  ),
                ),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: ListTile.divideTiles(
              context: context,
              tiles: <Widget>[
                SettingsListTile(
                  title: "Change Password",
                  onTap: () => R.Router.navigator
                      .pushNamed(R.Router.changePasswordScreen),
                ),
//                SettingsListTile(
//                  title: "Change Language",
//                  onTap: () => R.Router.navigator
//                      .pushNamed(R.Router.changeLanguageScreen),
//                )
              ],
            ).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildOtherSettings({@required BuildContext context}) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.secondaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.MARGIN_16,
              vertical: Sizes.MARGIN_16,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  "Others",
                  style: textTheme.title.copyWith(
                    fontSize: Sizes.TEXT_SIZE_16,
                    color: AppColors.indigoShade1,
                  ),
                ),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: ListTile.divideTiles(
              context: context,
              tiles: <Widget>[
                SettingsListTile(
                  title: "Privacy Policy",
                  onTap: () {
                    launch('https://www.misteridli.com/privacy-policy/');
                  },
                ),
                SettingsListTile(
                  title: "Terms & Conditions",
                  onTap: () {
                    launch('https://www.misteridli.com/terms-and-conditions/');
                  },
                ),
                SettingsListTile(
                  title: "Logout",
                  titleColor: AppColors.secondaryElement,
                  hasTrailing: false,
                  onTap: () => _logoutDialog(context),
                ),
              ],
            ).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildAlertDialog(context);
      },
    );
  }

  Widget _buildAlertDialog(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(Sizes.RADIUS_32),
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(
          Sizes.PADDING_0,
          Sizes.PADDING_36,
          Sizes.PADDING_0,
          Sizes.PADDING_0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
        ),
        elevation: Sizes.ELEVATION_4,
        content: Container(
          height: Sizes.HEIGHT_150,
          width: Sizes.WIDTH_300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: Text(
                    'Are you sure you want to Logout ?',
                    style: textTheme.title.copyWith(
                      fontSize: Sizes.TEXT_SIZE_16,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Row(
                children: <Widget>[
                  AlertDialogButton(
                    buttonText: "No",
                    width: Sizes.WIDTH_150,
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: AppColors.greyShade1,
                      ),
                      right: BorderSide(
                        width: 1,
                        color: AppColors.greyShade1,
                      ),
                    ),
                    textStyle:
                        textTheme.button.copyWith(color: AppColors.accentText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  AlertDialogButton(
                      buttonText: "Yes",
                      width: Sizes.WIDTH_150,
                      border: Border(
                        top: BorderSide(
                          width: 1,
                          color: AppColors.greyShade1,
                        ),
                      ),
                      textStyle: textTheme.button
                          .copyWith(color: AppColors.secondaryElement),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        R.Router.navigator.pushNamedAndRemoveUntil(
                          R.Router.loginScreen,
                          (Route<dynamic> route) => false,
                        );
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  SettingsListTile({
    this.title,
    this.titleColor = AppColors.primaryText,
    this.iconData = Icons.arrow_forward_ios,
    this.onTap,
    this.hasTrailing = true,
  });

  final String title;
  final Color titleColor;
  final IconData iconData;
  final GestureTapCallback onTap;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            vertical: Sizes.PADDING_4, horizontal: Sizes.PADDING_16),
        title: Container(
          margin: const EdgeInsets.only(bottom: Sizes.MARGIN_8),
          child: Text(
            title,
            style: textTheme.title
                .copyWith(fontSize: Sizes.TEXT_SIZE_16, color: titleColor),
          ),
        ),
        trailing: hasTrailing ? Icon(iconData, color: AppColors.indigo) : null,
      ),
    );
  }
}

class AlertDialogButton extends StatelessWidget {
  AlertDialogButton({
    @required this.buttonText,
    this.textStyle,
    this.border,
    this.width,
    this.onPressed,
  });

  final TextStyle textStyle;
  final String buttonText;
  final VoidCallback onPressed;
  final Border border;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: border,
      ),
      child: FlatButton(
        child: Text(
          buttonText,
          style: textStyle,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
