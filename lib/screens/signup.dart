import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:health_care_iot/firebase_services/auth.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/screens/main_page.dart';
import 'package:health_care_iot/utilities/size_config.dart';
import 'package:health_care_iot/widgets/default_button.dart';
import 'package:health_care_iot/widgets/tabs.dart';

import '../utilities/utilities.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

final formKeyName = GlobalKey<FormState>();
final formKeyEmail = GlobalKey<FormState>();
final formKeyPass = GlobalKey<FormState>();
AuthMethods _auth = AuthMethods();

DataBaseMethod _dataBaseMethod = new DataBaseMethod();
//bool _reMe = false;
bool _isDoc = false;
bool _loading = false;
String name = '';
String email = '';
String pass = '';

Widget _buildNameTextField() {
  return Container(
    alignment: Alignment.centerLeft,
    decoration: kBoxDecorationStyle,
    height: 60.0,
    child: Form(
      key: formKeyName,
      child: TextFormField(
        validator: (val) {
          return val!.isEmpty || val.length < 6
              ? "Please provide valid UserName"
              : null;
        },
        onChanged: (val) {
          name = val;
        },
        keyboardType: TextInputType.text,
        style: TextStyle(
          fontFamily: 'Opensins',
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(
            top: 14.0,
          ),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.white,
          ),
          hintText: 'Enter your Name',
          hintStyle: kLabelStyle,
        ),
      ),
    ),
  );
}

Widget _buildEmailTextField() {
  return Container(
    alignment: Alignment.centerLeft,
    decoration: kBoxDecorationStyle,
    height: 60.0,
    child: Form(
      key: formKeyEmail,
      child: TextFormField(
        validator: (val) {
          return RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(val!)
              ? null
              : "Please provide valid email";
        },
        onChanged: (val) {
          email = val;
        },
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontFamily: 'Opensins',
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(
            top: 14.0,
          ),
          prefixIcon: Icon(
            Icons.email,
            color: Colors.white,
          ),
          hintText: 'Enter your Email',
          hintStyle: kLabelStyle,
        ),
      ),
    ),
  );
}

Widget _buildPassTextField() {
  return Container(
    alignment: Alignment.centerLeft,
    decoration: kBoxDecorationStyle,
    height: 60.0,
    child: Form(
      key: formKeyPass,
      child: TextFormField(
        validator: (val) {
          return val!.length < 6 ? "Enter Password 6+ characters" : null;
        },
        onChanged: (val) {
          pass = val;
        },
        obscureText: true,
        keyboardType: TextInputType.text,
        style: TextStyle(
          fontFamily: 'OpenSins',
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(
            top: 14.0,
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          hintText: 'Enter your Password',
          hintStyle: kLabelStyle,
        ),
      ),
    ),
  );
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    helperData(Map<String, Object> userMap, String type) {
      HelperFunction.saveUserLoggedInSharedPreference(true);

      HelperFunction.saveUserEmailSharedPreference(email);
      HelperFunction.saveUserNameSharedPreference(name);
      HelperFunction.saveUserTypeSharedPreference(type);

      _dataBaseMethod.updateUserInfo(userMap);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    }

    signUpMethod() async {
      if (email.isNotEmpty && pass.isNotEmpty) {
        String type = 'nurse';
        if (_isDoc) {
          type = 'doctor';
        }

        Map<String, Object> userMap = {
          "name": name,
          "email": email,
          "type": type
          // "createdAt": new DateTime.now().microsecondsSinceEpoch,
          // "uid": "${value.key}"
        };

        if (formKeyName.currentState!.validate() &&
            formKeyEmail.currentState!.validate() &&
            formKeyPass.currentState!.validate()) {
          setState(() {
            _loading = true;
          });

          await _auth
              .signUpwithEmailAndPassword(email, pass, name, type)
              .then((value) => {
                    if (value != null)
                      {
                        helperData(userMap, type),
                      }
                    else
                      {
                        setState(() {
                          _loading = false;
                        })
                      }
                  });
        }
      }
    }

    return _loading
        ? Loading()
        : Scaffold(
            body: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).accentColor,
                        Theme.of(context).accentColor,
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor,
                      ],
                      stops: [0.1, 0.4, 0.7, 0.9],
                    )),
                  ),
                ),
                Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(vertical: 120.0, horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Name',
                              style: kLabelStyle,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildNameTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'Email',
                              style: kLabelStyle,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildEmailTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'Password',
                              style: kLabelStyle,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildPassTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'type',
                              style: kLabelStyle,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            //buildFlutterSwitch(),
                            Tabs(
                              press: (value) {
                                print(value.toString());
                                if (value == 0) {
                                  setState(() {
                                    _isDoc = false;
                                  });
                                } else {
                                  setState(() {
                                    _isDoc = true;
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25.0),
                              width: double.infinity,
                              child: DefaultButton(
                                // elevation: 5.0,
                                press: signUpMethod,
                                text: 'Sign In',
                                // padding: EdgeInsets.all(15.0),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(30.0),
                                // ),
                                // color: Colors.white,

                                // style: TextStyle(
                                //     color: Theme.of(context).hoverColor,
                                //     letterSpacing: 1.5,
                                //     fontSize: 19.0,
                                //     fontWeight: FontWeight.bold,
                                //     fontFamily: 'OpenSins'),
                                // ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  widget.toggleView();
                                },
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Already have Account? ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18.0)),
                                    TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0))
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }

  FlutterSwitch buildFlutterSwitch() {
    return FlutterSwitch(
      activeText: "Doctor",
      inactiveText: "Nurse",
      value: _isDoc,
      valueFontSize: 20.0,
      width: 160,
      borderRadius: 30.0,
      showOnOff: true,
      height: 55.0,
      toggleSize: 45.0,
      // borderRadius: 30.0,
      padding: 2.0,
      activeToggleColor: Color(0xFF009DE4),
      inactiveToggleColor: Color(0xFFE75572),
      activeSwitchBorder: Border.all(
        color: Color(0xFF009DE4),
        width: 2.0,
      ),
      inactiveSwitchBorder: Border.all(
        color: Color(0xFFE75572),
        width: 2.0,
      ),
      activeColor: Color(0xFF2E2F81),
      inactiveColor: Color(0xFFB01D47),
      // activeIcon: Icon(
      //   Icons.nightlight_round,
      //   color: Color(0xFFF8E3A1),
      // ),
      // inactiveIcon: Icon(
      //   Icons.wb_sunny,
      //   color: Color(0xFFFFDF5D),
      // ),
      onToggle: (val) {
        setState(() {
          _isDoc = val;

          // if (val) {
          //   _textColor = Colors.white;
          //   _appBarColor =
          //       Color.fromRGBO(22, 27, 34, 1);
          //   _scaffoldBgcolor = Color(0xFF0D1117);
          // } else {
          //   _textColor = Colors.black;
          //   _appBarColor =
          //       Color.fromRGBO(36, 41, 46, 1);
          //   _scaffoldBgcolor = Colors.white;
          // }
        });
      },
    );
  }
}
