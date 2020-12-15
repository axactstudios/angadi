import 'dart:io';

import 'package:angadi/routes/router.gr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/dark_overlay.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
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
        key: _scaffoldKey,
        body: Container(
          decoration: Decorations.regularDecoration,
          child: Stack(
            children: [
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
                bottom: 40,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: Sizes.MARGIN_40),
                  child: ListView(
                    children: [
                      SpaceH36(),
                      _buildProfileSelector(context, this, _scaffoldKey),
                      SpaceH16(),
                      _buildForm(),
                      SpaceH40(),
                      angadiButton(
                        StringConst.REGISTER,
                        onTap: () async {
                          await _createUser(mail.text, password.text, context);
                        },
                      ),
                      SpaceH40(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            StringConst.HAVE_AN_ACCOUNT_QUESTION,
                            textAlign: TextAlign.right,
                            style: Styles.customNormalTextStyle(),
                          ),
                          SpaceW16(),
                          InkWell(
                            onTap: () => R.Router.navigator
                                .pushReplacementNamed(R.Router.loginScreen),
                            child: Text(
                              StringConst.LOGIN,
                              textAlign: TextAlign.left,
                              style: Styles.customNormalTextStyle(
                                color: AppColors.secondaryElement,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildProfileSelector(context, state, skey) {
    return Center(
        child: file == null
            ? Container(
                width: 150,
                height: 150,
                margin: EdgeInsets.only(top: 28),
                decoration: BoxDecoration(
                  color: AppColors.fillColor,
                  border: Border.all(
                    width: 1,
                    color: Color.fromARGB(125, 0, 0, 0),
                  ),
                  boxShadow: [
                    Shadows.secondaryShadow,
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(76)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    Center(
                        child: Image.asset(
                      ImagePath.personIconMedium,
                      fit: BoxFit.none,
                    )),
                    InkWell(
                      onTap: () {
                        filePicker(context, state, skey);
                      },
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          ImagePath.uploadIcon,
                          fit: BoxFit.none,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : CircleAvatar(
                radius: 70,
                backgroundImage: FileImage(file),
              ));
  }

  TextEditingController name = new TextEditingController();

  TextEditingController mail = new TextEditingController();

  TextEditingController password = new TextEditingController();

  TextEditingController cpassword = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CustomTextFormField(
            hasPrefixIcon: true,
            prefixIconImagePath: ImagePath.personIcon,
            hintText: StringConst.HINT_TEXT_NAME,
            controller: name,
          ),
          SpaceH16(),
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
            obscured: true,
            controller: password,
          ),
          SpaceH16(),
          CustomTextFormField(
            hasPrefixIcon: true,
            prefixIconImagePath: ImagePath.passwordIcon,
            hintText: StringConst.HINT_TEXT_CONFIRM_PASSWORD,
            obscured: true,
            controller: cpassword,
          ),
        ],
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _createUser(String email, String pw, context) {
    password.text == cpassword.text
        ? _auth
            .createUserWithEmailAndPassword(email: email, password: pw)
            .then((authResult) async {
            FirebaseUser user = await FirebaseAuth.instance.currentUser();
            user.sendEmailVerification();
            Fluttertoast.showToast(
                msg: 'Verification link has been sent to your email address!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER);

            final databaseReference = Firestore.instance;
            await databaseReference.collection('Users').add({
              'Name': name.text,
              'id': user.uid,
              'mail': mail.text,
              'pUrl': url
            });
            setState(() {
              n = name.text;
            });
            name.clear();
            mail.clear();
            password.clear();
            cpassword.clear();
            R.Router.navigator.pushNamed(R.Router.setLocationScreen);
//      FirebaseAuth.instance.signOut();

//      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
//        return new MaterialApp(
//          theme: ThemeData(
//            scaffoldBackgroundColor: Colors.white,
//            primaryColor: Colors.white,
//          ),
//          home: HomeScreen(),
//        );
//      }));
          }).catchError((err) {
            print(err);
            if (err.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('This email is already in use'),
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
            if (err.code == 'ERROR_MISSING_EMAIL') {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('Please Enter Email'),
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
            if (err.code == 'ERROR_WEAK_PASSWORD') {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('Password should be of 6 or more characters'),
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
            if (err.code == 'ERROR_INVALID_EMAIL') {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('Enter a valid email.'),
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
          })
        : showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Passwords don\'t match!'),
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

  ProgressDialog pr;

  bool _isLoading = false;

  double _progress = 0;

  String url;

  void _uploadFile(File file, String filename, context, state, key) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://angadi-9c0e9.appspot.com/');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    StorageReference storageReference;
    storageReference = _storage
        .ref()
        .child("Users/${DateTime.now().millisecondsSinceEpoch}/profileImage");

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
    );
    pr.style(
      progressWidget: CircularProgressIndicator(),
      message: 'Uploading photo...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    await pr.show();
    uploadTask.events.listen((event) {
      state.setState(() {
        _isLoading = true;
        _progress = (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble()) *
            100;
        print('${_progress.toStringAsFixed(2)}%');
        pr.update(
          progress: double.parse(_progress.toStringAsFixed(2)),
          maxProgress: 100.0,
        );
      });
    }).onError((error) {
      key.currentState.showSnackBar(new SnackBar(
        content: new Text(error.toString()),
        backgroundColor: Colors.red,
      ));
    });

    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    url = (await downloadUrl.ref.getDownloadURL());

    Fluttertoast.showToast(
        msg: 'Upload Complete', gravity: ToastGravity.BOTTOM);
    state.setState(() async {
      print("URL is $url");
      await pr.hide();
    });
  }

  File file;

  String fileName = '';

  Future filePicker(BuildContext context, state, key) async {
    try {
      print(1);
      file = await ImagePicker.pickImage(source: ImageSource.gallery);
      print(1);
      state.setState(() {
        fileName = p.basename(file.path);
      });
      print(fileName);
      Fluttertoast.showToast(msg: 'Uploading...', gravity: ToastGravity.BOTTOM);
      state.setState(() {});
      _uploadFile(file, fileName, context, state, key);
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }
}
