import '../providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'on_work.dart';
import 'today_schedule.dart';
import 'pre_check.dart';
import 'home_page.dart';
import 'dart:io';
import 'dart:async';
import 'package:toast/toast.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> getData(BuildContext context) async {
    var profile = Provider.of<DataProviderClass>(context);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var id = pref.getString('id');
      var screen = pref.getString('screen');
      print(screen);
      if (id == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (screen == 'home') {
          var ans = await profile.setProfile(id.toString());
          if (ans == "OK") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
          } else {
            Toast.show("⚠️ " + ans + " !", context, duration: 2, gravity: Toast.BOTTOM);
          }
        } else if (screen == 'precheck') {
          var ans0 = await profile.setProfile(id.toString());
          var ans1 = await profile.getSchedule();
          await profile.carDoneMarkerLocalStorage();
          if (ans1 == "No Schedule Available") {
            pref.setString('screen', 'home');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
          }
          if ((ans0 == "OK") && (ans1 == "OK")) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PreCheck()),
              (Route<dynamic> route) => false,
            );
          } else {
            print("precheck_");
            Toast.show("⚠️ " + ans1 + " !", context, duration: 2, gravity: Toast.BOTTOM);
          }
        } else if (screen == 'schedule') {
          var ans0 = await profile.setProfile(id.toString());
          var ans1 = await profile.getSchedule();
          if (ans1 == "No Schedule Available") {
            pref.setString('screen', 'home');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
          }
          await profile.carDoneMarkerLocalStorage();
          if ((ans0 == "OK") && (ans1 == "OK")) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => TodaySchedule()),
              (Route<dynamic> route) => false,
            );
          } else {
            print("schedule_");
            Toast.show("⚠️ " + ans1 + " !", context, duration: 2, gravity: Toast.BOTTOM);
          }
        } else if (screen == 'onwork') {
          var ans0 = await profile.setProfile(id.toString());
          var ans1 = await profile.getSchedule();
          await profile.carDoneMarkerLocalStorage();
          if ((ans0 == "OK") && (ans1 == "OK")) {
            String startTimeV = pref.getString('onWorkStartTime');
            String sectionV = pref.getString('onWorkSsection');
            int carIndexV = pref.getInt('onWorkCarIndex');
            String schedulePlanIdV = pref.getString('onWorkSschedulePlanId');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => OnWork(
                        schedulePlanId: schedulePlanIdV,
                        carIndex: carIndexV,
                        section: sectionV,
                        stratTime: startTimeV,
                      )),
              (Route<dynamic> route) => false,
            );
          } else {
            print("onWork_");
            Toast.show("⚠️ " + ans1 + " !", context, duration: 2, gravity: Toast.BOTTOM);
          }
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on SocketException catch (_) {
      Toast.show(" Internet is not connected !", context, duration: 2, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    getData(context);
    return Container(
      width: double.infinity,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/bg.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/white_logo.png'),
          SizedBox(height: 20),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
