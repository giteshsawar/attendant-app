import 'fragments/utilityfunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'on_work.dart';
import 'today_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fragments/connection_related.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:typed_data';
import '../providers/schedule.dart';
import 'package:firebase_core/firebase_core.dart';

class PictureScreen extends StatefulWidget {
  final String section;
  final int carIndex;
  final String startEnd;
  final List<String> undoneTaskList;

  const PictureScreen({Key key, this.section, this.carIndex, this.startEnd, this.undoneTaskList}) : super(key: key);

  @override
  _PictureScreenState createState() => _PictureScreenState();
}

final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
TextEditingController reasonText = new TextEditingController();

class _PictureScreenState extends State<PictureScreen> {
  File imageFile;
  List<File> imageList = [];

  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<DataProviderClass>(context);

    //check for isLate
    var isLateCheckTime = DateTime.now().toLocal();
    bool isLate;

    String timeisLateCheckTime;
    if (isLateCheckTime.minute.toString().length == 1) {
      timeisLateCheckTime = isLateCheckTime.hour.toString() + ":0" + isLateCheckTime.minute.toString();
      if (isLateCheckTime.hour.toString().length == 1) {
        timeisLateCheckTime = "0" + timeisLateCheckTime;
      }
    } else {
      timeisLateCheckTime = isLateCheckTime.hour.toString() + ":" + isLateCheckTime.minute.toString();
      if (isLateCheckTime.hour.toString().length == 1) {
        timeisLateCheckTime = "0" + timeisLateCheckTime;
      }
    }
    if (compareTime(timeisLateCheckTime, carEnties[widget.carIndex].deliveryTime) == false) {
      isLate = true;
    } else {
      isLate = false;
    }

