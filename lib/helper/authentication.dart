import 'package:flutter/material.dart';
import 'package:health_care_iot/screens/login.dart';
import 'package:health_care_iot/screens/signup.dart';

class Authenticate extends StatefulWidget {
  Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = false;
  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn
        ? SignIn(
            toggleView: toggleView,
          )
        : Login(
            toggleView: toggleView,
          );
  }
}
