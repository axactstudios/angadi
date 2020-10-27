import 'package:angadi/classes/cart.dart';
import 'package:angadi/screens/offers_screen.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/custom_text_form_field.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'order_placed.dart';

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  String type = 'Delivery';
  List<Cart> cartItems = [];
  double total;
  final addressController = TextEditingController();
  final hnoController = TextEditingController();
  final notesController = TextEditingController();

  final dbHelper = DatabaseHelper.instance;
//  final dbRef = FirebaseDatabase.instance.reference();
  FirebaseAuth mAuth = FirebaseAuth.instance;
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

  TimeOfDay time;
  TimeOfDay selectedTime;
  @override
  void initState() {
    getAllItems();
    _getCurrentLocation();
    time = TimeOfDay.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _pickTime() async {
      TimeOfDay t = await showTimePicker(context: context, initialTime: time);
      if (t != null)
        setState(() {
          time = t;
        });
      return time;
    }

    var textTheme = Theme.of(context).textTheme;
    var hintTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: AppColors.accentText);
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios),
          ),
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Checkout',
            style: Styles.customTitleTextStyle(
              color: AppColors.headingText,
              fontWeight: FontWeight.w600,
              fontSize: Sizes.TEXT_SIZE_22,
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
                    Radio(
                        activeColor: AppColors.secondaryElement,
                        value: 'Schedule Delivery',
                        groupValue: type,
                        onChanged: (value) {
                          setState(() {
                            type = value;
                          });
                        }),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          'Schedule Delivery',
                          style: TextStyle(fontSize: 15),
                        )),
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
                                  child: Image.network(cartItems[i].imgUrl),
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
                                title: 'Address',
                                number: '',
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  showPlacePicker();

//                              _locationDialog(context);
                                },
                                child: Icon(
                                  Icons.map,
                                  size: 30,
                                )),
                          ],
                        ),
                      )
                    : Container(),
                type != 'Takeaway'
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomTextFormField(
                          controller: hnoController,
                          textFormFieldStyle: textFormFieldTextStyle,
                          prefixIconColor: AppColors.secondaryElement,
                          hintTextStyle: hintTextStyle,
                          borderStyle: BorderStyle.solid,
                          borderWidth: Sizes.WIDTH_1,
                          hintText: 'Enter House No, Street Name',
                          hasPrefixIcon: true,
                          prefixIconImagePath: ImagePath.homeIcon,
                        ),
                      )
                    : Container(),
                type != 'Takeaway'
                    ? SizedBox(
                        height: 10,
                      )
                    : Container(),
                type != 'Takeaway'
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomTextFormField(
                          controller: addressController,
                          textFormFieldStyle: textFormFieldTextStyle,
                          prefixIconColor: AppColors.secondaryElement,
                          hintTextStyle: hintTextStyle,
                          borderStyle: BorderStyle.solid,
                          borderWidth: Sizes.WIDTH_1,
                          hintText: 'Enter Address',
                          maxLines: 4,
                          hasPrefixIcon: true,
                          prefixIconImagePath: ImagePath.homeIcon,
                        ),
                      )
                    : Container(),
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
                type == 'Schedule Delivery'
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, bottom: 0, top: 10),
                        child: HeadingRow(
                          title: 'Delivery Time',
                          number: '',
                        ),
                      )
                    : Container(),
                type == 'Schedule Delivery'
                    ? InkWell(
                        onTap: () {
                          _pickTime().then((value) {
                            setState(() {
                              selectedTime = value;
                            });
                          });
                        },
                        child: selectedTime == null
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Schedule Delivery Time',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 20),
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: selectedTime.hour < 23 &&
                                                  selectedTime.hour > 10
                                              ? Text(
                                                  'Delivery Time is ${selectedTime.format(context)}. Your order will reach to you on time. Click to edit time.',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Text(
                                                  'Sorry we do not deliver after 11:00 PM and before 10:00 AM. Click to choose another time.',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                    : Container(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, bottom: 0, top: 10),
                  child: HeadingRow(
                    title: 'Choose Payment Method',
                    number: '',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: angadiButton(
                        'Cash On Delivery',
                        buttonWidth: MediaQuery.of(context).size.width,
                        onTap: () {
                          showAlertDialog(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: angadiButton(
                        'Proceed to pay online',
                        buttonWidth: MediaQuery.of(context).size.width,
                      ),
                    )
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

  var docID;
  placeOrder(orderType) async {
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
    orderType == 'Delivery'
        ? await databaseReference.collection('Orders').add({
            'Items': items,
            'Price': prices,
            'Qty': quantities,
            'Type': orderType,
            'UserID': user.uid,
            'Address': addressController.text,
            'TimeStamp': DateTime.now(),
            'Status': 'Awaiting Confirmation',
            'Notes':
                notesController.text != null ? notesController.text : 'None',
            'GrandTotal':
                ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
          }).then((value) {
            setState(() {
              docID = value.documentID;
            });
          })
        : orderType == 'Takeaway'
            ? await databaseReference.collection('Orders').add({
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
                  docID = value.documentID;
                });
              })
            : await databaseReference.collection('Orders').add({
                'Items': items,
                'Price': prices,
                'Qty': quantities,
                'Type': orderType,
                'UserID': user.uid,
                'Address': '${hnoController.text},${addressController.text} ',
                'TimeStamp': DateTime.now(),
                'Status': 'Awaiting Confirmation',
                'DeliveryTime': selectedTime.format(context).toString(),
                'Notes': notesController.text != null
                    ? notesController.text
                    : 'None',
                'GrandTotal':
                    ((totalAmount() * 0.18) + totalAmount()).toStringAsFixed(2),
              }).then((value) {
                setState(() {
                  docID = value.documentID;
                });
              });
    await databaseReference.collection('Notifications').add({
      'UserID': user.uid,
      'OrderID': docID,
      'Notification': 'Order Placed. Awaiting confirmation.',
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

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return OrderPlaced(Bill(), docID);
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
}