    Future<void> endUploadImages() async {
      var imgA = [];
      for (int i = 0; i < imageList.length; i++) {
        imgA.add(imageList[i].toString());
      }
      final prefs = await SharedPreferences.getInstance();
      var currentData = prefs.getString('pendingList');
      if (currentData != null) {
        List newCurrentData = json.decode(currentData);
        for (int i = 0; i < newCurrentData.length; i++) {
          if (newCurrentData[i]['jobId'] == carEnties[widget.carIndex].schedulePlanId) {
            var date2 = DateTime.now();
            newCurrentData[i]['endTime'] = date2.toUtc().toLocal().toString();
            newCurrentData[i]['afterMedia'] = {'media': imgA, 'timing': 'after'};
            newCurrentData[i]['endComment'] = reasonText.text;
            newCurrentData[i]['undoneTasks'] = widget.undoneTaskList;
          }
        }
        prefs.setString('pendingList', json.encode(newCurrentData));
      }
      if (carEnties[widget.carIndex].status == CarWorkStatus.OUTSIDEDONE) {
        if (widget.section == "Inside") {
          carEnties[widget.carIndex].status = CarWorkStatus.COMPLETE;
        }
      } else if (carEnties[widget.carIndex].status == CarWorkStatus.INSIDEDONE) {
        if (widget.section == "Outside") {
          carEnties[widget.carIndex].status = CarWorkStatus.COMPLETE;
        }
      } else {
        if (widget.section == "Outside") {
          carEnties[widget.carIndex].status = CarWorkStatus.OUTSIDEDONE;
          if (carEnties[widget.carIndex].isKeyRequired == false) {
            carEnties[widget.carIndex].status = CarWorkStatus.COMPLETE;
          }
        } else if (widget.section == "Inside") {
          carEnties[widget.carIndex].status = CarWorkStatus.INSIDEDONE;
        }
      }
      //carEnties[widget.carIndex].isDone = true;
      prefs.remove('onWorkStartTime');
      prefs.remove('onWorkSschedulePlanId');
      prefs.remove('onWorkSsection');
      prefs.remove('onWorkCarIndex');
      prefs.setString('screen', 'schedule');

      // If there is internet, upload the car data
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          var currentDataTemp = prefs.getString('pendingList');

          List currentData2 = json.decode(currentDataTemp);
          await Firebase.initializeApp();
          var res2 = await dataProvider.saveSesionBulkIntermediate(currentData2, "");
        }
      } on SocketException catch (_) {}

      _btnController.success();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TodaySchedule()),
        (Route<dynamic> route) => false,
      );
    }

    Future<void> startUploadImages() async {
      var date = DateTime.now().toLocal();
      String time;
      if (date.minute.toString().length == 1) {
        time = date.hour.toString() + ":0" + date.minute.toString();
        if (date.hour.toString().length == 1) {
          time = "0" + time;
        }
      } else {
        time = date.hour.toString() + ":" + date.minute.toString();
        if (date.hour.toString().length == 1) {
          time = "0" + time;
        }
      }

      var imgB = [];
      var imgA = [];
      for (int i = 0; i < imageList.length; i++) {
        imgB.add(imageList[i].toString());
      }
      var date2 = DateTime.now();
      var pendingData = {
        'jobId': carEnties[widget.carIndex].schedulePlanId,
        'startTime': date2.toUtc().toLocal().toString(),
        'endTime': '',
        'section': widget.section.toLowerCase(),
        'beforeMedia': {'media': imgB, 'timing': 'before'},
        'afterMedia': {'media': imgA, 'timing': 'after'},
        'startReason': reasonText.text,
        'endComment': '',
        'undoneTasks': '',
      };
      final prefs = await SharedPreferences.getInstance();
      List newData = [];
      int pendingIndex = prefs.getInt('pendingIndex');
      var currentData = prefs.getString('pendingList');
      if (currentData == null) {
        prefs.setInt('pendingIndex', 1);
        newData.add(pendingData);
        prefs.setString('pendingList', json.encode(newData));
      } else {
        List newCurrData = json.decode(currentData);
        print(newCurrData.length);
        prefs.setInt('pendingIndex', pendingIndex + 1);
        for (int i = 0; i < newCurrData.length; i++) {
          newData.add(newCurrData[i]);
        }
        newData.add(pendingData);
        prefs.setString('pendingList', json.encode(newData));
      }
      _btnController.success();
      prefs.setString('onWorkStartTime', time);
      prefs.setString('onWorkSschedulePlanId', carEnties[widget.carIndex].schedulePlanId);
      prefs.setString('onWorkSsection', widget.section);
      prefs.setInt('onWorkCarIndex', widget.carIndex);
      prefs.setString('screen', 'onwork');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnWork(
            carIndex: widget.carIndex,
            section: widget.section,
            schedulePlanId: carEnties[widget.carIndex].schedulePlanId,
            stratTime: time,
          ),
        ),
      );
    }

    void pickImage() async {
      imageFile = null;
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 50,
      );

      imageFile = File(pickedFile.path);

      if (imageFile != null) {
        setState(() {
          imageList.add(imageFile);
        });
      }
    }

    Future<void> confirmEndUpload(BuildContext context) async {
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
                            "End Service",
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "Please make sure that \nthe car is properly locked",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondColor, fontSize: 18),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image.asset('assets/lock2.png'),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.024),
                    SizedBox(
                      height: 32,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: GestureDetector(
                        onTap: () {
                          endpointMap.forEach((key, value) {
                            String a = widget.section + "*" + carEnties[widget.carIndex].carNumber;
                            Nearby().sendBytesPayload(key, Uint8List.fromList(a.codeUnits));
                          });
                          endUploadImages();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Center(child: Text(" End ", style: TextStyle(color: white))),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Tap to Click Pictures"),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel_outlined, color: white, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLate == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 12, top: 12),
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
                                hintText: "You are late, provide a reason...",
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
              Center(
                child: Text(
                  "Files should be jpg, jpeg, png",
                  style: TextStyle(color: textLight, fontSize: 20),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (imageList.length < 4) {
                    pickImage();
                  } else {
                    Toast.show("⚠️ Only 4 images allowed !", context, duration: 2, gravity: Toast.BOTTOM);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: mainLight, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Center(
                    child: Icon(Icons.camera_alt, color: mainLight, size: 70),
                  ),
                ),
              ),
              SizedBox(height: 15),
              imageList.length == 0
                  ? Container()
                  : Text(
                      "Upload List",
                      style: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
              imageList.length == 0 ? Container() : SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < imageList.length; i++)
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 15),
                            height: MediaQuery.of(context).size.width * 0.18,
                            child: Image.file(imageList[i]),
                          ),
                          Positioned(
                            top: -18,
                            right: -7,
                            child: IconButton(
                              icon: Icon(Icons.cancel, color: textLight),
                              onPressed: () {
                                imageList.remove(imageList[i]);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              imageList.length == 0
                  ? Container()
                  : RoundedLoadingButton(
                      color: mainColor,
                      borderRadius: 25,
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 32,
                      child: Text('Upload', style: TextStyle(color: Colors.white, fontSize: 18)),
                      controller: _btnController,
                      onPressed: () {
                        if ((isLate == true) && (reasonText.text == "")) {
                          _btnController.reset();
                          Toast.show("⚠️ You need to provide reason !", context, duration: 2, gravity: Toast.BOTTOM);
                        } else {
                          if (widget.startEnd == "before") {
                            startUploadImages();
                          } else {
                            confirmEndUpload(context);
                          }
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
