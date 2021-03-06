import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:angadi/classes/cart.dart';
import 'package:angadi/classes/emirates.dart';
import 'package:angadi/classes/emiratesarea.dart';
import 'package:angadi/screens/home_screen.dart';
import 'package:angadi/screens/my_addresses.dart';
import 'package:angadi/screens/my_addresses2.dart';
import 'package:angadi/screens/my_orders.dart';
import 'package:angadi/screens/offers_screen.dart';
import 'package:angadi/screens/root_screen.dart';
import 'package:angadi/screens/settings_screen.dart';
import 'package:angadi/screens/webview.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_paytabs_bridge_emulator/flutter_paytabs_bridge_emulator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:location/location.dart';
import 'package:mailer2/mailer.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'bookmarks_screen.dart';
import 'order_placed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Checkout extends StatefulWidget {
  String address;
  String SavedArea;
  String savedEmirate;
  var id;
  Checkout(this.address, this.id, this.SavedArea, this.savedEmirate);
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  List<EmiratesArea> savedarea = [];
  bool val = true;
  GlobalKey key = new GlobalKey();
//  final scaffoldState = GlobalKey<ScaffoldState>();
  bool ischecked = false;
  String type = 'Delivery';
  List<Cart> cartItems = [];
  double minOrderPrice = 0;
  double deliveryCharge = 0;
  List<Emirates> savedemirate = [];
  List<Emirates> allemirates = [];
  List<EmiratesArea> allareas = [];
  String area;
  List<String> areaname = [];
  DateTime selectedDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  String selectedTime = 'Choose Slot';
  DateTime date;
  var addresstype = 'House';
  var color1 = false;
  var color2 = true;
  var color3 = false;
  double total;
  String emirate2;
  List<String> emiratesname = [];
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final phncontroller = TextEditingController();
  final buildingController = TextEditingController();
  final floorcontroller = TextEditingController();
  final flatcontroller = TextEditingController();
  final additionalcontroller = TextEditingController();
  final hnoController = TextEditingController();
  final notesController = TextEditingController();
  final PhoneNumber = TextEditingController();

  final dbHelper = DatabaseHelper.instance;
//  final dbRef = FirebaseDatabase.instance.reference();
  FirebaseAuth mAuth = FirebaseAuth.instance;
