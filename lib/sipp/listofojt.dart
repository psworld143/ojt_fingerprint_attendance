// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';
import 'package:http/http.dart' as http;
import 'hte_list.dart';
import 'registration_screen.dart';
import 'package:ojt_fingerprint_attendance/globals.dart' as globals;

import 'time_sheet.dart';

class OJTList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
      home: OJTListHome(),
    );
  }
}

class OJTListHome extends StatefulWidget {
  @override
  State<OJTListHome> createState() => _OJTListHomeState();
}

class _OJTListHomeState extends State<OJTListHome> {
  String hteName = globals.hteName;
  int hteID = globals.hteID;
  List<Map<String, dynamic>> listOfInterns = [];
  List<DropdownMenuItem<String>> hteList =[];
  var firstNameController = TextEditingController();
  var middleNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var requiredHoursController = TextEditingController();
  String dropdownValue = "1";

  @override
  void initState() {
    super.initState();
    getHTE();
    getListOfInterns();
  }

  Future<void> getListOfInterns() async {
    final res = await DatabaseHelper.getListOfStudents(hteID);
    setState(() {
      listOfInterns = res;
    });
  }
  Future<void> deleteStudent(int id) async{
    final res = await DatabaseHelper.deleteStudent(id);
    //print(res);
    if(res > 0){
      setState(() {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'Success',
          desc: 'Student removed successfully',
          buttonsTextStyle: const TextStyle(color: Colors.black),
          showCloseIcon: true,
          btnOkOnPress: () {
            setState(() {
              getListOfInterns();
            });
          },
        ).show();
      });


    }
    else{

    }
  }
  void syncHTEData() async{
    String desc = 'This option will upload Student data to cloud for registration process';
    String title = 'Upload List of OJT Data';
    setState(() {
      AwesomeDialog(
        context: context,
        btnOkText: "Upload",
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        headerAnimationLoop: true,
        title: title,
        desc: desc,
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          late AwesomeDialog dialog = AwesomeDialog(
              dismissOnTouchOutside: true,
              context: context,
              btnOkText: "Hide",
              dialogType: DialogType.info,
              animType: AnimType.rightSlide,
              headerAnimationLoop: true,
              title: 'Uploading Data',
              desc: 'Please wait patiently, the List of intern data is currently syncing to the cloud server',
              btnOkOnPress: (){

              }
          );
          setState(() {

            dialog.show();
          });
          print(listOfInterns.toString());
          String apiUrl = "${globals.url_api}/sync_students.php";
          for(int i = 0; i < listOfInterns.length; i++){
            var id = listOfInterns[i]['id'];
            var firstname = listOfInterns[i]['firstname'];
            var middleName = listOfInterns[i]['middle_name'];
            var lastname = listOfInterns[i]['lastname'];
            var username = listOfInterns[i]['username'];
            var password = listOfInterns[i]['password'];
            var course = listOfInterns[i]['course'];
            var requiredHours = listOfInterns[i]['required_hours'];
            var assignmentArea = listOfInterns[i]['assignment_area'];
            var createdAt = listOfInterns[i]['createdAt'];
            //print(id);

            var res = await http.post(Uri.parse(apiUrl), headers: {
              "Accept": "application/json",
              "Access-Control-Allow-Origin": "*"
            }, body: {
              'id': id.toString(),
              'firstname': firstname,
              'middle_name': middleName,
              'lastname': lastname,
              'username': username,
              'password': password,
              'course': course.toString(),
              'required_hours': requiredHours.toString(),
              'assignment_area': assignmentArea.toString(),
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

            Future.delayed(const Duration(seconds: 1));

          }
          setState(() {
            dialog.dismiss();

            AwesomeDialog(
              dismissOnTouchOutside: false,
              context: context,
              btnOkText: "Confirm",
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              headerAnimationLoop: false,
              title: 'Upload Complete',
              desc: 'All OJT Data for this HTE is successfully uploaded to cloud storage',
              btnOkOnPress: (){

              }
            ).show();
          });
        },
      ).show();
    });

  }
  DropdownMenuItem<String> getDropDownWidget(Map<String, dynamic> map){
    return DropdownMenuItem<String>(
      alignment: AlignmentDirectional.center,
      value: map['id'].toString(),
      child: Text(map['name']),

    );
  }
  void getHTE() async{
    await DatabaseHelper.getHTEList().then((hteMap){
      hteMap.map((map) {
        return getDropDownWidget(map);
      }).forEach((dropDownItem) {
        hteList.add(dropDownItem);
      });
    });
    setState((){
    });
  }
  void showEditOJT() async{

    var editContext = AwesomeDialog(
      context: context,
      title: 'Update OJT Details',
      customHeader: const Icon(Icons.account_circle_rounded, size: 80, color: Colors.pinkAccent,),
      btnOkText: 'Update',
      btnCancelOnPress: (){

      },
      headerAnimationLoop: true,
      body: Column(
        children: [

          SizedBox(
            height: MediaQuery.of(context).size.height / 1.6,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: firstNameController,
                        style: const TextStyle(
                            fontSize: 18.0
                        ),
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
                        style: const TextStyle(
                            fontSize: 18.0
                        ),
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
                        style: const TextStyle(
                            fontSize: 18.0
                        ),
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
                        controller: requiredHoursController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18.0
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Required OJT Hours',
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
                  const Text('Upldate Deployment Area', style: TextStyle(fontSize: 16.0),),

                  SizedBox(
                    width: MediaQuery.of(context).size.width/1.1,
                    height: MediaQuery.of(context).size.height/12,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: DropdownButton(
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0
                          ),
                          alignment: AlignmentDirectional.center,
                          iconSize: 24,
                          value: dropdownValue,
                          items: hteList,
                          onChanged: (value){
                            setState(() {
                              dropdownValue = value!;
                            });

                            //print(value);

                          }
                      ),
                    ),
                  ),


                ],
              ),
            ),
          )
        ],
      ),
      btnOkOnPress: () async{
        if(firstNameController.text.isEmpty){
          setState(() {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Empty Field',
              desc: 'Firstname is required',
              buttonsTextStyle: const TextStyle(color: Colors.black),
              showCloseIcon: true,
              btnOkOnPress: () {},
            ).show();
          });

        }
        else if(middleNameController.text.isEmpty){
          setState(() {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Empty Field',
              desc: 'Middlename is required',
              buttonsTextStyle: const TextStyle(color: Colors.black),
              showCloseIcon: true,
              btnOkOnPress: () {},
            ).show();
          });

        }
        else if(lastNameController.text.isEmpty){
          setState(() {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Empty Field',
              desc: 'Lastname is required',
              buttonsTextStyle: const TextStyle(color: Colors.black),
              showCloseIcon: true,
              btnOkOnPress: () {},
            ).show();
          });

        }
        else if(requiredHoursController.text.isEmpty){
          setState(() {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Empty Field',
              desc: 'OJT Hours is required',
              buttonsTextStyle: const TextStyle(color: Colors.black),
              showCloseIcon: true,
              btnOkOnPress: () {},
            ).show();
          });

        }
        else{

          final res = await DatabaseHelper.insertStudent(firstNameController.text, middleNameController.text, lastNameController.text, 1, int.parse(requiredHoursController.text), int.parse(dropdownValue));
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
                desc: 'Student Successfully registered',
                showCloseIcon: true,
                btnOkOnPress: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OJTList()));
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
                'There is an error registering student',
                btnOkOnPress: () {},
                btnOkIcon: Icons.cancel,
                btnOkColor: Colors.red,
              ).show();
            });

          }


        }
      },

    );
    editContext.show();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Interns',
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              elevation: 1,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HTEList()));
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amberAccent)
                    ),
                    onPressed: (){
                      syncHTEData();
                    },
                    icon: const Icon(Icons.cloud_upload_rounded, color: Colors.red,),
                    label: Text('UPLOAD', style: TextStyle(color: Colors.green),),
                  ),
                )
              ],
            ),
            body: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5,
                  decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                          child: CircleAvatar(
                        radius: 40.0,
                        child: Icon(
                          Icons.account_box,
                          size: 50.0,
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [

                            Text(hteName,
                                style: const TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: listOfInterns.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, int index) {
                      return ListTile(
                        leading: const Icon(Icons.account_circle_rounded, size: 40.0, color: Colors.green,),
                        title: Text(
                          listOfInterns[index]['lastname'] +
                              ', ' +
                              listOfInterns[index]['firstname'],
                          style: const TextStyle(fontSize: 18.0, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        trailing: SizedBox(
                          height: 100,
                          width: 100,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: InkWell(
                                  onTap: () async{
                                    setState((){
                                      firstNameController.text = listOfInterns[index]['firstname'];
                                      middleNameController.text = listOfInterns[index]['middle_name'];
                                      lastNameController.text = listOfInterns[index]['lastname'];
                                      requiredHoursController.text = listOfInterns[index]['required_hours'].toString();
                                    });



                                    showEditOJT();
                                  },
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(50)),
                                        color: Colors.green
                                    ),
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.edit, size: 14.0, color: Colors.white,),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        headerAnimationLoop: false,
                                        animType: AnimType.bottomSlide,
                                        title: 'Confirmation',
                                        desc: 'Are you sure you want to delete this student?',
                                        buttonsTextStyle: const TextStyle(color: Colors.black),
                                        showCloseIcon: true,
                                        btnCancelOnPress: (){

                                        },
                                        btnOkOnPress: () {
                                          deleteStudent(listOfInterns[index]['id']);
                                        },
                                      ).show();
                                    });


                                  },
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(50)),
                                        color: Colors.red
                                    ),
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.delete, size: 14.0, color: Colors.white,),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: InkWell(
                                  onTap: () {
                                    globals.internName = listOfInterns[index]['lastname'] +
                                        ', ' +
                                        listOfInterns[index]['firstname'] +
                                        ' ' +
                                        listOfInterns[index]['middle_name'];
                                    globals.ojtRequiredHours = listOfInterns[index]['required_hours'];
                                    globals.internID = listOfInterns[index]['id'];
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const TimeSheet()));


                                  },
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(50)),
                                        color: Colors.orange
                                    ),
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.open_in_new, size: 14.0, color: Colors.white,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const OJTRegistration()));
              },
              child: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
              ),
            )));
  }
}
