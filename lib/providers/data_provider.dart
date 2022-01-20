import 'schedule.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'user_profile.dart';
import 'package:intl/intl.dart';
import 'urls.dart';
import '../screens/fragments/utilityfunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

Profile user = new Profile();
Partner partner = new Partner();
Schedule schedule = new Schedule();

List<CarEntry> carEnties = [];
List<ItemsList> itemsToPick = [];

String myAttendantNumber;

class DataProviderClass extends ChangeNotifier {
  setUserData(var data) {
    int incentiveR = 0, penaltyR = 0;
    if (data['financials'] != null) {
      if (data['financials']['incentive'] != null) {
        var incentiveA = data['financials']['incentive'];
        if (incentiveA != null) {
          for (int i = 0; i < incentiveA.length; i++) {
            incentiveR += incentiveA[i];
          }
        }
      }
      if (data['financials']['penalty'] != null) {
        var penaltyA = data['financials']['penalty'];

        if (penaltyA != null) {
          for (int i = 0; i < penaltyA.length; i++) {
            penaltyR += penaltyA[i];
          }
        }
      }
    }

    user.id = data['_id'].toString();
    user.name = data['name'].toString();
    user.dp = data['profilePic'].toString();
    user.empId = data['employeeId'].toString();
    user.phone = data['phoneNumber'].toString();
    user.designation = data['designation'].toString();
    user.salary = data['salary'].toString();
    user.joinDate = data['joiningDate'].toString().substring(0, 10);
    user.rating = (double.parse(data['ratingCurrent'].toString()) / double.parse(data['ratingMax'].toString()));
    user.penalty = penaltyR.toString();
    user.incentive = incentiveR.toString();
  }

  setUserAttendance(var offDays, var data, var workData) {
    var date = DateTime.now().toLocal();
    int absent = 0, present = 0, earlyLate = 0;

    for (DateTime indexDay = DateTime(date.year, date.month, 1); indexDay.month == date.month; indexDay = indexDay.add(Duration(days: 1))) {
      if (data['data'].any((item) => item['date'].toString().substring(0, 10) == indexDay.toString().substring(0, 10))) {
        present++;
      } else {
        if (offDays.toString().contains(indexDay.weekday.toString()) == false) absent++;
      }
      if ((date.year == indexDay.year) && (date.month == indexDay.month) && (date.day == indexDay.day)) break;
    }
    for (int i = 0; i < data['data'].length; i++) {
      if (data['data'][i]['lateEntry'] == true) earlyLate++;
      if (data['data'][i]['earlyOut'] == true) earlyLate++;
    }
    user.addons = workData['data']['addOns'].toString();
    user.adhocs = workData['data']['adHocs'].toString();
    user.services = workData['data']['services'].toString();
    user.present = present.toString();
    user.absent = absent.toString();
    user.earlyLate = earlyLate.toString();
  }

  Future<String> updateAttendance(String month, String year) async {
    var date = DateTime.now().toLocal();

    var response = await http.post(Uri.parse(get_profile), body: {'employeeId': user.id});
    var data = jsonDecode(response.body);
    var response2 = await http.post(Uri.parse(get_monthly), body: {'employeeId': user.id, 'month': month, 'year': year});
    var data2 = jsonDecode(response2.body);
    if (data2['data'].toString() == "[]") {
      user.addons = "0";
      user.adhocs = "0";
      user.services = "0";
      user.present = "0";
      user.absent = "0";
      user.earlyLate = "0";
      return "No Attendance Data Found";
    }
    var response3 = await http.post(Uri.parse(get_work_history), body: {'employeeId': user.id, 'month': month, 'year': year});
    var data3 = jsonDecode(response3.body);
    await setUserAttendance(data['data']['user']['shift']['offDays'], data2, data3);
    int absent = 0, present = 0, earlyLate = 0;

    for (DateTime indexDay = DateTime(int.parse(year), int.parse(month), 1); indexDay.month == int.parse(month); indexDay = indexDay.add(Duration(days: 1))) {
      if (data2['data'].any((item) => item['date'].toString().substring(0, 10) == indexDay.toString().substring(0, 10))) {
        present++;
      } else {
        if (data['data']['user']['shift']['offDays'].toString().contains(indexDay.weekday.toString()) == false) absent++;
      }
      if ((date.year == indexDay.year) && (date.month == indexDay.month) && (date.day == indexDay.day)) break;
    }
    for (int i = 0; i < data['data'].length; i++) {
      if (data2['data'][i]['lateEntry'] == true) earlyLate++;
      if (data2['data'][i]['earlyOut'] == true) earlyLate++;
    }
    user.addons = data3['data']['addOns'].toString();
    user.adhocs = data3['data']['adHocs'].toString();
    user.services = data3['data']['services'].toString();
    user.present = present.toString();
    user.absent = absent.toString();
    user.earlyLate = earlyLate.toString();
    return "OK";
  }

