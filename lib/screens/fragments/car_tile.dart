import 'package:ccube_attendant/screens/today_schedule.dart';

import '../picturescreen.dart';
import 'listings.dart';
import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme.dart';
import 'utilityfunctions.dart';

class CarTile extends StatefulWidget {
  final int carIndex;

  const CarTile({Key key, this.carIndex}) : super(key: key);

  @override
  _CarTileState createState() => _CarTileState();
}

TextEditingController reasonText = new TextEditingController();

class _CarTileState extends State<CarTile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  String workChoice;

  @override
  Widget build(BuildContext context) {
    var dataprovider = Provider.of<DataProviderClass>(context);

    collectKey(String spId, String reasonTxt, String keyChoice) async {
      var res = await dataprovider.keyCollected(spId, reasonTxt, keyChoice);
      if (res == "OK") {
        Toast.show(" Submitted !", context, duration: 2, gravity: Toast.BOTTOM);
        if (keyChoice == 'Yes') {
          carEnties[widget.carIndex].isKeyCollected = true;
        }
        setState(() {});
      } else {
        Toast.show("⚠️ " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
      }
    }

    Future<void> _keyCollect(BuildContext context, String spId, String keyCollectionTime) async {
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
                                        hintText: "Reason...",
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
                              collectKey(spId, reasonText.text, keyChoice);
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

    Future<void> _startService(BuildContext context) async {
      reasonText.clear();
      bool isInsideExist = false;
      if ((carEnties[widget.carIndex].serviceList.any((item) => item.inOut == "Inside")) || (carEnties[widget.carIndex].addOnServiceList.any((item) => item.inOut == "Inside"))) {
        workChoice = "Inside";
        isInsideExist = true;
      } else
        workChoice = "Outside";
      if (carEnties[widget.carIndex].isKeyCollected == false) {
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
                      ListView.builder(
                        itemCount: carEnties[widget.carIndex].serviceList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return inOutListItems(mainColor, carEnties[widget.carIndex].serviceList[index].serviceName, carEnties[widget.carIndex].serviceList[index].inOut, workChoice, context);
                        },
                      ),
                      ListView.builder(
                        itemCount: carEnties[widget.carIndex].addOnServiceList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return inOutListItems(
                              secondColor, carEnties[widget.carIndex].addOnServiceList[index].serviceName, carEnties[widget.carIndex].addOnServiceList[index].inOut, workChoice, context);
                        },
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
                                      if (carEnties[widget.carIndex].isKeyCollected == false) {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PictureScreen(
                                  startEnd: "before",
                                  carIndex: widget.carIndex,
                                  section: workChoice,
                                ),
                              ),
                            );
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
              );
            },
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        activeCar = carEnties[widget.carIndex].carNumber;
        print(activeCar);
        setState(() {});
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(carEnties[widget.carIndex].isKeyCollected.toString(), style: TextStyle(fontSize: 16)),
                  Wrap(
                    children: [
                      Container(color: textLight, width: 1, height: 14),
                      SizedBox(
                        width: 50,
                        child: Wrap(
                          children: [
                            SizedBox(width: 5),
                            carEnties[widget.carIndex].isKeyRequired == false
                                ? Container()
                                : Icon(Icons.vpn_key, size: 14, color: carEnties[widget.carIndex].isKeyCollected == true ? Colors.amber[600] : textLight),
                            SizedBox(width: 5),
                            Text(
                              carEnties[widget.carIndex].label,
                              style: TextStyle(color: carEnties[widget.carIndex].addOnCount == 0 ? textLight : secondColor),
                            ),
                            SizedBox(width: 5),
                            Text(
                              carEnties[widget.carIndex].addOnCount.toString(),
                              style: TextStyle(color: "nmr" == "0" ? textLight : mainColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              carEnties[widget.carIndex].carNumber == activeCar
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
                                  image: NetworkImage(carEnties[widget.carIndex].ownerDp),
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
                                    carEnties[widget.carIndex].ownerName,
                                    style: TextStyle(
                                      color: textDark,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    carEnties[widget.carIndex].ownerAddress,
                                    style: TextStyle(
                                      color: textLight,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            launch('tel:' + carEnties[widget.carIndex].ownerPhone);
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.phone, color: mainColor, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  carEnties[widget.carIndex].ownerPhone,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                              carEnties[widget.carIndex].keyCollectionTime,
                              style: TextStyle(fontSize: 15),
                            ),
                            carEnties[widget.carIndex].isKeyRequired == false
                                ? Container()
                                : SizedBox(
                                    height: 17,
                                    width: 80,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(elevation: 4.0, primary: carEnties[widget.carIndex].isKeyCollected == false ? mainColor : mainLight),
                                      child: Text(
                                        carEnties[widget.carIndex].isKeyCollected == false ? "Collect" : "Collected",
                                        style: TextStyle(fontSize: 11, color: carEnties[widget.carIndex].isKeyCollected == false ? white : textDark),
                                      ),
                                      onPressed: () {
                                        if (carEnties[widget.carIndex].isKeyCollected == false) {
                                          _keyCollect(context, carEnties[widget.carIndex].schedulePlanId, carEnties[widget.carIndex].keyCollectionTime);
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
                            Text(carEnties[widget.carIndex].deliveryTime.toString()),
                          ],
                        ),
                        SizedBox(height: 3),
                        SizedBox(
                          height: 20,
                          width: 90,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(elevation: 8.0, primary: secondColor),
                            child: Text(
                              "Start service",
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              _startService(context);
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
    );
  }
}
