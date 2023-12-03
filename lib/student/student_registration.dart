import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';
import 'package:ojt_fingerprint_attendance/student_login.dart';
import 'package:ojt_fingerprint_attendance/globals.dart' as globals;
import 'package:http/http.dart' as http;

class StudentRegistration extends StatelessWidget {
  const StudentRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.amber),
        home: const StudentRegistrationHome());
  }
}

class StudentRegistrationHome extends StatefulWidget {
  const StudentRegistrationHome({super.key});

  @override
  State<StudentRegistrationHome> createState() =>
      _StudentRegistrationHomeState();
}

class _StudentRegistrationHomeState extends State<StudentRegistrationHome> {
  var lastNameController = TextEditingController();
  var firstNameController = TextEditingController();
  var middleNameController = TextEditingController();
  var usernameController = TextEditingController();
  var password1Controller = TextEditingController();
  var password2Controller = TextEditingController();
  var obscureText = true;
  var totalData = 0;

  void downloadFromCloud() async {
    var downloadingDialog = AwesomeDialog(
      context: context,
      btnOkText: 'Hide',
      dialogType: DialogType.info,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Downloading',
      desc: 'Please wait patiently, downloading data from cloud storage.',
      buttonsTextStyle: const TextStyle(color: Colors.white),
      showCloseIcon: false,
      btnOkOnPress: () {},
    );
    var finishDialog = AwesomeDialog(
      context: context,
      btnOkText: 'Confirm',
      dialogType: DialogType.success,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Download Finished',
      desc: 'Data from cloud downloaded successfully.',
      buttonsTextStyle: const TextStyle(color: Colors.white),
      showCloseIcon: false,
      btnOkOnPress: () {},
    );

    downloadingDialog.show();

    var students = [];
    String apiUrl = "${globals.url_api}/download_student.php";

    var resStudent = await http.post(Uri.parse(apiUrl), headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*"
    }, body: {
      'id': '1234'
    });
    if (resStudent.statusCode == 200) {
      var jsonResponseDataStudent = json.decode(resStudent.body);
      setState(() {
        students = jsonResponseDataStudent['students'];
      });
    }
    for (int i = 0; i < students.length; i++) {
      var id = int.parse(students[i]['id']);
      var firstname = students[i]['firstname'];
      var middleName = students[i]['middle_name'];
      var lastname = students[i]['lastname'];
      var username = students[i]['username'];
      var password = students[i]['password'];
      var course = students[i]['course'];
      var requiredHours = students[i]['required_hours'];
      var assignmentArea = students[i]['assignment_area'];
      var createdAt = students[i]['createdAt'];
      final resForChecking =
          await DatabaseHelper.checkDownloadedStudentFromAPI(id);
      if (resForChecking.isNotEmpty) {
        print('Student Data exist locally');
      } else {
        print("Trying to insert student data locally");
        final resInsert = await DatabaseHelper.insertStudentFromAPI(
            id,
            firstname,
            middleName,
            lastname,
            username,
            password,
            int.parse(course),
            int.parse(requiredHours),
            int.parse(assignmentArea),
            createdAt);
        if (resInsert > 0) {
          setState(() {
            totalData += 1;
          });
        }
      }
    }

