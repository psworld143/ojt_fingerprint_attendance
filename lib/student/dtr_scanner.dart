// ignore_for_file: use_key_in_widget_constructors


import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';
import 'package:ojt_fingerprint_attendance/globals.dart' as globals;
import 'package:http/http.dart' as http;

import '../student_login.dart';
import 'student_time_sheet.dart';

class DTRScanner extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber
      ),
      home: DTRScannerHome(),
    );
  }
}

class DTRScannerHome extends StatefulWidget{
  @override
  State<DTRScannerHome> createState() => _DTRScannerHomeState();
}

class _DTRScannerHomeState extends State<DTRScannerHome> {
  bool canAuthenticate = false;
  bool didAuthenticate = false;
  List<Map<String, dynamic>> hteLocation = [];
  List<Map<String, dynamic>> ojtDetails = [];
  String ojt_lat = "";
  String ojt_long = "";

  String? _currentAddress;
  String lat = "";
  String long ="";
  Position? _currentPosition;
  String ojtName = "";
  String hteName = "";
  String requiredTotalHours = "";

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
      setState(() {
        _currentPosition = position;
        lat = _currentPosition!.latitude.toString();
        long = _currentPosition!.longitude.toString();
      });
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
        '${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  @override
  void initState(){

    _getCurrentPosition();
    getOJTDetails();
    getTimeSheet();
    super.initState();

  }

  int ojtID = globals.internLoggedID;
  String internName = globals.internName;
  int internID = globals.internID;
  var timeSheet = [];
  var totalRendered = 0;


  void getTimeSheet() async{
    final data = await DatabaseHelper.getAttendance(ojtID);
    setState(() {
      timeSheet = data;
    });
  }

  Future<void> getOJTDetails() async{
    final res = await DatabaseHelper.getOJTDetails(globals.internLoggedID);

    if(res.isNotEmpty){

      setState((){
        ojtDetails = res;

      });
      print(ojtDetails.toString());
      setState(() {
        ojt_lat = ojtDetails[0]['lat'];
        ojt_long = ojtDetails[0]['long'];
        ojtName = ojtDetails[0]['lastname'] + ', ' + ojtDetails[0]['firstname'];
        hteName = ojtDetails[0]['name'];
        globals.ojtRequiredHours = ojtDetails[0]['required_hours'];
        requiredTotalHours = "${ojtDetails[0]['required_hours']} Hours";
      });

    }
    else{

    }
  }
  //Authenticate user fingerprint
  Future<void> _authenticate() async {
    try {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;

      canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        return;
      }
      setState(() {
        canAuthenticate = canAuthenticate;
      });
      didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to save attendance log.',
          options: const AuthenticationOptions(
              biometricOnly: true));
      setState(() {});

