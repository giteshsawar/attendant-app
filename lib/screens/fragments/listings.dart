import 'package:flutter/material.dart';
import 'cards.dart';

inOutListItems(Color starColor, String name, String place, String selected, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
    child: Opacity(
      opacity: selected == place ? 1.0 : 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.star, color: starColor, size: 17),
              SizedBox(width: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Text(name),
              ),
            ],
          ),
          textLightBgSmall(place),
        ],
      ),
    ),
  );
}