  Future<String> loginwithPassword(String eid, String pwd) async {
    var date = DateTime.now();
    String monthNumber = DateFormat('M').format(date).toString();
    String yearNumber = DateFormat('y').format(date).toString();

    final response = await http.post(Uri.parse(login_employeeWPassword), body: {'employeeId': eid, 'password': pwd});
    var data = jsonDecode(response.body);

    if (data['user'] == null) {
      return "Invalid Login Credentials";
    }

    if (data['user']['_id'] != null) {
      var response2 = await http.post(Uri.parse(get_monthly), body: {'employeeId': data['user']['_id'], 'month': monthNumber, 'year': yearNumber});
      var data2 = jsonDecode(response2.body);
      jsonEncode(data);
      setUserData(data['user']);
      var response3 = await http.post(Uri.parse(get_work_history), body: {'employeeId': data['user']['_id'], 'month': monthNumber, 'year': yearNumber});
      var data3 = jsonDecode(response3.body);
      setUserAttendance(data['user']['shift']['offDays'], data2, data3);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('id', data['user']['_id'].toString());
      pref.setString('screen', 'home');
      return "OK";
    } else {
      return data['error'];
    }
  }

  Future<String> sendOTP(String pnmr) async {
    final response = await http.post(Uri.parse(generate_loginOTP), body: {'phoneNumber': pnmr});
    var data = jsonDecode(response.body);
    if (data['status'] == 200) {
      return "SENT";
    } else {
      return "ERROR";
    }
  }

  Future<String> verifyOTP(String pnmr, String otp) async {
    var date = DateTime.now();
    String monthNumber = DateFormat('M').format(date).toString();
    String yearNumber = DateFormat('y').format(date).toString();

    var response = await http.post(Uri.parse(login_employeeWOTP), body: {'phoneNumber': pnmr, 'otpCode': otp});
    var data = jsonDecode(response.body);

    if (data['user']['_id'] != null) {
      var response2 = await http.post(Uri.parse(get_monthly), body: {'employeeId': data['user']['_id'], 'month': monthNumber, 'year': yearNumber});
      var data2 = jsonDecode(response2.body);
      var response3 = await http.post(Uri.parse(get_work_history), body: {'employeeId': data['user']['_id'], 'month': monthNumber, 'year': yearNumber});
      var data3 = jsonDecode(response3.body);
      setUserAttendance(data['user']['shift']['offDays'], data2, data3);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('id', data['user']['_id'].toString());
      pref.setString('screen', 'home');
      setUserData(data['user']);
      return "OK";
    }

    if (data['user'] == null) {
      return "Invalid";
    }
  }

  Future<String> setProfile(String id) async {
    var date = DateTime.now();
    String monthNumber = DateFormat('M').format(date).toString();
    String yearNumber = DateFormat('y').format(date).toString();

    var response = await http.post(Uri.parse(get_profile), body: {'employeeId': id});
    var data = jsonDecode(response.body);

    if (data['data']['user']['_id'] != null) {
      var response2 = await http.post(Uri.parse(get_monthly), body: {'employeeId': id, 'month': monthNumber, 'year': yearNumber});
      var data2 = jsonDecode(response2.body);
      var response3 = await http.post(Uri.parse(get_work_history), body: {'employeeId': id, 'month': monthNumber, 'year': yearNumber});
      var data3 = jsonDecode(response3.body);
      setUserAttendance(data['data']['user']['shift']['offDays'], data2, data3);
      setUserData(data['data']['user']);
      return "OK";
    }

    return data['error'];
  }

  Future<void> addItemToPickListFunction(String name, double qnt, bool isAdOn, String _id) {
    if (itemsToPick.length == 0) {
      ItemsList pickItem = ItemsList(
        itemName: name,
        isCheck: true,
        isForAddOn: isAdOn,
        quantity: qnt,
        id: _id,
      );
      itemsToPick.add(pickItem);
    } else {
      bool existH = false;
      for (int i = 0; i < itemsToPick.length; i++) {
        if (itemsToPick[i].itemName == name) {
          existH = true;
          itemsToPick[i].quantity += qnt;
          break;
        }
      }
      if (existH == false) {
        ItemsList pickItem = ItemsList(
          itemName: name,
          isCheck: true,
          isForAddOn: isAdOn,
          quantity: qnt,
          id: _id,
        );
        itemsToPick.add(pickItem);
      }
    }
    return null;
  }

