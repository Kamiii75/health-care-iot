// import 'package:flutter/material.dart';
// import 'package:flutterfirebase/models/users_model.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'chat_screen.dart';

// class UsersList extends StatefulWidget {
//   String uid;

//   @override
//   _UsersListState createState() => _UsersListState();
// }

// class _UsersListState extends State<UsersList> {
//   void inputData(context) async {
//     final FirebaseUser user = await FirebaseAuth.instance.currentUser();
//     widget.uid = user.uid;
//     // here you write the codes to input the data into firestore
//   }

//   @override
//   Widget build(BuildContext context) {
//     final users = Provider.of<List<Users>>(context);

//     // here you write the codes to input the data into firestore

//     inputData(context);

//     users.forEach((usr) {
//       print(usr.uid);
//       print(usr.name);
//       print(usr.device_token);
//     });
//     return ListView.builder(
//         itemCount: users.length,
//         itemBuilder: (BuildContext context, int index) {
//           return users[index].uid.contains(widget.uid)
//               ? Text('')
//               : Center(
//                 child: GestureDetector(
//                   onTap: (){
//                     print(users[index].uid);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => ChatScreen(receiver: users[index],)

//                       ),
//                     );
//                   },
//                   child: Container(
//                     height: 50.0,
//                     width: MediaQuery.of(context).size.width * 0.75,
//                       child: Card(

//                         semanticContainer: true,
//                         clipBehavior: Clip.antiAliasWithSaveLayer,
//                         child: Center(
//                           child: Text(users[index].name,

//                             style: TextStyle(
//                             fontSize: 20.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ),
//               );
//         });
//   }
// }
