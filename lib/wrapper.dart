// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:health_care_iot/screens/login.dart';
// import 'package:health_care_iot/screens/main_page.dart';
// import 'package:health_care_iot/screens/signup.dart';
// import 'package:provider/provider.dart';

// class Wrapper extends StatefulWidget {
//   final bool showSignIn;
//   Wrapper({this.showSignIn});

//   @override
//   _WrapperState createState() => _WrapperState();
// }

// class _WrapperState extends State<Wrapper> {
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);
//     print(user.toString());

//     if (user == null) {
//       if (widget.showSignIn)
//         return SignIn();
//       else
//         return Login();
//     } else {
//       return HomePage();
//     }
//     // return SignIn();
//   }
// }
