import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';

import 'listofojt.dart';

class OJTRegistration extends StatelessWidget {
  const OJTRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const OJTRegistrationHome(),
    );
  }
}

class OJTRegistrationHome extends StatefulWidget {
  const OJTRegistrationHome({super.key});

  @override
  State<OJTRegistrationHome> createState() => _OJTRegistrationHomeState();
}

class _OJTRegistrationHomeState extends State<OJTRegistrationHome> {
  List<DropdownMenuItem<String>> hteList =[];
  List<Map<String, dynamic>> checkStudentResult = [];
  var firstNameController = TextEditingController();
  var middleNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var requiredHoursController = TextEditingController();
  String dropdownValue = "1";
  @override
  void initState(){
    super.initState();
    getHTEList();
  }

  Future<void> getHTEList() async{
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


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('REGISTRATION', style: TextStyle(color: Colors.white),),
          elevation: 1,
          leading: IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=> OJTList()));
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
                      const Text('Select Deployment Area', style: TextStyle(fontSize: 16.0),),

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

                                print(value);

                              }
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width/1.1,
                          height: MediaQuery.of(context).size.height/15,
                          child: ElevatedButton(
                              onPressed: () async{
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
                                  final res = await DatabaseHelper.checkStudentIfExist(firstNameController.text, middleNameController.text, lastNameController.text);
                                  setState(() {
                                    checkStudentResult = res;
                                  });

                                  if(checkStudentResult.isNotEmpty){
                                    setState(() {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.rightSlide,
                                        headerAnimationLoop: false,
                                        title: 'Unsuccessful',
                                        desc:
                                        'Student is already exists',
                                        btnOkOnPress: () {
                                          firstNameController.text = "";
                                          middleNameController.text = "";
                                          lastNameController.text = "";
                                          requiredHoursController.text = "";
                                        },
                                        btnOkIcon: Icons.cancel,
                                        btnOkColor: Colors.red,
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

                                }

                              },
                              child: const Text('Register')
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
  DropdownMenuItem<String> getDropDownWidget(Map<String, dynamic> map){
    return DropdownMenuItem<String>(
      alignment: AlignmentDirectional.center,
        value: map['id'].toString(),
        child: Text(map['name']),

    );
  }
}
