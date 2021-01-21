import 'dart:io';

import 'package:angadi/classes/address.dart';
import 'package:angadi/classes/emirates.dart';
import 'package:angadi/classes/emiratesarea.dart';
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
  final locationselected = TextEditingController();
  List<Emirates> allemirates = [];
  List<EmiratesArea> allareas = [];
  String area;
  String emirate2;
  String emirate;
  List<String> emiratesname = [];
  List<String> areaname = [];
  var id = '';
  var minimumOrderValue = '150';

  void addAddress() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('Users')
        .where('mail', isEqualTo: user.email)
        .snapshots()
        .listen((event) {
      setState(() {
        id = event.documents[0].documentID;
      });
      print(event.documents[0].documentID);
      print(id);
    });
  }

  void setaddress(String id) async {
    (id != null && id != '')
        ? await Firestore.instance
            .collection('Users')
            .document(id)
            .collection('Address')
            .add({
            'address': locationselected.text,
            'hno': hnocontroller.text,
            'landmark': localitycontroller.text,
            'Emirate': emirate,
            'Area': area
          })
        : print('not');
    Navigator.of(context).pop(minimumOrderValue);
  }

  @override
  void initState() {
    locationselected.text = widget.location;

    addAddress();

    super.initState();
  }

  final hnocontroller = TextEditingController();
  final localitycontroller = TextEditingController();
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
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop(minimumOrderValue);
              },
              child: Icon(Icons.arrow_back_rounded)),
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
                      phone: '7060222315',
                      message: 'Check out this awesome app');
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
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                HeadingRow(
                  title: 'Complete your full Address',
                  number: '',
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(color: Color(0xFF6b3600))),
                    ),
                    maxLines: 2,
                    controller: locationselected,
                  ),
                ),
                StreamBuilder(
                    stream:
                        Firestore.instance.collection('Emirates').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData && !snap.hasError && snap.data != null) {
                        allemirates.clear();
                        emiratesname.clear();
                        for (int i = 0; i < snap.data.documents.length; i++) {
                          print(snap.data.documents.length);
                          emirate2 = snap.data.documents[0]['name'];
                          emiratesname.add(snap.data.documents[i]['name']);
                          Emirates emi = Emirates(
                              snap.data.documents[i]['deliveryCharge'],
                              snap.data.documents[i]['minOrderPrice'],
                              snap.data.documents[i]['name']);

                          allemirates.add(emi);
                        }
                        if (emirate == null) {
                          emirate = allemirates[0].name;
                        }
                        // minimumOrderValue = allemirates[0].minorderprice;
                        return allemirates.length != 0
                            ? Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: DropdownButtonHideUnderline(
                                      child:
                                          new DropdownButtonFormField<String>(
                                        validator: (value) => value == null
                                            ? 'field required'
                                            : null,
                                        hint: Text('Emirates'),
                                        value: emiratesname[0],
                                        items: emiratesname.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            emirate = newValue;
                                            emirate2 = newValue;
                                            print(emirate);
                                            for (int i = 0;
                                                i < allemirates.length;
                                                i++) {
                                              if (allemirates[i].name ==
                                                  newValue) {
                                                minimumOrderValue =
                                                    allemirates[i]
                                                        .minorderprice;
                                                print(allemirates[i]
                                                    .minorderprice);
                                                print(allemirates[i].name);
                                              }
                                            }
//                      Navigator.pop(context);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container();
                      } else {
                        return Container();
                      }
                    }),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('EmiratesArea')
                        .where('Emirate', isEqualTo: emirate)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData && !snap.hasError && snap.data != null) {
                        allareas.clear();
                        areaname.clear();
                        for (int i = 0; i < snap.data.documents.length; i++) {
                          print(snap.data.documents.length);

                          areaname.add(snap.data.documents[i]['name']);

                          EmiratesArea emi2 = EmiratesArea(
                              snap.data.documents[i]['Emirate'],
                              snap.data.documents[i]['deliveryCharge'],
                              snap.data.documents[i]['minOrderPrice'],
                              snap.data.documents[i]['name'],
                              snap.data.documents[i]['zone']);
                          allareas.add(emi2);
                        }
                        areaname.add('Others');
                        if (area == null) {
                          area = allareas[0].name;
                        }
                        return areaname.length != 0
                            ? Column(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: DropdownButtonHideUnderline(
                                          child: new DropdownButtonFormField<
                                                  String>(
                                              validator: (value) =>
                                                  value == null
                                                      ? 'field required'
                                                      : null,
                                              hint: Text('Area'),
                                              value: areaname[0],
                                              items:
                                                  areaname.map((String value) {
                                                return new DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: new Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String newValue) {
                                                setState(() {
                                                  area = newValue;
                                                  for (int i = 0;
                                                      i < allareas.length;
                                                      i++) {
                                                    if (newValue ==
                                                        allareas[i].name)
                                                      minimumOrderValue =
                                                          allareas[i]
                                                              .minOrderPrice;
                                                  }
                                                  print('---------------');
                                                  print(area);
                                                  if (area == 'Others') {
                                                    for (int i = 0;
                                                        i < allemirates.length;
                                                        i++) {
                                                      if (emirate ==
                                                          allemirates[i].name) {
                                                        print('check');
                                                        print(emirate);
                                                        print(allemirates[i]);
                                                        minimumOrderValue =
                                                            allemirates[i]
                                                                .minorderprice;
                                                        setState(() {});
                                                      }
                                                    }
                                                  }
                                                });
                                              })))
                                ],
                              )
                            : Container();
                      } else {
                        return Container();
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Color(0xFF6b3600))),
                        hintText: 'House No.(Optional)'),
                    controller: hnocontroller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Color(0xFF6b3600))),
                        hintText: 'Landmark(Optional)'),
                    controller: localitycontroller,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                angadiButton(
                  'Save Address',
                  buttonWidth: MediaQuery.of(context).size.width,
                  onTap: () async {
                    setaddress(id);
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
