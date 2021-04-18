import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as p;

import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_app_bar.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String whatsappMessage = '';
  @override
  void initState() {
    getUserDetails();

    setState(() {
      final firestoreInstance = Firestore.instance;

      firestoreInstance
          .collection("WhatsappMessage")
          .getDocuments()
          .then((querySnapshot) {
        querySnapshot.documents.forEach((result) {
          whatsappMessage = result.data['WhatsappMessage'];
          print('Whatsapp Message ${result.data['WhatsappMessage']}');
        });
      });
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String name, email, url, phone;
  getUserDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print('================$user');
    Firestore.instance
        .collection('Users')
        .where('id', isEqualTo: user.uid)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          name = element['Name'];
          email = element['mail'];
          url = element['pUrl'];
          phone = element['phone'];
          nameCtrl.text = name;
          phoneCtrl.text = phone;
          emailCtrl.text = email;
        });
      });
    });
    await print('=====${nameCtrl.text}');
  }

  TextEditingController nameCtrl = new TextEditingController(),
      emailCtrl = new TextEditingController(),
      phoneCtrl = new TextEditingController();
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
  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var hintTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.secondaryElement,
          actions: [
            InkWell(
                onTap: () {
                  _launchURL('tel:+919027553376');
                },
                child: Icon(Icons.phone, color: Color(0xFF6b3600))),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
                  FlutterOpenWhatsapp.sendSingleMessage("+971 50 7175406", "");
                },
                child: Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.whatsapp,
                        color: Color(0xFF6b3600)))),
            SizedBox(width: 8),
            InkWell(
                onTap: () {
//                print(1);
                  _launchURL(
                      'mailto:info@angadi.ae?subject=Complaint/Feedback&body=Type your views here.');
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
        body: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: Sizes.MARGIN_20, vertical: Sizes.MARGIN_20),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Positioned(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          url == null ? 'https://picsum.photos/200' : url),
                      minRadius: 70.0,
                      maxRadius: 70.0,
                    ),
                  ),
                  Positioned(
                    left: 90,
                    top: 94,
                    child: InkWell(
                      onTap: () {
                        filePicker(context, this, _scaffoldKey);
                      },
                      child: Image.asset(
                        ImagePath.uploadIcon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 1),
              CustomTextFormField(
                hasPrefixIcon: true,
                prefixIconImagePath: ImagePath.personIcon,
                textFormFieldStyle: textFormFieldTextStyle,
                hintText: "Name",
                prefixIconColor: AppColors.secondaryElement,
                hintTextStyle: hintTextStyle,
                borderStyle: BorderStyle.solid,
                borderWidth: Sizes.WIDTH_1,
                controller: nameCtrl,
              ),
              SpaceH20(),
              CustomTextFormField(
                hasPrefixIcon: true,
                prefixIconImagePath: ImagePath.emailIcon,
                textFormFieldStyle: textFormFieldTextStyle,
                hintText: "Email",
                hintTextStyle: hintTextStyle,
                borderStyle: BorderStyle.solid,
                borderWidth: Sizes.WIDTH_1,
                controller: emailCtrl,
                prefixIconColor: AppColors.secondaryElement,
              ),
              SpaceH20(),
              CustomTextFormField(
                hasPrefixIcon: true,
                prefixIconImagePath: 'assets/images/call_icon.png',
                textFormFieldStyle: textFormFieldTextStyle,
                hintText: "Phone Number",
                hintTextStyle: hintTextStyle,
                borderStyle: BorderStyle.solid,
                borderWidth: Sizes.WIDTH_1,
                controller: phoneCtrl,
                prefixIconColor: AppColors.secondaryElement,
              ),
              Spacer(flex: 1),
              InkWell(
                onTap: () {
                  _updateUser();
                },
                child: angadiButton(
                  "Update",
                  buttonWidth: MediaQuery.of(context).size.width,
                  onTap: () => R.Router.navigator.pop(),
                ),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  File file;
  ProgressDialog pr;

  bool _isLoading = false;

  double _progress = 0;

  String fileName = '';
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

    Fluttertoast.showToast(
        msg: 'Upload Complete', gravity: ToastGravity.BOTTOM);
    state.setState(() async {
      url = (await downloadUrl.ref.getDownloadURL());
      print("URL is $url");
      await pr.hide();
    });
  }

  _updateUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.updateEmail(emailCtrl.text);
    final databaseReference = Firestore.instance;
    await databaseReference.collection('Users').add({
      'Name': nameCtrl.text,
      'id': user.uid,
      'phone': phoneCtrl.text,
      'mail': emailCtrl.text,
      'pUrl': url
    });
    Navigator.pop(context);
  }

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
