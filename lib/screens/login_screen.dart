import 'package:angadi/screens/home_screen.dart';
import 'package:angadi/screens/root_screen.dart';
import 'package:angadi/utils/my_shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/dark_overlay.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';

import 'package:getwidget/types/gf_loader_type.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:progress_dialog/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final databaseReference = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  List<dynamic> dToken = ['test_token'];
  List<dynamic> dTokens = ['test_token'];
  _getTokenList() {
    databaseReference
        .collection('Users')
        .where('mail', isEqualTo: mail.text)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        dToken = element['dTokens'];
      });
    });
  }

  _updateTokenList() {
    databaseReference
        .collection('Users')
        .where('mail', isEqualTo: mail.text)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        await databaseReference
            .collection('Users')
            .document(element.documentID)
            .updateData({'dTokens': dToken});
      });
    });
  }

  _getToken() async {
    await _getTokenList();
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        if (dToken != null) {
          if (dToken.contains(token)) {
            print('Token already saved');
          } else {
            dToken.add(token);
            _updateTokenList();
          }
        } else {
          dToken = ['test_token'];

          dToken.add(token);
          _updateTokenList();
        }
      });
      print("Device Token: $dToken");
    });
  }

  List<dynamic> toList() {
    dToken.forEach((item) {
      dTokens.add(item.toString());
    });

    return dTokens.toList();
  }

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
                  ImagePath.splashImage,
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
                    SizedBox(height: 60),
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

  int j = 0;
  int length = 0;
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final ProgressDialog pr = await ProgressDialog(context);
    pr.style(
        message: 'Logging in..',
        backgroundColor: Colors.white,
        progressWidget: GFLoader(
          type: GFLoaderType.ios,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    await pr.show();
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');
      Firestore.instance.collection('Users').snapshots().forEach((element) {
        length = element.documents.length;
        print(length);
        for (int i = 0; i < element.documents.length; i++) {
          if (element.documents[i]['mail'] != googleSignIn.currentUser.email) {
            print(element.documents[i]['mail']);
            j++;
            print(j.toString());
          }
        }
        if (j == length) {
          List<String>titles=[];
          Firestore.instance
              .collection('Users')
              .document(currentUser.uid)
              .setData({
            'Name': googleSignIn.currentUser.displayName,
            'id': currentUser.uid,
            'mail': googleSignIn.currentUser.email,
            'pUrl': googleSignIn.currentUser.photoUrl,
            'couponUsed':titles,
            'role': 'user'
          });
        }
      });

      await pr.hide();
      return '$user';
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
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

  Widget _signInButton() {
    return Container(
      width: 300,
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          signInWithGoogle().then((result) {
            if (result != null) {
              _getToken();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return RootScreen();
                  },
                ),
              );
            }
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                  image: AssetImage("assets/images/google.png"), height: 35.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: <Widget>[
        angadiButton(StringConst.LOGIN, onTap: () {
          _getToken();
          _signIn(mail.text, password.text);
        }),
        SizedBox(
          height: Sizes.HEIGHT_20,
        ),
        _signInButton(),
        SizedBox(height: Sizes.HEIGHT_60),
        InkWell(
          onTap: () => R.Router.navigator.pushNamed(R.Router.registerScreen),
          child: Container(
            width: Sizes.WIDTH_150,
            height: 50,
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
