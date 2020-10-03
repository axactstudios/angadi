import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/dark_overlay.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController mail = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var heightOfScreen = MediaQuery.of(context).size.height;
    var widthOfScreen = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0.0,
                child: Image.asset(
                  ImagePath.boiledEggs,
                  fit: BoxFit.cover,
                  height: heightOfScreen,
                  width: widthOfScreen,
                ),
              ),
              DarkOverLay(),
              Positioned(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: Sizes.MARGIN_24),
                  child: ListView(
                    children: [
                      SpaceH16(),
                      _buildAppBar(),
                      Container(
                        margin: EdgeInsets.only(top: Sizes.MARGIN_60),
                        child: Text(
                          StringConst.RESET_PASSWORD_DESCRIPTION,
                          textAlign: TextAlign.center,
                          style: Styles.customMediumTextStyle(),
                        ),
                      ),
                      SizedBox(height: Sizes.HEIGHT_60),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Sizes.MARGIN_16),
                        child: CustomTextFormField(
                          hasPrefixIcon: true,
                          prefixIconImagePath: ImagePath.emailIcon,
                          hintText: StringConst.HINT_TEXT_EMAIL,
                          controller: mail,
                        ),
                      ),
                      SizedBox(height: Sizes.HEIGHT_180),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Sizes.MARGIN_16,
                        ),
                        child: angadiButton(StringConst.SEND,
                            buttonWidth: widthOfScreen, onTap: () async {
                          await sendResetLink();
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        InkWell(
          onTap: () => R.Router.navigator.pop(),
          child: Padding(
            padding: const EdgeInsets.only(
              left: Sizes.MARGIN_12,
              right: Sizes.MARGIN_12,
              top: Sizes.MARGIN_4,
              bottom: Sizes.MARGIN_4,
            ),
            child: Image.asset(
              ImagePath.arrowBackIcon,
              fit: BoxFit.none,
            ),
          ),
        ),
        Spacer(),
        Text(
          StringConst.FORGOT_PASSWORD,
          style: Styles.customMediumTextStyle(),
        ),
        Spacer(),
      ],
    );
  }

  FirebaseAuth mAuth = FirebaseAuth.instance;
  sendResetLink() async {
    await mAuth
        .sendPasswordResetEmail(email: mail.text)
        .then((AuthResult) async {
      Fluttertoast.showToast(
          msg: 'Reset link has been sent!', toastLength: Toast.LENGTH_SHORT);
      R.Router.navigator.pushReplacementNamed(R.Router.loginScreen);
    }).catchError((err) {
      print(err);
      if (err.code == "ERROR_USER_NOT_FOUND") {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'This email is not yet registered. Please sign up first.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    });
  }
}
