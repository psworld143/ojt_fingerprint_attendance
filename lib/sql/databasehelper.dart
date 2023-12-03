import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<sql.Database> database() async {
    return await sql.openDatabase('database.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      fullname TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL
    )
    """);
    await database.execute("""
    CREATE TABLE hte(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT NOT NULL,
      location TEXT NOT NULL,
      lat TEXT NOT NULL,
      long TEXT NOT NULL,
      head TEXT NOT NULL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
    await database.execute("""
    CREATE TABLE students(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      firstname TEXT NOT NULL,
      middle_name TEXT NOT NULL,
      lastname TEXT NOT NULL,
      username TEXT NULL,
      password TEXT NULL,
      course INTEGER NULL,
      required_hours INTEGER NOT NULL,
      assignment_area INTEGER NOT NULL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
    await database.execute("""
    CREATE TABLE login(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      student_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      time_in TEXT DEFAULT "na",
      time_out TEXT DEFAULT "na",
      login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  static Future<int> insertHTE(String hteName, String hteHead,
      String hteLocation, String lat, String long) async {
    final db = await DatabaseHelper.database();
    final data = {
      'name': hteName,
      'location': hteLocation,
      'head': hteHead,
      'lat': lat,
      'long': long
    };
    final res = await db.insert('hte', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return res;
  }

  static Future<int> updateHTE(int id, String hteName, String hteHead,
      String hteLocation, String lat, String long) async {
    final db = await DatabaseHelper.database();
    final data = {
      'name': hteName,
      'location': hteLocation,
      'head': hteHead,
      'lat': lat,
      'long': long
    };
    final res = await db.update('hte', data, where: 'id=?', whereArgs: [id]);
    return res;
  }

  static Future<List<Map<String, Object?>>> getHTEList() async {
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM hte ORDER BY name ASC");
  }

  static Future<List<Map<String, dynamic>>> checkStudentIfExist(
      String firstName, String middleName, String lastName) async {
    final db = await DatabaseHelper.database();
    return await db.rawQuery(
        "SELECT * FROM students WHERE firstname = '$firstName' AND middle_name = '$middleName' AND lastname ='$lastName'");
  }

  static Future<int> insertStudent(
      String firstName,
      String middleName,
      String lastName,
      int course,
      int requiredHours,
      int assignmentArea) async {
    final db = await DatabaseHelper.database();
    final data = {
      'firstname': firstName,
      'middle_name': middleName,
      'lastname': lastName,
      'username' : 'abc123',
      'password' : 'abc123',
      'course': course,
      'required_hours': requiredHours,
      'assignment_area': assignmentArea
    };
    final res = await db.insert('students', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return res;
  }

  static Future<List<Map<String, dynamic>>> getListOfStudents(int hteID) async {
    final db = await DatabaseHelper.database();
    return await db
        .query('students', where: 'assignment_area = ?', whereArgs: ['$hteID']);
  }

  static Future<List<Map<String, dynamic>>> checkIfRegistered(
      String firstName, String middleName, String lastName) async {
    final db = await DatabaseHelper.database();
    return await db.rawQuery(
        "SELECT * FROM students WHERE firstname = '$firstName' AND middle_name = '$middleName' AND lastname = '$lastName' ");
  }
  static Future<int> deleteStudent(int id) async{
    final db = await DatabaseHelper.database();
    final res = await db.rawDelete("DELETE FROM students WHERE id = '$id'");
    return res;
  }
  static Future<int> signUp(int id, String username, String password) async{
    final db = await DatabaseHelper.database();
    final res= await db.rawUpdate("UPDATE students SET username ='$username', password = '$password' WHERE id ='$id'");
    return res;
  }
  static Future<int> signUpUser(int id, String fullname, String username, String password) async{
    final db = await DatabaseHelper.database();
    final res= await db.rawInsert("INSERT INTO users(id,fullname,username,password) VALUES('$id','$fullname','$username','$password')");
    return res;
  }
  static Future<List<Map<String, dynamic>>> loginStudent(String username, String password) async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM students WHERE username = '$username' AND password = '$password'");
  }
  static Future<List<Map<String, dynamic>>> getOJTDetails(int id) async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM students LEFT JOIN hte ON students.assignment_area = hte.id WHERE students.id = '$id'");

  }
  static Future<List<Map<String, dynamic>>> checkTimeInIfExist(int id, String date) async{

    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM login WHERE student_id = '$id' AND date = '$date'");
  }
  static Future<List<Map<String, dynamic>>> checkTimeOutIfExist(int id, String date) async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM login WHERE student_id = '$id' AND date = '$date' AND time_out != 'na'");
  }
  static Future<int> insertTimeIn(int id, String date, String timeIn) async{
    final db = await DatabaseHelper.database();
    final res = await db.rawInsert("INSERT INTO login(student_id,date,time_in,time_out) VALUES('$id','$date','$timeIn','na')");
    return res;
  }
  static Future<int> insertTimeOut(int id, String date, String timeOut) async{
    final db = await DatabaseHelper.database();
    final res = await db.rawUpdate("UPDATE login SET time_out = '$timeOut' WHERE date = '$date' AND student_id = '$id' AND time_out = 'na'");
    return res;
  }
  static Future<List<Map<String, dynamic>>> getAttendance(int id) async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM login WHERE student_id = '$id'");
  }
  static Future<List<Map<String, dynamic>>> checkDownloadedHTEFromAPI(int id) async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM hte WHERE id = '$id'");
  }
  static Future<int> insertHTEFromAPI(int id, String hteName, String hteHead,
      String hteLocation, String lat, String long) async {
    final db = await DatabaseHelper.database();
    final data = {
      'id' : id,
      'name': hteName,
      'location': hteLocation,
      'head': hteHead,
      'lat': lat,
      'long': long
    };
    final res = await db.insert('hte', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return res;
  }
  static Future<List<Map<String, dynamic>>> checkDownloadedStudentFromAPI(int id) async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM students WHERE id = '$id'");
  }
  static Future<int> insertStudentFromAPI(int id, String firstname, String middleName,
      String lastname, String username, String password, int course, int requiredHours, int assignmentArea, String createdAt) async {
    final db = await DatabaseHelper.database();
    final data = {
      'id' : id,
      'firstname': firstname,
      'middle_name': middleName,
      'lastname': lastname,
      'username' : username,
      'password' : password,
      'course': course,
      'required_hours': requiredHours,
      'assignment_area': assignmentArea,
      'createdAt' : createdAt
    };
    final res = await db.insert('students', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return res;
  }
  static Future<List<Map<String, dynamic>>> checkIfDeviceHasUser() async{
    final db = await DatabaseHelper.database();
    return await db.rawQuery("SELECT * FROM users");
  }
  static Future<List<Map<String, dynamic>>> checkLoginFromAPI(int studentID, String date) async{
    final db = await DatabaseHelper.database();
    return db.rawQuery("SELECT * FROM login WHERE student_id = '$studentID' AND date = '$date'");
  }
  static Future<int> insertLoginFromAPI(int studentID, String date, String timeIn, String timeOut, String loginTime) async{
    final db = await DatabaseHelper.database();
    final res = db.rawInsert("INSERT INTO login(student_id,date,time_in,time_out,login_time) VALUES('$studentID','$date','$timeIn','$timeOut','$loginTime')");
    return res;
  }
  static Future<int> updateLoginFromAPI(int studentID, String date, String timeIn, String timeOut, String loginTime) async{
    final db = await DatabaseHelper.database();
    final res = db.rawInsert("UPDATE login SET time_in='$timeIn',time_out='$timeOut',login_time='$loginTime' WHERE student_id='$studentID' AND date='$date'");
    return res;
  }

}
