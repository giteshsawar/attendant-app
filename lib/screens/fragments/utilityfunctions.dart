import 'package:ccube_attendant/providers/data_provider.dart';
import 'package:flutter/material.dart';

bool compareTime(String start, String end) {
  TimeOfDay startTime = TimeOfDay(
    hour: int.parse(start.split(":")[0]) % 24, // in case of a bad time format entered manually by the user
    minute: int.parse(start.split(":")[1]) % 60,
  );
  TimeOfDay endTime = TimeOfDay(
    hour: int.parse(end.split(":")[0]) % 24, // in case of a bad time format entered manually by the user
    minute: int.parse(end.split(":")[1]) % 60,
  );
  bool isStartEarly = false;
  if ((startTime.hour < endTime.hour) || ((startTime.hour == endTime.hour) && (startTime.minute <= endTime.minute))) {
    isStartEarly = true;
  }
  return isStartEarly;
}
