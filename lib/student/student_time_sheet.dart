import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ojt_fingerprint_attendance/sql/databasehelper.dart';
import 'package:ojt_fingerprint_attendance/globals.dart' as globals;

import 'dtr_scanner.dart';

class TimeSheetStudent extends StatelessWidget {
  const TimeSheetStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
      home: const TimeSheetHome(),
    );
  }
}

class TimeSheetHome extends StatefulWidget{
  const TimeSheetHome({super.key});

  @override
  State<TimeSheetHome> createState() => _TimeSheetHomeState();
}

class _TimeSheetHomeState extends State<TimeSheetHome> {
  String internName = globals.internName;
  int internID = globals.internLoggedID;
  var timeSheet = [];
  var totalRendered = 0;
  @override
  void initState(){
    getTimeSheet();

    super.initState();
  }

  void getTimeSheet() async{
    final data = await DatabaseHelper.getAttendance(internID);
    setState(() {
      timeSheet = data;
    });
    setState(() {
      refresh();
    });
  }

  void refresh(){
    for(int i= 0; i <  timeSheet.length; i++){
      var timeInDB = timeSheet[i]['time_in'];
      var timeOutDB="";
      if(timeSheet[i]['time_out'] == 'na'){
        timeOutDB = '0000-00-00 00:00:00.000000';
      }else{
        timeOutDB = timeSheet[i]['time_out'];
      }


      DateTime timeIn =  DateTime.parse(timeInDB);
      DateTime timeOut = DateTime.parse(timeOutDB);

      Duration difference = timeOut.difference(timeIn);
      int hours = difference.inHours % 24;
      print(timeOutDB.toString());

      if(timeSheet[i]['time_out'] == 'na'){

      }
      else{
        totalRendered = totalRendered + hours;
      }



      Future.delayed(const Duration(seconds: 1));
    }
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(internName,
                style: const TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DTRScanner()));
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),

          ),
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 6,
                decoration: const BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: CircleAvatar(
                          radius: 40.0,
                          child: Icon(
                            Icons.calendar_month,
                            size: 50.0,
                          ),
                        )),

                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Daily Time Record',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child:
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [

                            SizedBox(
                                height: 40.0,
                                width: 40.0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50.0),
                                        color: Colors.orange
                                    ),
                                    child: Center(child: Text(globals.ojtRequiredHours.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),))
                                )
                            ),
                            const Text('Required Hours'),
                          ],
                        ),
                      ),
                    ),

                    Card(
                      child:
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [

                            SizedBox(
                                height: 40.0,
                                width: 40.0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50.0),
                                        color: Colors.green
                                    ),
                                    child: Center(child: Text(totalRendered.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),))
                                )
                            ),
                            const Text('Total Rendered'),
                          ],
                        ),
                      ),
                    ),

                    Card(
                      child:
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [

                            SizedBox(
                              height: 40.0,
                              width: 40.0,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: Colors.red
                                  ),
                                  child: Center(
                                    child: Text((globals.ojtRequiredHours - totalRendered).toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),
                                    ),
                                  )
                              ),
                            ),
                            const Text('Remaining Time'),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),

              timeSheet.isNotEmpty? Container(
                height: MediaQuery.of(context).size.height/1.82,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 0.8), //(x,y)
                      blurRadius: 2.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: timeSheet.length,
                      separatorBuilder: (_, __) => const Divider(
                        thickness: 1,
                      ),
                      itemBuilder: (BuildContext context, int index){


                        var timeInDB = timeSheet[index]['time_in'];
                        var timeOutDB="";
                        if(timeSheet[index]['time_out'] == 'na'){
                          timeOutDB = '0000-00-00 00:00:00.000000';
                        }else{
                          timeOutDB = timeSheet[index]['time_out'];
                        }


                        //print(timeSheet[index]['time_out'].toString());
                        DateTime timeIn =  DateTime.parse(timeInDB);
                        DateTime timeOut = DateTime.parse(timeOutDB);

                        Duration difference = timeOut.difference(timeIn);

                        late int hours;
                        if(timeSheet[index]['time_out'] == 'na'){
                          hours = 0;
                        }
                        else{
                          if((difference.inHours % 24) > 4){
                            hours = (difference.inHours % 24)-1;
                          }
                          else{
                            hours = difference.inHours % 24;
                          }

                        }
                        if(timeSheet[index]['time_out'] == 'na'){

                        }
                        else{
                          totalRendered = totalRendered + hours;
                        }




                        final DateFormat formatter = DateFormat('hh:mm aa');
                        final String timeInHour = formatter.format(timeIn);
                        String timeOutHour = "";
                        if(timeOutDB == '0000-00-00 00:00:00.000000'){
                          timeOutHour = 'Pending';
                        }
                        else{
                          timeOutHour = formatter.format(timeOut);
                        }


                        return ListTile(
                          leading: const Icon(Icons.punch_clock_outlined, color: Colors.amber,),
                          title: Text(timeSheet[index]['date'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Row(
                            children: [
                              const Text('From ',style: TextStyle(fontWeight: FontWeight.bold),),
                              Card(
                                elevation: 0,
                                color: Colors.yellowAccent,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(timeInHour.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                              const Text('to',style: TextStyle(fontWeight: FontWeight.bold),),
                              Card(
                                elevation: 0,
                                color: timeOutHour.toString()=='Pending'?Colors.deepOrangeAccent:Colors.yellowAccent,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(timeOutHour.toString(),style: const TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              )
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                                elevation: 0,
                                color: Colors.green,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: hours == 0?  const Text("N/A", style: TextStyle(color: Colors.white),):Text("$hours Hour", style: const TextStyle(color: Colors.white),),
                                )
                            ),
                          ),
                        );


                      }
                  ),
                ),
              ) : const Center(
                child: Text('No DTR Record found for now, You may download DTR Reports from cloud if you are connected to the internet',
                    style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),

            ],
          ),
        )
    );

  }
}