import '../providers/schedule.dart';
import 'home_page.dart';
import 'fragments/cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'picturescreen.dart';
import 'fragments/listings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart' as bc;
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'fragments/confirmExit.dart';
import 'package:toast/toast.dart';
import 'fragments/utilityfunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'connect_partner.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'fragments/connection_related.dart';
import 'dart:typed_data';

class TodaySchedule extends StatefulWidget {
  const TodaySchedule({Key key}) : super(key: key);

  @override
  _TodayScheduleState createState() => _TodayScheduleState();
}

final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
final RoundedLoadingButtonController _btnController2 = RoundedLoadingButtonController();
TextEditingController commentText = new TextEditingController();
TextEditingController reasonText = new TextEditingController();
String activeCar;

class _TodayScheduleState extends State<TodaySchedule> {
  String _scanBarcode = 'Unknown';
  ScrollController _scrollController = ScrollController();
  List<int> slotsUsed = [];
  var slotMap = {
    1: "5:00 AM - 6:00 AM",
    2: "6:01 AM - 7:00 AM",
    3: "7:01 AM - 8:00 AM",
    4: "8:01 AM - 9:00 AM",
    5: "9:01 AM - 10:00 AM",
    6: "10:01 AM - 11:00 AM",
    7: "11:01 AM - 12:00 PM",
    8: "12:01 PM - 1:00 PM",
    9: "1:01 PM - 2:00 PM",
    10: "2:01 PM - 3:00 PM",
    11: "3:01 PM - 4:00 PM",
  };

