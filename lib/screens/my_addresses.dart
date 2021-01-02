import 'dart:io';

import 'package:angadi/classes/address.dart';
import 'package:angadi/screens/confirm_address.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAddresses extends StatefulWidget {
  String id;
  MyAddresses(this.id);
  @override
  _MyAddressesState createState() => _MyAddressesState();
}

class _MyAddressesState extends State<MyAddresses> {
  var location = 'Dubai';

  LocationResult result;
  var id;
  void showPlacePicker() async {
    print('called');
    result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw")));
    setState(() {
      location = result.formattedAddress;
    });
    // Handle the result in your way
    print(location);
    if (location != null) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ConfirmAddress(location)));
    }
  }

  List<Address> alladresses = [];
  List<Widget> addressCards = [];
  void alladdresses() async {
    setState(() {
      alladresses.clear();
      print(alladresses.length);
    });

    print('--------------');
    await Firestore.instance
        .collection('Users')
        .document(widget.id)
        .collection('Address')
        .snapshots()
        .forEach((element) {
      element.documents.forEach((element) {
        setState(() {
          Address add =
              Address(element['address'], element['hno'], element['landmark'],element['Emirate'],element['Area']);
          alladresses.add(add);
        });
        print(id);
        print(alladresses.length);
      });
    });
  }

  @override
  void initState() {
    setState(() {
      alladresses.clear();
      print(alladresses.length);
    });

    alladdresses();
    super.initState();
  }

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
                  child: FaIcon(FontAwesomeIcons.whatsapp,
                      color: Color(0xFF6b3600)))),
          SizedBox(width: 8),
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
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),

                  child: StreamBuilder(
                      stream: Firestore.instance.collection('Users').document(widget.id).collection('Address').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                        if (snap.hasData && !snap.hasError && snap.data != null) {
                          alladresses.clear();
                          for (int i = 0; i < snap.data.documents.length; i++) {
                            print(snap.data.documents.length);
                            Address add=Address(snap.data.documents[i]['address'],snap.data.documents[i]['hno'],snap.data.documents[i]['landmark'],snap.data.documents[i]['Emirate'],snap.data.documents[i]['Area']);
                            alladresses.add(add);}
                          return  alladresses.length!=0
                              ?  Column(
                            children: [
                              HeadingRow(
                                title: 'Saved Addresses',
                                number: '',
                              ),
                              ListView.builder(
                                itemCount: alladresses.length,
                                shrinkWrap:true,
                                physics:ClampingScrollPhysics(),
                                itemBuilder: (context,index){
                                  var item=alladresses[index];
                                  return Card(
                                      child:Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            (item.hno!=null&&item.hno!='')?Text('Address : H.no. ${item.hno} , ${item.address}'):Text('Address :  ${item.address}'),

                                            (item.landmark!=null&&item.landmark!='')?Align(alignment:Alignment.bottomLeft,child: Text('Landmark : ${item.landmark}')):Text(''),
                                        Align(alignment:Alignment.bottomLeft,child: Text('Emirate : ${item.emirate}')),
                                        Align(alignment:Alignment.bottomLeft,child: Text('Area : ${item.area}'))
                                          ],
                                        ),
                                      )
                                  );
                                },
                              )
                            ],
                          ):Container();
                        }
                        else{
                          return Container();
                        }
                      }



                  )),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: angadiButton(
                  '+ Add new address',
                  buttonWidth: double.infinity,
                  onTap: () {
                    showPlacePicker();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