      if (didAuthenticate) {
        //Algorithm to insert logs goes here
        var dateTime = DateTime.now();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        final String today = formatter.format(dateTime);


        var id = globals.internLoggedID;
        var checkTimeInData = await DatabaseHelper.checkTimeInIfExist(id, today.trim());

        if(checkTimeInData.isEmpty){

          final timeInRes = await DatabaseHelper.insertTimeIn(id, today.trim(), dateTime.toString());
          if(timeInRes > 0){
            setState(() {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                headerAnimationLoop: true,
                animType: AnimType.bottomSlide,
                title: 'Time-in Success' ,
                desc: 'Your Time in is recorded successfully. Have a productive day!',
                buttonsTextStyle: const TextStyle(color: Colors.black),
                showCloseIcon: true,
                btnOkOnPress: () {

                },
              ).show();
            });

          }else{
            setState(() {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                headerAnimationLoop: true,
                animType: AnimType.bottomSlide,
                title: 'Time-in Error' ,
                desc: 'There is an error saving your time in log. Please contact your SIPP immediately.',
                buttonsTextStyle: const TextStyle(color: Colors.black),
                showCloseIcon: true,
                btnOkOnPress: () {

                },
              ).show();
            });

          }
        }
        else{
          var timeIn = checkTimeInData[0]['time_in'];
          DateTime a =  DateTime.parse(timeIn);
          DateTime b = DateTime.now();

          Duration difference = b.difference(a);
          int hours = difference.inHours % 24;

          if(hours > 0){
            final res = await DatabaseHelper.checkTimeOutIfExist(id, today);
            if(res.isEmpty){
              //Insert Logout
              var dateTay =dateTime.toString();
              final resLogout = await DatabaseHelper.insertTimeOut(id, today, dateTime.toString());
              print(resLogout.toString());
              if(resLogout > 0){
                setState(() {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    headerAnimationLoop: true,
                    animType: AnimType.bottomSlide,
                    title: 'Success' ,
                    desc: 'You have Log out successfully.',
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    showCloseIcon: true,
                    btnOkOnPress: () {
                      getOJTDetails();
                      getTimeSheet();
                      setState(() {

                      });

                    },
                  ).show();
                });
              }
              else{
                setState(() {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    headerAnimationLoop: true,
                    animType: AnimType.bottomSlide,
                    title: 'Log Failed' ,
                    desc: 'There is an error inserting log out. Please contact your SIPP.',
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    showCloseIcon: true,
                    btnOkOnPress: () {

                    },
                  ).show();
                });

              }
            }
            else{
              setState(() {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  headerAnimationLoop: true,
                  animType: AnimType.bottomSlide,
                  title: 'Log Failed' ,
                  desc: 'You have time out already.',
                  buttonsTextStyle: const TextStyle(color: Colors.black),
                  showCloseIcon: true,
                  btnOkOnPress: () {

                  },
                ).show();
              });
            }
          }
          else{
            setState(() {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                headerAnimationLoop: true,
                animType: AnimType.bottomSlide,
                title: 'Log Failed' ,
                desc: 'You have time in already, please wait after 1 hour to logout.',
                buttonsTextStyle: const TextStyle(color: Colors.black),
                showCloseIcon: true,
                btnOkOnPress: () {

                },
              ).show();
            });
          }





        }


      }
    } on PlatformException catch (e) {
      print(e);
    }
  }
  void uploadDTRToCloud() async{
    var alertDialog = AwesomeDialog(
      context: context,
      btnOkText: 'Hide',
      dialogType: DialogType.infoReverse,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Uploading',
      desc: 'Please wait while uploading your Daily Time Record to our Cloud Server',
      buttonsTextStyle: const TextStyle(color: Colors.white),
      showCloseIcon: true,
      btnOkOnPress: () {

      },
    );
    var successDialog = AwesomeDialog(
      context: context,
      btnOkText: 'Confirm',
      dialogType: DialogType.success,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Upload Success',
      desc: 'Your Daily Time Record is successfully uploaded to our Cloud Server',
      buttonsTextStyle: const TextStyle(color: Colors.white),
      showCloseIcon: true,
      btnOkOnPress: () {
          setState(() {

          });
      },
    );
    var noNetworkDialog = AwesomeDialog(
      context: context,
      btnOkText: 'Close',
      dialogType: DialogType.error,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Upload Failed',
      desc: 'You are not connected to internet. Please connect to any network to upload your data to cloud',
      buttonsTextStyle: const TextStyle(color: Colors.white),
      showCloseIcon: true,
      btnOkOnPress: () {
        setState(() {

        });
      },
    );
    alertDialog.show();
    //
    var id = globals.internLoggedID;
    var noNetwork = false;

    final res = await DatabaseHelper.getAttendance(id);
    //print(res.toString());
    for(int i = 0; i < res.length; i++){
      var id = res[i]['id'].toString();
      var studentId = res[i]['student_id'].toString();
      var date = res[i]['date'].toString();
      var timeIn = res[i]['time_in'].toString();
      var timeOut = res[i]['time_out'].toString();
      var loginTime = res[i]['login_time'].toString();

      //Syncing Data
      String apiUrl = "${globals.url_api}/sync_login.php";
      try{
        await http
            .post(Uri.parse(apiUrl), headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        }, body: {
          'id': id,
          'studentID': studentId,
          'date' : date,
          'timeIn': timeIn,
          'timeOut': timeOut,
          'loginTime': loginTime
        });

      }
      catch(ex){
        noNetwork = true;
      }




      Future.delayed(const Duration(seconds: 1));
    }
    alertDialog.dismiss();

    if(noNetwork){
      noNetworkDialog.show();
    }
    else{
      successDialog.show();
    }

  }



  @override
  Widget build(BuildContext context){
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('DTR Scanner',
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            elevation: 0.0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap:(){

                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const TimeSheetStudent()));

                },
                  child: SizedBox(
                    width: 40,
                    child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Colors.white
                            ),
                          child: const Icon(Icons.list_alt_outlined, color: Colors.green,)),
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap:(){
                    var alertDialog = AwesomeDialog(
                      context: context,
                      btnOkText: 'Upload DTR',
                      dialogType: DialogType.question,
                      headerAnimationLoop: false,
                      animType: AnimType.bottomSlide,
                      title: 'Confirmation',
                      desc: 'Are you sure you want to upload your daily time record to cloud?',
                      buttonsTextStyle: const TextStyle(color: Colors.white),
                      showCloseIcon: true,
                      btnCancelOnPress: (){

                      },
                      btnOkOnPress: () {
                        uploadDTRToCloud();

                      },
                    );
                    alertDialog.show();
                  },
                  child: SizedBox(
                    width: 40,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0),
                            color: Colors.white
                        ),
                        child: const Icon(Icons.cloud_upload, color: Colors.blue,)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap:(){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const StudentLogin()));
                  },
                  child: SizedBox(
                    width: 40,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0),
                            color: Colors.white
                        ),
                        child: const Icon(Icons.logout, color: Colors.red,)),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(100.0))),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: CircleAvatar(
                            radius: 60.0,
                            child: Icon(
                              Icons.document_scanner_outlined,
                              size: 60.0,
                            ),
                          )),

                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Card(
                    color: Colors.amber,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('OJT Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white ),),
                      )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Name'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(ojtName, style: const TextStyle(fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Designation Area'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(hteName, style: const TextStyle(fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total Required Hours'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(requiredTotalHours,style: const TextStyle(fontWeight: FontWeight.bold),),
                    )
                  ],
                ),

                const Divider(),

                Center(
                  child: InkWell(
                      onTap: () async{
                        if(ojt_lat.substring(0,5) == lat.substring(0,5) && ojt_long.substring(0,5) == long.substring(0,5)){
                          _authenticate();
                        }
                        else{
                          setState(() {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              headerAnimationLoop: true,
                              animType: AnimType.bottomSlide,
                              title: 'Invalid HTE Location',
                              desc: 'Scanner detected that you are not in your designated area',
                              buttonsTextStyle: const TextStyle(color: Colors.black),
                              showCloseIcon: true,
                              btnOkOnPress: () {

                              },
                            ).show();
                          });
                        }

                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 80.0,
                        child: Icon(Icons.fingerprint, size: 80,),
                      )
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                Text('ADDRESS: ${_currentAddress ?? ""}'),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height /18,
                    decoration: const BoxDecoration(
                        color: Colors.amber,
                        borderRadius:
                        BorderRadius.only(topRight: Radius.circular(100.0))),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text('© College of Information and Communication Technology', style: TextStyle(color: Colors.white),),
                        )


                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