  Future<String> setSchedule(var data, var data2) async {
    var date = DateTime.now().toLocal();
    String weekDay = DateFormat('EEEE').format(date).toLowerCase();
    itemsToPick.clear();

    print(data);
    //Partner Info
    if (data['data']['attendant_one']['_id'] == user.id) {
      myAttendantNumber = "attendant_one";
      partner.empId = data['data']['attendant_two']['employeeId'];
      partner.name = data['data']['attendant_two']['name'];
      partner.phone = data['data']['attendant_two']['phoneNumber'].toString();
      partner.dp = data['data']['attendant_two']['profilePic'];
    } else {
      myAttendantNumber = "attendant_two";
      partner.empId = data['data']['attendant_one']['employeeId'];
      partner.name = data['data']['attendant_one']['name'];
      partner.phone = data['data']['attendant_one']['phoneNumber'].toString();
      partner.dp = data['data']['attendant_one']['profilePic'];
    }

    print("checkPt");

    // //schedule Info
    schedule.schduleId = data['data']['_id'];
    if (data['data']['jobs'].length == 0) {
      return "No Work Today";
    } else {
      //Society Information
      schedule.societyAddress =
          data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['city'] + ", " + data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['state'];
      schedule.societyName = data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['name'];
      schedule.societyPin = data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['zipCode'];
      schedule.locality = data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['locality'];
      schedule.lat = data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['location']['coordinates'][0].toString();
      schedule.lng = data['data']['jobs'][0]['schedulePlan']['purchase']['user']['locality']['location']['coordinates'][1].toString();

      schedule.washingCount = 0;
      schedule.addOnsCount = 0;
      schedule.dustingCount = 0;

      carEnties.clear();

      int thisCarAddOn;

      print("checkPt");

      for (int i = 0; i < data['data']['jobs'].length; i++) {
        print("checkPt");
        List<ServiceList> sList = [];
        List<AddOnServiceList> asList = [];
        thisCarAddOn = 0;
        bool isKeyRequiredV = false;

        if (data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan'] != null) {
          if (data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan']['label'] == "washing") schedule.washingCount++;
          if (data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan']['label'] == "dusting") schedule.dustingCount++;

          //Day wise services
          for (int a = 0; a < data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan']['services'].length; a++) {
            for (int s = 0; s < data2['data'].length; s++) {
              if (data2['data'][s]['_id'] == data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan']['services'][a]) {
                //check Inside/Outside
                String inOrOut;
                if (data2['data'][s]['isInternalJob'] == true) {
                  isKeyRequiredV = true;
                  inOrOut = "Inside";
                } else {
                  inOrOut = "Outside";
                }

                //ForItemsToCollect
                for (int it = 0; it < data2['data'][s]['items'].length; it++) {
                  addItemToPickListFunction(
                    data2['data'][s]['items'][it]['consumable']['name'],
                    double.parse(data2['data'][s]['items'][it]['quantity'].toString()),
                    data2['data'][s]['items'][it]['consumable']['addOn'],
                    data2['data'][s]['items'][it]['consumable']['_id'],
                  );
                }

                //addOns
                if (data2['data'][s]['addOn'] == true) {
                  schedule.addOnsCount++;
                  thisCarAddOn++;
                  AddOnServiceList asListItem = AddOnServiceList(
                    id: data2['data'][s]['_id'],
                    serviceName: data2['data'][s]['name'],
                    inOut: inOrOut,
                    isCheck: true,
                  );
                  asList.add(asListItem);
                } else {
                  ServiceList sListItem = ServiceList(
                    id: data2['data'][s]['_id'],
                    serviceName: data2['data'][s]['name'],
                    inOut: inOrOut,
                    isCheck: true,
                  );
                  sList.add(sListItem);
                }
              }
            }
          }

          //Extra service
          for (int b = 0; b < data['data']['jobs'][i]['schedulePlan'][weekDay]['extraServices'].length; b++) {
            for (int s = 0; s < data2['data'].length; s++) {
              if (data2['data'][s]['_id'] == data['data']['jobs'][i]['schedulePlan'][weekDay]['extraServices'][b]) {
                //check Inside/Outside
                String inOrOut;
                if (data2['data'][s]['isInternalJob'] == true) {
                  isKeyRequiredV = true;
                  inOrOut = "Inside";
                } else {
                  inOrOut = "Outside";
                }

                //ForItemsToCollect
                for (int it = 0; it < data2['data'][s]['items'].length; it++) {
                  addItemToPickListFunction(
                    data2['data'][s]['items'][it]['consumable']['name'],
                    double.parse(data2['data'][s]['items'][it]['quantity'].toString()),
                    data2['data'][s]['items'][it]['consumable']['addOn'],
                    data2['data'][s]['items'][it]['consumable']['_id'],
                  );
                }

                //addOns
                if (data2['data'][s]['addOn'] == true) {
                  schedule.addOnsCount++;
                  thisCarAddOn++;
                  AddOnServiceList asListItem = AddOnServiceList(
                    id: data2['data'][s]['_id'],
                    serviceName: data2['data'][s]['name'],
                    inOut: inOrOut,
                    isCheck: true,
                  );
                  asList.add(asListItem);
                } else {
                  ServiceList sListItem = ServiceList(
                    id: data2['data'][s]['_id'],
                    serviceName: data2['data'][s]['name'],
                    inOut: inOrOut,
                    isCheck: true,
                  );
                  sList.add(sListItem);
                }
              }
            }
          }

          //Additional Service
          for (int c = 0; c < data['data']['jobs'][i]['additionalServices'].length; c++) {
            for (int s = 0; s < data2['data'].length; s++) {
              if (data2['data'][s]['_id'] == data['data']['jobs'][i]['additionalServices'][c]) {
                //check Inside/Outside
                String inOrOut;
                if (data2['data'][s]['isInternalJob'] == true) {
                  isKeyRequiredV = true;
                  inOrOut = "Inside";
                } else {
                  inOrOut = "Outside";
                }

                //ForItemsToCollect
                for (int it = 0; it < data2['data'][s]['items'].length; it++) {
                  addItemToPickListFunction(
                    data2['data'][s]['items'][it]['consumable']['name'],
                    double.parse(data2['data'][s]['items'][it]['quantity'].toString()),
                    data2['data'][s]['items'][it]['consumable']['addOn'],
                    data2['data'][s]['items'][it]['consumable']['_id'],
                  );
                }

                //addOns
                if (data2['data'][s]['addOn'] == true) {
                  schedule.addOnsCount++;
                  thisCarAddOn++;
                  AddOnServiceList asListItem = AddOnServiceList(
                    id: data2['data'][s]['_id'],
                    serviceName: data2['data'][s]['name'],
                    inOut: inOrOut,
                    isCheck: true,
                  );
                  asList.add(asListItem);
                } else {
                  ServiceList sListItem = ServiceList(
                    id: data2['data'][s]['_id'],
                    serviceName: data2['data'][s]['name'],
                    inOut: inOrOut,
                    isCheck: true,
                  );
                  sList.add(sListItem);
                }
              }
            }
          }

          //Cars info
          String workType;
          if (data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan']['label'] == "dusting") workType = "D";
          if (data['data']['jobs'][i]['schedulePlan'][weekDay]['workPlan']['label'] == "washing") workType = "W";

          String delRange, delTime = data['data']['jobs'][i]['schedulePlan']['purchase']['car']['deliveryTime'];

          if (((compareTime(delTime, "5:00")) == false) && ((compareTime(delTime, "6:00")) == true))
            delRange = "5:00 AM - 6:00 AM";
          else if (((compareTime(delTime, "6:01")) == false) && ((compareTime(delTime, "7:00")) == true))
            delRange = "6:01 AM - 7:00 AM";
          else if (((compareTime(delTime, "7:01")) == false) && ((compareTime(delTime, "8:00")) == true))
            delRange = "7:01 AM - 8:00 AM";
          else if (((compareTime(delTime, "8:01")) == false) && ((compareTime(delTime, "9:00")) == true))
            delRange = "8:01 AM - 9:00 AM";
          else if (((compareTime(delTime, "9:01")) == false) && ((compareTime(delTime, "10:00")) == true))
            delRange = "9:01 AM - 10:00 AM";
          else if (((compareTime(delTime, "10:01")) == false) && ((compareTime(delTime, "11:00")) == true))
            delRange = "10:01 AM - 11:00 AM";
          else if (((compareTime(delTime, "11:01")) == false) && ((compareTime(delTime, "12:00")) == true))
            delRange = "11:01 AM - 12:00 PM";
          else if (((compareTime(delTime, "1:01")) == false) && ((compareTime(delTime, "2:00")) == true))
            delRange = "1:01 PM - 2:00 PM";
          else if (((compareTime(delTime, "2:01")) == false) && ((compareTime(delTime, "3:00")) == true))
            delRange = "2:01 PM - 3:00 PM";
          else if (((compareTime(delTime, "3:01")) == false) && ((compareTime(delTime, "4:00")) == true))
            delRange = "3:01 PM - 4:00 PM";
          else
            delRange = "12:01 PM - 1:00 PM";

          //Key Collected Check
          bool isKeyCheckVar = false;
          if (data['data']['jobs'][i]['keyCollected'] != null) isKeyCheckVar = data['data']['jobs'][i]['keyCollected']['collected'];

          // Car Done status from API
          CarWorkStatus carWorkStatus = CarWorkStatus.UNDONE;

          if (data['data']['jobs'][i]['endTime'] != null) {
            if (data['data']['jobs'][i]['endTime']['attendant_one'] != null) {
              if (data['data']['jobs'][i]['endTime']['attendant_one']['section'] == "inside") {
                carWorkStatus = CarWorkStatus.INSIDEDONE;
              }
            }
            if (data['data']['jobs'][i]['endTime']['attendant_two'] != null) {
              if (data['data']['jobs'][i]['endTime']['attendant_two']['section'] == "inside") {
                carWorkStatus = CarWorkStatus.INSIDEDONE;
              }
            }
            if (data['data']['jobs'][i]['endTime']['attendant_one'] != null) {
              if (data['data']['jobs'][i]['endTime']['attendant_one']['section'] == "outside") {
                if (isKeyRequiredV == false) {
                  carWorkStatus = CarWorkStatus.COMPLETE;
                } else if (carWorkStatus == CarWorkStatus.INSIDEDONE) {
                  carWorkStatus = CarWorkStatus.COMPLETE;
                } else {
                  carWorkStatus = CarWorkStatus.OUTSIDEDONE;
                }
              }
            }
            if (data['data']['jobs'][i]['endTime']['attendant_two'] != null) {
              if (data['data']['jobs'][i]['endTime']['attendant_two']['section'] == "outside") {
                if (isKeyRequiredV == false) {
                  carWorkStatus = CarWorkStatus.COMPLETE;
                } else if (carWorkStatus == CarWorkStatus.INSIDEDONE) {
                  carWorkStatus = CarWorkStatus.COMPLETE;
                } else {
                  carWorkStatus = CarWorkStatus.OUTSIDEDONE;
                }
              }
            }
          }

          // Customer DP
          String ownerDpString = data['data']['jobs'][i]['schedulePlan']['purchase']['user']['profilePic'];
          if (ownerDpString == '') {
            ownerDpString = "https://firebasestorage.googleapis.com/v0/b/ccube-1575c.appspot.com/o/customer-app%2Fdefault.jpg?alt=media&token=";
          }

          CarEntry car = CarEntry(
            status: carWorkStatus,
            //jobId: data['data']['jobs'][i]['_id'] in place of  data['data']['jobs'][i]['schedulePlan']['_id'],
            carNumber: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['regNo'],
            parkingSlot: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['parkingNo'],
            carModel: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['model']['brand'] + " " + data['data']['jobs'][i]['schedulePlan']['purchase']['car']['model']['model'],
            carVariant: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['model']['variant'][data['data']['jobs'][i]['schedulePlan']['purchase']['car']['model']['__v']],
            carPicture: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['picture'],
            serviceList: sList,
            addOnServiceList: asList,
            label: workType,
            deliveryTime: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['deliveryTime'],
            timeRange: delRange,
            keyCollectionTime: data['data']['jobs'][i]['schedulePlan']['purchase']['car']['keyCollectionTime'],
            ownerName: data['data']['jobs'][i]['schedulePlan']['purchase']['user']['name'],
            ownerAddress: data['data']['jobs'][i]['schedulePlan']['purchase']['user']['address']['area'] +
                ", " +
                data['data']['jobs'][i]['schedulePlan']['purchase']['user']['address']['houseNum'] +
                ", " +
                data['data']['jobs'][i]['schedulePlan']['purchase']['user']['locality']['name'],
            ownerPhone: data['data']['jobs'][i]['schedulePlan']['purchase']['user']['phoneNumber'].toString(),
            ownerDp: ownerDpString,
            addOnCount: thisCarAddOn,
            schedulePlanId: data['data']['jobs'][i]['_id'],
            isKeyCollected: isKeyCheckVar,
            isKeyRequired: isKeyRequiredV,
          );

          carEnties.add(car);
        }
      }

      return "OK";
    }
  }

  Future<void> carDoneMarkerLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    var currentDataTemp = prefs.getString('pendingList');
    var partnerDones = prefs.getString('partnerDones');

    if (partnerDones != null) {
      for (int i = 0; i < partnerDones.length; i++) {
        var str = partnerDones[i];
        var section = str.split("*")[0];
        var carNumber = str.split("*")[1];
        for (int i = 0; i < carEnties.length; i++) {
          if (carNumber == carEnties[i].carNumber) {
            if (carEnties[i].status == CarWorkStatus.OUTSIDEDONE) {
              if (section == "Inside") {
                carEnties[i].status = CarWorkStatus.COMPLETE;
              }
            } else if (carEnties[i].status == CarWorkStatus.INSIDEDONE) {
              if (section == "Outside") {
                carEnties[i].status = CarWorkStatus.COMPLETE;
              }
            } else {
              if (section == "Outside") {
                carEnties[i].status = CarWorkStatus.OUTSIDEDONE;
                if (carEnties[i].isKeyRequired == false) {
                  carEnties[i].status = CarWorkStatus.COMPLETE;
                }
              } else if (section == "Inside") {
                carEnties[i].status = CarWorkStatus.INSIDEDONE;
              }
            }
          }
        }
      }
    }

    if (currentDataTemp != null) {
      List currentData2 = json.decode(currentDataTemp);
      for (int j = 0; j < currentData2.length; j++) {
        for (int i = 0; i < carEnties.length; i++) {
          if ((carEnties[i].schedulePlanId == currentData2[j]['schedulePlanId']) && (currentData2[j]['endTime'] != "")) {
            if (currentData2[j]['section'] == "inside") {
              carEnties[i].status = CarWorkStatus.INSIDEDONE;
            } else if (currentData2[j]['section'] == "outside") {
              carEnties[i].status = CarWorkStatus.OUTSIDEDONE;
              if (carEnties[i].isKeyRequired == false) {
                carEnties[i].status = CarWorkStatus.COMPLETE;
              }
            }
          }
        }
      }
    }
  }

  Future<String> getSchedule() async {
    var response = await http.post(Uri.parse(get_schedule), body: {'attendantId': user.id});
    var data = jsonDecode(response.body);

    var response2 = await http.get(Uri.parse(get_all_service_list));
    var data2 = jsonDecode(response2.body);

    if (data['data'] == null) {
      return data['error'];
    } else {
      var ans = await setSchedule(data, data2);
      if (carEnties.length == 0) {
        return "No Schedule Available";
      }
      return "OK";
    }
  }

  Future<String> markMePresent() async {
    var response = await http.post(Uri.parse(mark_present), body: {'employeeId': user.id});
    var data = jsonDecode(response.body);

    var response2 = await http.get(Uri.parse(get_all_service_list));
    var data2 = jsonDecode(response2.body);

    if (data['data'] == null) {
      return data['error'];
    } else {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (data['status'] == 202) {
        pref.remove('pendingList');
      }
      var ans = await setSchedule(data, data2);
      if (carEnties.length == 0) {
        return "No Schedule Available";
      }
      pref.setString('screen', 'precheck');
      if (data['data']['attendant_one']['_id'] == user.id) {
        if (data['data']['itemsNotReceived']['attendant_one']['marked'] == true) {
          return "JUMP";
        }
      }
      if (data['data']['attendant_two']['_id'] == user.id) {
        if (data['data']['itemsNotReceived']['attendant_two']['marked'] == true) {
          return "JUMP";
        }
      }
      return ans;
    }
  }

  Future<String> preCheckReceived() async {
    List notRecd = [];
    for (int i = 0; i < itemsToPick.length; i++) {
      if (itemsToPick[i].isCheck == false) {
        notRecd.add(itemsToPick[i].id.toString());
      }
    }
    var bodyC = {'attendantId': user.id, 'scheduleId': schedule.schduleId, 'notReceived': notRecd};
    var response = await http.post(Uri.parse(consumables_received), headers: {"content-type": "application/json", "accept": "application/json"}, body: json.encode(bodyC));
    var data = jsonDecode(response.body);
    if (data['data'] != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('screen', 'schedule');
      return "OK";
    } else {
      return data['error'];
    }
  }

  Future<String> keyCollected(String spId, String lateReason, String yesNo) async {
    bool collected;
    if (yesNo == "Yes") {
      collected = true;
    } else {
      collected = false;
    }
    var response = await http.post(Uri.parse(key_collected),
        headers: {"content-type": "application/json", "accept": "application/json"},
        body: json.encode({'attendantId': user.id, 'scheduleId': schedule.schduleId, 'scheduleJobId': spId, 'reason': lateReason, 'collected': collected}));
    var data = jsonDecode(response.body);
    if (data['status'] == 200) {
      return "OK";
    } else {
      return data['error'];
    }
  }

  Future<String> startService(String section, String sPId, String lateReason, String vehNo, List<File> imgFiles) async {
    var response =
        await http.post(Uri.parse(start_service), body: {'attendantId': user.id, 'scheduleId': schedule.schduleId, 'schedulePlanId': sPId, 'section': section.toLowerCase(), 'lateReason': lateReason});
    var data = jsonDecode(response.body);

    // var response2 = await http.post(Uri.parse(get_aws_config), body: {'category': 'services', 'folder': vehNo});
    // var data2 = jsonDecode(response2.body);

    // print(data2['config']['s3Url'] + "/" + data2['config']['folderName']);

    // var imgResponse = await http.post(
    //   Uri.parse(data2['config']['s3Url'] + "/" + data2['config']['folderName']),
    //   body: imgFiles[0].readAsBytesSync(),
    // );

    // var imgResponseresult = jsonDecode(imgResponse.body);

    // print(imgResponseresult);

    //.. var now = new DateTime.now();
    // var formatter = new DateFormat('yyyy-MM-dd-H-m-s');
    // String formatted = formatter.format(now);
    // var fileext = fileName.split('.').last;
    // fileName = formatted + "." + fileext;
    // var request = http.MultipartRequest('POST', Uri.parse(data2['config']['s3Url'] + "/" + data2['config']['folderName'].toString().replaceAll(' ', '')))
    //   ..fields['name'] = fileName
    //   ..files.add(
    //     await http.MultipartFile.fromPath(
    //       'files',
    //       imgFiles[0].path,
    //       contentType: MediaType('application', 'x-tar'),
    //     ),
    //   );
    // print(data2['config']['s3Url'] + "/" + data2['config']['folderName'].toString().replaceAll(' ', '') + fileName);
    // var res = await request.send();

    //.. var stream = new http.ByteStream(DelegatingStream.typed(imgFiles[0].openRead()));
    // var length = await imgFiles[0].length();

    // var uri = Uri.parse(data2['config']['s3Url'] + "/" + data2['config']['folderName'].toString().replaceAll(' ', ''));

    // var request = new http.MultipartRequest("POST", uri);
    // var multipartFile = new http.MultipartFile('file', stream, length, filename: fileName);
    // //contentType: new MediaType('image', 'png'));

    // request.files.add(multipartFile);
    // var imgResponseresult = await request.send();
    // print(imgResponseresult);

    FirebaseStorage storage = FirebaseStorage.instance;

    List imgLinks = [];
    String downloadUrl, img;
    for (int i = 0; i < imgFiles.length; i++) {
      img = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
      Reference ref = storage.ref().child("attendant-app/" + img);
      UploadTask uploadTask = ref.putFile(imgFiles[i]);
      downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + ref.storage.bucket + "/o/attendant-app%2F" + img + "?alt=media&token=";
      imgLinks.add(downloadUrl);
    }

    var response3 = await http.post(
      Uri.parse(save_media),
      headers: {"content-type": "application/json", "accept": "application/json"},
      body: json.encode({'attendantId': user.id, 'scheduleId': schedule.schduleId, 'schedulePlanId': sPId, 'place': section.toLowerCase(), 'timing': 'before', 'media': imgLinks}),
    );
    var data3 = jsonDecode(response3.body);
    print(data3);

    if (data3['status'] == 200) {
      return "OK";
    } else {
      return data['error'];
    }
  }

  Future<String> endService(String section, String sPId, String lateReason, String vehNo, List<File> imgFiles, List<ServiceList> serviceList, List<AddOnServiceList> addonServiceList) async {
    List notDone = [];
    for (int i = 0; i < serviceList.length; i++) {
      if (serviceList[i].isCheck == false) {
        notDone.add(serviceList[i].id.toString());
      }
    }
    for (int i = 0; i < addonServiceList.length; i++) {
      if (addonServiceList[i].isCheck == false) {
        notDone.add(addonServiceList[i].id.toString());
      }
    }
    var bodyC = {'attendantId': user.id, 'scheduleId': schedule.schduleId, 'schedulePlanId': sPId, 'section': section.toLowerCase(), 'comment': lateReason, 'undoneTasks': notDone};
    var response = await http.post(Uri.parse(end_service), headers: {"content-type": "application/json", "accept": "application/json"}, body: json.encode(bodyC));
    var data = jsonDecode(response.body);
    FirebaseStorage storage = FirebaseStorage.instance;

    List imgLinks = [];
    String downloadUrl, img;
    for (int i = 0; i < imgFiles.length; i++) {
      img = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
      Reference ref = storage.ref().child("attendant-app/" + img);
      UploadTask uploadTask = ref.putFile(imgFiles[i]);
      downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + ref.storage.bucket + "/o/attendant-app%2F" + img + "?alt=media&token=";
      imgLinks.add(downloadUrl);
    }

    var response3 = await http.post(
      Uri.parse(save_media),
      headers: {"content-type": "application/json", "accept": "application/json"},
      body: json.encode({'attendantId': user.id, 'scheduleId': schedule.schduleId, 'schedulePlanId': sPId, 'place': section.toLowerCase(), 'timing': 'after', 'media': imgLinks}),
    );
    var data3 = jsonDecode(response3.body);
    print(data3);

    if (data3['status'] == 200) {
      return "OK";
    } else {
      return data['error'];
    }
  }

  Future<String> doneForTheDay(String commentText) async {
    var response = await http.post(Uri.parse(mark_eod), body: {'attendantId': user.id, 'scheduleId': schedule.schduleId, 'comment': commentText});
    var data = jsonDecode(response.body);
    if (data['status'] == 200) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('screen', 'home');
      return "OK";
    } else {
      return data['error'];
    }
  }

  Future<String> saveSesionBulkIntermediate(List allSPdata, String commentText) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    for (int i = 0; i < allSPdata.length; i++) {
      List imgLinksB = [], imgLinksA = [];
      String downloadUrl, img;
      for (int a = 0; a < allSPdata[i]['beforeMedia']['media'].length; a++) {
        File theFile = File(allSPdata[i]['beforeMedia']['media'][a].toString().replaceAll('File: ', '').replaceAll("'", ""));
        img = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
        Reference ref = storage.ref().child("attendant-app/" + img);
        UploadTask uploadTask = ref.putFile(theFile);
        downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + ref.storage.bucket + "/o/attendant-app%2F" + img + "?alt=media&token=";
        imgLinksB.add(downloadUrl);
      }
      for (int b = 0; b < allSPdata[i]['afterMedia']['media'].length; b++) {
        File theFile = File(allSPdata[i]['afterMedia']['media'][b].toString().replaceAll('File: ', '').replaceAll("'", ""));
        img = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
        Reference ref = storage.ref().child("attendant-app/" + img);
        UploadTask uploadTask = ref.putFile(theFile);
        downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + ref.storage.bucket + "/o/attendant-app%2F" + img + "?alt=media&token=";
        imgLinksA.add(downloadUrl);
      }
      allSPdata[i]['beforeMedia']['media'] = imgLinksB;
      allSPdata[i]['afterMedia']['media'] = imgLinksA;

      //Getting undoneTask ID
      List notDone = [];
      for (int z = 0; z < carEnties.length; z++) {
        if (carEnties[z].schedulePlanId == allSPdata[i]['jobId']) {
          for (int s = 0; s < carEnties[z].serviceList.length; s++) {
            if (carEnties[z].serviceList[s].isCheck == false) {
              notDone.add(carEnties[z].serviceList[s].id.toString());
            }
          }
          for (int s = 0; s < carEnties[z].addOnServiceList.length; s++) {
            if (carEnties[z].addOnServiceList[s].isCheck == false) {
              notDone.add(carEnties[z].addOnServiceList[s].id.toString());
            }
          }
        }
      }
      allSPdata[i]['undoneTasks'] = notDone;
    }
    var responseBulk = await http.post(
      Uri.parse(save_session_bulk),
      headers: {"content-type": "application/json", "accept": "application/json"},
      body: json.encode({'attendantId': user.id, 'scheduleId': schedule.schduleId, 'scheduleJobs': allSPdata}),
    );
    var dataBulk = jsonDecode(responseBulk.body);
    if (dataBulk['error'] == null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('pendingList');
      return "OK";
    } else {
      return dataBulk['error'];
    }
  }

