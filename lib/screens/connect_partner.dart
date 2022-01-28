import 'today_schedule.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../providers/data_provider.dart';
import 'fragments/connection_related.dart';

class ConnectionToPartner extends StatefulWidget {
  const ConnectionToPartner({Key key}) : super(key: key);

  @override
  _MyTestAppState createState() => _MyTestAppState();
}

class _MyTestAppState extends State<ConnectionToPartner> {
  final String userName = user.empId;
  final Strategy strategy = Strategy.P2P_POINT_TO_POINT;
  bool isSearching, isHotspot;


  String tempFileUri; //reference to the file currently being transferred

  Future<void> permissionChecks() async {
    if (await Nearby().checkLocationPermission()) {
      if (await Nearby().checkExternalStoragePermission()) {
        if (await Nearby().checkLocationEnabled()) {
        } else {
          await Nearby().enableLocationServices();
        }
      } else {
        Nearby().askExternalStoragePermission();
      }
    } else {
      await Nearby().askLocationPermission();
    }
  }

  @override
  void initState() {
    isSearching = false;
    isHotspot = false;
    permissionChecks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Connection with Partner"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: Row(
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
                                "Your Partner: " + partner.empId,
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
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Card(
                color: endpointMap.length == 0 ? Colors.red[100] : mainLight,
                margin: EdgeInsets.all(5),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(endpointMap.length == 0 ? "You are not connected to your partner" : "You are connected to " + partner.empId),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Divider(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              endpointMap.length == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        isHotspot == false
                            ? Card(
                                color: mainLight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        color: textLight,
                                        iconSize: 50,
                                        onPressed: () async {
                                          if (isSearching == false) {
                                            try {
                                              bool a = await Nearby().startAdvertising(
                                                userName,
                                                strategy,
                                                onConnectionInitiated: onConnectionInit,
                                                onConnectionResult: (id, status) {
                                                  showSnackbar(status);
                                                },
                                                onDisconnected: (id) {
                                                  showSnackbar("Disconnected: ${endpointMap[id].endpointName}, id $id");
                                                  setState(() {
                                                    endpointMap.remove(id);
                                                  });
                                                },
                                              );
                                              isSearching = true;
                                              //showSnackbar("ADVERTISING: " + a.toString());
                                            } catch (exception) {
                                              showSnackbar(exception);
                                            }
                                          } else {
                                            await Nearby().stopAdvertising();
                                            isSearching = false;
                                          }
                                          setState(() {});
                                        },
                                        icon: Icon(isSearching == false ? Icons.search : Icons.stop),
                                      ),
                                      Text(isSearching == false ? "Search Partner" : "Searching " + partner.empId),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        isSearching == false
                            ? Card(
                                color: mainLight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        color: textLight,
                                        iconSize: 50,
                                        onPressed: () async {
                                          if (isHotspot == false) {
                                            try {
                                              bool a = await Nearby().startDiscovery(
                                                userName,
                                                strategy,
                                                onEndpointFound: (id, name, serviceId) {
                                                  // show sheet automatically to request connection
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (builder) {
                                                      return Center(
                                                        child: Column(
                                                          children: <Widget>[
                                                            SizedBox(height: 30),
                                                            //Text("id: " + id),
                                                            Text("Name: " + name),
                                                            //Text("ServiceId: " + serviceId),
                                                            SizedBox(height: 30),
                                                            ElevatedButton(
                                                              child: Text("Request Connection"),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                Nearby().requestConnection(
                                                                  userName,
                                                                  id,
                                                                  onConnectionInitiated: (id, info) {
                                                                    onConnectionInit(id, info);
                                                                  },
                                                                  onConnectionResult: (id, status) {
                                                                    showSnackbar(status);
                                                                  },
                                                                  onDisconnected: (id) {
                                                                    setState(() {
                                                                      endpointMap.remove(id);
                                                                    });
                                                                    isSearching = false;
                                                                    isHotspot = false;

                                                                    showSnackbar("Disconnected from: ${endpointMap[id].endpointName}, id $id");
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                onEndpointLost: (id) {
                                                  showSnackbar("Lost discovered Endpoint: ${endpointMap[id].endpointName}, id $id");
                                                },
                                              );
                                              isHotspot = true;
                                              //showSnackbar("DISCOVERING: " + a.toString());
                                            } catch (e) {
                                              showSnackbar(e);
                                            }
                                          } else {
                                            await Nearby().stopDiscovery();
                                            isHotspot = false;
                                          }
                                          setState(() {});
                                        },
                                        icon: Icon(isHotspot == false ? Icons.wifi : Icons.wifi_off),
                                      ),
                                      Text(isHotspot == false ? "Turn On Hotspot" : "Your ID :  " + user.empId),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    )
                  : Column(
                      children: [
                        ElevatedButton(
                          child: Text("Disconnect"),
                          onPressed: () async {
                            await Nearby().stopAllEndpoints();
                            setState(() {
                              endpointMap.clear();
                            });
                          },
                        ),
                      ],
                    ),
              // Divider(),
              // Text(
              //   "Sending Data",
              // ),
              // ElevatedButton(
              //   child: Text("Send Random Bytes Payload"),
              //   onPressed: () async {
              //     endpointMap.forEach((key, value) {
              //       String a = Random().nextInt(100).toString();

              //       showSnackbar("Sending $a to ${value.endpointName}, id: $key");
              //       Nearby().sendBytesPayload(key, Uint8List.fromList(a.codeUnits));
              //     });
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  // Future<bool> moveFile(String uri, String fileName) async {
  //   String parentDir = (await getExternalStorageDirectory()).absolute.path;
  //   final b = await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

  //   showSnackbar("Moved file:" + b.toString());
  //   return b;
  // }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              //Text("id: " + id),
              //Text("Token: " + info.authenticationToken),
              SizedBox(height: 30),
              Text("Name: " + info.endpointName),
              SizedBox(height: 30),
              // Text("Incoming: " + info.isIncomingConnection.toString()),
              ElevatedButton(
                child: Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    endpointMap[id] = info;
                  });
                  connectSegment(id);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => TodaySchedule()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              ElevatedButton(
                child: Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
