import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';
import 'package:ojt_fingerprint_attendance/student_login.dart';
import 'package:path/path.dart' as pth;
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'hte_setup.dart';
import 'listofojt.dart';
import 'package:ojt_fingerprint_attendance/globals.dart' as globals;
import 'package:http/http.dart' as http;

class HTEList extends StatelessWidget {
  const HTEList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: HTEListHome(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class HTEListHome extends StatefulWidget {
  @override
  State<HTEListHome> createState() => _HTEListHomeState();
}

class _HTEListHomeState extends State<HTEListHome> {
  List<Map<String, dynamic>> hteList = [];
  List<Map<String, dynamic>> hteListFromAPI = [];

  var hteNameController = TextEditingController();
  var hteHeadController = TextEditingController();

  String? _currentAddress;
  String? lat;
  String? long;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> getHTEList() async {
    final list = await DatabaseHelper.getHTEList();
    setState(() {
      hteList = list;
    });
  }

  @override
  void initState() {
    getHTEList();
    super.initState();
  }

  Future<void> editHTE(int id, String name, String location, String lat,
      String long, String head) async {
    setState(() {
      hteNameController.text = name;
      hteHeadController.text = head;
      _currentAddress = location;
      lat = lat;
      long = long;
    });
    var heightOfModalBottomSheet = MediaQuery.of(context).size.height / 1.3;

    showModalBottomSheet<void>(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            height: heightOfModalBottomSheet,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 8,
                    decoration: const BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100.0))),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: CircleAvatar(
                          radius: 20.0,
                          child: Icon(
                            Icons.edit,
                            size: 20.0,
                          ),
                        )),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Edit HTE',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.6,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                controller: hteNameController,
                                style: const TextStyle(fontSize: 18.0),
                                decoration: const InputDecoration(
                                  hintText: 'HTE Name',
                                  icon: Icon(Icons.abc),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amber),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amber),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                controller: hteHeadController,
                                style: const TextStyle(fontSize: 18.0),
                                decoration: const InputDecoration(
                                  hintText: 'HTE Head',
                                  icon: Icon(Icons.abc),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amber),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amber),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: Text(
                              'Please tap the button below to update the HTE Location',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              height: 50.0,
                              width: 60.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _getCurrentPosition();
                                  });
                                  setState(() {
                                    heightOfModalBottomSheet += 1;
                                  });

                                  //editHTE(id,name,location,lat,long,head);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0))),
                                child: const Icon(
                                  Icons.map_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                          Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                          Text('ADDRESS: ${_currentAddress ?? ""}'),
                          Padding(
                            padding: const EdgeInsets.only(top: 80.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: MediaQuery.of(context).size.height / 14,
                              child: ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.orange)),
                                  onPressed: () async {
                                    if (hteNameController.text.isEmpty) {
                                      setState(() {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          headerAnimationLoop: false,
                                          animType: AnimType.bottomSlide,
                                          title: 'Empty Field',
                                          desc: 'HTE Name is required',
                                          buttonsTextStyle: const TextStyle(
                                              color: Colors.black),
                                          showCloseIcon: true,
                                          btnOkOnPress: () {},
                                        ).show();
                                      });
                                    } else if (hteHeadController.text.isEmpty) {
                                      setState(() {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          headerAnimationLoop: false,
                                          animType: AnimType.bottomSlide,
                                          title: 'Empty Field',
                                          desc:
                                              'Fullname of HTE Head is required',
                                          buttonsTextStyle: const TextStyle(
                                              color: Colors.black),
                                          showCloseIcon: true,
                                          btnOkOnPress: () {},
                                        ).show();
                                      });
                                    } else {
                                      final res =
                                          await DatabaseHelper.updateHTE(
                                              id,
                                              hteNameController.text,
                                              hteHeadController.text,
                                              _currentAddress.toString(),
                                              _currentPosition!.latitude
                                                  .toString(),
                                              _currentPosition!.longitude
                                                  .toString());
                                      //print("Returned id is: $res");
                                      if (res > 0) {
                                        setState(() {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.info,
                                            borderSide: const BorderSide(
                                              color: Colors.green,
                                              width: 2,
                                            ),
                                            width: 280,
                                            buttonsBorderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(2),
                                            ),
                                            dismissOnTouchOutside: true,
                                            dismissOnBackKeyPress: false,
                                            onDismissCallback: (type) {},
                                            headerAnimationLoop: false,
                                            animType: AnimType.bottomSlide,
                                            title: 'Success',
                                            desc: 'HTE Successfully updated',
                                            showCloseIcon: true,
                                            btnOkOnPress: () {},
                                          ).show();
                                        });
                                      } else {
                                        setState(() {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            animType: AnimType.rightSlide,
                                            headerAnimationLoop: false,
                                            title: 'Unsuccessful',
                                            desc:
                                                'There is an error updating HTE',
                                            btnOkOnPress: () {},
                                            btnOkIcon: Icons.cancel,
                                            btnOkColor: Colors.red,
                                          ).show();
                                        });
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'UPDATE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> deleteHTE(int id, String hteName) async {
    setState(() {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.rightSlide,
        headerAnimationLoop: true,
        title: 'Delete HTE?',
        desc: 'Are you sure you want to delete $hteName',
        btnCancelOnPress: () {},
        btnOkOnPress: () async {},
      ).show();
    });
  }

  void syncHTE() async {
    return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context1) {
          bool isSyncing = false;
          int delayTime = hteList.length;
          Icon ic = const Icon(
            Icons.sync,
            color: Colors.amber,
            size: 100.0,
          );
          String txt =
              'This operation will upload/download List of HTE data to cloud. ';
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                titlePadding: const EdgeInsets.all(50.0),
                title: const Text('HTE Data Cloud Syncing'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Center(
                        child:
                            isSyncing ? const CircularProgressIndicator() : ic,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Center(
                          child: Text(
                        txt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20.0),
                      )),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.red),
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.close,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                isSyncing = true;
                                txt =
                                    'Syncing in Progress please wait patiently.';
                              });

                              //Start to sync
                              String apiUrl =
                                  "${globals.url_api}/download_hte.php";
                              var resHTE = await http.post(Uri.parse(apiUrl),
                                  headers: {
                                    "Accept": "application/json",
                                    "Access-Control-Allow-Origin": "*"
                                  },
                                  body: {
                                    'id': '1234'
                                  });

                              if (resHTE.statusCode == 200) {
                                var jsonResponseDataHTE =
                                    json.decode(resHTE.body);

                                var hte = jsonResponseDataHTE['hte'];
                                //print(hte.toString());
                                var successData = 0;

                                //Start to import locally
                                for (int i = 0; i < hte.length; i++) {
                                  var id = int.parse(hte[i]['id']);
                                  var name = hte[i]['name'];
                                  var location = hte[i]['location'];
                                  var lat = hte[i]['latitude'];
                                  var long = hte[i]['longitude'];
                                  var head = hte[i]['head'];

                                  //Checking if exist locally
                                  final hteIfExist = await DatabaseHelper
                                      .checkDownloadedHTEFromAPI(id);
                                  if (hteIfExist.isNotEmpty) {
                                    //print("Data exist locally");
                                  } else {
                                    final resInsert =
                                        await DatabaseHelper.insertHTEFromAPI(
                                            id,
                                            name,
                                            head,
                                            location,
                                            lat,
                                            long);
                                    if (resInsert > 0) {
                                      successData += 1;
                                    }
                                  }
                                }

                                setState(() {
                                  isSyncing = false;
                                  txt =
                                      'HTE successfully downloaded $successData HTE data.';
                                  ic = const Icon(
                                    Icons.cloud_upload_sharp,
                                    color: Colors.amber,
                                    size: 100.0,
                                  );
                                });
                              } else {}

                              setState(() {
                                getHTEList();
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.amberAccent),
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.cloud_download_rounded,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                isSyncing = true;
                                txt =
                                    'Syncing in Progress please wait patiently.';
                              });

                              //Start to sync
                              String apiUrl = "${globals.url_api}/sync_hte.php";

                              for (int hte = 0; hte < hteList.length; hte++) {
                                String id = hteList[hte]['id'].toString();
                                String name = hteList[hte]['name'];
                                String location = hteList[hte]['location'];
                                String lat = hteList[hte]['lat'];
                                String long = hteList[hte]['long'];
                                String head = hteList[hte]['head'];
                                String createdAt = hteList[hte]['createdAt'];

                                var res = await http
                                    .post(Uri.parse(apiUrl), headers: {
                                  "Accept": "application/json",
                                  "Access-Control-Allow-Origin": "*"
                                }, body: {
                                  'id': id,
                                  'name': name,
                                  'location': location,
                                  'latitude': lat,
                                  'longitude': long,
                                  'head': head,
                                  'createdAt': createdAt
                                });

                                if (res.statusCode == 200) {
                                  var jsonResponseData = json.decode(res.body);
                                  //print(jsonResponseData.toString());

                                  setState(() {});
                                } else {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      headerAnimationLoop: true,
                                      title: 'Syncing Failed',
                                      desc: 'Please connect to Internet',
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () async {},
                                    ).show();
                                  });
                                }
                                await Future.delayed(
                                    const Duration(seconds: 2));
                              }

                              Future.delayed(Duration(seconds: delayTime), () {
                                setState(() {
                                  isSyncing = false;
                                  txt = 'HTE data successfully synced.';
                                  ic = const Icon(
                                    Icons.cloud_upload_sharp,
                                    color: Colors.amber,
                                    size: 100.0,
                                  );
                                });
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.green),
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.cloud_upload_rounded,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void copyOfflineDB() async {
    var date = DateTime.now().toString();
    final dbFolder = await getDatabasesPath();
    File source1 = File('$dbFolder/database.db');
    String location = "storage/emulated/0/Timesheet Offline Backup";
    Directory copyTo = Directory(location);
    if ((await copyTo.exists())) {
      print("Path exist");
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } else {
      print("not exist");
      if (await Permission.storage.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        await copyTo.create();
      } else {
        print('Please give permission');
      }
    }

    String newPath = "${copyTo.path}/$date - Backup.db";
    await source1.copy(newPath);

    setState(() {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Database Backup',
              desc: 'Database successfully backed-up to $location',
              btnOkOnPress: () {},
              btnOkText: 'Confirm')
          .show();
    });
  }

  void restoreDatabaseBackUp() async{
    var databasesPath = await getDatabasesPath();
    var dbPath = pth.join(databasesPath, 'doggie_database.db');

    FilePickerResult? result =
    await FilePicker.platform.pickFiles();

    if (result != null) {
      File source = File(result.files.single.path!);
      await source.copy(dbPath);
      setState(() {
        AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            title: 'Database Restored',
            desc: 'Database successfully restored',
            btnOkOnPress: () {},
            btnOkText: 'Confirm')
            .show();
      });
    } else {
      // User canceled the picker

    }
  }

  Future<void> deleteDB() async{
    var databasesPath = await getDatabasesPath();
    var dbPath = pth.join(databasesPath, 'database.db');
    await deleteDatabase(dbPath);
    setState(() {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Application Reset',
          desc: 'Application reset is successful, No more data available now.',
          btnOkOnPress: () {
            getHTEList();

          },
          btnOkText: 'Confirm')
          .show();
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellowAccent)),
              onPressed: () {
                syncHTE();
              },
              icon: const Icon(Icons.sync),
              label: const Text('SYNC'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const StudentLogin()));
              },
              label: const Text(''),
            ),
          )
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 50,
              backgroundImage: AssetImage('images/seait.png'),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Divider(
              thickness: 1.5,
              color: Colors.amber,
            ),
            const ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.grey,
              ),
              title: Text(
                'Utilities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            InkWell(
              child: const ListTile(
                leading: Icon(
                  Icons.account_tree_outlined,
                  color: Colors.green,
                ),
                title: Text('Offline Backup'),
              ),
              onTap: () {
                setState(() {
                  AwesomeDialog(
                          context: context,
                          dialogType: DialogType.question,
                          title: 'Backup Database',
                          desc:
                              'Are you sure you want to backup the Database locally?',
                          btnOkText: 'Backup',
                          btnOkOnPress: () {
                            copyOfflineDB();
                          },
                          btnCancelOnPress: () {})
                      .show();
                });
              },
            ),
            InkWell(
              onTap: (){
                restoreDatabaseBackUp();
              },
              child: const ListTile(
                leading: Icon(
                  Icons.restore_page_sharp,
                  color: Colors.orange,
                ),
                title: Text('Restore Database from backup'),
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            InkWell(
              onTap: (){
                setState(() {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    title: 'Application Reset',
                    desc: 'Are you sure you want to reset/delete data? Data that is not uploaded to cloud will be lost.',
                    btnOkOnPress: () async{
                      deleteDB();

                    },
                    btnOkText: 'Reset',
                    btnCancelOnPress: (){

                    }
                  ).show();
                });
              },
              child: const ListTile(
                leading: Icon(
                  Icons.reset_tv_sharp,
                  color: Colors.orange,
                ),
                title: Text('Reset Application'),
              ),
            ),

            const Divider(
              thickness: 1.5,
              color: Colors.amber,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('OJT Attendace System')
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5,
            decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(100.0))),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: CircleAvatar(
                  radius: 50.0,
                  child: Icon(
                    Icons.business,
                    size: 60.0,
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                  itemCount: hteList.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 3 / 2.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 12),
                  itemBuilder: (BuildContext ctx, int index) {
                    return SizedBox(
                      height: 500.0,
                      width: 600.0,
                      child: Card(
                        semanticContainer: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                hteList[index]["name"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                hteList[index]["location"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                hteList[index]["head"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: InkWell(
                                        onTap: () async {
                                          editHTE(
                                              hteList[index]["id"],
                                              hteList[index]["name"],
                                              hteList[index]["location"],
                                              hteList[index]["lat"],
                                              hteList[index]["long"],
                                              hteList[index]["head"]);
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50)),
                                              color: Colors.orange),
                                          width: 35,
                                          height: 35,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.edit,
                                            size: 14.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: InkWell(
                                        onTap: () async {
                                          deleteHTE(hteList[index]["id"],
                                              hteList[index]["name"]);
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50)),
                                              color: Colors.red),
                                          width: 35,
                                          height: 35,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.delete,
                                            size: 14.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: InkWell(
                                        onTap: () {
                                          globals.hteName =
                                              hteList[index]["name"];
                                          globals.hteID = hteList[index]["id"];
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OJTList()));
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50)),
                                              color: Colors.green),
                                          width: 35,
                                          height: 35,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.open_in_new_sharp,
                                            size: 14.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const HTESetup()));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    ));
  }
}