  Future<String> saveSesionBulk(List allSPdata, String commentText) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    for (int i = 0; i < allSPdata.length; i++) {
      List imgLinksB = [], imgLinksA = [];
      String downloadUrl, img;
      for (int a = 0; a < allSPdata[i]['beforeMedia']['media'].length; a++) {
        File theFile = File(allSPdata[i]['beforeMedia']['media'][a].toString().replaceAll('File: ', '').replaceAll("'", ""));
        img = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
        Reference ref = storage.ref().child("attendant-app/" + img);
        UploadTask uploadTask = ref.putFile(theFile);
        downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + ref.storage.bucket + "/o/attendant-app%2F" + img + "?alt=media&token=";
        imgLinksB.add(downloadUrl);
      }
      for (int b = 0; b < allSPdata[i]['afterMedia']['media'].length; b++) {
        File theFile = File(allSPdata[i]['afterMedia']['media'][b].toString().replaceAll('File: ', '').replaceAll("'", ""));
        img = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
        Reference ref = storage.ref().child("attendant-app/" + img);
        UploadTask uploadTask = ref.putFile(theFile);
        downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + ref.storage.bucket + "/o/attendant-app%2F" + img + "?alt=media&token=";
        imgLinksA.add(downloadUrl);
      }
      allSPdata[i]['beforeMedia']['media'] = imgLinksB;
      allSPdata[i]['afterMedia']['media'] = imgLinksA;

      //Getting undoneTask ID
      List notDone = [];
      for (int z = 0; z < carEnties.length; z++) {
        if (carEnties[z].schedulePlanId == allSPdata[i]['jobId']) {
          for (int s = 0; s < carEnties[z].serviceList.length; s++) {
            if (carEnties[z].serviceList[s].isCheck == false) {
              notDone.add(carEnties[z].serviceList[s].id.toString());
            }
          }
          for (int s = 0; s < carEnties[z].addOnServiceList.length; s++) {
            if (carEnties[z].addOnServiceList[s].isCheck == false) {
              notDone.add(carEnties[z].addOnServiceList[s].id.toString());
            }
          }
        }
      }
      allSPdata[i]['undoneTasks'] = notDone;
    }
    var responseBulk = await http.post(
      Uri.parse(save_session_bulk),
      headers: {"content-type": "application/json", "accept": "application/json"},
      body: json.encode({'attendantId': user.id, 'scheduleId': schedule.schduleId, 'scheduleJobs': allSPdata}),
    );
    var dataBulk = jsonDecode(responseBulk.body);
    if (dataBulk['status'] == 200) {
      var responseLast = await http.post(Uri.parse(mark_eod), body: {'attendantId': user.id, 'scheduleId': schedule.schduleId, 'comment': commentText});
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('screen', 'home');
      pref.remove('pendingList');
      return "OK";
    } else {
      return dataBulk['error'];
    }
  }
}