    String apiUrlHTE = "${globals.url_api}/download_hte.php";
    var resHTE = await http.post(Uri.parse(apiUrlHTE), headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*"
    }, body: {
      'id': '1234'
    });

    if (resHTE.statusCode == 200) {
      var jsonResponseDataHTE = json.decode(resHTE.body);

      var hte = jsonResponseDataHTE['hte'];
      //print(hte.toString());
      var successData= 0;

      //Start to import locally
      for(int i = 0; i < hte.length; i++){
        var id = int.parse(hte[i]['id']);
        var name = hte[i]['name'];
        var location = hte[i]['location'];
        var lat = hte[i]['latitude'];
        var long = hte[i]['longitude'];
        var head = hte[i]['head'];

        //Checking if exist locally
        final hteIfExist = await DatabaseHelper.checkDownloadedHTEFromAPI(id);
        if(hteIfExist.isNotEmpty){
          //print("Data exist locally");
        }
        else{

          final resInsert = await DatabaseHelper.insertHTEFromAPI(id, name, head, location, lat, long);
          if(resInsert > 0){
            successData += 1;
          }
        }
        Future.delayed(const Duration(seconds: 2));

      }



    } else {

    }
    downloadingDialog.dismiss();

    finishDialog.show();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const StudentLogin()));
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () {
                var alertDialog = AwesomeDialog(
                  context: context,
                  btnOkText: 'Download',
                  dialogType: DialogType.question,
                  headerAnimationLoop: false,
                  animType: AnimType.bottomSlide,
                  title: 'Confirmation',
                  desc: 'Are you sure you want to download student data?',
                  buttonsTextStyle: const TextStyle(color: Colors.white),
                  showCloseIcon: true,
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    downloadFromCloud();
                  },
                );
                alertDialog.show();
              },
              icon: const Icon(
                Icons.cloud_download,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 6,
              decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(100.0))),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: CircleAvatar(
                    radius: 40.0,
                    child: Icon(
                      Icons.account_box,
                      size: 50.0,
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text('Registration',
                        style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: firstNameController,
                            style: const TextStyle(fontSize: 18.0),
                            decoration: const InputDecoration(
                              hintText: 'Firstname',
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
                            controller: middleNameController,
                            style: const TextStyle(fontSize: 18.0),
                            decoration: const InputDecoration(
                              hintText: 'Middlename',
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
                            controller: lastNameController,
                            style: const TextStyle(fontSize: 18.0),
                            decoration: const InputDecoration(
                              hintText: 'Lastname',
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
                            controller: usernameController,
                            style: const TextStyle(fontSize: 18.0),
                            decoration: const InputDecoration(
                              hintText: 'Username',
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
                            obscureText: obscureText,
                            controller: password1Controller,
                            style: const TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (obscureText == true) {
                                        obscureText = false;
                                      } else {
                                        obscureText = true;
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                      Icons.remove_red_eye_outlined)),
                              hintText: 'Password',
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                              focusedBorder: const OutlineInputBorder(
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
                            obscureText: obscureText,
                            controller: password2Controller,
                            style: const TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (obscureText == true) {
                                        obscureText = false;
                                      } else {
                                        obscureText = true;
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                      Icons.remove_red_eye_outlined)),
                              hintText: 'Confirm Password',
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 15,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.amber)
                              ),
                              onPressed: () async {
                                if (firstNameController.text.isEmpty) {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'Firstname is required',
                                      buttonsTextStyle:
                                          const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });
                                } else if (middleNameController.text.isEmpty) {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'Middlename is required',
                                      buttonsTextStyle:
                                          const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });
                                } else if (lastNameController.text.isEmpty) {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'Lastname is required',
                                      buttonsTextStyle:
                                          const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });
                                } else if (usernameController.text.isEmpty) {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'Username is required',
                                      buttonsTextStyle:
                                          const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });
                                } else if (password1Controller.text.isEmpty) {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Empty Field',
                                      desc: 'Password is required',
                                      buttonsTextStyle:
                                          const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });
                                } else if (password1Controller.text !=
                                    password2Controller.text) {
                                  setState(() {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      headerAnimationLoop: false,
                                      animType: AnimType.bottomSlide,
                                      title: 'Password does not match',
                                      desc: 'Please verify Password',
                                      buttonsTextStyle:
                                          const TextStyle(color: Colors.black),
                                      showCloseIcon: true,
                                      btnOkOnPress: () {},
                                    ).show();
                                  });
                                } else {
                                  //Check if Registered
                                  final res = await DatabaseHelper.checkIfRegistered(
                                          firstNameController.text,
                                          middleNameController.text,
                                          lastNameController.text);
                                  print(res.toString());
                                  if (res.isEmpty) {
                                    //Invalid Student
                                    setState(() {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        headerAnimationLoop: false,
                                        animType: AnimType.bottomSlide,
                                        title: 'Invalid Credentials',
                                        desc:
                                            'You are not a registered student to use this Application, Please connect to internet to sync cloud data locally.',
                                        buttonsTextStyle: const TextStyle(
                                            color: Colors.black),
                                        showCloseIcon: true,
                                        btnOkOnPress: () {},
                                      ).show();
                                    });
                                  }
                                  else {
                                    //Valid Student
                                    final resCheckDevice = await DatabaseHelper.checkIfDeviceHasUser();

                                    if (resCheckDevice.isNotEmpty) {
                                      setState(() {
                                        var fullname = resCheckDevice[0]['fullname'];
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.error,
                                          headerAnimationLoop: false,
                                          animType: AnimType.bottomSlide,
                                          title: 'Device already registered',
                                          desc:
                                          'You can not use this device. It is already registered to $fullname ',
                                          buttonsTextStyle: const TextStyle(
                                              color: Colors.black),
                                          showCloseIcon: true,
                                          btnOkOnPress: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const StudentLogin()));
                                          },
                                        ).show();
                                      });



                                    } else {

                                      int id = res[0]['id'];
                                      var firstname = firstNameController.text;
                                      var middleName = middleNameController.text;
                                      var lastName = lastNameController.text;
                                      var userName = usernameController.text;
                                      var password = password1Controller.text;
                                      var fullname = '$firstname $middleName $lastName';


                                      //Update students Table
                                      final resStudents = await DatabaseHelper.signUp(id, userName,password);

                                      if (resStudents > 0) {

                                        await DatabaseHelper.signUpUser(id, fullname, userName, password);
                                        setState(() {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.success,
                                            headerAnimationLoop: false,
                                            animType: AnimType.bottomSlide,
                                            title: 'Success',
                                            desc:
                                                'You may use this application to record your attendance within your designated area',
                                            buttonsTextStyle: const TextStyle(
                                                color: Colors.black),
                                            showCloseIcon: true,
                                            btnOkOnPress: () {
                                              firstNameController.text = "";
                                              firstNameController.text= "";
                                              firstNameController.text= "";
                                              firstNameController.text= "";
                                              firstNameController.text= "";
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>StudentLogin()));
                                            },
                                          ).show();
                                        });
                                      } else {
                                        setState(() {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            headerAnimationLoop: false,
                                            animType: AnimType.bottomSlide,
                                            title: 'Registration Error',
                                            desc:
                                                "You can't signup to this application, Contact your SIPP",
                                            buttonsTextStyle: const TextStyle(
                                                color: Colors.black),
                                            showCloseIcon: true,
                                            btnOkOnPress: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          const StudentLogin()));
                                            },
                                          ).show();
                                        });
                                      }
                                    }
                                  }
                                }
                              },
                              child: const Text('Register', style: TextStyle(
                                color: Colors.white
                              ),)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
