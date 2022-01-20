import '../../providers/data_provider.dart';
import '../../providers/schedule.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Map<String, ConnectionInfo> endpointMap = Map();
Map<int, String> map = Map(); //store filename mapped to corresponding payloadId

connectSegment(var id) async {
  Nearby().acceptConnection(
    id,
    onPayLoadRecieved: (endid, payload) async {
      final prefs = await SharedPreferences.getInstance();
      var partnerDones = prefs.getString('partnerDones');
      List<String> newPartnerDones = [];
      if (payload.type == PayloadType.BYTES) {
        String str = String.fromCharCodes(payload.bytes);
        //showSnackbar(endid + ": " + str);
        if (partnerDones == null) {
          newPartnerDones.add(str);
          prefs.setString('partnerDones', json.encode(newPartnerDones));
        } else {
          List<String> newCurrData = json.decode(partnerDones);
          print(newCurrData.length);
          for (int i = 0; i < newCurrData.length; i++) {
            newPartnerDones.add(newCurrData[i]);
          }
          newPartnerDones.add(str);
          prefs.setString('partnerDones', json.encode(newPartnerDones));
        }
        print(str);
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
        // if (str.contains(':')) {
        //   // used for file payload as file payload is mapped as
        //   // payloadId:filename
        //   int payloadId = int.parse(str.split(':')[0]);
        //   String fileName = (str.split(':')[1]);

        //   if (map.containsKey(payloadId)) {
        //     if (tempFileUri != null) {
        //       moveFile(tempFileUri, fileName);
        //     } else {
        //       showSnackbar("File doesn't exist");
        //     }
        //   } else {
        //     //add to map if not already
        //     map[payloadId] = fileName;
        //   }
        // }
      } else if (payload.type == PayloadType.FILE) {
        //showSnackbar(endid + ": File transfer started");
        //tempFileUri = payload.uri;
      }
    },
    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
      if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRESS) {
        print(payloadTransferUpdate.bytesTransferred);
      } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
        print("failed");
        //showSnackbar(endid + ": FAILED to transfer file");
      } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
        //showSnackbar("$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

        // if (map.containsKey(payloadTransferUpdate.id)) {
        //   //rename the file now
        //   String name = map[payloadTransferUpdate.id];
        //   moveFile(tempFileUri, name);
        // } else {
        //   //bytes not received till yet
        //   map[payloadTransferUpdate.id] = "";
        // }
      }
    },
  );
}
