import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ojt_fingerprint_attendance/sipp/hte_list.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';

class HTESetup extends StatelessWidget {
  const HTESetup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: const HTESetupHome(),
    );
  }
}

class HTESetupHome extends StatefulWidget {
  const HTESetupHome({super.key});

  @override
  State<HTESetupHome> createState() => _HTESetupHomeState();
}

class _HTESetupHomeState extends State<HTESetupHome> {


  var hteNameController = TextEditingController();
  var hteHeadController = TextEditingController();

  String? _currentAddress;
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
        '${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const HTEList()));
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
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
                            Icons.account_box,
                            size: 60.0,
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text('HTE Setup',
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
                            style: const TextStyle(
                                fontSize: 18.0
                            ),
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
                            style: const TextStyle(
                                fontSize: 18.0
                            ),
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
                        child: Text('Please tap the button below to get the HTE Location', style: TextStyle(fontSize: 14.0),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          height: 50.0,
                          width: 60.0,
                          child: ElevatedButton(
                              onPressed: (){
                                _getCurrentPosition();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)
                                )
                              ),
                              child: const Icon(Icons.map_outlined, color: Colors.white,),
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
                          width: MediaQuery.of(context).size.width/1.2,
                          height: MediaQuery.of(context).size.height/14,
                          child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Colors.orange)
                              ),
                              onPressed: () async{
                                if(hteNameController.text.isEmpty){
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'HTE Name is required',
                                      buttonsTextStyle: const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });

                                }
                                else if(hteHeadController.text.isEmpty){
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'Fullname of HTE Head is required',
                                      buttonsTextStyle: const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });

                                }
                                else {
                                  final res = await DatabaseHelper.insertHTE(
                                      hteNameController.text,
                                      hteHeadController.text,
                                      _currentAddress.toString(),
                                      _currentPosition!.latitude.toString(),
                                      _currentPosition!.longitude.toString()

                                  );
                                  print("Returned id is: $res");
                                  if(res > 0){
                                    setState(() {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.info,
                                        borderSide: const BorderSide(
                                          color: Colors.green,
                                          width: 2,
                                        ),
                                        width: 280,
                                        buttonsBorderRadius: const BorderRadius.all(
                                          Radius.circular(2),
                                        ),
                                        dismissOnTouchOutside: true,
                                        dismissOnBackKeyPress: false,
                                        onDismissCallback: (type) {

                                        },
                                        headerAnimationLoop: false,
                                        animType: AnimType.bottomSlide,
                                        title: 'Success',
                                        desc: 'HTE Successfully registered',
                                        showCloseIcon: true,
                                        btnOkOnPress: () {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const HTEList()));
                                        },
                                      ).show();
                                    });
                                  }
                                  else{
                                    setState(() {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.rightSlide,
                                        headerAnimationLoop: false,
                                        title: 'Unsuccessful',
                                        desc:
                                        'There is an error adding HTE',
                                        btnOkOnPress: () {},
                                        btnOkIcon: Icons.cancel,
                                        btnOkColor: Colors.red,
                                      ).show();
                                    });
                                  }
                                }
                                },
                              child: const Text('Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              )
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
