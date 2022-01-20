import 'fragments/cards.dart';
import 'today_schedule.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'package:toast/toast.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'fragments/confirmExit.dart';

class PreCheck extends StatefulWidget {
  const PreCheck({Key key}) : super(key: key);

  @override
  _PreCheckState createState() => _PreCheckState();
}

final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

class _PreCheckState extends State<PreCheck> {
  @override
  Widget build(BuildContext context) {
    var dataprovider = Provider.of<DataProviderClass>(context);

    Future<void> receivedConsumables() async {
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => TodaySchedule()),
      //   (Route<dynamic> route) => false,
      // );
      var res = await dataprovider.preCheckReceived();
      if (res == "OK") {
        _btnController.success();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TodaySchedule()),
          (Route<dynamic> route) => false,
        );
      } else {
        Toast.show("⚠️  " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
        _btnController.reset();
      }
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
          title: Text("Pre Check"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
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
                Divider(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Today's work",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textDark,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    multiColorCard("Washing", schedule.washingCount.toString()),
                    multiColorCard("Dusting", schedule.dustingCount.toString()),
                    multiColorCard("Addons", schedule.addOnsCount.toString()),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Divider(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Items required for work",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textDark,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            "Name",
                            style: TextStyle(color: textLight, fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            "Quantity",
                            style: TextStyle(color: textLight, fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            "  For addon",
                            style: TextStyle(color: textLight, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      itemCount: itemsToPick.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: GestureDetector(
                                onTap: () {
                                  if (itemsToPick[index].isCheck == true) {
                                    itemsToPick[index].isCheck = false;
                                  } else {
                                    itemsToPick[index].isCheck = true;
                                  }
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    itemsToPick[index].isCheck == true ? Icon(Icons.check_box_outlined, color: mainColor, size: 20) : Icon(Icons.check_box_outline_blank, color: textLight, size: 20),
                                    SizedBox(width: 3),
                                    Text(
                                      itemsToPick[index].itemName,
                                      style: TextStyle(color: textDark, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Text(
                                "  " + itemsToPick[index].quantity.toStringAsPrecision(4),
                                style: TextStyle(color: textDark, fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: itemsToPick[index].isForAddOn == true ? secondColor : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                RoundedLoadingButton(
                  color: mainColor,
                  borderRadius: 25,
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 32,
                  child: Text('Received', style: TextStyle(color: Colors.white, fontSize: 18)),
                  controller: _btnController,
                  onPressed: () {
                    receivedConsumables();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