//  GlobalKey key = new GlobalKey();
  final scaffoldState = GlobalKey<ScaffoldState>();
  String id2;
  void shared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id2 = prefs.getString('Orderid');
    // print('####################${id2}');
  }

  String emirate;
  _pickTime() async {
    var today = DateTime.now();
    DateTime t = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year, today.month, today.day + dateAddition),
      lastDate: DateTime(today.year, today.month, today.day + 6),
      firstDate:
          DateTime(today.year, DateTime.now().month, today.day + dateAddition),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (t != null)
      setState(() {
        date = t;
      });
    return date;
  }

  Future<void> _timeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildTimeDialog(context);
      },
    );
  }

  List<String> timeSlots2 = [];

  void time2() {
    timeSlots2.clear();
    Firestore.instance.collection('Timeslots').snapshots().forEach((element) {
      for (int i = 0; i < element.documents[0].data['Timeslots'].length; i++) {
        DateTime dt = DateTime.now();

        if (dt.hour > 12) {
          String st = element.documents[0].data['Timeslots'][i];
          String s = '';
          for (int i = 0; i < st.length; i++) {
            if (st[i] != ' ')
              s = s + st[i];
            else
              break;
          }

          double d = double.parse(s);
          if (d > (dt.hour - 12) &&
              element.documents[0].data['Timeslots'][i].contains('PM')) {
            timeSlots2.add(element.documents[0].data['Timeslots'][i]);
          }
        } else {
          String st = element.documents[0].data['Timeslots'][i];
          String s = '';
          for (int i = 0; i < st.length; i++) {
            if (st[i] != ' ')
              s = s + st[i];
            else
              break;
          }

          double d = double.parse(s);
          if (d > (dt.hour) &&
              element.documents[0].data['Timeslots'][i].contains('AM')) {
            timeSlots2.add(element.documents[0].data['Timeslots'][i]);
          }
        }
      }
      if (timeSlots2.length == 0) {
        selectedDate = selectedDate.add(new Duration(days: 1));
        for (int i = 0;
            i < element.documents[0].data['Timeslots'].length;
            i++) {
          timeSlots2.add(element.documents[0].data['Timeslots'][i]);
        }
      }

//      print('-----------------');
//      print(timeSlots2.length);
      selectedTime = timeSlots2[0];
    });
//    print('enddd');
//    print(timeSlots2.length);
//  if(timeSlots2.length>0){
//    print('Heya');
//    setState(() {
//      selectedTime=timeSlots2[0];
//    });
//
//  }
  }

  List<EmiratesArea> getall = [];
  void alldata2(String newemirate, BuildContext ctx) async {
    final ProgressDialog pr = await ProgressDialog(ctx);
    pr.style(
        message: 'Loading...',
        backgroundColor: Colors.white,
        progressWidget: GFLoader(
          type: GFLoaderType.ios,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    await pr.show();
    setState(() {
      showIndicator = true;
    });
    getall.clear();
    areaname.clear();
//    areaname.add('Others');
    print(getall.length);
    emirate = newemirate;
    print(newemirate);
//  length2=0;

    await Firestore.instance
        .collection('EmiratesArea')
        .where('Emirate', isEqualTo: newemirate)
        .snapshots()
        .listen((event) {
      index = 0;
      for (int i = 0; i < event.documents.length; i++) {
        length2 == event.documents.length;
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
          area = event.documents[i]['name'];
          setState(() {
            deliveryCharge = double.parse(getall[0].deliveryCharge);
            minOrderPrice = double.parse(getall[0].minOrderPrice);
          });
        }
//      print(event.documents.length);
        for (int j = i + 1; j < event.documents.length; j++) {
          if (event.documents[i]['name'] == event.documents[j]['name']) {
            areaname.add(' ${event.documents[j]['name']}');
//           print('5555555555555${event.documents[j]['name']}');
//           print('Minorder${ event.documents[j]
//           ['minOrderPrice']}');
            EmiratesArea emi2 = EmiratesArea(
                event.documents[j]['Emirate'],
                event.documents[j]['deliveryCharge'],
                event.documents[j]['minOrderPrice'],
                ' ${event.documents[j]['name']}',
                event.documents[j]['zone']);
            getall.add(emi2);
//              print('length:${areaname.length}');
            index = j;
            // print('Index:${index}');

          }
          break;
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
//    if(getall.length==length2){
//      pr.hide();
//    }
      if (areaname.length > 1) {
        deliveryCharge = double.parse(getall[0].deliveryCharge);
        minOrderPrice = double.parse(getall[0].minOrderPrice);
        area = areaname[0];
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

    setState(() {
      showIndicator = false;
    });
    await pr.hide();
  }

  void alldata(String newemirate) async {
//  final ProgressDialog pr = await ProgressDialog(context);
//  pr.style(
//      message: 'Loading...',
//      backgroundColor: Colors.white,
//      progressWidget: GFLoader(
//        type: GFLoaderType.ios,
//      ),
//      elevation: 10.0,
//      insetAnimCurve: Curves.easeInOut,
//      progress: 0.0,
//      maxProgress: 100.0,
//      progressTextStyle: TextStyle(
//          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//      messageTextStyle: TextStyle(
//          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
//  await pr.show();
    getall.clear();
    areaname.clear();
//  areaname.add('Others');
    print(getall.length);
    emirate = newemirate;
    print(newemirate);
//  length2=0;

    await Firestore.instance
        .collection('EmiratesArea')
        .where('Emirate', isEqualTo: newemirate)
        .snapshots()
        .listen((event) {
      index = 0;
      for (int i = 0; i < event.documents.length; i++) {
        length2 == event.documents.length;
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
          area = event.documents[i]['name'];
          setState(() {
            deliveryCharge = double.parse(getall[0].deliveryCharge);
            minOrderPrice = double.parse(getall[0].minOrderPrice);
          });
        }
//      print(event.documents.length);
        for (int j = i + 1; j < event.documents.length; j++) {
          if (event.documents[i]['name'] == event.documents[j]['name']) {
            areaname.add(' ${event.documents[j]['name']}');
//           print('5555555555555${event.documents[j]['name']}');
//           print('Minorder${ event.documents[j]
//           ['minOrderPrice']}');
            EmiratesArea emi2 = EmiratesArea(
                event.documents[j]['Emirate'],
                event.documents[j]['deliveryCharge'],
                event.documents[j]['minOrderPrice'],
                ' ${event.documents[j]['name']}',
                event.documents[j]['zone']);
            getall.add(emi2);
//              print('length:${areaname.length}');
            index = j;
            // print('Index:${index}');
          }
          break;
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
//    if(getall.length==length2){
//      pr.hide();
//    }
      if (areaname.length > 1) {
        deliveryCharge = double.parse(getall[0].deliveryCharge);
        minOrderPrice = double.parse(getall[0].minOrderPrice);
        area = areaname[0];
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
//  await pr.hide();
  }

  void areas() async {
    savedemirate.clear();
    savedarea.clear();
    await Firestore.instance
        .collection('Emirates')
        .getDocuments()
        .then((value) {
      for (int i = 0; i < value.documents.length; i++) {
//        print(value.documents.length);

//        emiratesname.add(value.documents[i]['name']);
        Emirates emi = Emirates(value.documents[i]['deliveryCharge'],
            value.documents[i]['minOrderPrice'], value.documents[i]['name']);

        savedemirate.add(emi);
      }
    });
    emiratesname.add('Sharjah');
    emiratesname.add('Ajman');
    emirate = emiratesname[0];
    alldata(emirate);
    await Firestore.instance
        .collection('EmiratesArea')
        .where('Emirate', isEqualTo: emirate)
        .getDocuments()
        .then((value) {
      for (int i = 0; i < value.documents.length; i++) {
        if (savedarea.length == 0) {
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
        if (savedarea.length > 0) {
          for (int j = 0; j < savedarea.length; j++) {
            if (savedarea[j].name == value.documents[i]['name']) {
              EmiratesArea emi2 = EmiratesArea(
                  value.documents[i]['Emirate'],
                  value.documents[i]['deliveryCharge'],
                  value.documents[i]['minOrderPrice'],
                  ' ${value.documents[i]['name']}',
                  value.documents[i]['zone']);
              savedarea.add(emi2);
              break;
            }
          }

          EmiratesArea emi2 = EmiratesArea(
              value.documents[i]['Emirate'],
              value.documents[i]['deliveryCharge'],
              value.documents[i]['minOrderPrice'],
              value.documents[i]['name'],
              value.documents[i]['zone']);
          savedarea.add(emi2);
        }
      }
    });
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

  List<String> timeSlots = [];

  Widget _buildTimeDialog(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var hintTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(Sizes.RADIUS_32),
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(
          Sizes.PADDING_0,
          Sizes.PADDING_36,
          Sizes.PADDING_0,
          Sizes.PADDING_0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
        ),
        elevation: Sizes.ELEVATION_4,
        content: Container(
          height: Sizes.HEIGHT_160,
          width: Sizes.WIDTH_300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: Text(
                    'Change delivery time',
                    style: textTheme.title.copyWith(
                      fontSize: Sizes.TEXT_SIZE_20,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder(
                    stream:
                        Firestore.instance.collection('Timeslots').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData && !snap.hasError && snap.data != null) {
                        timeSlots.clear();
                        // print(snap.data.documents[0].data['Timeslots']);
                        for (int i = 0;
                            i < snap.data.documents[0].data['Timeslots'].length;
                            i++) {
                          DateTime dt = DateTime.now();

                          if (dt.hour > 12) {
                            String st =
                                snap.data.documents[0].data['Timeslots'][i];
                            String s = '';
                            for (int i = 0; i < st.length; i++) {
                              if (st[i] != ' ')
                                s = s + st[i];
                              else
                                break;
                            }

                            double d = double.parse(s);
                            if (d > (dt.hour - 12) &&
                                snap.data.documents[0].data['Timeslots'][i]
                                    .contains('PM')) {
                              timeSlots.add(
                                  snap.data.documents[0].data['Timeslots'][i]);
                            }
                          } else {
                            String st =
                                snap.data.documents[0].data['Timeslots'][i];
                            String s = '';
                            for (int i = 0; i < st.length; i++) {
                              if (st[i] != ' ')
                                s = s + st[i];
                              else
                                break;
                            }

                            double d = double.parse(s);
                            if (d > (dt.hour) &&
                                snap.data.documents[0].data['Timeslots'][i]
                                    .contains('AM')) {
                              timeSlots.add(
                                  snap.data.documents[0].data['Timeslots'][i]);
                            }
                            if (snap.data.documents[0].data['Timeslots'][i]
                                .contains('PM')) {
                              timeSlots.add(
                                  snap.data.documents[0].data['Timeslots'][i]);
                            }
                          }
                        }
                        if (timeSlots.length == 0) {
                          selectedDate =
                              selectedDate.add(new Duration(days: 1));
                          for (int i = 0;
                              i <
                                  snap.data.documents[0].data['Timeslots']
                                      .length;
                              i++) {
                            timeSlots.add(
                                snap.data.documents[0].data['Timeslots'][i]);
                          }
                        }
                        if (selectedDate.difference(DateTime.now()).inDays >=
                            1) {
                          timeSlots.clear();
                          for (int i = 0;
                              i <
                                  snap.data.documents[0].data['Timeslots']
                                      .length;
                              i++) {
                            timeSlots.add(
                                snap.data.documents[0].data['Timeslots'][i]);
                          }
                        }
                        return timeSlots.length != 0
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
                                        hint: Text('Time Slots'),
                                        value: timeSlots[0],
                                        items: timeSlots.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            selectedTime = newValue;

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
              ),
              Spacer(flex: 1),
              AlertDialogButton(
                  buttonText: "Change",
                  width: 280,
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: AppColors.greyShade1,
                    ),
                  ),
                  textStyle: textTheme.button
                      .copyWith(color: AppColors.secondaryElement),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop(true);
                  })
            ],
          ),
        ),
      ),
    );
  }

  int newQty;
  void getAllItems() async {
    final allRows = await dbHelper.queryAllRows();
    cartItems.clear();
    allRows.forEach((row) => cartItems.add(Cart.fromMap(row)));
  }

  double totalAmount() {
    double sum = 0;
    getAllItems();
    for (int i = 0; i < cartItems.length; i++) {
      sum += (double.parse(cartItems[i].price) * cartItems[i].qty);
    }
    return sum;
  }

  var docid = '';
  void address() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var email = user.email;
    Firestore.instance
        .collection('Users')
        .where('mail', isEqualTo: email)
        .snapshots()
        .listen((event) {
      setState(() {
        docid = event.documents[0].documentID;
      });
      // print(event.documents[0].documentID);
    });
  }

  int length2 = 0;
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

  TimeOfDay time;
  var orderid;
  void getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    orderid = prefs.getString('Orderid');
  }

  void setaddress() async {
    // print('=====================Reached');
    if (addresstype == 'House') {
      // print('------------------');
      // print(docid);
      (docid != null && docid != '')
          ? await Firestore.instance
              .collection('Users')
              .document(docid)
              .collection('Address')
              .add({
              'address':
                  '${buildingController.text} , Street:${flatcontroller.text}',
              'hno': '',
              'landmark': additionalcontroller.text,
              'Emirate': emirate,
              'Area': area
            })
          : print('not');
    }
    if (addresstype == 'Office') {
      (docid != null && docid != '')
          ? await Firestore.instance
              .collection('Users')
              .document(docid)
              .collection('Address')
              .add({
              'address': '${buildingController.text} ',
              'hno': '',
              'landmark': additionalcontroller.text,
              'Emirate': emirate,
              'Area': area
            })
          : print('not');
    }
  }

  int dateAddition = 1;
  checkLastSlot() async {
    await Firestore.instance
        .collection('Timeslots')
        .snapshots()
        .listen((event) {
      // print(event.documents[0].data['LastSlot']);
      String st = event.documents[0].data['LastSlot'];
      String s = '';
      for (int i = 0; i < st.length; i++) {
        if (st[i] != ' ')
          s = s + st[i];
        else
          break;
      }

      double d = double.parse(s);
      if (st.contains('PM')) d = d + 12;
      DateTime dt = DateTime.now();
      if (dt.hour > d) dateAddition = dateAddition + 1;
    });
  }

  void _launchURL2(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
  String whatsappMessage = '';
  bool showIndicator = false;
  @override
  void initState() {
    showIndicator = false;
//     indicator();
//  areaname.add('Others');
    time2();
    getAllItems();
    _getCurrentLocation();
    getid();
    address();
    shared();
    areas();
//    alldata();
    val = true;

    // print('---------------${orderid}');
    checkLastSlot();
    time = TimeOfDay.now();
    date = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + dateAddition);
    BackButtonInterceptor.add(myInterceptor);
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

//@override
//void dispose(){
//    BackButtonInterceptor.remove(myInterceptor);
//    super.dispose();
//}
  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Checksuccess();
//   pushNewScreen(context, screen: BookmarksScreen());
    return true;
  }

  Widget web(String url, BuildContext context, double height, double width) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15.0, // soften the shadow
                spreadRadius: 1.0, //extend the shadow
                offset: Offset(
                  0.0, // Move to right 10  horizontally
                  0.0, // Move to bottom 10 Vertically
                ),
              )
            ],
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  // height: 20,
                  child: Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          child: Icon(Icons.clear),
                          onTap: () => Navigator.pop(context),
                        ),
                      )
                    ],
                  ),
                  // color: Colors.black,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: WebView(
                    initialUrl: '${url}',
                    gestureRecognizers: {
                      Factory<PlatformViewVerticalGestureRecognizer>(
                        () => PlatformViewVerticalGestureRecognizer()
                          ..onUpdate = (_) {},
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dropdown(BuildContext context, double height, double width) {
    return Padding(
        padding:
            EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.015),
        child: Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15.0, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                  offset: Offset(
                    0.0, // Move to right 10  horizontally
                    0.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          margin: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.02,
              MediaQuery.of(context).size.height * 0.02,
              MediaQuery.of(context).size.width * 0.02,
              MediaQuery.of(context).size.height * 0.02),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          height: 110,
          width: width,
          child: Column(
            children: [
//              HeadingRow(
//                title: 'Choose Delivery Time',
//                number: '',
//              ),
//              DropdownButtonHideUnderline(
//                child: new DropdownButton<String>(
//                  hint: Text('  Please choose a slot for delivery'),
//                  items: <String>[
//                    '10:00 a.m.-12:00 p.m.',
//                    '1:00 p.m.-3:00 p.m.',
//                    '4:00 p.m.-6:00 p.m.',
//                    '8:00 p.m.:10:00 p.m.'
//                  ].map((String value) {
//                    return new DropdownMenuItem<String>(
//                      value: value,
//                      child: new Text(value),
//                    );
//                  }).toList(),
//                  onChanged: (value) {
//                    setState(() {
//                      selectedTime = value;
//                      Navigator.pop(context);
//                    });
//                  },
//                ),
//              ),
//              Container(
//                width: MediaQuery.of(context).size.width,
//                color: AppColors.secondaryElement,
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Row(
//                    children: [
//                      Icon(Icons.location_on, color: Colors.white),
//                      SizedBox(
//                        width: 5,
//                      ),
//                      Container(
//                          width: MediaQuery.of(context).size.width * 0.6,
//                          child: Text('Deliver to $location',
//                              style: TextStyle(color: Colors.white))),
//                      SizedBox(
//                        width: 10,
//                      ),
//                      InkWell(
//                          onTap: () {
////                                  _locationDialog(context);
//                            showPlacePicker();
//
////
//                          },
//                          child: Icon(Icons.edit, color: Colors.white)),
////                            InkWell(
////                                onTap: () {
////                                  showPlacePicker();
////
//////                              _locationDialog(context);
////                                },
////                                child: Icon(Icons.map, color: Colors.white))
//                    ],
//                  ),
//                ),
//              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondaryElement),
                    borderRadius: BorderRadius.all(Radius.zero)),
                child: Row(
                  children: [
                    Text('    Next Delivery: '),
                    Icon(
                      Icons.delivery_dining,
                      color: AppColors.secondaryElement,
                    ),
                    SizedBox(width: 5),
                    InkWell(
                        onTap: () {
                          _pickTime().then((value) {
                            setState(() {
                              selectedDate = value;
                            });
                          });
                        },
                        child: selectedDate != null
                            ? Text(
                                '${selectedDate.day.toString()}/${selectedDate.month.toString()}/20 ',
                                style: TextStyle(color: Color(0xFF6b3600)),
                              )
                            : Text(
                                '${date.day.toString()}/${date.month.toString()}/20 ',
                                style: TextStyle(color: Color(0xFF6b3600)),
                              )),
                    Text(' at '),
                    Icon(
                      Icons.timer,
                      size: 19,
                      color: AppColors.secondaryElement,
                    ),
                    SizedBox(width: 5),
                    InkWell(
                        onTap: () {
                          _timeDialog(context);
                        },
                        child: Text(
                          '$selectedTime ',
                          style: TextStyle(color: Color(0xFF6b3600)),
                        )),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void delivery() {
    if (widget.address != '') {
      for (int i = 0; i < savedarea.length; i++) {
        if (widget.SavedArea == savedarea[i].name) {
          // print(widget.SavedArea);
          setState(() {
            minOrderPrice = double.parse(savedarea[i].minOrderPrice);
            deliveryCharge = double.parse(savedarea[i].deliveryCharge);
          });
        } else {
          for (int i = 0; i < savedemirate.length; i++) {
            if (widget.savedEmirate == savedemirate[i].name) {
              setState(() {
                minOrderPrice = double.parse(savedemirate[i].minorderprice);
                deliveryCharge = double.parse(savedemirate[i].deliverycharge);
              });
            }
          }
        }
      }
    }
  }

  Future<bool> onPressed() {
    // print('pressed');
    Checksuccess();
    return Future.value(false);
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
//    print(_result);
    delivery();

//    _pickTime() async {
//      TimeOfDay t = await showTimePicker(context: context, initialTime: time);
//      if (t != null)
//        setState(() {
//          time = t;
//        });
//      return time;
//    }

    var textTheme = Theme.of(context).textTheme;
    var hintTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    return Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Checksuccess();
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white)),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.secondaryElement,
          actions: [
            InkWell(
                onTap: () {
                  launch(Uri.encodeFull('tel:+971 50 7175406'));
                },
                child: Icon(Icons.phone, color: Color(0xFF6b3600))),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
                  launch(Uri.encodeFull("https://wa.me/971507175406"));
                },
                child: Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.whatsapp,
                        color: Color(0xFF6b3600)))),
            SizedBox(width: 8),
            InkWell(
                onTap: () {
                  launch(Uri.encodeFull(
                      "mailto:info@angadi.ae?subject=Complaint/Feedback&body=Type your views here."));
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: (showIndicator != true)
                ? Column(
                    children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Container(
//                       child: Radio(
//                           activeColor: AppColors.secondaryElement,
//                           value: 'Delivery',
//                           groupValue: type,
//                           onChanged: (value) {
//                             setState(() {
//                               type = value;
//                             });
//                           }),
//                     ),
//                     Text(
//                       'Delivery',
//                       style: TextStyle(fontSize: 15),
//                     ),
//                     Container(
//                       height: 6,
//                       child: Radio(
//                           activeColor: AppColors.secondaryElement,
//                           value: 'Takeaway',
//                           groupValue: type,
//                           onChanged: (value) {
//                             setState(() {
//                               type = value;
//                             });
//                           }),
//                     ),
//                     Text(
//                       'Takeaway',
//                       style: TextStyle(fontSize: 15),
//                     ),
//                     SizedBox(
//                       width: 1,
//                     ),
// //                    Radio(
// //                        activeColor: AppColors.secondaryElement,
// //                        value: 'Schedule Delivery',
// //                        groupValue: type,
// //                        onChanged: (value) {
// //                          setState(() {
// //                            type = value;
// //                          });
// //                        }),
// //                    Container(
// //                        width: MediaQuery.of(context).size.width * 0.2,
// //                        child: Text(
// //                          'Schedule Delivery',
// //                          style: TextStyle(fontSize: 15),
// //                        )),
//                   ],
//                 ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: HeadingRow(
                          title: 'Items',
                          number: '',
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.29,
                        child: ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (BuildContext ctxt, int i) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: Row(
                                    children: [
                                      Container(
                                        child: FancyShimmerImage(
                                          imageUrl: cartItems[i].imgUrl,
                                          shimmerDuration: Duration(seconds: 2),
                                        ),
                                        height: 80,
                                        width: 80,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(
                                          cartItems[i].productName,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Qty: ${cartItems[i].qty.toString()}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Price: AED ${cartItems[i].price.toString()}',
                                        style: TextStyle(fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      type != 'Takeaway'
                          ? Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, bottom: 12),
                                    child: HeadingRow(
                                      title: ' Delivery Address',
                                      number: '',
                                    ),
                                  ),
//                             InkWell(
//                                 onTap: () {
//                                   showPlacePicker();
//
// //                              _locationDialog(context);
//                                 },
//                                 child: Icon(
//                                   Icons.map,
//                                   size: 30,
//                                 )),
                                ],
                              ),
                            )
                          : Container(),
                      type != 'Takeaway' && widget.address == ''
//                    ? Padding(
//                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                        child: CustomTextFormField(
//                          controller: hnoController,
//                          textFormFieldStyle: textFormFieldTextStyle,
//                          prefixIconColor: AppColors.secondaryElement,
//                          hintTextStyle: hintTextStyle,
//                          borderStyle: BorderStyle.solid,
//                          borderWidth: Sizes.WIDTH_1,
//                          hintText: 'Enter House No, Street Name',
//                          hasPrefixIcon: true,
//                          prefixIconImagePath: ImagePath.homeIcon,
//                        ),
//                      )
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
//                            Container(
//                              width: MediaQuery.of(context).size.width * 0.31,
//                              height: MediaQuery.of(context).size.height * 0.08,
//                              child: OutlineButton(
//                                highlightedBorderColor: Color(0xFF6b3600),
//                                borderSide: BorderSide(
//                                    color: (color1)
//                                        ? Color(0xFF6b3600)
//                                        : Colors.grey),
//                                onPressed: () {
//                                  setState(() {
//                                    color1 = !color1;
//                                    color2 = false;
//                                    color3 = false;
//                                    addresstype = 'Apartment';
//                                  });
//                                },
//                                child: Padding(
//                                  padding: EdgeInsets.only(top: 8.0),
//                                  child: Column(
//                                    children: [
//                                      Image.asset('assets/images/apartment.png',
//                                          height: 25),
//                                      Text('Apartment',
//                                          style: TextStyle(
//                                              fontSize: MediaQuery.of(context)
//                                                      .size
//                                                      .height *
//                                                  0.016,
//                                              color: Colors.black,
//                                              fontWeight: FontWeight.w300))
//                                    ],
//                                  ),
//                                ),
//                                disabledBorderColor: Colors.grey,
//                                color: Color(0xFF6b3600),
//                              ),
//                            ),
//                            SizedBox(
//                                width:
//                                    MediaQuery.of(context).size.width * 0.04),
                                  OutlineButton(
                                    highlightedBorderColor: Color(0xFF6b3600),
                                    borderSide: BorderSide(
                                        color: (color2)
                                            ? Color(0xFF6b3600)
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        color2 = !color2;
                                        color1 = false;
                                        color3 = false;
                                        addresstype = 'House';
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Image.asset('assets/images/house.png',
                                              height: 25),
                                          Text('House/Apartment ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w300))
                                        ],
                                      ),
                                    ),
                                    disabledBorderColor: Colors.grey,
                                    color: Color(0xFF6b3600),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.04),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: OutlineButton(
                                      highlightedBorderColor: Color(0xFF6b3600),
                                      borderSide: BorderSide(
                                          color: (color3)
                                              ? Color(0xFF6b3600)
                                              : Colors.grey),
                                      onPressed: () {
                                        setState(() {
                                          color3 = !color3;
                                          color2 = false;
                                          color1 = false;
                                          addresstype = 'Office';
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                                'assets/images/office.png',
                                                height: 25),
                                            Text('Office',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ],
                                        ),
                                      ),
                                      disabledBorderColor: Colors.grey,
                                      color: Color(0xFF6b3600),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.address),
                              ),
                            ),
                      type != 'Takeaway' && widget.address == ''
                          ? SizedBox(
                              height: 10,
                            )
                          : Container(),
                      type != 'Takeaway' && widget.address == ''
//                    ? Padding(
//                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                        child: CustomTextFormField(
//                          controller: addressController,
//                          textFormFieldStyle: textFormFieldTextStyle,
//                          prefixIconColor: AppColors.secondaryElement,
//                          hintTextStyle: hintTextStyle,
//                          borderStyle: BorderStyle.solid,
//                          borderWidth: Sizes.WIDTH_1,
//                          hintText: 'Enter Address',
//                          maxLines: 4,
//                          hasPrefixIcon: true,
//                          prefixIconImagePath: ImagePath.homeIcon,
//                        ),
//                      )
                          ? (addresstype == 'Apartment')
                              ? Form(
                                  key: _formkey,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xFF6b3600))),
                                              hintText: 'Building'),
                                          controller: buildingController,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xFF6b3600))),
                                              hintText: 'Floor'),
                                          controller: floorcontroller,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xFF6b3600))),
                                              hintText: 'Apartment'),
                                          controller: flatcontroller,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xFF6b3600))),
                                              hintText:
                                                  'Additional Directions'),
                                          maxLines: 2,
                                          controller: additionalcontroller,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : (addresstype == 'House')
                                  ? Form(
                                      key: _formkey,
                                      child: Column(
                                        children: [
                                          StreamBuilder(
                                              stream: Firestore.instance
                                                  .collection('Emirates')
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snap) {
                                                if (snap.hasData &&
                                                    !snap.hasError &&
                                                    snap.data != null) {
                                                  allemirates.clear();
                                                  emiratesname.clear();
                                                  for (int i = 0;
                                                      i <
                                                          snap.data.documents
                                                              .length;
                                                      i++) {
//                                              print(snap.data.documents.length);
                                                    emirate2 = snap.data
                                                        .documents[0]['name'];
//                                                    emiratesname.add(snap.data
//                                                        .documents[i]['name']);
                                                    Emirates emi = Emirates(
                                                        snap.data.documents[i]
                                                            ['deliveryCharge'],
                                                        snap.data.documents[i]
                                                            ['minOrderPrice'],
                                                        snap.data.documents[i]
                                                            ['name']);

                                                    allemirates.add(emi);
                                                  }
                                                  emiratesname.add('Sharjah');
                                                  emiratesname.add('Ajman');
                                                  return allemirates.length != 0
                                                      ? Column(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    new DropdownButtonFormField<
                                                                        String>(
                                                                  validator: (value) =>
                                                                      value ==
                                                                              null
                                                                          ? 'field required'
                                                                          : null,
                                                                  hint: Text(
                                                                      'Emirates'),
                                                                  value:
                                                                      emirate,
                                                                  items: emiratesname
                                                                      .map((String
                                                                          value) {
                                                                    return new DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child: new Text(
                                                                          value),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged: (String
                                                                      newValue) {
                                                                    setState(
                                                                        () {
                                                                      emirate =
                                                                          newValue;
                                                                      emirate2 =
                                                                          newValue;
                                                                      // print(emirate);
                                                                      alldata2(
                                                                          emirate,
                                                                          context);

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
//                                    StreamBuilder(
//                                        stream: Firestore.instance
//                                            .collection('EmiratesArea')
//                                            .where('Emirate',
//                                                isEqualTo: emirate)
//                                            .snapshots(),
//                                        builder: (BuildContext context,
//                                            AsyncSnapshot<QuerySnapshot> snap) {
//
//                                          if (snap.hasData &&
//                                              !snap.hasError &&
//                                              snap.data != null) {
//                                            length2=0;
////                                            final ProgressDialog pr =  ProgressDialog(context);
////                                            pr.style(
////                                                message: 'Please wait ..',
////                                                backgroundColor: Colors.white,
////                                                progressWidget: GFLoader(
////                                                  type: GFLoaderType.ios,
////                                                ),
////                                                elevation: 10.0,
////                                                insetAnimCurve: Curves.easeInOut,
////                                                progress: 0.0,
////                                                maxProgress: 100.0,
////                                                progressTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
////                                                messageTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
////                                            pr.show();
////                                            final ProgressDialog pr =  ProgressDialog(context);
////                                            pr.style(
////                                                message: 'Please wait ..',
////                                                backgroundColor: Colors.white,
////                                                progressWidget: GFLoader(
////                                                  type: GFLoaderType.ios,
////                                                ),
////                                                elevation: 10.0,
////                                                insetAnimCurve: Curves.easeInOut,
////                                                progress: 0.0,
////                                                maxProgress: 100.0,
////                                                progressTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
////                                                messageTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
////                                            pr.show();
//                                            allareas.clear();
//                                            areaname.clear();
//                                            index=0;
////                                            length2=0;
////                                             print('Streambuilder');
//                                            for (int i = 0;
//                                                i < snap.data.documents.length;
//                                                i++) {
//                                              length2=snap.data.documents.length;
//                                              if(i==0){
//                                                areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                                                EmiratesArea emi2=EmiratesArea( snap.data.documents[i]
//                                                ['Emirate'],
//                                                    snap.data.documents[i]
//                                                    ['deliveryCharge'],
//                                                    snap.data.documents[i]
//                                                    ['minOrderPrice'],
//                                                    '${snap.data.documents[i]['name']}',
//                                                    snap.data.documents[i]
//                                                    ['zone']);
//                                                allareas.add(emi2);
//                                              }
////                                              print(snap.data.documents.length);
//                                              for(int j=i+1;j<snap.data.documents.length;j++){
//                                                if(snap.data.documents[i]['name']==snap.data.documents[j]['name']){
//                                                  areaname.add(' ${snap.data.documents[j]['name']}');
//                                                  // print('5555555555555${snap.data.documents[j]['name']}');
//                                                  // print('Minorder${  snap.data.documents[j]
//                                                  // ['minOrderPrice']}');
//                                                  EmiratesArea emi2=EmiratesArea( snap.data.documents[j]
//                                                  ['Emirate'],
//                                                      snap.data.documents[j]
//                                                      ['deliveryCharge'],
//                                                      snap.data.documents[j]
//                                                      ['minOrderPrice'],
//                                                      ' ${snap.data.documents[j]['name']}',
//                                                      snap.data.documents[j]
//                                                      ['zone']);
//                                                  allareas.add(emi2);
//                                                  // print('length:${areaname.length}');
//                                                  index=j;
//                                                  // print('Index:${index}');
//
//
//                                                }
//
//                                              }
//
//                                               if(index!=i){
//                                                 areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                                                 EmiratesArea emi2=EmiratesArea( snap.data.documents[i]
//                                                 ['Emirate'],
//                                                     snap.data.documents[i]
//                                                     ['deliveryCharge'],
//                                                     snap.data.documents[i]
//                                                     ['minOrderPrice'],
//                                                     '${snap.data.documents[i]['name']}',
//                                                     snap.data.documents[i]
//                                                     ['zone']);
//                                                 allareas.add(emi2);
//                                               }
//                                               }
////                                            if(allareas.length==length2){
////                                              pr.hide();
////                                            }
//
//
//
//                                            areaname.add('Others');

//                                            return areaname.length != 0
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child:
                                                      new DropdownButtonFormField<
                                                          String>(
                                                    validator: (value) =>
                                                        value == null
                                                            ? 'field required'
                                                            : null,
                                                    hint: Text('Area'),
                                                    value: area,
                                                    items: areaname
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String newValue) {
                                                      setState(() {
                                                        area = newValue;
                                                        // print('DeliveryCharge:${deliveryCharge}');

                                                        // print(
                                                        //     '---------------');
                                                        // print(area);
                                                        if (area == 'Others') {
                                                          // print(
                                                          //     'Reached');
                                                          for (int i = 0;
                                                              i <
                                                                  allemirates
                                                                      .length;
                                                              i++) {
                                                            // print(
                                                            //     'yess');
                                                            // print(
                                                            //     '===============${emirate}');
                                                            if (emirate ==
                                                                allemirates[i]
                                                                    .name) {
                                                              // print(
                                                              //     'check');
                                                              // print(
                                                              //     emirate);
                                                              // print(allemirates[
                                                              //     i]);
                                                              setState(() {
                                                                minOrderPrice =
                                                                    double.parse(
                                                                        allemirates[i]
                                                                            .minorderprice);
                                                                deliveryCharge =
                                                                    double.parse(
                                                                        allemirates[i]
                                                                            .deliverycharge);
                                                              });
                                                            }
                                                          }
                                                        }
                                                        for (int i = 0;
                                                            i < getall.length;
                                                            i++) {
                                                          if (area ==
                                                              getall[i].name)
                                                            setState(() {
                                                              minOrderPrice =
                                                                  double.parse(
                                                                      getall[i]
                                                                          .minOrderPrice);
                                                              deliveryCharge =
                                                                  double.parse(
                                                                      getall[i]
                                                                          .deliveryCharge);
                                                            });
                                                        }
//                      Navigator.pop(context);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
//                                                : Container();
//                                          } else {
//                                            return Container();
//                                          }
//                                        }),
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Name*'),
//                                      controller: nameController,
//                                    ),
//                                  ),
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Phone no*'),
//                                      controller: phncontroller,
//                                    ),
//                                  ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value == '')
                                                  return 'Required field';
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF6b3600))),
                                                  hintText: 'Building name/no.,floor,apartment or villa no.*'),
                                              controller: buildingController,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value == '')
                                                  return 'Required field';
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF6b3600))),
                                                  hintText: 'Street name*'),
                                              controller: flatcontroller,
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
//                                        validator: (value){if(value==null||value=='')return 'Required field';return null;},

                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF6b3600))),
                                                  hintText: 'Additional Directions/Nearest Landmark'),
                                              maxLines: 2,
                                              controller: additionalcontroller,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Form(
                                      key: _formkey,
                                      child: Column(
                                        children: [
                                          StreamBuilder(
                                              stream: Firestore.instance
                                                  .collection('Emirates')
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snap) {
                                                if (snap.hasData &&
                                                    !snap.hasError &&
                                                    snap.data != null) {
                                                  allemirates.clear();
                                                  emiratesname.clear();
                                                  for (int i = 0;
                                                      i <
                                                          snap.data.documents
                                                              .length;
                                                      i++) {
                                                    // print(snap.data.documents.length);
                                                    emirate2 = snap.data
                                                        .documents[0]['name'];
//                                                    emiratesname.add(snap.data
//                                                        .documents[i]['name']);
                                                    Emirates emi = Emirates(
                                                        snap.data.documents[i]
                                                            ['deliveryCharge'],
                                                        snap.data.documents[i]
                                                            ['minOrderPrice'],
                                                        snap.data.documents[i]
                                                            ['name']);
                                                    allemirates.add(emi);
                                                  }
                                                  emiratesname.add('Sharjah');
                                                  emiratesname.add('Ajman');
                                                  return allemirates.length != 0
                                                      ? Column(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    new DropdownButtonFormField<
                                                                        String>(
                                                                  validator: (value) =>
                                                                      value ==
                                                                              null
                                                                          ? 'field required'
                                                                          : null,
                                                                  hint: Text(
                                                                      'Emirates'),
                                                                  value:
                                                                      emirate,
                                                                  items: emiratesname
                                                                      .map((String
                                                                          value) {
                                                                    return new DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child: new Text(
                                                                          value),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged: (String
                                                                      newValue) {
                                                                    setState(
                                                                        () {
                                                                      emirate =
                                                                          newValue;
                                                                      emirate2 =
                                                                          newValue;
                                                                      // print(emirate);
                                                                      alldata2(
                                                                          emirate,
                                                                          context);
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
//                                    StreamBuilder(
//                                        stream: Firestore.instance
//                                            .collection('EmiratesArea')
//                                            .where('Emirate',
//                                                isEqualTo: emirate)
//                                            .snapshots(),
//                                        builder: (BuildContext context,
//                                            AsyncSnapshot<QuerySnapshot> snap) {
//                                          if (snap.hasData &&
//                                              !snap.hasError &&
//                                              snap.data != null) {
//                                            allareas.clear();
//                                            areaname.clear();
//                                            index=0;
//                                            for (int i = 0;
//                                            i < snap.data.documents.length;
//                                            i++) {
//                                              // print(snap.data.documents.length);
//                                              for(int j=i+1;j<snap.data.documents.length;j++){
//                                                if(snap.data.documents[i]['name']==snap.data.documents[j]['name']){
//                                                  areaname.add(' ${snap.data.documents[j]['name']}');
//                                                  // print('5555555555555${snap.data.documents[j]['name']}');
//                                                  // print('Minorder${  snap.data.documents[j]
//                                                  // ['minOrderPrice']}');
//                                                  EmiratesArea emi2=EmiratesArea( snap.data.documents[j]
//                                                  ['Emirate'],
//                                                      snap.data.documents[j]
//                                                      ['deliveryCharge'],
//                                                      snap.data.documents[j]
//                                                      ['minOrderPrice'],
//                                                      ' ${snap.data.documents[j]['name']}',
//                                                      snap.data.documents[j]
//                                                      ['zone']);
//                                                  allareas.add(emi2);
//                                                  // print('length:${areaname.length}');
//                                                  index=j;
//                                                  // print('Index:${index}');
//
//
//                                                }
//
//                                              }
//                                              if(i!=index){
//                                                areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                                                EmiratesArea emi2=EmiratesArea( snap.data.documents[i]
//                                                ['Emirate'],
//                                                    snap.data.documents[i]
//                                                    ['deliveryCharge'],
//                                                    snap.data.documents[i]
//                                                    ['minOrderPrice'],
//                                                    '${snap.data.documents[i]['name']}',
//                                                    snap.data.documents[i]
//                                                    ['zone']);
//                                                allareas.add(emi2);
//                                              }
//
//                                            }
//                                            areaname.add('Others');
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child:
                                                      new DropdownButtonFormField<
                                                          String>(
                                                    validator: (value) =>
                                                        value == null
                                                            ? 'field required'
                                                            : null,
                                                    hint: Text('Area'),
                                                    value: area,
                                                    items: areaname
                                                        .map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String newValue) {
                                                      setState(() {
                                                        area = newValue;
                                                        // print(
                                                        //     '---------------------');
                                                        // print(area);

                                                        if (area == 'Others') {
                                                          for (int i = 0;
                                                              i <
                                                                  allemirates
                                                                      .length;
                                                              i++) {
                                                            if (emirate2 ==
                                                                allemirates[i]
                                                                    .name) {
                                                              setState(() {
                                                                minOrderPrice =
                                                                    double.parse(
                                                                        allemirates[i]
                                                                            .minorderprice);
                                                                deliveryCharge =
                                                                    double.parse(
                                                                        allemirates[i]
                                                                            .deliverycharge);
                                                              });
                                                            }
                                                          }
                                                        }

                                                        for (int i = 0;
                                                            i < getall.length;
                                                            i++) {
                                                          if (area ==
                                                              getall[i].name)
                                                            setState(() {
                                                              minOrderPrice =
                                                                  double.parse(
                                                                      getall[i]
                                                                          .minOrderPrice);
                                                              deliveryCharge =
                                                                  double.parse(
                                                                      getall[i]
                                                                          .deliveryCharge);
                                                            });
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
//                                                : Container();
//                                          } else {
//                                            return Container();
//                                          }
//                                        }),
//                                  Padding(
//                                  padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Name*'),
//                                      controller: nameController,
//                                    ),
//                                  ),
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Phone no*'),
//                                      controller: phncontroller,
//                                    ),
//                                  ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value == '')
                                                  return 'Required field';
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF6b3600))),
                                                  hintText: 'Building name/no.,floor*'),
                                              controller: buildingController,
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
//                                        validator: (value){if(value==null||value=='')return 'Required field';return null;},
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF6b3600))),
                                                  hintText: 'Additional Directions/Nearest Landmark'),
                                              maxLines: 2,
                                              controller: additionalcontroller,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                          : Container(),
                      type != 'Takeaway' && widget.address == ''
                          ? CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              checkColor: Colors.white,
                              activeColor: AppColors.secondaryElement,
                              title: Text("Save to my addresses"),
                              value: ischecked,
                              onChanged: (newValue) {
                                setState(() {
                                  ischecked = !ischecked;
                                });
                                if (ischecked == true) {
                                  // print(ischecked);
                                  if (_formkey.currentState.validate()) {
                                    setaddress();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Address required',
                                        toastLength: Toast.LENGTH_SHORT);
                                  }
                                }
                              })
                          : Container(),
                      type != 'Takeaway'
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0, vertical: 10),
                              child: angadiButton(
                                'Saved addresses',
                                buttonWidth: MediaQuery.of(context).size.width,
                                onTap: () {
                                  setState(() {});
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) {
                                    return MyAddresses2(docid);
                                  }));
                                },
                              ),
                            )
                          : Container(),
                      Form(
                        key: _formkey2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Required field';
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(2),
                                    borderSide: BorderSide(color: Colors.grey)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(2),
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(2),
                                    borderSide:
                                        BorderSide(color: Color(0xFF6b3600))),
                                hintText: 'Phone Number *'),
                            controller: PhoneNumber,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, bottom: 0, top: 20),
                        child: HeadingRow(
                          title: 'Bill',
                          number: '',
                        ),
                      ),

                      Bill(),
                      discount == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No promo code applied!'),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return ApplyOffers(this, context);
                                    }));
                                  },
                                  child: Text(
                                    ' Apply Promo Code',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    '${discount.discount}% off promo code applied!'),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return ApplyOffers(this, context);
                                    }));
                                  },
                                  child: Text(
                                    ' Change',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                      type != 'Takeaway'
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 12, top: 12),
                              child: HeadingRow(
                                title: 'Notes',
                                number: '',
                              ),
                            )
                          : Container(),
                      type != 'Takeaway'
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: CustomTextFormField(
                                controller: notesController,
                                textFormFieldStyle: textFormFieldTextStyle,
                                prefixIconColor: AppColors.secondaryElement,
                                hintTextStyle: hintTextStyle,
                                borderStyle: BorderStyle.solid,
                                borderWidth: Sizes.WIDTH_1,
                                hintText: 'Add delivery note (Optional)',
                                maxLines: 2,
                                hasPrefixIcon: true,
                                prefixIconImagePath:
                                    ImagePath.activeBookmarksIcon,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      type == 'Delivery'
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 0, top: 10),
                              child: HeadingRow(
                                title: 'Delivery Time',
                                number: '',
                              ),
                            )
                          : Container(),
                      type == 'Delivery'
                          ? InkWell(
                              onTap: () {
//                          scaffoldState.currentState.showBottomSheet((context) {
//                            return StatefulBuilder(builder:
//                                (BuildContext context, StateSetter state) {
//                              return dropdown(
//                                  context,
//                                  MediaQuery.of(context).size.height * 0.3,
//                                  MediaQuery.of(context).size.width * 0.9);
//                            });
//                          });
//                          _pickTime().then((value) {
//                            setState(() {
//                              selectedTime = value;
//                            });
//                          });
                              },
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    AppColors.secondaryElement),
                                            borderRadius:
                                                BorderRadius.all(Radius.zero)),
                                        child: Row(
                                          children: [
                                            Text('    Next Delivery: '),
                                            Icon(
                                              Icons.delivery_dining,
                                              color: AppColors.secondaryElement,
                                            ),
                                            SizedBox(width: 5),
                                            InkWell(
                                                onTap: () {
                                                  _pickTime().then((value) {
                                                    setState(() {
                                                      selectedDate = value;
                                                    });
                                                  });
                                                },
                                                child: selectedDate != null
                                                    ? Text(
                                                        '${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()} ',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF6b3600)),
                                                      )
                                                    : Text(
                                                        '${date.day.toString()}/${date.month.toString()}/${selectedDate.year.toString()} ',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF6b3600)),
                                                      )),
                                            Text(' at '),
                                            Icon(
                                              Icons.timer,
                                              size: 19,
                                              color: AppColors.secondaryElement,
                                            ),
                                            SizedBox(width: 5),
                                            InkWell(
                                                onTap: () {
                                                  _timeDialog(context);
                                                },
                                                child: Text(
                                                  '$selectedTime ',
                                                  style: TextStyle(
                                                      color: Color(0xFF6b3600)),
                                                )),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                                          ],
                                        ),
                                      ),
