import 'fragments/cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import 'fragments/confirmExit.dart';
import '../providers/data_provider.dart';
import 'dart:async';
import 'picturescreen.dart';

class OnWork extends StatefulWidget {
  final int carIndex;
  final String section;
  final String schedulePlanId;
  final String stratTime;

  const OnWork({Key key, this.carIndex, this.section, this.schedulePlanId, this.stratTime}) : super(key: key);
  @override
  _OnWorkState createState() => _OnWorkState();
}

class _OnWorkState extends State<OnWork> {
  @override
  Duration duration = Duration();
  Timer timer;

  bool countDown = false;

  @override
  void initState() {
    super.initState();
    reset();
    startTimer();
  }

  void reset() {
    int startMin = int.parse(widget.stratTime.toString().split(":")[1]);
    int currentMin = DateTime.now().toLocal().minute;
    int theMinute;
    if (currentMin > startMin) {
      theMinute = currentMin - startMin;
    } else {
      theMinute = currentMin + (60 - startMin);
    }
    setState(() => duration = Duration(minutes: theMinute));
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  Widget build(BuildContext context) {
    var dataprovider = Provider.of<DataProviderClass>(context);

    Widget buildTime() {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(minutes + ":" + seconds, style: TextStyle(fontSize: 18)),
      ]);
    }

    return new WillPopScope(
      onWillPop: () {
        confirmExit(context);
        return Future<bool>.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(carEnties[widget.carIndex].carNumber),
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
                          height: MediaQuery.of(context).size.width * 0.10,
                          width: MediaQuery.of(context).size.width * 0.10,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width * 0.10,
                          width: MediaQuery.of(context).size.width * 0.10,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(carEnties[widget.carIndex].ownerDp),
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
                                carEnties[widget.carIndex].ownerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                  fontSize: 19,
                                ),
                              ),
                              Text(
                                carEnties[widget.carIndex].ownerAddress,
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
                        launch('tel:' + carEnties[widget.carIndex].ownerPhone);
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
                              carEnties[widget.carIndex].ownerPhone,
                              style: TextStyle(color: textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        carEnties[widget.carIndex].carPicture == ''
                            ? Container(
                                height: MediaQuery.of(context).size.width * 0.10,
                                width: MediaQuery.of(context).size.width * 0.10,
                                decoration: BoxDecoration(
                                  color: mainLight,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Icon(CupertinoIcons.car_detailed, color: mainColor),
                              )
                            : Container(
                                height: MediaQuery.of(context).size.width * 0.10,
                                width: MediaQuery.of(context).size.width * 0.10,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(carEnties[widget.carIndex].carPicture),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              " " + carEnties[widget.carIndex].carModel + " " + carEnties[widget.carIndex].carVariant,
                              style: TextStyle(color: textLight, fontSize: 16),
                            ),
                            carEnties[widget.carIndex].parkingSlot != ''
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Icon(Icons.local_parking_rounded, color: mainColor, size: 14),
                                        SizedBox(width: 2),
                                        Text(carEnties[widget.carIndex].parkingSlot, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.alarm, color: mainColor, size: 17),
                        SizedBox(width: 8),
                        Text(
                          carEnties[widget.carIndex].deliveryTime,
                          style: TextStyle(color: textLight, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              carEnties[widget.carIndex].serviceList.length != 0
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Services",
                              style: TextStyle(color: textLight, fontSize: 16),
                            ),
                          ),
                          Divider(),
                          ListView.builder(
                            itemCount: carEnties[widget.carIndex].serviceList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (carEnties[widget.carIndex].serviceList[index].inOut == widget.section) {
                                return GestureDetector(
                                  onTap: () {
                                    if (carEnties[widget.carIndex].serviceList[index].isCheck == true) {
                                      carEnties[widget.carIndex].serviceList[index].isCheck = false;
                                    } else {
                                      carEnties[widget.carIndex].serviceList[index].isCheck = true;
                                    }
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      carEnties[widget.carIndex].serviceList[index].isCheck == true
                                          ? Icon(Icons.check_box_outlined, color: mainColor, size: 20)
                                          : Icon(Icons.check_box_outline_blank, color: textLight, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        carEnties[widget.carIndex].serviceList[index].serviceName,
                                        style: TextStyle(color: textDark, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : Container(),
              carEnties[widget.carIndex].addOnServiceList.length != 0
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
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
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Addons",
                              style: TextStyle(color: textLight, fontSize: 16),
                            ),
                          ),
                          Divider(),
                          ListView.builder(
                            itemCount: carEnties[widget.carIndex].addOnServiceList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (carEnties[widget.carIndex].addOnServiceList[index].inOut == widget.section) {
                                return GestureDetector(
                                  onTap: () {
                                    if (carEnties[widget.carIndex].addOnServiceList[index].isCheck == true) {
                                      carEnties[widget.carIndex].addOnServiceList[index].isCheck = false;
                                    } else {
                                      carEnties[widget.carIndex].addOnServiceList[index].isCheck = true;
                                    }
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      carEnties[widget.carIndex].addOnServiceList[index].isCheck == true
                                          ? Icon(Icons.check_box_outlined, color: secondColor, size: 20)
                                          : Icon(Icons.check_box_outline_blank, color: textLight, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        carEnties[widget.carIndex].addOnServiceList[index].serviceName,
                                        style: TextStyle(color: textDark, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: Colors.black26),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Start Time",
                        style: TextStyle(color: textLight, fontSize: 12),
                      ),
                      Text(widget.stratTime, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Duration",
                        style: TextStyle(color: textLight, fontSize: 12),
                      ),
                      buildTime(),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  //reset();
                  stopTimer(resets: false);
                  List<String> undoneTasks = [];
                  for (int a = 0; a < carEnties[widget.carIndex].addOnServiceList.length; a++) {
                    if (carEnties[widget.carIndex].addOnServiceList[a].isCheck == false) {
                      undoneTasks.add(carEnties[widget.carIndex].addOnServiceList[a].id);
                    }
                  }
                  for (int a = 0; a < carEnties[widget.carIndex].serviceList.length; a++) {
                    if (carEnties[widget.carIndex].serviceList[a].isCheck == false) {
                      undoneTasks.add(carEnties[widget.carIndex].serviceList[a].id);
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PictureScreen(
                        startEnd: "after",
                        carIndex: widget.carIndex,
                        section: widget.section,
                        undoneTaskList: undoneTasks,
                      ),
                    ),
                  );
                },
                child: textSecondColorSmall("Stop"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
