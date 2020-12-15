import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:angadi/classes/cart.dart';
import 'package:angadi/screens/home_screen.dart';
import 'package:angadi/screens/my_addresses.dart';
import 'package:angadi/screens/offers_screen.dart';
import 'package:angadi/screens/settings_screen.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_paytabs_bridge_emulator/flutter_paytabs_bridge_emulator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_placed.dart';

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  String type = 'Delivery';
  List<Cart> cartItems = [];
  DateTime selectedDate=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1);
  String selectedTime = '9 AM';
  DateTime date;
  var addresstype='Apartment';
  var color1=true;
  var color2=false;
  var color3=false;
  double total;
  final addressController = TextEditingController();
  final buildingController=TextEditingController();
  final floorcontroller=TextEditingController();
  final flatcontroller=TextEditingController();
  final additionalcontroller=TextEditingController();
  final hnoController = TextEditingController();
  final notesController = TextEditingController();


  final dbHelper = DatabaseHelper.instance;
//  final dbRef = FirebaseDatabase.instance.reference();
  FirebaseAuth mAuth = FirebaseAuth.instance;
  GlobalKey key = new GlobalKey();
  final scaffoldState = GlobalKey<ScaffoldState>();

  _pickTime() async {
    var today=DateTime.now();
    DateTime t = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year,today.month,today.day+1),
      lastDate: DateTime(today.year, today.month, today.day+6),
      firstDate: DateTime(
        today.year,
        DateTime.now().month,
        today.day+1
      ),
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
    return date;}
  Future<void> _timeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildTimeDialog(context);
      },
    );
  }
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
                child: DropDown<String>(
                  initialValue: '9 AM',
                  items: <String>['9 AM', '12 PM', '2 PM', '5 PM', '7 PM'],
                  hint: Text("Select quantity"),
                  onChanged: (value) async {
                    setState(() {
                      selectedTime = value;
                    });
                  },
                ),
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

  @override
  void initState() {
    getAllItems();
    _getCurrentLocation();
    time = TimeOfDay.now();
    date = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1);
    super.initState();
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
                height: MediaQuery.of(context).size.height*0.05,
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
                          style:
                          TextStyle(color: Color(0xFF6b3600)),
                        )
                            : Text(
                          '${date.day.toString()}/${date.month.toString()}/20 ',
                          style:
                          TextStyle(color: Color(0xFF6b3600)),
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

  @override
  Widget build(BuildContext context) {
    print(_result);
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
              width: 6,
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
            SizedBox(
              width: 6,
            ),
            InkWell(
                onTap: () {
//                print(1);
                  launch(
                      'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
                },
                child: Icon(Icons.mail, color: Color(0xFF6b3600))),
            SizedBox(width: 7)
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Radio(
                          activeColor: AppColors.secondaryElement,
                          value: 'Delivery',
                          groupValue: type,
                          onChanged: (value) {
                            setState(() {
                              type = value;
                            });
                          }),
                    ),
                    Text(
                      'Delivery',
                      style: TextStyle(fontSize: 15),
                    ),
                    Container(
                      height: 6,
                      child: Radio(
                          activeColor: AppColors.secondaryElement,
                          value: 'Takeaway',
                          groupValue: type,
                          onChanged: (value) {
                            setState(() {
                              type = value;
                            });
                          }),
                    ),
                    Text(
                      'Takeaway',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 1,
                    ),
//                    Radio(
//                        activeColor: AppColors.secondaryElement,
//                        value: 'Schedule Delivery',
//                        groupValue: type,
//                        onChanged: (value) {
//                          setState(() {
//                            type = value;
//                          });
//                        }),
//                    Container(
//                        width: MediaQuery.of(context).size.width * 0.2,
//                        child: Text(
//                          'Schedule Delivery',
//                          style: TextStyle(fontSize: 15),
//                        )),
                  ],
                ),
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
                                      MediaQuery.of(context).size.width * 0.2,
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
                                  'Price: Rs. ${cartItems[i].price.toString()}',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, bottom: 12),
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
                type != 'Takeaway'
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
                    ?Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [Container(
                        width:MediaQuery.of(context).size.width*0.31,
                        height:MediaQuery.of(context).size.height*0.08,
                        child: OutlineButton(highlightedBorderColor:Color(0xFF6b3600),borderSide:BorderSide(color:(color1)?Color(0xFF6b3600):Colors.grey),onPressed: (){setState(() {
                          color1=!color1;
                          color2=false;
                          color3=false;
                          addresstype='Apartment';
                        });},child:Padding(
                          padding:  EdgeInsets.only(top:8.0),
                          child: Column(children: [Image.asset('assets/images/apartment.png',height:25),Text('Apartment',style:TextStyle(fontSize:MediaQuery.of(context).size.height*0.016,color:Colors.black,fontWeight:FontWeight.w300))],),
                        ),disabledBorderColor: Colors.grey,color:Color(0xFF6b3600),),
                      ),
                        SizedBox(width:MediaQuery.of(context).size.width*0.04),
                        OutlineButton(highlightedBorderColor:Color(0xFF6b3600),borderSide:BorderSide(color:(color2)?Color(0xFF6b3600):Colors.grey),onPressed: (){
                          setState(() {
                            color2=!color2;
                            color1=false;
                            color3=false;
                            addresstype='House';
                          });
                        },child:Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [Image.asset('assets/images/house.png',height:25),Text('House',style:TextStyle(color:Colors.black,fontWeight:FontWeight.w300))],),
                        ),disabledBorderColor: Colors.grey,color:Color(0xFF6b3600),),
                        SizedBox(width:MediaQuery.of(context).size.width*0.04),
                        OutlineButton(highlightedBorderColor:Color(0xFF6b3600),borderSide:BorderSide(color:(color3)?Color(0xFF6b3600):Colors.grey),onPressed: (){setState(() {
                         color3=!color3;
                         color2=false;
                         color1=false;
                          addresstype='Office';
                        });},child:Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [Image.asset('assets/images/office.png',height:25),Text('Office',style:TextStyle(color:Colors.black,fontWeight:FontWeight.w300))],),
                        ),disabledBorderColor: Colors.grey,color:Color(0xFF6b3600),)],),
                    ): Container(),
                type != 'Takeaway'
                    ? SizedBox(
                        height: 10,
                      )
                    : Container(),
                type != 'Takeaway'
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
                   ?(addresstype=='Apartment')?Column(children: [Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Building' ),   controller: buildingController,),
                ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Floor' ),   controller: floorcontroller,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Apartment' ),   controller: flatcontroller,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Additional Directions' ),  maxLines: 2, controller: additionalcontroller,        ),
                  ),
                ],):(addresstype=='House')?Column(children: [Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Street' ),   controller: buildingController,),
                ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Area' ),   controller: floorcontroller,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Landmark' ),   controller: flatcontroller,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Additional Directions' ),  maxLines: 2, controller: additionalcontroller,        ),
                  ),
                ],) :Column(children: [Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Building' ),   controller: buildingController,),
                ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Floor' ),   controller: floorcontroller,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Landmark' ),   controller: flatcontroller,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(decoration:InputDecoration(border:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Colors.grey)),focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(2),borderSide: BorderSide(color:Color(0xFF6b3600))),hintText: 'Additional Directions' ),  maxLines: 2, controller: additionalcontroller,        ),
                  ),
                ],): Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 10),
                  child: angadiButton(
                    'Saved addresses',
                    buttonWidth: MediaQuery.of(context).size.width,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return MyAddresses();
                      }));
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, bottom: 0, top: 20),
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
                          Text('${discount.discount}% off promo code applied!'),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          prefixIconImagePath: ImagePath.activeBookmarksIcon,
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
                        child:
                             Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                       child: Container(
                         height: MediaQuery.of(context).size.height*0.05,
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
                                   style:
                                   TextStyle(color: Color(0xFF6b3600)),
                                 )
                                     : Text(
                                   '${date.day.toString()}/${date.month.toString()}/20 ',
                                   style:
                                   TextStyle(color: Color(0xFF6b3600)),
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
//                                    child: Text(
//                                      'Schedule Delivery Time',
//                                      style: TextStyle(
//                                          color: Colors.blue, fontSize: 20),

                                  ),
                                )
                              )
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
                    _result != '833'
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: angadiButton(
                              'Cash On Delivery',
                              buttonWidth: MediaQuery.of(context).size.width,
                              onTap: () {
                                showAlertDialog(context);
                              },
                            ),
                          )
                        : Container(),
                    _result != '833'
                        ? SizedBox(
                            height: 20,
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: angadiButton(
                        _result != '833' && j != 1
                            ? 'Proceed to pay online'
                            : 'Check your status',
                        onTap: () {
                          _result != '833' && j != 1
                              ? onlineorder(
                                  (discount != null)
                                      ? ((totalAmount() * 0.18) +
                                              totalAmount() -
                                              (totalAmount() *
                                                  (double.parse(
                                                          discount.discount) /
                                                      100)))
                                          .toStringAsFixed(2)
                                      : ((totalAmount() * 0.18) + totalAmount())
                                          .toString(),
                                  type)
                              : Checksuccess();
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
            ),
          ),
        ));
  }

  FirebaseUser user;

  getUserDetails() async {
    user = await FirebaseAuth.instance.currentUser();
  }

  var docID;var dd;
  var id;
  placeOrder(orderType) async {
    print('----------------------');
    print(selectedDate.year);
    print(selectedTime.split(' ').join().toLowerCase());
    var tt=selectedTime.split(' ').join().toLowerCase();
    if(selectedTime.contains('AM')){
      setState(() {
        dd=int.parse(selectedTime.substring(0,1).trim());
      });

    }
    else if(selectedTime.contains('12')){
      setState(() {
        dd=int.parse(selectedTime.substring(0,1).trim());
      });

    }
    else if(selectedTime.contains('PM')&&!selectedTime.contains('12')){
      setState(() {
        dd=int.parse(selectedTime.substring(0,1).trim()) + 12;
      });

    }

    var rng = new Random();
    var code = rng.nextInt(90000) + 10000;
    print('ANG${code.toString()}');
    setState(() {
      id = 'ANG${code.toString()}';
    });

    await getUserDetails();
    List items = [];
    List prices = [];
    List quantities = [];
    for (var v in cartItems) {
      print(v.productName);
      items.add(v.productName);
      prices.add(v.price);
      quantities.add(v.qty);
    }
    final databaseReference = Firestore.instance;
    orderType == 'Delivery'&&addresstype=='Apartment'
        ? await databaseReference.collection('Orders').document(id).setData({
            'Items': items,
            'Price': prices,
            'Qty': quantities,
            'Type': orderType,
            'UserID': user.uid,
            'Building':buildingController.text,
             'Floor':floorcontroller.text,
              'Apartment':flatcontroller.text,
            'Additional Directions':additionalcontroller.text,
            'DeliveryDate':DateTime(selectedDate.year,selectedDate.month,selectedDate.day,dd),
             'DeliveryTime':selectedTime,
            'TimeStamp': DateTime.now(),
            'Status': 'Awaiting Confirmation',
            'Notes':
                notesController.text != null ? notesController.text : 'None',
            'GrandTotal':
                ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
          }).then((value) {
            setState(() {
//              docID = value;
            });
          }):orderType == 'Delivery'&&addresstype=='House'?
    await databaseReference.collection('Orders').document(id).setData({
      'Items': items,
      'Price': prices,
      'Qty': quantities,
      'Type': orderType,
      'UserID': user.uid,
      'Street':buildingController.text,
      'Area':floorcontroller.text,
      'Landmark':flatcontroller.text,
      'Additional Directions':additionalcontroller.text,
      'DeliveryDate':DateTime(selectedDate.year,selectedDate.month,selectedDate.day,dd),
      'DeliveryTime':selectedTime,
      'TimeStamp': DateTime.now(),
      'Status': 'Awaiting Confirmation',
      'Notes':
      notesController.text != null ? notesController.text : 'None',
      'GrandTotal':
      ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
    }).then((value) {
      setState(() {
//              docID = value;
      });
    }):orderType == 'Delivery'&&addresstype=='Office'?await databaseReference.collection('Orders').document(id).setData({
      'Items': items,
      'Price': prices,
      'Qty': quantities,
      'Type': orderType,
      'UserID': user.uid,
      'Building':buildingController.text,
      'Floor':floorcontroller.text,
      'Landmark':flatcontroller.text,
      'Additional Directions':additionalcontroller.text,
      'DeliveryDate':DateTime(selectedDate.year,selectedDate.month,selectedDate.day,dd),
      'DeliveryTime':selectedTime,
      'TimeStamp': DateTime.now(),
      'Status': 'Awaiting Confirmation',
      'Notes':
      notesController.text != null ? notesController.text : 'None',
      'GrandTotal':
      ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
    }).then((value) {
      setState(() {
//              docID = value;
      });
    })
        : orderType == 'Takeaway'
            ? await databaseReference
                .collection('Orders')
                .document(id)
                .setData({
                'Items': items,
                'Price': prices,
                'Qty': quantities,
                'Type': orderType,
                'UserID': user.uid,
                // 'Status':'${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                'TimeStamp': DateTime.now(),
                'Status': 'Awaiting Confirmation',
                'GrandTotal':
                    ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
              }).then((value) {
                setState(() {
//                  docID = value.documentID;
                });
              })
            : await databaseReference
                .collection('Orders')
                .document(id)
                .setData({
                'Items': items,
                'Price': prices,
                'Qty': quantities,
                'Type': orderType,
                'UserID': user.uid,
                 'DeliveryDate':selectedDate,
                  'DeliveryTime':selectedTime,
                'Address': '${hnoController.text},${addressController.text} ',
                'TimeStamp': DateTime.now(),
                'Status': 'Awaiting Confirmation',
//                'DeliveryTime': selectedTime.toString(),
                'Notes': notesController.text != null
                    ? notesController.text
                    : 'None',
                'GrandTotal':
                    ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
              }).then((value) {
                setState(() {
//                  docID = value.documentID;
                });
              });
    await databaseReference.collection('Notifications').add({
      'UserID': user.uid,
      'OrderID': id,
      'Notification': 'Order Placed. Awaiting confirmation.',
      'DeliveryDate':selectedDate,
      'DeliveryTime':selectedTime,
      'TimeStamp': DateTime.now(),
      'Type': orderType,
      'GrandTotal': ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
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
    Firestore.instance.collection('Orders').getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.documentID == id) {
          status = element['Status'];
        }
      });
    });

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return OrderPlaced(Bill(), id, status,selectedDate);
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
              onPressed: () {},
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
    print(_currentPosition);
    _getAddressFromLatLng();
    print(_currentPosition);
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
        print(currentAddress);
        addressController.text = currentAddress;
      });
    } catch (e) {
      print(e);
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
                  Text('Rs. ${totalAmount().toString()}')
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
                      ? 'Rs. ${(totalAmount() * (double.parse(discount.discount) / 100)).toStringAsFixed(2)}'
                      : 'Rs. 0'),
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
                  Text('Rs. ${(totalAmount() * 0.18).toStringAsFixed(2)}'),
                ],
              ),
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
                      ? 'Rs. ${((totalAmount() * 0.18) + totalAmount() - (totalAmount() * (double.parse(discount.discount) / 100))).toStringAsFixed(2)}'
                      : 'Rs. ${((totalAmount() * 0.18) + totalAmount())}'),
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
    print(addressController.text);
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
        print(event);
        List<dynamic> eventList = event;
        Map firstEvent = eventList.first;
        if (firstEvent.keys.first == "EventPreparePaypage") {
          //_result = firstEvent.values.first.toString();
//          _result = firstEvent["pt_response_code"];
          print(
              '========================================================================');
        } else {
          _result = firstEvent["pt_response_code"];
          print(_result);
        }
      });
    });
  }

  Map<String, dynamic> map;
  int j = 0;
  Future<String> onlineorder(String price, String type) async {
    await getUserDetails();
    List items = [];
    List prices = [];
    List quantities = [];
    j = 0;
    for (var v in cartItems) {
      print(v.productName);
      items.add(v.productName);
      prices.add(v.price);
      quantities.add(v.qty);
    }
    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    final String apiUrl = "https://paytab.herokuapp.com/pay";
    Map map = {
      'Items': items,
      'Price': prices,
      'Qty': quantities,
   'TimeStamp': DateTime.now(),
      'GrandTotal': price,
      'Status': 'Order Placed',
      'Type': type,
      'UserID': user.uid,
      'Notes': notesController.text,
      'Address': addressController.text,
      'Phone': user.phoneNumber
    };
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(apiUrl));

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    var reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    print(reply);
    var decode = jsonDecode(reply);
    map = decode;

    _launchURL(map['payment_url']);
  }

  placeOnlinePaidOrder() {
    print(_result);
    if (_result == '100' || _result == '833') {
      placeOrder(type);
    }
  }

  _launchURL(reply) async {
    if (await canLaunch(reply)) {
      await launch(reply);
      setState(() {
        removeAll();
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

  Future<String> Checksuccess() async {
    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    final String apiUrl = 'https://paytab.herokuapp.com/success';
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(apiUrl));
    request.headers.set('content-type', 'application/json');

    HttpClientResponse response = await request.close();

    response.transform(utf8.decoder).listen((contents) {
      print(contents);
      httpClient.close();
    });
  }
}