//                                    child: Text(
//                                      'Schedule Delivery Time',
//                                      style: TextStyle(
//                                          color: Colors.blue, fontSize: 20),
                                    ),
                                  ))
//                            : Row(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: [
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: Card(
//                                      child: Padding(
//                                        padding: const EdgeInsets.all(8.0),
//                                        child: Container(
//                                            width: MediaQuery.of(context)
//                                                    .size
//                                                    .width *
//                                                0.89,
////                                        child: selectedTime.hour < 23 &&
//////                                                  selectedTime.hour > 10
//                                            child: Text(
//                                              'Delivery Date and Time is ${date.day}-${date.month}-${date.year} , ${selectedTime}. Your order will reach to you on time. Click to edit date and time.',
//                                              style: TextStyle(
//                                                  fontSize:
//                                                      MediaQuery.of(context)
//                                                              .size
//                                                              .height *
//                                                          0.015,
//                                                  color: Colors.blue,
//                                                  fontWeight: FontWeight.bold),
//                                            )
////                                              : Text(
////                                                  'Sorry we do not deliver after 11:00 PM and before 10:00 AM. Click to choose another time.',
////                                                  style: TextStyle(
////                                                      color: Colors.red,
////                                                      fontWeight:
////                                                          FontWeight.bold)),
//                                            ),
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ))
//                    : type == 'Delivery'
//                        ? Padding(
//                            padding: const EdgeInsets.only(
//                                left: 12.0, bottom: 0, top: 10),
//                            child: HeadingRow(
//                              title: 'Delivery Time',
//                              number: '',
//                            ),
//                          )
//                        : Container(),
//                type == 'Delivery'
//                    ? InkWell(
//                        onTap: () {
//                          scaffoldState.currentState.showBottomSheet((context) {
//                            return StatefulBuilder(builder:
//                                (BuildContext context, StateSetter state) {
//                              return dropdown(
//                                  context,
//                                  MediaQuery.of(context).size.height * 0.12,
//                                  MediaQuery.of(context).size.width * 0.9);
//                            });
//                          });
////                          _pickTime().then((value) {
////                            setState(() {
////                              selectedTime = value;
////                            });
////                          });
//                        },
//                        child: selectedTime == null
//                            ? Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Card(
//                                  elevation: 5,
//                                  child: Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: Text(
//                                      'Schedule Delivery Time',
//                                      style: TextStyle(
//                                          color: Colors.blue, fontSize: 20),
//                                    ),
//                                  ),
//                                ),
//                              )
//                            : Row(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: [
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: Card(
//                                      child: Padding(
//                                        padding: const EdgeInsets.all(8.0),
//                                        child: Container(
//                                            width: MediaQuery.of(context)
//                                                    .size
//                                                    .width *
//                                                0.89,
////                                        child: selectedTime.hour < 23 &&
//////                                                  selectedTime.hour > 10
//                                            child: Text(
//                                              'Delivery Time is ${selectedTime}. Your order will reach to you on time. Click to edit time.',
//                                              style: TextStyle(
//                                                  fontSize:
//                                                      MediaQuery.of(context)
//                                                              .size
//                                                              .height *
//                                                          0.015,
//                                                  color: Colors.blue,
//                                                  fontWeight: FontWeight.bold),
//                                            )
////                                              : Text(
////                                                  'Sorry we do not deliver after 11:00 PM and before 10:00 AM. Click to choose another time.',
////                                                  style: TextStyle(
////                                                      color: Colors.red,
////                                                      fontWeight:
////                                                          FontWeight.bold)),
//                                            ),
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ))
                              )
                          : Container(),
                      _result != '833'
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 0, top: 10),
                              child: HeadingRow(
                                title: 'Choose Payment Method',
                                number: '',
                              ),
                            )
                          : Container(),
                      _result != '833'
                          ? SizedBox(
                              height: 20,
                            )
                          : Container(),
                      Column(
                        children: [
                          _result != '833' && type != 'Takeaway'
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: angadiButton('Cash On Delivery',
                                      buttonWidth: MediaQuery.of(context)
                                          .size
                                          .width, onTap: () {
                                    // print('-------------------------------------');

                                    if (widget.address != '') {
                                      if (_formkey2.currentState.validate()) {
                                        if (widget.SavedArea != '') {
//
//                                    for (int i = 0; i < savedarea.length; i++) {
//                                      if (widget.SavedArea ==
//                                          savedarea[i].name) {
//                                        print(widget.SavedArea);
//                                        setState(() {
//                                          minOrderPrice = double.parse(
//                                              savedarea[i].minOrderPrice);
//                                          deliveryCharge = double.parse(
//                                              savedarea[i].deliveryCharge);
//                                        });
//                                      }
//                                      print('kkkkkkkkkkkkkkkkkkkkkkk');
//                                      print(minOrderPrice);
//                                      print(deliveryCharge);
//                                    }
//                                  }
                                          if (selectedTime == 'Choose Slot') {
                                            Fluttertoast.showToast(
                                                msg: 'Please select time slot',
                                                toastLength:
                                                    Toast.LENGTH_SHORT);
                                          } else {
                                            var total = 0.0;
                                            discount != null
                                                ? total = ((totalAmount() *
                                                        0.18) +
                                                    totalAmount() -
                                                    (totalAmount() *
                                                        (double.parse(discount
                                                                .discount) /
                                                            100)) +
                                                    deliveryCharge)
                                                : total =
                                                    ((totalAmount() * 0.18) +
                                                        totalAmount() +
                                                        deliveryCharge);
                                            if (total > minOrderPrice) {
                                              showAlertDialog(context);
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'The minimum order price is :${minOrderPrice.toString()}',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT);
                                            }
                                          }
//                                var total = 0.0;
//                                discount != null
//                                    ? total = ((totalAmount() * 0.18) +
//                                        totalAmount() -
//                                        (totalAmount() *
//                                            (double.parse(discount.discount) /
//                                                100)) +
//                                        deliveryCharge)
//                                    : total = ((totalAmount() * 0.18) +
//                                        totalAmount() +
//                                        deliveryCharge);
//                                if (total > minOrderPrice) {
//                                  showAlertDialog(context);
//                                } else {
//                                  Fluttertoast.showToast(
//                                      msg:
//                                          'Your order amount is less \n than the minimum order price',
//                                      toastLength: Toast.LENGTH_SHORT);
//                                }
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Please enter the details correctly',
                                              toastLength: Toast.LENGTH_SHORT);
                                        }
                                      }
                                    }
//

                                    if (widget.address == '') {
                                      if (_formkey.currentState.validate() &&
                                          _formkey2.currentState.validate()) {
//                                    if (widget.SavedArea != '') {
//                                      for (int i = 0; i <
//                                          allareas.length; i++) {
//                                        if (widget.SavedArea ==
//                                            allareas[i].name) {
//                                          setState(() {
//                                            minOrderPrice = double.parse(
//                                                allareas[i].minOrderPrice);
//                                            deliveryCharge = double.parse(
//                                                allareas[i].deliveryCharge);
//                                          });
//                                        }
//                                        print(minOrderPrice);
//                                        print(deliveryCharge);
//                                      }
//                                    }
                                        if (selectedTime == 'Choose Slot') {
                                          Fluttertoast.showToast(
                                              msg: 'Please select time slot',
                                              toastLength: Toast.LENGTH_SHORT);
                                        } else {
                                          var total = 0.0;
                                          discount != null
                                              ? total =
                                                  ((totalAmount() * 0.18) +
                                                      totalAmount() -
                                                      (totalAmount() *
                                                          (double.parse(discount
                                                                  .discount) /
                                                              100)) +
                                                      deliveryCharge)
                                              : total =
                                                  ((totalAmount() * 0.18) +
                                                      totalAmount() +
                                                      deliveryCharge);
                                          if (total > minOrderPrice) {
                                            showAlertDialog(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'The minimum order price is:${minOrderPrice.toString()}',
                                                toastLength:
                                                    Toast.LENGTH_SHORT);
                                          }
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                'Please enter the details correctly',
                                            toastLength: Toast.LENGTH_SHORT);
                                      }
                                    }
                                  }),
                                )
                              : type == 'Takeaway'
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      child: angadiButton('Pay on Pickup',
                                          buttonWidth: MediaQuery.of(context)
                                              .size
                                              .width, onTap: () {
                                        placeOrder(type);
                                      }),
                                    )
                                  : Container(),
                          _result != '833'
                              ? SizedBox(
                                  height: 20,
                                )
                              : Container(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: angadiButton(
                              _result != '833' && val
                                  ? 'Proceed to pay online'
                                  : 'Go to my orders',
                              onTap: () {
                                if (widget.SavedArea != '') {
                                  if (_formkey2.currentState.validate()) {
                                    //    for (int i = 0; i < savedarea.length; i++) {
//    if (widget.SavedArea ==
//    savedarea[i].name) {
//    print(widget.SavedArea);
//    setState(() {
//    minOrderPrice = double.parse(
//    savedarea[i].minOrderPrice);
//    deliveryCharge = double.parse(
//    savedarea[i].deliveryCharge);
//    });
//    }
//    print('kkkkkkkkkkkkkkkkkkkkkkk');
//    print(minOrderPrice);
//    print(deliveryCharge);

//    }
                                    if (selectedTime == 'Choose Slot') {
                                      Fluttertoast.showToast(
                                          msg: 'Please select time slot',
                                          toastLength: Toast.LENGTH_SHORT);
                                    } else {
                                      var total = 0.0;
                                      discount != null
                                          ? total = ((totalAmount() * 0.18) +
                                              totalAmount() -
                                              (totalAmount() *
                                                  (double.parse(
                                                          discount.discount) /
                                                      100)) +
                                              deliveryCharge)
                                          : total = ((totalAmount() * 0.18) +
                                              totalAmount() +
                                              deliveryCharge);
                                      if (total > minOrderPrice) {
                                        _result != '833' && j != 1 && val
                                            ? onlineorder(
                                                (discount != null)
                                                    ? ((totalAmount() * 0.18) +
                                                            totalAmount() -
                                                            (totalAmount() *
                                                                (double.parse(
                                                                        discount
                                                                            .discount) /
                                                                    100)) +
                                                            deliveryCharge)
                                                        .toStringAsFixed(2)
                                                    : ((totalAmount() * 0.18) +
                                                            totalAmount() +
                                                            deliveryCharge)
                                                        .toString(),
                                                type,
                                                orderid)
                                            : Checksuccess();
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                'The minimum order price is :${minOrderPrice.toString()}',
                                            toastLength: Toast.LENGTH_SHORT);
                                      }
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Please enter the details correctly',
                                        toastLength: Toast.LENGTH_SHORT);
                                  }
                                }

                                if (widget.address == '') {
                                  if (_formkey.currentState.validate() &&
                                      _formkey2.currentState.validate()) {
//                    if (widget.SavedArea != '') {
//                    for (int i = 0; i <
//                    allareas.length; i++) {
//                    if (widget.SavedArea ==
//                    allareas[i].name) {
//                    setState(() {
//                    minOrderPrice = double.parse(
//                    allareas[i].minOrderPrice);
//                    deliveryCharge = double.parse(
//                    allareas[i].deliveryCharge);
//                    });
//                    }
//                    print(minOrderPrice);
//                    print(deliveryCharge);
//                    }
//                    }
                                    if (selectedTime == 'Choose Slot') {
                                      Fluttertoast.showToast(
                                          msg: 'Please select time slot',
                                          toastLength: Toast.LENGTH_SHORT);
                                    } else {
                                      var total = 0.0;
                                      discount != null
                                          ? total = ((totalAmount() * 0.18) +
                                              totalAmount() -
                                              (totalAmount() *
                                                  (double.parse(
                                                          discount.discount) /
                                                      100)) +
                                              deliveryCharge)
                                          : total = ((totalAmount() * 0.18) +
                                              totalAmount() +
                                              deliveryCharge);
                                      if (total > minOrderPrice) {
                                        _result != '833' && j != 1 && val
                                            ? onlineorder(
                                                (discount != null)
                                                    ? ((totalAmount() * 0.18) +
                                                            totalAmount() -
                                                            (totalAmount() *
                                                                (double.parse(
                                                                        discount
                                                                            .discount) /
                                                                    100)) +
                                                            deliveryCharge)
                                                        .toStringAsFixed(2)
                                                    : ((totalAmount() * 0.18) +
                                                            totalAmount() +
                                                            deliveryCharge)
                                                        .toString(),
                                                type,
                                                orderid)
                                            : Checksuccess();
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                'The minimum order price is:${minOrderPrice.toString()}',
                                            toastLength: Toast.LENGTH_SHORT);
                                      }
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Please enter the details correctly',
                                        toastLength: Toast.LENGTH_SHORT);
                                  }
                                }

//                        if(_formkey.currentState.validate()){
//                            _result != '833' && j != 1
//                                ? onlineorder(
//                                (discount != null)
//                                    ? ((totalAmount() * 0.18) +
//                                    totalAmount() -
//                                    (totalAmount() *
//                                        (double.parse(
//                                            discount.discount) /
//                                            100)))
//                                    .toStringAsFixed(2)
//                                    : ((totalAmount() * 0.18) + totalAmount())
//                                    .toString(),
//                                type,
//                                orderid)
//                                : Checksuccess();
//                          }
//                         else{
//                            Fluttertoast.showToast(
//                                msg: 'Address required', toastLength: Toast.LENGTH_SHORT);
//                          }
                              },
                              buttonWidth: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      )
                    ],
                  )
                : Center(
                    child: Container(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator()),
                  ),
          ),
        ));
  }

  FirebaseUser user;

  getUserDetails() async {
    user = await FirebaseAuth.instance.currentUser();
  }

  var docID;
  var dd;
  var id;
  void set(String title) async {
    await getUserDetails();
    // print('title:${title}');
    List titles = [];
//    titles.add(title);
    List check = [];
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((value) {
      Map map = value.data;
      check = map['couponUsed'];
      for (int i = 0; i < check.length; i++) {
        titles.add(check[i]);
      }

      // print('checkkkkkkkkkkkkkkkkkkkk${check.length}');

      titles.add(title);
      // print('========================${titles}');
      Firestore.instance.collection('Users').document(user.uid).updateData({
        'couponUsed': titles,
      });
    });
  }

  TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid:
          'AC88a8448d0a8b43fe42e5a75abf494c66', // replace *** with Account SID
      authToken:
          '10026062638aa681a90b74c127293ee6', // replace xxx with Auth Token
      twilioNumber: '+18573424327' // replace .... with Twilio Number
      );

  send(orderNumber) async {
    print(user.email);
    var options = new GmailSmtpOptions()
      ..username = 'axactstudios@gmail.com'
      ..password = 'aascaasc3838';

    var emailTransport = new SmtpTransport(options);

    // Create our mail/envelope.
    var envelope = new Envelope()
      ..from = 'axactstudios@gmail.com'
      ..recipients.add(user.email)
      ..subject = 'YOUR ORDER $orderNumber THROUGH ANGADI.AE'
      ..text =
          'Your order $orderNumber is successfully placed and confirmed! Check your order details on the app.';

    // Email it.
    emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));
  }

  placeOrder(orderType) async {
    var dis;
    var coupon;
    (discount != null) ? coupon = discount.title : coupon = '';
    set(coupon);

//    if(discount.discount==''&&discount.discount==null){
//      dis='0.0';
//    }
//    else{
//      dis=double.parse(discount.discount).toString();
//    }

    discount != null
        ? dis =
            ('${(totalAmount() * (double.parse(discount.discount) / 100)).toStringAsFixed(2)}')
        : dis = ' 0';
    // print('----------------------');
    // print(selectedDate);
    // print(selectedDate.year);
    // print(selectedTime.split(' ').join().toLowerCase());
    var tt = selectedTime.split(' ').join().toLowerCase();
    String s = '';
    for (int i = 0; i < selectedTime.length; i++) {
      if (selectedTime[i] != ' ')
        s = s + selectedTime[i];
      else
        break;
    }

    dd = int.parse(s);
    if (selectedTime.contains('PM')) dd = dd + 12;
    // print(
    //     'Hours are $dd ${DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd)}');
    var rng = new Random();
    var code = rng.nextInt(90000) + 10000;
    // print('ANG${code.toString()}');
    setState(() {
      id = 'ANG${code.toString()}';
    });

    await getUserDetails();
    List items = [];
    List prices = [];
    List quantities = [];
    List productIDs = [];
    List qtytags = [];
    for (var v in cartItems) {
      // print(v.productName);
      items.add(v.productName);
      prices.add(v.price);
      quantities.add(v.qty);
      productIDs.add(v.id);
      qtytags.add(v.qtyTag);
    }
    final databaseReference = Firestore.instance;
    orderType == 'Delivery' &&
            addresstype == 'Apartment' &&
            widget.address == ''
        ? await databaseReference
            .collection('Orders')
            .document(orderid)
            .setData({
            'Items': items,
            'Price': prices,
            'Qty': quantities,
            'Type': orderType,
            'ProductIDs': productIDs,
            'orderid': orderid,
            'UserID': user.uid,
            'Quantity': qtytags,
            'CouponUsed': coupon,
            'phoneNumber': PhoneNumber.text,
            'paymentMethod': 'Cash On Delivery',
            'discountPrice': dis,
            'Address':
                'Building :${buildingController.text} , Apartment :${flatcontroller.text} , Floor:${floorcontroller.text}, Additional Directions :${additionalcontroller.text}',
            'DeliveryDate': DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day, dd),
            'DeliveryTime': selectedTime,
            'TimeStamp': Timestamp.now(),
            'Status': 'Order Confirmed',
            'Notes':
                notesController.text != null ? notesController.text : 'None',
            'GrandTotal':
                ((totalAmount() * 0.18) + totalAmount() + deliveryCharge)
                    .toStringAsFixed(2),
          }).then((value) {
            setState(() {
//              docID = value;
            });
          })
        : orderType == 'Delivery' &&
                addresstype == 'House' &&
                widget.address == ''
            ? await databaseReference
                .collection('Orders')
                .document(orderid)
                .setData({
                'Items': items,
                'Price': prices,
                'Qty': quantities,
                'ProductIDs': productIDs,
                'Type': orderType,
                'Quantity': qtytags,
                'CouponUsed': coupon,
                'UserID': user.uid,
                'orderid': orderid,
                'phoneNumber': PhoneNumber.text,
                'paymentMethod': 'Cash On Delivery',
                'discountPrice': dis,
                'Address':
                    'Emirate:${emirate},Area:${area},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}',
                'DeliveryDate': DateTime(selectedDate.year, selectedDate.month,
                    selectedDate.day, dd),
                'DeliveryTime': selectedTime,
                'TimeStamp': Timestamp.now(),
                'Status': 'Awaiting Confirmation',
                'Notes': notesController.text != null
                    ? notesController.text
                    : 'None',
                'GrandTotal':
                    ((totalAmount() * 0.18) + totalAmount() + deliveryCharge)
                        .toStringAsFixed(2),
              }).then((value) {
                setState(() {
//              docID = value;
                });
              })
            : orderType == 'Delivery' &&
                    addresstype == 'Office' &&
                    widget.address == ''
                ? await databaseReference
                    .collection('Orders')
                    .document(orderid)
                    .setData({
                    'Items': items,
                    'Price': prices,
                    'Qty': quantities,
                    'ProductIDs': productIDs,
                    'Type': orderType,
                    'orderid': orderid,
                    'UserID': user.uid,
                    'Quantity': qtytags,
                    'CouponUsed': coupon,
                    'phoneNumber': PhoneNumber.text,
                    'paymentMethod': 'Cash On Delivery',
                    'discountPrice': dis,
                    'Address':
                        'Emirate:${emirate},Area:${area},${buildingController.text},Additional Directions:${additionalcontroller.text}',
                    'DeliveryDate': DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day, dd),
                    'DeliveryTime': selectedTime,
                    'TimeStamp': Timestamp.now(),
                    'Status': 'Awaiting Confirmation',
                    'Notes': notesController.text != null
                        ? notesController.text
                        : 'None',
                    'GrandTotal': ((totalAmount() * 0.18) +
                            totalAmount() +
                            deliveryCharge)
                        .toStringAsFixed(2),
                  }).then((value) {
                    setState(() {
//              docID = value;
                    });
                  })
                : orderType == 'Delivery' && widget.address != ''
                    ? await databaseReference
                        .collection('Orders')
                        .document(orderid)
                        .setData({
                        'Items': items,
                        'Price': prices,
                        'Qty': quantities,
                        'Type': orderType,
                        'UserID': user.uid,
                        'Quantity': qtytags,
                        'CouponUsed': coupon,
                        'orderid': orderid,
                        'phoneNumber': PhoneNumber.text,
                        'paymentMethod': 'Cash On Delivery',
                        'discountPrice': dis,
                        'ProductIDs': productIDs,
                        'Address': widget.address,
                        'DeliveryDate': DateTime(selectedDate.year,
                            selectedDate.month, selectedDate.day, dd),
                        'DeliveryTime': selectedTime,
                        'TimeStamp': Timestamp.now(),
                        'Status': 'Awaiting Confirmation',
                        'Notes': notesController.text != null
                            ? notesController.text
                            : 'None',
                        'GrandTotal': ((totalAmount() * 0.18) +
                                totalAmount() +
                                deliveryCharge)
                            .toStringAsFixed(2),
                      }).then((value) {
                        setState(() {
//              docID = value;
                        });
                      })
                    : orderType == 'Takeaway'
                        ? await databaseReference
                            .collection('Orders')
                            .document(orderid)
                            .setData({
                            'Items': items,
                            'Price': prices,
                            'Qty': quantities,
                            'Type': orderType,
                            'OrderID': orderid,
                            'ProductIDs': productIDs,
                            'CouponUsed': coupon,
                            'UserID': user.uid,
                            'Quantity': qtytags,
                            'phoneNumber': phncontroller.text,
                            'paymentMethod': 'Takeaway',
                            'discountPrice': dis,
                            'isPaid': false,
                            // 'Status':'${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                            'TimeStamp': Timestamp.now(),
                            'Status': 'Awaiting Confirmation',
                            'GrandTotal':
                                ((totalAmount() * 0.18) + totalAmount())
                                    .toStringAsFixed(2),
                          }).then((value) {
                            setState(() {
//                  docID = value.documentID;
                            });
                          })
                        : await databaseReference
                            .collection('Orders')
                            .document(orderid)
                            .setData({
                            'Items': items,
                            'Price': prices,
                            'Qty': quantities,
                            'Type': orderType,
                            'ProductIDs': productIDs,
                            'UserID': user.uid,
                            'orderid': orderid,
                            'Quantity': qtytags,
                            'CouponUsed': coupon,
                            'DeliveryDate': selectedDate,
                            'phoneNumber': PhoneNumber.text,
                            'paymentMethod': 'Cash On Delivery',
                            'discountPrice': dis,
                            'DeliveryTime': selectedTime,
                            'Address':
                                '${hnoController.text},${addressController.text} ',
                            'TimeStamp': Timestamp.now(),
                            'Status': 'Awaiting Confirmation',
//                'DeliveryTime': selectedTime.toString(),
                            'Notes': notesController.text != null
                                ? notesController.text
                                : 'None',
                            'GrandTotal': ((totalAmount() * 0.18) +
                                    totalAmount() +
                                    deliveryCharge)
                                .toStringAsFixed(2),
                          }).then((value) {
                            setState(() {
//                  docID = value.documentID;
                            });
                          });

    await databaseReference.collection('Notifications').add({
      'UserID': user.uid,
      'OrderID': orderid,
      'Notification': 'Order Placed. Awaiting confirmation.',
      'DeliveryDate':
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),
      'DeliveryTime': selectedTime,
      'TimeStamp': Timestamp.now(),
      'Type': orderType,
      'GrandTotal': ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
    });
    print('+91${PhoneNumber.text}');
    send(orderid);
    await twilioFlutter.sendSMS(
        toNumber: '+91${PhoneNumber.text}',
        messageBody:
            'Sent from a Twilio trial account. Your order $orderid is successfully placed and confirmed! Check your order details on the app.');

    // for (int i = 0; i < cartItems.length; i++) {
    //   await databaseReference
    //       .collection('Orders')
    //       .document(docID)
    //       .collection('Items')
    //       .add({
    //     'ItemName': cartItems[i].productName,
    //     'Price': cartItems[i].price,
    //     'Quantity': cartItems[i].qty,
    //     'ImageURL': cartItems[i].imgUrl
    //   });
    // }

    removeAll();
    String status;
    Firestore.instance.collection('Orders').getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.documentID == orderid) {
          status = element['Status'];
        }
      });
    });
    Timestamp myTimeStamp = Timestamp.fromDate(selectedDate);
    // print(myTimeStamp.toString());

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return HomeScreen();
    }));
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Place Order"),
          content: Text("Your order will be placed!"),
          actions: [
            FlatButton(
              color: Colors.red,
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              color: AppColors.secondaryElement,
              child: Text("Place Order"),
              onPressed: () {
                placeOrder(type);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void removeAll() async {
    // Assuming that the number of rows is the id for the last row.
    for (var v in cartItems) {
      final rowsDeleted = await dbHelper.delete(v.productName, v.qtyTag);
    }
  }

  final Geolocator geolocator = Geolocator();

  LocationData _currentPosition;

  Location location = new Location();
  String currentAddress = 'Enter Address';
  Future<Position> _getCurrentLocation() async {
    _currentPosition = await location.getLocation();
//    Position position = await geolocator.getCurrentPosition(
//        desiredAccuracy: LocationAccuracy.high);
//    print(position);
//    geolocator
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//        .then((Position position) {
//      setState(() {
//        _currentPosition = position;
//      });
//     print(_currentPosition);
    _getAddressFromLatLng();
    // print(_currentPosition);
  }

  _getAddressFromLatLng() async {
    try {
      final coordinates =
          Coordinates(_currentPosition.latitude, _currentPosition.longitude);

// this fetches multiple address, but you need to get the first address by doing the following two codes
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;

      setState(() {
        currentAddress =
            "${first.subLocality}, ${first.locality}, ${first.postalCode}, ${first.countryName},  ${first.adminArea} ";
        // print(currentAddress);
        addressController.text = currentAddress;
      });
    } catch (e) {
      // print(e);
    }
  }

  Widget Bill() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sub Total-'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.187,
//                  ),
//                  Text(':'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
                  Text('AED. ${totalAmount().toString()}')
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount-'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.2,
//                  ),
//                  Text(':'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
                  Text(discount != null
                      ? 'AED. ${(totalAmount() * (double.parse(discount.discount) / 100)).toStringAsFixed(2)}'
                      : 'AED. 0'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Taxes and Charges-'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
//                  Text(':'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
                  Text('AED. ${(totalAmount() * 0.18).toStringAsFixed(2)}'),
                ],
              ),
              (deliveryCharge != 0)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Charge-'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
//                  Text(':'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
                        Text('AED. ${deliveryCharge.toString()}'),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 0.5,
                color: Colors.black,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Grand Total-'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.147,
//                  ),
//                  Text(':'),
//                  SizedBox(
//                    width: MediaQuery.of(context).size.width * 0.03,
//                  ),
                  Text(discount != null
                      ? 'AED. ${((totalAmount() * 0.18) + totalAmount() - (totalAmount() * (double.parse(discount.discount) / 100)) + deliveryCharge).toStringAsFixed(2)}'
                      : 'AED. ${((totalAmount() * 0.18) + totalAmount() + deliveryCharge).toStringAsFixed(2)}'),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LocationResult result;

  void showPlacePicker() async {
    result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw")));
    setState(() {
      addressController.text = result.formattedAddress;
    });
    // Handle the result in your way
    // print(addressController.text);
  }

  String _result = '---';
  String _instructions = 'Tap on "Pay" Button to try PayTabs plugin';
  Future<void> payPressed() async {
    var args = {
//      'pt_merchant_email': "vkumarsaraswat@gmail.com",
      pt_merchant_email: 'test@example.com',
      pt_secret_key:
          "kuTEjyEMhpVSWTwXBSOSeiiDAeMCOdyeuFZKiXAlhzjSKqswUWAgbCaYFivjvYzCWaWJbRszhjZuEQqsUycVzLSyMIaZiQLlRqlp",
//      'pt_secret_key':
//          "P45UE6iY0pIhWSWx5vLPmN5icCio1PXQT2Ky82w8repo7mVcRG2eu7wGKP5LE2By4l6coDkPRKeZ69bXQdbklH15w6Qb8sKcOQoc", // Add your Secret Key Here
      pt_transaction_title: "Mr. John Doe",
      pt_amount: "39",
      pt_currency_code: "INR",
      'pt_customer_email': "test@example.com",
      'pt_customer_phone_number': "+91333109781",
      'pt_order_id': "1234567",
      'pt_product_name': "Angadi Bill",
      'pt_timeout_in_seconds': "300", //Optional
      'pt_address_billing': currentAddress,
      'pt_city_billing': "Juffair",
      'pt_state_billing': "state",
      'pt_country_billing': "BHR",
      'pt_postal_code_billing': "243001",
      'pt_address_shipping': "test test",
      'pt_city_shipping': "Juffair",
      'pt_state_shipping': "state",
      'pt_country_shipping': "BHR",
      'pt_postal_code_shipping': "00973", //Put Country Phone code if Postal
      'pt_color': "#ffb000",
      'pt_language': 'en', // 'en', 'ar'
      'pt_tokenization': true,
      'pt_preauth': false
    };
    FlutterPaytabsSdk.startPayment(args, (event) {
      setState(() {
        // print(event);
        List<dynamic> eventList = event;
        Map firstEvent = eventList.first;
        if (firstEvent.keys.first == "EventPreparePaypage") {
          //_result = firstEvent.values.first.toString();
//          _result = firstEvent["pt_response_code"];
//           print(
//               '========================================================================');
        } else {
          _result = firstEvent["pt_response_code"];
          // print(_result);
        }
      });
    });
  }

  Map<String, dynamic> map;
  int j = 0;
  Future<String> onlineorder(String price, String type, String orderid) async {
    final ProgressDialog pr = await ProgressDialog(context);
    pr.style(
        message: 'Please wait...',
        backgroundColor: Colors.white,
        progressWidget: GFLoader(
          type: GFLoaderType.ios,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    await pr.show();
    await getUserDetails();
    List items = [];
    List prices = [];
    List quantities = [];
    j = 0;
    for (var v in cartItems) {
      // print(v.productName);
      items.add(v.productName);
      prices.add(v.price);
      quantities.add(v.qty);
    }
    // print(selectedTime.split(' ').join().toLowerCase());
    var tt = selectedTime.split(' ').join().toLowerCase();
    String s = '';
    for (int i = 0; i < selectedTime.length; i++) {
      if (selectedTime[i] != ' ')
        s = s + selectedTime[i];
      else
        break;
    }

    dd = int.parse(s);
    if (selectedTime.contains('PM')) dd = dd + 12;
    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    final String apiUrl = "https://paytab.herokuapp.com/pay";
    Map map = {
      'UserID': user.uid,
      'GrandTotal': price,
      'orderid': orderid,
    };
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(apiUrl));

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    var reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    // print(reply);
    var decode = jsonDecode(reply);
    map = decode;
    await pr.hide();
    scaffoldState.currentState.showBottomSheet((context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter state) {
        return web(
            map['payment_url'],
            context,
            MediaQuery.of(context).size.height * 0.7,
            MediaQuery.of(context).size.width * 0.9);
      });
    });
    setState(() {
      val = false;
    });

    // print(val);
//    Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeScreen()));
//         Navigator.push(context,MaterialPageRoute(builder:(context)=>WebviewScreen(map['payment_url'])));
//   _launchURL(map['payment_url']);
  }

  placeOnlinePaidOrder() {
    // print(_result);
    if (_result == '100' || _result == '833') {
      placeOrder(type);
    }
  }

  _launchURL(reply) async {
    if (await canLaunch(reply)) {
      await launch(reply);
      setState(() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var status = prefs.setString('Status', 'Placed');
        j++;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }));
      });
    } else {
      throw 'Could not launch $reply';
    }
  }

  int k = 0;
  int length = 0;
  bool yes = false;
  Future<String> Checksuccess() async {
    // print('running check');
    var coupon;
    (discount != null) ? coupon = discount.title : coupon = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String onlineid = prefs.getString('Orderid');
    // print('----------------------$onlineid');
    // print(selectedDate);
    // print(selectedDate.year);
    // print(selectedTime.split(' ').join().toLowerCase());
    var tt = selectedTime.split(' ').join().toLowerCase();
    String s = '';
    for (int i = 0; i < selectedTime.length; i++) {
      if (selectedTime[i] != ' ')
        s = s + selectedTime[i];
      else
        break;
    }
    var dis;
//    if(discount.discount==''&&discount.discount==null){
//      dis='0.0';
//    }
//    else{
//      dis=double.parse(discount.discount).toString();
//    }
    discount != null
        ? dis =
            ('${(totalAmount() * (double.parse(discount.discount) / 100)).toStringAsFixed(2)}')
        : dis = ' 0';
    dd = int.parse(s);
    if (selectedTime.contains('PM')) dd = dd + 12;
    // print(
    //     'Hours are $dd ${DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd)}');

    await getUserDetails();
    List items = [];
    List prices = [];
    List quantities = [];
    List qtytags = [];
    for (var v in cartItems) {
      // print(v.productName);
      items.add(v.productName);
      prices.add(v.price);
      quantities.add(v.qty);
      qtytags.add(v.qtyTag);
    }
    Firestore.instance.collection('OnlineOrders').snapshots().listen((element) {
      for (int i = 0; i < element.documents.length; i++) {
        if (onlineid == element.documents[i].documentID) {
          setState(() {
            yes = true;
          });
          Firestore.instance
              .collection('Orders')
              .snapshots()
              .forEach((element) {
            length = element.documents.length;
            for (int j = 0; j < element.documents.length; j++) {
              if (element.documents[j].documentID != onlineid) {
                k++;
              }
            }
          });
          if (length == k) {
            widget.address == ''
                ? Firestore.instance
                    .collection('Orders')
                    .document(orderid)
                    .setData({
                    'Items': items,
                    'Price': prices,
                    'Qty': quantities,
                    'Type': 'Online order',
                    'UserID': user.uid,
                    'Quantity': qtytags,
                    'CouponUsed': coupon,
                    'orderid': orderid,
                    'phoneNumber': PhoneNumber.text,
                    'paymentMethod': 'Online payment',
                    'discountPrice': dis,
                    'Address':
                        'Emirate:${emirate},Area:${area},${buildingController.text},Additional Directions :${additionalcontroller.text}',
                    'DeliveryDate': DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day, dd),
                    'DeliveryTime': selectedTime,
                    'TimeStamp': Timestamp.now(),
                    'Status': 'Awaiting Confirmation',
                    'Notes': notesController.text != null
                        ? notesController.text
                        : 'None',
                    'GrandTotal': ((totalAmount() * 0.18) +
                            totalAmount() +
                            deliveryCharge)
                        .toStringAsFixed(2),
                  }).then((value) {
                    setState(() {
//              docID = value;
                    });
                  })
                : Firestore.instance
                    .collection('Orders')
                    .document(orderid)
                    .setData({
                    'Items': items,
                    'Price': prices,
                    'Qty': quantities,
                    'Type': 'Online order',
                    'UserID': user.uid,
                    'Quantity': qtytags,
                    'CouponUsed': coupon,
                    'Address': widget.address,
                    'orderid': orderid,
                    'phoneNumber': PhoneNumber.text,
                    'paymentMethod': 'Online Payment',
                    'discountPrice': dis,
                    'DeliveryDate': DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day, dd),
                    'DeliveryTime': selectedTime,
                    'TimeStamp': Timestamp.now(),
                    'Status': 'Awaiting Confirmation',
                    'Notes': notesController.text != null
                        ? notesController.text
                        : 'None',
                    'GrandTotal': ((totalAmount() * 0.18) +
                            totalAmount() +
                            deliveryCharge)
                        .toStringAsFixed(2),
                  }).then((value) {
                    setState(() {
//              docID = value;
                    });
                  });
            Firestore.instance.collection('Notifications').add({
              'UserID': user.uid,
              'OrderID': orderid,
              'Notification': 'Order Placed. Awaiting confirmation.',
              'DeliveryDate': DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day, dd),
              'DeliveryTime': selectedTime,
              'TimeStamp': Timestamp.now(),
              'Type': 'Online order',
              'GrandTotal':
                  ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
            });
            // for (int i = 0; i < cartItems.length; i++) {
            //   await databaseReference
            //       .collection('Orders')
            //       .document(docID)
            //       .collection('Items')
            //       .add({
            //     'ItemName': cartItems[i].productName,
            //     'Price': cartItems[i].price,
            //     'Quantity': cartItems[i].qty,
            //     'ImageURL': cartItems[i].imgUrl
            //   });
            // }

            removeAll();
            String status;
            Firestore.instance
                .collection('Orders')
                .getDocuments()
                .then((value) {
              value.documents.forEach((element) {
                if (element.documentID == orderid) {
                  status = element['Status'];
                }
              });
            });
            Timestamp myTimeStamp = Timestamp.fromDate(selectedDate);
            // print(myTimeStamp.toString());

            pushNewScreen(context, screen: MyOrders(user));
          }

//    HttpClient httpClient = new HttpClient();
//    httpClient.badCertificateCallback =
//        ((X509Certificate cert, String host, int port) => true);
//    final String apiUrl = 'https://paytab.herokuapp.com/success';
//    HttpClientRequest request = await httpClient.getUrl(Uri.parse(apiUrl));
//    request.headers.set('content-type', 'application/json');
//
//    HttpClientResponse response = await request.close();
//
//    response.transform(utf8.decoder).listen((contents) {
//      print(contents);
//      httpClient.close();
//    });

        } else {
          BackButtonInterceptor.remove(myInterceptor);
          Navigator.of(context).popUntil((route) => route.isFirst);
//
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    });
  }
}

class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind kind})
      : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        resolve(GestureDisposition.accepted);
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
