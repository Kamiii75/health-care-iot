import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_care_iot/firebase_services/auth.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/screens/main_page.dart';
import 'package:health_care_iot/utilities/size_config.dart';
import 'package:health_care_iot/widgets/default_button.dart';

import '../utilities/utilities.dart';

class Login extends StatefulWidget {
  final Function toggleView;
  Login({required this.toggleView});
  @override
  _LoginState createState() => _LoginState();
}

String email = '';
String pass = '';
// bool _reMe = false;
// bool _isDoc = false;
bool _loading = false;

AuthMethods _auth = AuthMethods();
DataBaseMethod _dataBaseMethod = DataBaseMethod();

Widget _buildEmailTextField(BuildContext context) {
  SizeConfig().init(context);
  return Container(
    alignment: Alignment.centerLeft,
    decoration: kBoxDecorationStyle,
    height: 60.0,
    child: TextField(
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
  );
}

Widget _buildPassTextField() {
  return Container(
    alignment: Alignment.centerLeft,
    decoration: kBoxDecorationStyle,
    height: 60.0,
    child: TextField(
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
  );
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
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
                          'Login',
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
                              'Email',
                              style: kLabelStyle,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildEmailTextField(context),
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
                            // Container(
                            //   alignment: Alignment.centerRight,
                            //   padding: EdgeInsets.only(right: 10.0),
                            //   child: Text(
                            //     'Forget Password?',
                            //     style: kLabelStyle,
                            //   ),
                            // ),
                            // Container(
                            //   child: Row(
                            //     children: <Widget>[
                            //       Theme(
                            //         data: ThemeData(
                            //           unselectedWidgetColor: Colors.white,
                            //         ),
                            //         child: Checkbox(
                            //           value: _reMe,
                            //           checkColor: Colors.green,
                            //           activeColor: Colors.white,
                            //           onChanged: (value) {
                            //             setState(() {
                            //               _reMe = value;
                            //             });
                            //           },
                            //         ),
                            //       ),
                            //       Text(
                            //         'Remember Me',
                            //         style: kLabelStyle,
                            //       )
                            //     ],
                            //   ),
                            // ),

                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 25.0),
                              width: double.infinity,
                              child: DefaultButton(
                                // elevation: 5.0,

                                press: () async {
                                  print(email);
                                  print(pass);
                                  if (email.isNotEmpty && pass.isNotEmpty) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    dynamic result =
                                        await _auth.signInwithEmailAndPassword(
                                            email, pass);
                                    if (result == null) {
                                      setState(() {
                                        _loading = false;
                                      });
                                    } else {
                                      _dataBaseMethod
                                          .getUserByUserEmail(email)
                                          .then((val) {
                                        HelperFunction
                                            .saveUserLoggedInSharedPreference(
                                                true);

                                        HelperFunction
                                            .saveUserEmailSharedPreference(
                                                email);
                                        HelperFunction
                                            .saveUserNameSharedPreference(val
                                                .docs[0]
                                                .data()['name']
                                                .toString());
                                        HelperFunction
                                            .saveUserTypeSharedPreference(val
                                                .docs[0]
                                                .data()['type']
                                                .toString());

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MainPage()));
                                      });
                                    }
                                  }
                                },

                                text: "Log In",
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
                                        text: 'Don\'t have Account? ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18.0)),
                                    TextSpan(
                                        text: 'SignUp',
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
}
