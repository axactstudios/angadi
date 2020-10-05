import 'package:angadi/utils/my_shared_prefs.dart';
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

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
                child: Image.asset(
                  ImagePath.boiledEggs,
                  height: heightOfScreen,
                  width: widthOfScreen,
                  fit: BoxFit.cover,
                ),
              ),
              DarkOverLay(),
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 36,
                child: ListView(
                  children: <Widget>[
                    _buildHeader(),
                    SizedBox(height: Sizes.HEIGHT_200),
                    _buildForm(),
                    SpaceH36(),
                    _buildFooter()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(top: Sizes.MARGIN_60),
        child: Text(
          StringConst.FOODY_BITE,
          textAlign: TextAlign.center,
          style: Styles.titleTextStyleWithSecondaryTextColor,
        ),
      ),
    );
  }

  TextEditingController mail = new TextEditingController();

  TextEditingController password = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Widget _buildForm() {
    return Form(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Sizes.MARGIN_48),
        child: Column(
          children: <Widget>[
            CustomTextFormField(
              hasPrefixIcon: true,
              prefixIconImagePath: ImagePath.emailIcon,
              hintText: StringConst.HINT_TEXT_EMAIL,
              controller: mail,
            ),
            SpaceH16(),
            CustomTextFormField(
              hasPrefixIcon: true,
              prefixIconImagePath: ImagePath.passwordIcon,
              hintText: StringConst.HINT_TEXT_PASSWORD,
              controller: password,
              obscured: true,
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () =>
                    R.Router.navigator.pushNamed(R.Router.forgotPasswordScreen),
                child: Container(
                  margin: EdgeInsets.only(top: Sizes.MARGIN_16),
                  child: Text(
                    StringConst.FORGOT_PASSWORD_QUESTION,
                    textAlign: TextAlign.right,
                    style: Styles.customNormalTextStyle(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: <Widget>[
        angadiButton(StringConst.LOGIN, onTap: () {
          _signIn(mail.text, password.text);
        }),
        SizedBox(height: Sizes.HEIGHT_60),
        InkWell(
          onTap: () => R.Router.navigator.pushNamed(R.Router.registerScreen),
          child: Container(
            width: Sizes.WIDTH_150,
            height: Sizes.HEIGHT_24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  StringConst.CREATE_NEW_ACCOUNT,
                  textAlign: TextAlign.center,
                  style: Styles.customNormalTextStyle(),
                ),
                Spacer(),
                Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  decoration: Decorations.horizontalBarDecoration,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signIn(String email, String pw) {
    _auth
        .signInWithEmailAndPassword(email: email, password: pw)
        .then((authResult) async {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      if (user.isEmailVerified) {
        MySharedPreferences msp = new MySharedPreferences();
        msp.saveText('status', 'loggedin');
        R.Router.navigator.pushNamedAndRemoveUntil(
          R.Router.rootScreen,
          (Route<dynamic> route) => false,
        );
      } else {
        Fluttertoast.showToast(
            msg: 'Please verify your email to sign in',
            toastLength: Toast.LENGTH_SHORT);
      }
    }).catchError(
      (err) {
        print(err);
        if (err.code == 'ERROR_USER_NOT_FOUND') {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text(
                      'This email is not yet registered. Create an account.'),
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
        if (err.code == 'ERROR_WRONG_PASSWORD') {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'Password is incorrect. Please enter correct password.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        }
        if (err.code == 'ERROR_NETWORK_REQUEST_FAILED') {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'Your internet connection is either not available or too slow.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        }
      },
    );
  }
}
