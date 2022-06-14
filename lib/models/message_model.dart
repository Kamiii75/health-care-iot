import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final User sender;
  final String time;
  final String text;
  final bool unread;

  Message({
   required this.sender,
   required this.time,
   required this.text,
   required this.unread});
}
