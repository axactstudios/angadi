import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_app_bar.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:angadi/widgets/spaces.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final pass = TextEditingController();
  final confirmPass = TextEditingController();
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: CustomAppBar(
            title: "Change Password",
            trailing: <Widget>[
              InkWell(
                onTap: () => R.Router.navigator.pop(),
                child: Center(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Cancel',
                      style: textTheme.body1.copyWith(
                          color: AppColors.accentText,
                          fontSize: Sizes.TEXT_SIZE_20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: Sizes.MARGIN_20, vertical: Sizes.MARGIN_20),
          child: Column(
            children: <Widget>[
              CustomTextFormField(
                hasPrefixIcon: true,
                prefixIconImagePath: ImagePath.passwordIcon,
                textFormFieldStyle: textFormFieldTextStyle,
                hintText: "Current Password",
                prefixIconColor: AppColors.indigo,
                hintTextStyle: hintTextStyle,
                borderStyle: BorderStyle.solid,
                borderWidth: Sizes.WIDTH_1,
                obscured: true,
              ),
              SpaceH20(),
              CustomTextFormField(
                controller: pass,
                hasPrefixIcon: true,
                prefixIconImagePath: ImagePath.passwordIcon,
                textFormFieldStyle: textFormFieldTextStyle,
                hintText: "New Password",
                hintTextStyle: hintTextStyle,
                borderStyle: BorderStyle.solid,
                borderWidth: Sizes.WIDTH_1,
                obscured: true,
                prefixIconColor: AppColors.indigo,
              ),
              SpaceH20(),
              CustomTextFormField(
                controller: confirmPass,
                hasPrefixIcon: true,
                prefixIconImagePath: ImagePath.passwordIcon,
                textFormFieldStyle: textFormFieldTextStyle,
                hintText: "Confirm Password",
                hintTextStyle: hintTextStyle,
                borderStyle: BorderStyle.solid,
                borderWidth: Sizes.WIDTH_1,
                obscured: true,
                prefixIconColor: AppColors.indigo,
              ),
              Spacer(flex: 1),
              angadiButton("Update",
                  buttonWidth: MediaQuery.of(context).size.width,
                  onTap: () async {
                await _changePassword(pass.text);
                R.Router.navigator.pushNamedAndRemoveUntil(
                  R.Router.loginScreen,
                  (Route<dynamic> route) => false,
                );
              }),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword(String password) async {
    //Create an instance of the current user.
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    //Pass in the password to updatePassword.
    pass.text == confirmPass.text
        ? user.updatePassword(password).then((_) {
            Fluttertoast.showToast(msg: "Succesfull changed password");
            print("Succesfull changed password");
          }).catchError((error) {
            Fluttertoast.showToast(
                msg: "Password can't be changed" + error.toString());
            print("Password can't be changed" + error.toString());
            //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
          })
        : Fluttertoast.showToast(msg: "Passwords don't match!");
  }
}
