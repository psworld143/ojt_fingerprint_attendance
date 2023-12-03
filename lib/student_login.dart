import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ojt_fingerprint_attendance/sipp/hte_list.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';

import 'student/dtr_scanner.dart';
import 'globals.dart' as globals;
import 'student/student_registration.dart';

class StudentLogin extends StatelessWidget {
  const StudentLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber
      ),
      home: const StudentLoginHome()
    );
  }
}
//Test Commit

class StudentLoginHome extends StatefulWidget {
  const StudentLoginHome({super.key});

  @override
  State<StudentLoginHome> createState() => _StudentLoginHomeState();
}

class _StudentLoginHomeState extends State<StudentLoginHome> {
  var obscureText = true;

  var usernameController = TextEditingController();

  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        return false;
      },
      child: SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
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
                              backgroundColor: Colors.amber,
                              radius: 40.0,
                              backgroundImage: AssetImage('images/seait.png'),
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text('Login Screen',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width/1.2,
                      height: MediaQuery.of(context).size.height/2,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.white,
                        elevation: 8.0,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 50.0,
                                child: Icon(Icons.security, size: 100.0,color: Colors.amber,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 12.0),
                              child: TextField(
                                controller: usernameController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Enter username',
                                  hintStyle: const TextStyle(fontSize: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(16),
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                              child: TextField(
                                controller: passwordController,
                                obscureText: obscureText,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: (){
                                      if(obscureText == true){
                                        setState(() {
                                          obscureText = false;
                                        });

                                      }
                                      else{
                                        setState(() {
                                          obscureText = true;
                                        });
                                      }

                                    },
                                    icon: const Icon(Icons.remove_red_eye_outlined),
                                  ),
                                  hintText: 'Enter password',
                                  hintStyle: const TextStyle(fontSize: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(16),
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding:const EdgeInsets.only(left: 24.0, right: 24.0),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height/20,
                                width: MediaQuery.of(context).size.width/1.4,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.amber)
                                  ),
                                  onPressed: () async{
                                    if(usernameController.text.isEmpty){
                                      setState(() {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          headerAnimationLoop: false,
                                          animType: AnimType.bottomSlide,
                                          title: 'Empty Field',
                                          desc: 'Please provide your username',
                                          buttonsTextStyle: const TextStyle(color: Colors.black),
                                          showCloseIcon: true,
                                          btnOkOnPress: () {

                                          },
                                        ).show();
                                      });

                                    }else if(passwordController.text.isEmpty){
                                      setState(() {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          headerAnimationLoop: false,
                                          animType: AnimType.bottomSlide,
                                          title: 'Empty Field',
                                          desc: 'Please provide your password',
                                          buttonsTextStyle: const TextStyle(color: Colors.black),
                                          showCloseIcon: true,
                                          btnOkOnPress: () {

                                          },
                                        ).show();
                                      });

                                    }
                                    else if(usernameController.text == 'admin' && passwordController.text =='admin'){
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const HTEList()));

                                    }
                                    else{
                                      final res = await DatabaseHelper.loginStudent(usernameController.text, passwordController.text);
                                      if(res.isEmpty){
                                        setState(() {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.error,
                                            headerAnimationLoop: true,
                                            animType: AnimType.bottomSlide,
                                            title: 'Invalid Credentials',
                                            desc: 'You have provided an invalid username or password',
                                            buttonsTextStyle: const TextStyle(color: Colors.black),
                                            showCloseIcon: true,
                                            btnOkOnPress: () {

                                            },
                                          ).show();
                                        });

                                      }
                                      else{
                                        globals.internLoggedID = res[0]['id'];
                                        print(res[0]['id']);
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>DTRScanner()));
                                      }


                                    }

                                  },
                                  child: const Text('LOGIN', style: TextStyle(color: Colors.white),),
                                ),
                              )
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No Account?'),
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>const StudentRegistration()));
                                    },
                                    child: const Text('Register Here')
                                )
                              ],
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 154),
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
      ),
    );
  }
}
