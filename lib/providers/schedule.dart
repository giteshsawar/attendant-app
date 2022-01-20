import 'package:flutter/material.dart';

class Schedule {
  int washingCount, dustingCount, addOnsCount;
  String schduleId, societyName, societyAddress, societyPin, locality, lng, lat;

  Schedule({
    this.washingCount,
    this.dustingCount,
    this.addOnsCount,
    this.schduleId,
    this.societyName,
    this.societyAddress,
    this.societyPin,
    this.locality,
    this.lat,
    this.lng,
  });
}

class ServiceList {
  String id, serviceName, inOut;
  bool isCheck;

  ServiceList({
    this.id,
    this.serviceName,
    this.inOut,
    this.isCheck,
  });
}

class AddOnServiceList {
  String id, serviceName, inOut;
  bool isCheck;

  AddOnServiceList({
    this.id,
    this.serviceName,
    this.inOut,
    this.isCheck,
  });
}

enum CarWorkStatus { UNDONE, INSIDEDONE, OUTSIDEDONE, COMPLETE }

class CarEntry {
  String carNumber, carModel, carVariant, carPicture, label, keyCollectionTime, parkingSlot;
  String deliveryTime, timeRange;
  String ownerName, ownerAddress, ownerPhone, ownerDp, schedulePlanId;
  int addOnCount;
  List<ServiceList> serviceList;
  List<AddOnServiceList> addOnServiceList;
  bool isKeyCollected, isKeyRequired;
  CarWorkStatus status;

  CarEntry({
    this.status,
    this.carNumber,
    this.carModel,
    this.carVariant,
    this.carPicture,
    this.serviceList,
    this.addOnServiceList,
    this.label,
    this.deliveryTime,
    this.timeRange,
    this.keyCollectionTime,
    this.ownerName,
    this.ownerAddress,
    this.ownerPhone,
    this.ownerDp,
    this.addOnCount,
    this.schedulePlanId,
    this.isKeyCollected,
    this.isKeyRequired,
    this.parkingSlot,
  });
}

class ItemsList {
  String itemName, id;
  bool isCheck, isForAddOn;
  double quantity;

  ItemsList({
    this.id,
    this.itemName,
    this.isCheck,
    this.isForAddOn,
    this.quantity,
  });
}
