import 'dart:io';

import 'package:angadi/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  String url;
  WebviewScreen(this.url);
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading:InkWell(onTap:(){
            Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>HomeScreen()));
          },child: Icon(Icons.arrow_back_ios,color: Colors.black)),
      title:Text('Angadi.ae',style:TextStyle(fontSize:MediaQuery.of(context).size.height*0.02)),
        centerTitle: true,
      ),
      body: WebView(
        initialUrl: '${widget.url}',
      ),
    );
  }
}
