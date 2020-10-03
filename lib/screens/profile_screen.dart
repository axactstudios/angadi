import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';

class ProfileScreen extends StatefulWidget {
  static const int TAB_NO = 3;

  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: Sizes.ELEVATION_0,
          centerTitle: true,
          title: Text(
            'Profile',
            style: Styles.customTitleTextStyle(
              color: AppColors.headingText,
              fontWeight: FontWeight.w600,
              fontSize: Sizes.TEXT_SIZE_22,
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: Sizes.MARGIN_8),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: url == null
                        ? AssetImage(ImagePath.andy)
                        : NetworkImage(url),
                    minRadius: Sizes.RADIUS_60,
                    maxRadius: Sizes.RADIUS_60,
                  ),
                  SpaceH8(),
                  Text(name == null ? 'John Williams' : name,
                      style: Styles.foodyBiteTitleTextStyle),
                  SpaceH8(),
                  Text(email == null ? 'john.williams@gmail.com' : email,
                      style: Styles.foodyBiteSubtitleTextStyle),
                ],
              ),
              // SpaceH24(),
              // IntrinsicHeight(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       detail(number: "250", text: "Reviews"),
              //       VerticalDivider(
              //         width: Sizes.WIDTH_40,
              //         thickness: 1.0,
              //       ),
              //       detail(number: "100k", text: "Followers"),
              //       VerticalDivider(
              //         width: Sizes.WIDTH_40,
              //         thickness: 1.0,
              //       ),
              //       detail(number: "30", text: "Following"),
              //       SpaceH24(),
              //     ],
              //   ),
              // ),
              SpaceH24(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  angadiButton(
                    'Edit Profile',
                    onTap: () => R.Router.navigator
                        .pushNamed(R.Router.editProfileScreen),
                    buttonWidth: MediaQuery.of(context).size.width / 3,
                    buttonHeight: Sizes.HEIGHT_50,
                  ),
                  SpaceW16(),
                  angadiButton(
                    'Settings',
                    onTap: () =>
                        R.Router.navigator.pushNamed(R.Router.settingsScreen),
                    buttonWidth: MediaQuery.of(context).size.width / 3,
                    buttonHeight: Sizes.HEIGHT_50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      border: Border.all(color: AppColors.indigo),
                      borderRadius: BorderRadius.all(
                        Radius.circular(Sizes.RADIUS_8),
                      ),
                    ),
                    buttonTextStyle: Styles.customNormalTextStyle(
                      color: AppColors.accentText,
                      fontSize: Sizes.TEXT_SIZE_16,
                    ),
                  ),
                ],
              ),
              Divider(
                height: Sizes.HEIGHT_40,
                thickness: 3.0,
                color: Colors.grey[200],
              ),
              // Column(
              //   children: <Widget>[
              //     FoodyBiteCard(
              //       imagePath: ImagePath.dinnerIsServed,
              //       status: StringConst.STATUS_OPEN,
              //       cardTitle: "Gramercy Tavern",
              //       category: StringConst.ITALIAN,
              //       distance: "12 km",
              //       address: "394 Broome St, New York, NY 10013, USA",
              //       isThereStatus: false,
              //       onTap: () {},
              //     ),
              //     SpaceH16(),
              //     FoodyBiteCard(
              //       imagePath: ImagePath.breakfastInBed,
              //       status: StringConst.STATUS_OPEN,
              //       cardTitle: "Happy Bones",
              //       category: StringConst.ITALIAN,
              //       distance: "12 km",
              //       address: "394 Broome St, New York, NY 10013, USA",
              //       isThereStatus: false,
              //       onTap: () {},
              //     ),
              //   ],
              // ),
              Center(child: Text('No Recent Orders'))
            ],
          ),
        ));
  }

  Widget detail({@required String number, @required String text}) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            number,
            style: Styles.customNormalTextStyle(
                color: AppColors.secondaryElement,
                fontWeight: FontWeight.w600,
                fontSize: Sizes.TEXT_SIZE_18),
          ),
          SizedBox(height: 8.0),
          Text(text, style: Styles.foodyBiteSubtitleTextStyle),
        ],
      ),
    );
  }

  String name, email, url;
  getUserDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
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
        });
      });
    });
  }
}
