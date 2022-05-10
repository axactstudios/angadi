import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/theme.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(context),
      initialRoute: R.Router.splashScreen,
      onGenerateRoute: R.Router.onGenerateRoute,
      navigatorKey: R.Router.navigator.key,
    );
  }
}
//New Commit On 11 May 2022
