
import 'dart:io';

import 'package:angadi/classes/address.dart';
import 'package:angadi/screens/my_addresses.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmAddress extends StatefulWidget {
  String location;
  ConfirmAddress(this.location);
  @override
  _ConfirmAddressState createState() => _ConfirmAddressState();
}

class _ConfirmAddressState extends State<ConfirmAddress> {
  final locationselected=TextEditingController();
  var id='';


void addAddress()async{
  FirebaseUser user=await FirebaseAuth.instance.currentUser();
await Firestore.instance.collection('Users').where('mail',isEqualTo: user.email).snapshots().listen((event) {setState(() {
  id=event.documents[0].documentID;
});print(event.documents[0].documentID);
print(id);});

}
void setaddress(String id)async{
  (id!=null&&id!='')?await Firestore.instance.collection('Users').document(id).collection('Address').add({
    'address':locationselected.text,
    'hno':hnocontroller.text,
    'landmark':localitycontroller.text
  }):print('not');
  Navigator.of(context).pop();
}

  @override
  void initState() {
    locationselected.text=widget.location;


    addAddress();

    super.initState();
  }
  final hnocontroller=TextEditingController();
  final localitycontroller=TextEditingController();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppColors.secondaryElement,
        actions: [
          InkWell(
              onTap: () {
                launch('tel:+919027553376');
              },
              child: Icon(Icons.phone, color: Color(0xFF6b3600))),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                launchWhatsApp(
                    phone: '7060222315', message: 'Check out this awesome app');
              },
              child: Container(
                  alignment: Alignment.center,
                  child: FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF6b3600)))),
          SizedBox(width:8),
          InkWell(
              onTap: () {
//                print(1);
                launch(
                    'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
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
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
      body:Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(

            children: [

          HeadingRow(
                    title: 'Complete your full Address',
                    number: '',
                  ),
              SizedBox(height:MediaQuery.of(context).size.height*0.03),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),  ), maxLines: 2,  controller: locationselected,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'House No.(Optional)' ),   controller: hnocontroller,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Landmark(Optional)' ),   controller: localitycontroller,        ),
              ),
              SizedBox(height:MediaQuery.of(context).size.height*0.04),
              angadiButton(
                'Save Address',
                buttonWidth: MediaQuery.of(context).size.width,
                onTap: () async{
                 setaddress(id);
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}
