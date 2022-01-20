import 'package:ccube_attendant/screens/login_screen.dart';

import 'pre_check.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'fragments/cards.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'fragments/confirmExit.dart';
import 'package:toast/toast.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'today_schedule.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
final RoundedLoadingButtonController _btnController2 = RoundedLoadingButtonController();

class _HomePageState extends State<HomePage> {
  var todayDate = DateTime.now().toLocal().toString().substring(0, 10);
  String btnText = '', calendarDate = '';
  DateTime selectedDate;

  Future<void> setBtnText() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('markAtt') != todayDate) {
      btnText = " Mark Attendance ";
    } else {
      btnText = " See Schedule ";
    }

    if (calendarDate == '') {
      selectedDate = DateTime.now().toLocal();
      calendarDate = selectedDate.toString().substring(5, 7) + "/" + selectedDate.toString().substring(0, 4);
    }
    setState(() {});
  }

  confirmLogout(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "CANCEL",
        style: TextStyle(color: mainColor),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        "CONFIRM",
        style: TextStyle(color: Colors.black38),
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.remove('id');
        pref.remove('screen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
    AlertDialog alert = AlertDialog(
      title: Column(
        children: <Widget>[
          Text(
            "Are you sure you want to Logout ?",
            style: new TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
      actions: [cancelButton, okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<DataProviderClass>(context);
    setBtnText();

    Future<void> _markAttendance() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      //_btnController.reset();
      var ans = await profile.markMePresent();
      if (ans == "OK") {
        _btnController.success();
        pref.setString('markAtt', todayDate);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PreCheck()),
          (Route<dynamic> route) => false,
        );
      } else if (ans == "JUMP") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TodaySchedule()),
          (Route<dynamic> route) => false,
        );
      } else {
        _btnController.reset();
        Toast.show("⚠️ " + ans + " !", context, duration: 2, gravity: Toast.BOTTOM);
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
          title: Text("Your Profile"),
          actions: [
            IconButton(
                onPressed: () {
                  confirmLogout(context);
                },
                icon: Icon(Icons.exit_to_app))
          ],
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
                          height: MediaQuery.of(context).size.width * 0.2,
                          width: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(user.dp),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Attendant",
                                style: TextStyle(
                                  color: textLight,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    RoundedLoadingButton(
                      color: secondColor,
                      borderRadius: 25,
                      width: MediaQuery.of(context).size.width * 0.22,
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(btnText, style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      controller: _btnController,
                      onPressed: () {
                        _markAttendance();
                      },
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              "Employee ID:",
                              style: TextStyle(color: textLight, fontSize: 15),
                            ),
                          ),
                          Text(
                            user.empId,
                            style: TextStyle(color: textDark, fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              "Phone:",
                              style: TextStyle(color: textLight, fontSize: 15),
                            ),
                          ),
                          Text(
                            user.phone,
                            style: TextStyle(color: textDark, fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              "Joining Date:",
                              style: TextStyle(color: textLight, fontSize: 15),
                            ),
                          ),
                          Text(
                            user.joinDate.toString().substring(8, 10) + "/" + user.joinDate.toString().substring(5, 7) + "/" + user.joinDate.toString().substring(0, 4),
                            style: TextStyle(color: textDark, fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(
                              "Total Ratings:",
                              style: TextStyle(color: textLight, fontSize: 15),
                            ),
                          ),
                          Wrap(
                            children: [
                              Icon(Icons.star, color: mainColor),
                              Icon(Icons.star, color: mainColor),
                              Icon(Icons.star, color: mainColor),
                              Icon(Icons.star, color: mainColor),
                              Icon(Icons.star, color: mainColor),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RoundedLoadingButton(
                      color: white,
                      borderRadius: 25,
                      width: MediaQuery.of(context).size.width * 0.22,
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(calendarDate, style: TextStyle(color: textDark, fontSize: 14)),
                      ),
                      controller: _btnController2,
                      onPressed: () {
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1, 5),
                          lastDate: DateTime(DateTime.now().year + 1, 9),
                          initialDate: selectedDate,
                          locale: Locale("en"),
                        ).then((date) async {
                          if (date != null) {
                            selectedDate = date;
                            var res = await profile.updateAttendance(date.month.toString(), date.year.toString());
                            if (res == "OK") {
                              _btnController2.reset();
                              Toast.show("Updated !", context, duration: 2, gravity: Toast.BOTTOM);
                              calendarDate = date.month.toString() + "/" + date.year.toString();
                              setState(() {});
                            } else {
                              _btnController2.reset();
                              Toast.show("⚠️ " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
                              calendarDate = date.month.toString() + "/" + date.year.toString();
                              setState(() {});
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Work history",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textDark,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: apartCard("Total services", user.services, mainColor),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: apartCard("Total addons", user.addons, secondColor),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: apartCard("Total adhocs", user.adhocs, mainColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Attendance",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textDark,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.29,
                                child: apartCard("Present", user.present, mainColor),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.29,
                                child: apartCard("Absent", user.absent, secondColor),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.32,
                                child: apartCard("Late in/ Early out", user.earlyLate, mainColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Financials",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textDark,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: apartCard("In-hand salary", "Rs." + user.salary, mainColor),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: apartCard("Incentive", "Rs." + user.incentive, mainColor),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: apartCard("Penalty", "Rs." + user.penalty, Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
