import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/screens/home_screen.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/ratings_widget.dart';
import 'package:angadi/widgets/search_card.dart';
import 'package:angadi/widgets/search_input_field.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NewReviewScreen extends StatefulWidget {
  static const int TAB_NO = 4;

  @override
  _NewReviewScreenState createState() => _NewReviewScreenState();
}

class _NewReviewScreenState extends State<NewReviewScreen> {
  String nameGlb, emailGlb, urlGlb, idGlb;
  TextEditingController contrl = new TextEditingController();

  getUserDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String name, email, url, id;

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
          id = user.uid;
          print(contrl.text);
          final firestoreInstance = Firestore.instance;
          firestoreInstance.collection("Reviews").add({
            "userName": name,
            "userImage": url,
            "userID": id,
            "rating": ratingGlobal,
//            "details": contrl.text,
            "dishName": 'Idli Batter'
          }).then((value) {
            print(value.documentID);
          });

          Fluttertoast.showToast(
              msg: 'Review Added', toastLength: Toast.LENGTH_SHORT);
          R.Router.navigator.pushNamedAndRemoveUntil(
            R.Router.rootScreen,
            (Route<dynamic> route) => false,
            arguments: CurrentScreen(
              tab_no: HomeScreen.TAB_NO,
              currentScreen: HomeScreen(),
            ),
          );
        });
      });
    });
//    await contrl.clear();
  }

  TextEditingController controller = TextEditingController();
  bool showSuffixIcon = false;
  bool hasRestaurantBeenAdded = false;
  bool isCardShowing = false;
  bool canPost = false;

  TextStyle subTitleTextStyle = Styles.customNormalTextStyle(
    color: AppColors.accentText,
    fontSize: Sizes.TEXT_SIZE_16,
  );
  var ratingGlobal = '1';

  void postReview() async {
    await getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68.0),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: Sizes.MARGIN_16,
              vertical: Sizes.MARGIN_16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () => R.Router.navigator.pushNamedAndRemoveUntil(
                    R.Router.rootScreen,
                    (Route<dynamic> route) => false,
                    arguments: CurrentScreen(
                      tab_no: HomeScreen.TAB_NO,
                      currentScreen: HomeScreen(),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Cancel',
                        style: textTheme.body1.copyWith(
                          color: AppColors.accentText,
                          fontSize: Sizes.TEXT_SIZE_20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  "New Rating",
                  style: Styles.customTitleTextStyle(
                    color: AppColors.headingText,
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.TEXT_SIZE_22,
                  ),
                ),
                InkWell(
                  onTap: postReview,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Post',
                        style: textTheme.body1.copyWith(
                          color: canPost
                              ? AppColors.secondaryElement
                              : AppColors.accentText,
                          fontSize: Sizes.TEXT_SIZE_20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Sizes.MARGIN_16,
            vertical: Sizes.MARGIN_16,
          ),
          child: ListView(
            children: <Widget>[
//              FoodyBiteSearchInputField(
//                Icons.search,
//                controller: controller,
//                textFormFieldStyle:
//                    Styles.customNormalTextStyle(color: AppColors.accentText),
//                hintText: StringConst.HINT_TEXT_HOME_SEARCH_BAR,
//                hintTextStyle:
//                    Styles.customNormalTextStyle(color: AppColors.accentText),
//                hasSuffixIcon: showSuffixIcon,
//                suffixIcon: suffixIcon(),
//                suffixIconImagePath: Icons.sort,
//                borderWidth: 0.0,
//                onTapOfLeadingIcon: () {},
//                onTapOfSuffixIcon: () {
//                  controller.clear();
//                  changeState(
//                    showSuffixIcon: false,
//                    isCardShowing: false,
//                    hasRestaurantBeenAdded: false,
//                  );
//                },
//                borderStyle: BorderStyle.solid,
//                onChanged: (value) => _onChange(value),
//              ),
              isCardShowing ? SpaceH30() : Container(),
              isCardShowing
                  ? FoodyBiteSearchCard(
                      hasBeenAdded: hasRestaurantBeenAdded,
                      onPressed: () {
                        changeState(
                            hasRestaurantBeenAdded: true,
                            isCardShowing: true,
                            showSuffixIcon: true,
                            canPost: true);
                      },
                      onPressClose: () {
                        changeState(
                          isCardShowing: false,
                          hasRestaurantBeenAdded: false,
                          showSuffixIcon: true,
                        );
                      },
                    )
                  : Container(),
              SpaceH30(),
              Center(
                child: Text(
                  'Rating',
                  style: Styles.customTitleTextStyle(
                    color: AppColors.headingText,
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.TEXT_SIZE_20,
                  ),
                ),
              ),
              SpaceH16(),
              Container(
                width: MediaQuery.of(context).size.width - 60,
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.kFoodyBiteSkyBlue,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: RatingBar(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 48,
                    unratedColor: AppColors.kFoodyBiteGreyRatingStar,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        ratingGlobal = rating.toString();
                      });
                      print(rating);
                    },
                  ),
                ),
              ),
//              SpaceH12(),
//              Center(
//                child: Text(
//                  'Rate your experience',
//                  style: Styles.customNormalTextStyle(
//                    color: AppColors.accentText,
//                    fontSize: Sizes.TEXT_SIZE_16,
//                  ),
//                ),
//              ),
//              SpaceH30(),
//              _buildReview(context: context),
            ],
          ),
        ),
      ),
    );
  }

  void _onChange(String value) {
    if (value.length > 0) {
      changeState(showSuffixIcon: true, isCardShowing: true);
    } else {
      changeState(showSuffixIcon: false, isCardShowing: false);
    }
  }

  void changeState({
    bool showSuffixIcon = false,
    bool hasRestaurantBeenAdded = false,
    bool isCardShowing = false,
    bool canPost = false,
  }) {
    setState(() {
      this.showSuffixIcon = showSuffixIcon;
      this.hasRestaurantBeenAdded = hasRestaurantBeenAdded;
      this.isCardShowing = isCardShowing;
      this.canPost = canPost;
    });
  }

  Widget _buildReview({@required BuildContext context}) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(
          "Review",
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_20,
          ),
        ),
        SpaceH16(),
        CustomTextFormField(
          hasPrefixIcon: false,
          controller: contrl,
          maxLines: 10,
          hintText: "Write your experience",
          hintTextStyle: subTitleTextStyle,
          borderWidth: Sizes.WIDTH_1,
          borderRadius: Sizes.RADIUS_12,
          borderStyle: BorderStyle.solid,
          focusedBorderColor: AppColors.indigo,
          textFormFieldStyle: textTheme.body1,
          contentPaddingHorizontal: Sizes.MARGIN_16,
        ),
      ],
    );
  }

  Widget suffixIcon() {
    return Container(
      child: Icon(
        Icons.close,
        color: AppColors.indigo,
      ),
    );
  }
}
