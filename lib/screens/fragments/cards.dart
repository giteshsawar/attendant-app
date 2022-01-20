import 'package:flutter/material.dart';
import '../../theme.dart';

apartCard(String title, String subtitle, Color subColor) {
  return Card(
    elevation: 1.6,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              subtitle,
              style: TextStyle(color: subColor, fontSize: 22),
            ),
          ),
        ],
      ),
    ),
  );
}

multiColorCard(String left, String right) {
  return Wrap(
    children: [
      Container(
        child: Text(
          left,
          style: TextStyle(color: secondColor, fontSize: 16),
        ),
        padding: EdgeInsets.only(top: 3, bottom: 3, right: 4, left: 8),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(
            color: Colors.black12,
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            topLeft: Radius.circular(30.0),
          ),
        ),
      ),
      Container(
        child: Text(
          right,
          style: TextStyle(color: white, fontSize: 16),
        ),
        padding: EdgeInsets.only(top: 3, bottom: 3, left: 4, right: 7),
        decoration: BoxDecoration(
          color: secondColor,
          border: Border.all(
            color: Colors.black12,
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
      ),
    ],
  );
}

textLightBg(String str) {
  return Container(
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
    child: Text(
      str,
      textAlign: TextAlign.center,
      style: TextStyle(color: textDark, fontSize: 16),
    ),
  );
}

textLightBgSmall(String str) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: mainLight,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Text(
      str,
      textAlign: TextAlign.center,
      style: TextStyle(color: textDark, fontSize: 13),
    ),
  );
}

textSecondColorSmall(String str) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
    decoration: BoxDecoration(
      color: secondColor,
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
    child: Text(
      str,
      style: TextStyle(color: white),
    ),
  );
}
