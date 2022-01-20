import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme.dart';

confirmExit(BuildContext context) {
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
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
      exit(0);
    },
  );
  AlertDialog alert = AlertDialog(
    title: Column(
      children: <Widget>[
        Text(
          "Are you sure you want to exit ?",
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
