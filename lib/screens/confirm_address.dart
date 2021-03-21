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
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
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
  List<Emirates> savedemirate = [];
  List<EmiratesArea> savedarea = [];
  double minOrderPrice = 0;
  double deliveryCharge = 0;
  String area;
  String emirate2;
  String emirate;
  List<EmiratesArea> getall = [];
  void alldata(String newemirate) async {
    getall.clear();
    areaname.clear();
    print(newemirate);
    await Firestore.instance
        .collection('EmiratesArea')
        .where('Emirate', isEqualTo: newemirate)
        .snapshots()
        .listen((event) {
      index = 0;
      for (int i = 0; i < event.documents.length; i++) {
        if (i == 0) {
          areaname.add('${event.documents[i]['name']}');
//                                                print('5555555555555${snap.data.documents[i]['name']}');
          EmiratesArea emi2 = EmiratesArea(
              event.documents[i]['Emirate'],
              event.documents[i]['deliveryCharge'],
              event.documents[i]['minOrderPrice'],
              '${event.documents[i]['name']}',
              event.documents[i]['zone']);
          getall.add(emi2);
          setState(() {
            deliveryCharge = double.parse(getall[0].deliveryCharge);
            minOrderPrice = double.parse(getall[0].minOrderPrice);
          });
        }
//        print(event.documents.length);
        for (int j = i + 1; j < event.documents.length; j++) {
          if (event.documents[i]['name'] == event.documents[j]['name']) {
              areaname.add(' ${event.documents[j]['name']}');
//            print('5555555555555${event.documents[j]['name']}');
//            print('Minorder${event.documents[j]['minOrderPrice']}');
            EmiratesArea emi2 = EmiratesArea(
                event.documents[j]['Emirate'],
                event.documents[j]['deliveryCharge'],
                event.documents[j]['minOrderPrice'],
                ' ${event.documents[j]['name']}',
                event.documents[j]['zone']);
            getall.add(emi2);
//              print('length:${areaname.length}');
            index = j;
            print('Index:${index}');
          }
        }
        if (i != index) {
           areaname.add('${event.documents[i]['name']}');
//                                                print('5555555555555${snap.data.documents[i]['name']}');
          EmiratesArea emi2 = EmiratesArea(
              event.documents[i]['Emirate'],
              event.documents[i]['deliveryCharge'],
              event.documents[i]['minOrderPrice'],
              '${event.documents[i]['name']}',
              event.documents[i]['zone']);
          getall.add(emi2);
        }
      }
      areaname.add('Others');
      if (areaname.length > 1) {
        deliveryCharge = double.parse(getall[0].deliveryCharge);
        minOrderPrice = double.parse(getall[0].minOrderPrice);
        setState(() {
          area = getall[0].name;
        });
      } else {
        for (int i = 0; i < savedemirate.length; i++) {
          if (savedemirate[i].name == newemirate) {
            deliveryCharge = double.parse(savedemirate[i].deliverycharge);
            minOrderPrice = double.parse(savedarea[i].minOrderPrice);
            area = 'Others';
          }
        }
      }
    });
  }

  void areas() async {
    await Firestore.instance
        .collection('EmiratesArea')
        .getDocuments()
        .then((value) {
      for (int i = 0; i < value.documents.length; i++) {
        setState(() {
          EmiratesArea emi2 = EmiratesArea(
              value.documents[i]['Emirate'],
              value.documents[i]['deliveryCharge'],
              value.documents[i]['minOrderPrice'],
              value.documents[i]['name'],
              value.documents[i]['zone']);
          savedarea.add(emi2);
        });
      }
    });

    await Firestore.instance
        .collection('Emirates')
        .getDocuments()
        .then((value) {
      for (int i = 0; i < value.documents.length; i++) {
        print(value.documents.length);

        emiratesname.add(value.documents[i]['name']);
        Emirates emi = Emirates(value.documents[i]['deliveryCharge'],
            value.documents[i]['minOrderPrice'], value.documents[i]['name']);

        savedemirate.add(emi);
      }
    });
    emirate = savedemirate[0].name;
    alldata(emirate);
    if (savedarea.length > 0) {
      for (int k = 0; k < savedarea.length; k++) {
        if (emirate == savedarea[k].name) {
          area = savedarea[k].name;
          deliveryCharge = double.parse(savedarea[k].deliveryCharge);
          minOrderPrice = double.parse(savedarea[k].minOrderPrice);
          break;
        } else {
          setState(() {
            area = 'Others';
          });

          deliveryCharge = double.parse(savedemirate[0].deliverycharge);
          minOrderPrice = double.parse(savedemirate[0].minorderprice);
        }
      }
    }
  }

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
    areas();

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

  int index = 0;

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
                  launch('tel:+971 50 7175406');
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
                  launch(
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
              fontSize: Sizes.TEXT_SIZE_22,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: areaname.length!=0?Column(
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
                                        value: emirate,
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
                                            alldata(emirate);
//                                            for (int i = 0;
//                                                i < allemirates.length;
//                                                i++) {
//                                              if (allemirates[i].name ==
//                                                  newValue) {
//                                                minimumOrderValue =
//                                                    allemirates[i]
//                                                        .minorderprice;
//                                                print(allemirates[i]
//                                                    .minorderprice);
//                                                print(allemirates[i].name);
//                                              }
//                                            }
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
//                StreamBuilder(
//                    stream: Firestore.instance
//                        .collection('EmiratesArea')
//                        .where('Emirate', isEqualTo: emirate)
//                        .snapshots(),
//                    builder: (BuildContext context,
//                        AsyncSnapshot<QuerySnapshot> snap) {
//                      if (snap.hasData && !snap.hasError && snap.data != null) {
//                        allareas.clear();
//                        areaname.clear();
//                        index = 0;
//                        for (int i = 0; i < snap.data.documents.length; i++) {
//                          if (i == 0) {
//                            areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                            EmiratesArea emi2 = EmiratesArea(
//                                snap.data.documents[i]['Emirate'],
//                                snap.data.documents[i]['deliveryCharge'],
//                                snap.data.documents[i]['minOrderPrice'],
//                                '${snap.data.documents[i]['name']}',
//                                snap.data.documents[i]['zone']);
//                            allareas.add(emi2);
//                          }
////                          print(snap.data.documents.length);
//                          for (int j = i + 1;
//                              j < snap.data.documents.length;
//                              j++) {
//                            if (snap.data.documents[i]['name'] ==
//                                snap.data.documents[j]['name']) {
//                              areaname
//                                  .add(' ${snap.data.documents[j]['name']}');
//                              print(
//                                  '5555555555555${snap.data.documents[j]['name']}');
//                              print(
//                                  'Minorder${snap.data.documents[j]['minOrderPrice']}');
//                              EmiratesArea emi2 = EmiratesArea(
//                                  snap.data.documents[j]['Emirate'],
//                                  snap.data.documents[j]['deliveryCharge'],
//                                  snap.data.documents[j]['minOrderPrice'],
//                                  ' ${snap.data.documents[j]['name']}',
//                                  snap.data.documents[j]['zone']);
//                              allareas.add(emi2);
//                              print('length:${areaname.length}');
//                              index = j;
//                              print('Index:${index}');
//                            }
//                          }
//                          if (i != index) {
//                            areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                            EmiratesArea emi2 = EmiratesArea(
//                                snap.data.documents[i]['Emirate'],
//                                snap.data.documents[i]['deliveryCharge'],
//                                snap.data.documents[i]['minOrderPrice'],
//                                '${snap.data.documents[i]['name']}',
//                                snap.data.documents[i]['zone']);
//                            allareas.add(emi2);
//                          }
//                        }
//                        areaname.add('Others');
//                        if (area == null) {
//                          area = allareas[0].name;
//                        }
//                        return areaname.length != 0
                             Column(
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
                                                      i < getall.length;
                                                      i++) {
                                                    if (newValue ==
                                                        getall[i].name)
                                                      minimumOrderValue =
                                                          getall[i]
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
                              ),
//                            : Container();
//                      } else {
//                        return Container();
//                      }
//                    }),
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
            ):Center(
              child: Container(
                  height:100,
                  width:100,
                  child:CircularProgressIndicator()
              ),
            ),
          ),
        ));
  }
}