  Future<void> _scrollToSlot(String theSlot) async {
    double ofSet, shiftPixel = MediaQuery.of(context).size.width * 0.55;
    slotsUsed.sort();
    ofSet = 0;
    for (int i = 0; i < slotsUsed.length; i++) {
      if (slotMap[slotsUsed[i]] == theSlot) {
        break;
      } else {
        ofSet += shiftPixel;
        ofSet += 15;
      }
    }
    print(ofSet);
    _scrollController.animateTo(-1000000, duration: Duration(microseconds: 1), curve: Curves.linear);
    _scrollController.animateTo(ofSet, curve: Curves.easeOut, duration: Duration(milliseconds: 500));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await bc.FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, bc.ScanMode.QR);
      activeCar = barcodeScanRes;
      for (int i = 0; i < carEnties.length; i++) {
        if (activeCar == carEnties[i].carNumber) _scrollToSlot(carEnties[i].timeRange);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> checkConnection() async {
    if (await Nearby().checkLocationPermission()) {
      if (await Nearby().checkExternalStoragePermission()) {
        if (await Nearby().checkLocationEnabled()) {
          if (endpointMap.length == 0) {}
        } else {
          await Nearby().enableLocationServices();
        }
      } else {
        Nearby().askExternalStoragePermission();
      }
    } else {
      await Nearby().askLocationPermission();
    }
    if (endpointMap.length == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectionToPartner(),
        ),
      );
    }
  }

  @override
  void initState() {
    if (slotsUsed.isNotEmpty) {
      slotsUsed.clear();
    }
    checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

    String workChoice;
    var dataprovider = Provider.of<DataProviderClass>(context);

    collectKey(String spId, String reasonTxt, String keyChoice, int carIndex) async {
      var res = await dataprovider.keyCollected(spId, reasonTxt, keyChoice);
      if (res == "OK") {
        Toast.show(" Submitted !", context, duration: 2, gravity: Toast.BOTTOM);
        if (keyChoice == 'Yes') {
          carEnties[carIndex].isKeyCollected = true;
        }
        setState(() {});
      } else {
        Toast.show("⚠️ " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
      }
    }

    Future<void> _keyCollect(BuildContext context, String spId, String keyCollectionTime, int carIndex) async {
      String keyChoice = 'Yes';
      bool isReasonText = false;
      reasonText.clear();
      var date = DateTime.now();
      String nowTime;
      if (date.minute.toString().length == 1) {
        nowTime = date.hour.toString() + ":0" + date.minute.toString();
      } else {
        nowTime = date.hour.toString() + ":" + date.minute.toString();
      }
      if (compareTime(keyCollectionTime, nowTime) == true) {
        isReasonText = true;
      }
      return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Key Collected",
                              style: TextStyle(color: white, fontSize: 17),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel_outlined, color: white, size: 20),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Radio(
                            value: 'Yes',
                            groupValue: keyChoice,
                            onChanged: (val) {
                              setState(() {
                                keyChoice = 'Yes';
                              });
                            },
                          ),
                          Text(
                            "Yes",
                          ),
                          Radio(
                            value: 'No',
                            groupValue: keyChoice,
                            onChanged: (val) {
                              setState(() {
                                keyChoice = 'No';
                              });
                            },
                          ),
                          Text(
                            "No",
                          ),
                        ],
                      ),
                      keyChoice == 'No' || isReasonText == true
                          ? Container(
                              //height: ScreenUtil().setHeight(58),
                              //width: ScreenUtil().setWidth(280),
                              margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 6),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  border: Border.all(color: Colors.black26)),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: reasonText,
                                      maxLines: 4,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        fillColor: Colors.black,
                                        focusColor: Colors.black,
                                        labelStyle: TextStyle(color: Colors.black),
                                        border: InputBorder.none,
                                        hintText: "Add Comment...",
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 25,
                        width: 90,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(elevation: 8.0, primary: mainColor),
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 13),
                          ),
                          onPressed: () {
                            FocusManager.instance.primaryFocus.unfocus();
                            if (((keyChoice == 'No') || (isReasonText == true)) && (reasonText.text == "")) {
                              Toast.show("⚠️ Providing Reason is Mandatory !", context, duration: 2, gravity: Toast.BOTTOM);
                            } else {
                              Navigator.of(context).pop();
                              collectKey(spId, reasonText.text, keyChoice, carIndex);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    Future<void> _startService(BuildContext context, int carIndex) async {
      reasonText.clear();
      bool isInsideExist = false;
      if ((carEnties[carIndex].serviceList.any((item) => item.inOut == "Inside")) || (carEnties[carIndex].addOnServiceList.any((item) => item.inOut == "Inside"))) {
        workChoice = "Inside";
        isInsideExist = true;
      } else
        workChoice = "Outside";
      if (carEnties[carIndex].isKeyCollected == false) {
        workChoice = "Outside";
      }
      return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: Form(
                  key: _formKey2,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Start cleaning",
                                  style: TextStyle(color: white, fontSize: 17),
                                ),
                                IconButton(
                                  icon: Icon(Icons.cancel_outlined, color: white, size: 20),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          IgnorePointer(
                            child: ListView.builder(
                              itemCount: carEnties[carIndex].serviceList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return inOutListItems(mainColor, carEnties[carIndex].serviceList[index].serviceName, carEnties[carIndex].serviceList[index].inOut, workChoice, context);
                              },
                            ),
                          ),
                          IgnorePointer(
                            child: ListView.builder(
                              itemCount: carEnties[carIndex].addOnServiceList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return inOutListItems(secondColor, carEnties[carIndex].addOnServiceList[index].serviceName, carEnties[carIndex].addOnServiceList[index].inOut, workChoice, context);
                              },
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          Divider(),
                          isInsideExist == false
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Select ",
                                        style: TextStyle(color: textLight, fontSize: 14),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (carEnties[carIndex].isKeyCollected == false) {
                                            Toast.show("⚠️ Collect Key for Inside Job !", context, duration: 2, gravity: Toast.BOTTOM);
                                          } else {
                                            setState(() {
                                              workChoice = 'Inside';
                                            });
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.07,
                                              width: MediaQuery.of(context).size.width * 0.24,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                      'assets/carIn.jpg',
                                                    ),
                                                    fit: BoxFit.fill),
                                                color: white,
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10.0),
                                                  topLeft: Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.24,
                                              height: MediaQuery.of(context).size.height * 0.033,
                                              child: Center(
                                                child: Text(
                                                  "Inside",
                                                  style: TextStyle(
                                                    color: workChoice == 'Inside' ? white : mainColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              padding: EdgeInsets.only(top: 3, bottom: 3, left: 4, right: 7),
                                              decoration: BoxDecoration(
                                                color: workChoice != 'Inside' ? white : mainColor,
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10.0),
                                                  bottomLeft: Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            workChoice = 'Outside';
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.07,
                                              width: MediaQuery.of(context).size.width * 0.24,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                      'assets/carOut.jpeg',
                                                    ),
                                                    fit: BoxFit.fill),
                                                color: white,
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10.0),
                                                  topLeft: Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.24,
                                              height: MediaQuery.of(context).size.height * 0.033,
                                              child: Center(
                                                child: Text(
                                                  "Outside",
                                                  style: TextStyle(
                                                    color: workChoice == 'Outside' ? white : mainColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              padding: EdgeInsets.only(top: 3, bottom: 3, left: 4, right: 7),
                                              decoration: BoxDecoration(
                                                color: workChoice != 'Outside' ? white : mainColor,
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(10.0),
                                                  bottomLeft: Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          SizedBox(
                            height: 32,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: GestureDetector(
                              onTap: () {
                                if (carEnties[carIndex].status == CarWorkStatus.COMPLETE) {
                                  Toast.show("⚠️ Car already completed !", context, duration: 2, gravity: Toast.BOTTOM);
                                } else {
                                  if ((workChoice == "Inside") && (carEnties[carIndex].status == CarWorkStatus.INSIDEDONE)) {
                                    Toast.show("⚠️ Inside service already completed !", context, duration: 2, gravity: Toast.BOTTOM);
                                  } else {
                                    if ((workChoice == "Outside") && (carEnties[carIndex].status == CarWorkStatus.OUTSIDEDONE)) {
                                      Toast.show("⚠️ Outside service already completed !", context, duration: 2, gravity: Toast.BOTTOM);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PictureScreen(
                                            startEnd: "before",
                                            carIndex: carIndex,
                                            section: workChoice,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: secondColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25),
                                  ),
                                ),
                                child: Center(child: Text("Click Images", style: TextStyle(color: white))),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    Future<void> _doneForTheDay() async {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          var currentDataTemp = prefs.getString('pendingList');
          if (currentDataTemp == null) {
            await Firebase.initializeApp();
            var res = await dataprovider.doneForTheDay(commentText.text);
            if (res == "OK") {
              _btnController.success();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              });
              //_btnController.reset();
            } else {
              Toast.show("⚠️ " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
              _btnController.reset();
            }
          } else {
            List currentData2 = json.decode(currentDataTemp);
            await Firebase.initializeApp();
            var res2 = await dataprovider.saveSesionBulk(currentData2, commentText.text);
            if (res2 == "OK") {
              _btnController.success();
              prefs.remove('pendingList');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              });
            } else {
              Toast.show("⚠️ " + res2 + " !", context, duration: 2, gravity: Toast.BOTTOM);
              _btnController.reset();
            }
          }
        }
      } on SocketException catch (_) {
        _btnController.reset();
        Toast.show(" Internet is not connected !", context, duration: 2, gravity: Toast.BOTTOM);
      }
    }

    Future<void> _lateComment(BuildContext context, List<String> undoneCarsList) async {
      return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Service Incomplete",
                            style: TextStyle(color: white, fontSize: 17),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel_outlined, color: white, size: 20),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(undoneCarsList.toString()),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 6),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(color: Colors.black26)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: commentText,
                              maxLines: 4,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                fillColor: Colors.black,
                                focusColor: Colors.black,
                                labelStyle: TextStyle(color: Colors.black),
                                border: InputBorder.none,
                                hintText: "Please provide a reason for the incomplete service of these cars...",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 25,
                      width: 90,
                      child: RoundedLoadingButton(
                        color: mainColor,
                        borderRadius: 5,
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: 18, color: white),
                        ),
                        controller: _btnController2,
                        onPressed: () async {
                          FocusManager.instance.primaryFocus.unfocus();
                          if (commentText.text == '') {
                            Toast.show("⚠️ Providing Reason is Mandatory !", context, duration: 2, gravity: Toast.BOTTOM);
                            _btnController2.reset();
                          } else {
                            await _doneForTheDay();
                            _btnController2.success();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    _timeSlot(int slotIndex) {
      if (!slotsUsed.contains(slotIndex)) {
        slotsUsed.add(slotIndex);
      }
      return Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: textLightBg(slotMap[slotIndex]),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.55,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: mainLight,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 0.5),
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: carEnties.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (carEnties[index].timeRange == slotMap[slotIndex]) {
                    return GestureDetector(
                      onTap: () {
                        if (activeCar == carEnties[index].carNumber) {
                          activeCar = "";
                        } else {
                          activeCar = carEnties[index].carNumber;
                          _scrollToSlot(carEnties[index].timeRange);
                        }
                        setState(() {});
                      },
                      child: Card(
                        child: Opacity(
                          opacity: carEnties[index].status == CarWorkStatus.COMPLETE ? 0.3 : 1,
                          child: Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(carEnties[index].carNumber.toString().toUpperCase(), style: TextStyle(fontSize: 16)),
                                        SizedBox(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(color: textLight, width: 1, height: 14),
                                              SizedBox(width: 5),
                                              carEnties[index].isKeyRequired == false
                                                  ? Container()
                                                  : Icon(Icons.vpn_key, size: 14, color: carEnties[index].isKeyCollected == true ? Colors.amber[600] : textLight),
                                              SizedBox(width: 5),
                                              Text(
                                                carEnties[index].label,
                                                style: TextStyle(color: carEnties[index].addOnCount == 0 ? textLight : secondColor),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                carEnties[index].addOnCount.toString(),
                                                style: TextStyle(color: "nmr" == "0" ? textLight : mainColor),
                                              ),
                                              SizedBox(width: 5),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(carEnties[index].carModel.toString(), style: TextStyle(fontSize: 12, color: mainColor)),
                                          Text(carEnties[index].deliveryTime.toString(), style: TextStyle(fontSize: 13, color: mainColor)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(carEnties[index].ownerAddress.toString(), style: TextStyle(fontSize: 13, color: textLight)),
                                    ),
                                  ],
                                ),
                                carEnties[index].carNumber != activeCar
                                    ? Container()
                                    : Column(
                                        children: [
                                          Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context).size.width * 0.07,
                                                width: MediaQuery.of(context).size.width * 0.07,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(carEnties[index].ownerDp),
                                                    fit: BoxFit.fill,
                                                  ),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 6.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      carEnties[index].ownerName,
                                                      style: TextStyle(color: textDark, fontSize: 13),
                                                    ),
                                                    Text(
                                                      carEnties[index].ownerAddress,
                                                      style: TextStyle(color: textLight, fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              launch('tel:' + carEnties[index].ownerPhone);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Icon(Icons.phone, color: mainColor, size: 14),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    carEnties[index].ownerPhone,
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          carEnties[index].parkingSlot != ''
                                              ? Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Icon(Icons.local_parking_rounded, color: mainColor, size: 14),
                                                      SizedBox(width: 2),
                                                      Text(carEnties[index].parkingSlot, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                          Divider(),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Key collection time:",
                                              style: TextStyle(fontSize: 12, color: textLight),
                                            ),
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                carEnties[index].keyCollectionTime,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              carEnties[index].isKeyRequired == false
                                                  ? Container(
                                                      child: Text(
                                                        "Not Required",
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 17,
                                                      width: 80,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(elevation: 4.0, primary: carEnties[index].isKeyCollected == false ? mainColor : mainLight),
                                                        child: Text(
                                                          carEnties[index].isKeyCollected == false ? "Collect" : "Collected",
                                                          style: TextStyle(fontSize: 11, color: carEnties[index].isKeyCollected == false ? white : textDark),
                                                        ),
                                                        onPressed: () {
                                                          if (carEnties[index].isKeyCollected == false) {
                                                            _keyCollect(context, carEnties[index].schedulePlanId, carEnties[index].keyCollectionTime, index);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.alarm, color: mainColor, size: 17),
                                              SizedBox(width: 5),
                                              Text(carEnties[index].deliveryTime.toString()),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          SizedBox(
                                            height: 20,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(elevation: 8.0, primary: secondColor),
                                              child: Text(
                                                carEnties[index].status != CarWorkStatus.COMPLETE ? "Start service" : "DONE",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              onPressed: () {
                                                if (carEnties[index].status != CarWorkStatus.COMPLETE) {
                                                  _startService(context, index);
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 7),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    }

    return new WillPopScope(
      onWillPop: () {
        confirmExit(context);
        return Future<bool>.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          //centerTitle: true,
          title: Text("Today's Schedule"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConnectionToPartner(),
                  ),
                );
              },
              icon: Icon(Icons.bluetooth, color: endpointMap.length == 0 ? Colors.red : Colors.blue),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width * 0.12,
                          width: MediaQuery.of(context).size.width * 0.12,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(partner.dp),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                  fontSize: 19,
                                ),
                              ),
                              Text(
                                "Your Partner",
                                style: TextStyle(
                                  color: textLight,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        launch('tel:' + partner.phone);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 2.0,
                              spreadRadius: 0.0,
                              offset: Offset(0.0, 0.5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: mainColor, size: 15),
                            SizedBox(width: 6),
                            Text(
                              partner.phone,
                              style: TextStyle(color: textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      SizedBox(width: 8),
                      Icon(CupertinoIcons.building_2_fill, color: mainColor, size: 30),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.societyName,
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            schedule.locality,
                            style: TextStyle(fontSize: 13, color: textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      launch('https://www.google.com/maps/search/?api=1&query=${schedule.lat},${schedule.lng}');
                    },
                    child: Wrap(
                      children: [
                        Icon(Icons.location_on, color: mainColor),
                        SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.societyAddress,
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              schedule.societyPin,
                              style: TextStyle(fontSize: 13, color: textLight),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.005),
              Divider(),
              Container(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 15),
                      for (int i = 1; i <= slotMap.length; i++)
                        if (carEnties.any((item) => item.timeRange == slotMap[i])) _timeSlot(i)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: mainColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2),
                      SizedBox(width: 8),
                      Text(
                        "Scan Car",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    scanQR();
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.4,
                child: RoundedLoadingButton(
                  color: secondColor,
                  borderRadius: 5,
                  child: Text(
                    "Done for the day",
                    style: TextStyle(fontSize: 18, color: white),
                  ),
                  controller: _btnController,
                  onPressed: () {
                    bool isComment = false;
                    List<String> undoneCarsList = [];
                    for (int i = 0; i < carEnties.length; i++) {
                      if (carEnties[i].status != CarWorkStatus.COMPLETE) {
                        undoneCarsList.add(carEnties[i].carNumber);
                        isComment = true;
                      }
                    }
                    _btnController.reset();

                    if (isComment == false) {
                      _doneForTheDay();
                    } else {
                      _lateComment(context, undoneCarsList);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
