import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String sharedPreferencesUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferencesUserNameKey = "USERNAMEKEY";
  static String sharedPreferencesUserEmailKey = "USEREMAILKEY";
  static String sharedPreferencesUserTypeKey = "USERTYPEKEY";
  static String sharedPreferencesUserTokenKey = "TOKENKEY";
  static String sharedPreferencesUserTopicKey = "TOPICKEY";
  static String sharedPreferencesUserPatientKey = "PatientKey";

  //saving data to shared preference

  static Future<bool> saveUserLoggedInSharedPreference(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferencesUserLoggedInKey, isLoggedIn);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencesUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String isEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencesUserEmailKey, isEmail);
  }

  static Future<bool> saveUserTypeSharedPreference(String isType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencesUserTypeKey, isType);
  }

  static Future<bool> saveTokenSharedPreference(String isToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencesUserTokenKey, isToken);
  }

  static Future<bool> saveTopicSharedPreference(String isTopic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencesUserTopicKey, isTopic);
  }

  static Future<bool> savePatientSharedPreference(String isPatient) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencesUserPatientKey, isPatient);
  }
  // getting data from shared preferences

  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sharedPreferencesUserLoggedInKey);
  }

  static Future<String?> getUserNameSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencesUserNameKey);
  }

  static Future<String?> getUserEmailSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencesUserEmailKey);
  }

  static Future<String?> getUserTypeSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencesUserTypeKey);
  }

  static Future<String?> getTokenSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencesUserTokenKey);
  }

  static Future<String?> getTopicSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencesUserTopicKey);
  }

  static Future<String?> getPatientSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferencesUserPatientKey);
  }
}
