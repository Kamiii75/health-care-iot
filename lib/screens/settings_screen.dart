import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:health_care_iot/firebase_services/auth.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/authentication.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/screens/history_screen.dart';
import 'package:health_care_iot/screens/notifications/message_list.dart';
import 'package:health_care_iot/screens/notifications/permissions.dart';
import 'package:health_care_iot/screens/notifications/token_monitor.dart';
import 'package:health_care_iot/screens/patients_screen.dart';
import 'package:health_care_iot/widgets/cards.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Msg();
  }
}

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

class Msg extends StatefulWidget {
  Msg({Key? key}) : super(key: key);

  @override
  _MsgState createState() => _MsgState();
}

class _MsgState extends State<Msg> {
  late String _token;
  // void inputData(context) async {
  //   await HelperFunction.getTokenSharedPreference().then((value) {
  //     if (value != null)
  //       setState(() {
  //         _token = value;
  //       });
  //   });

  //   // here you write the codes to input the data into firestore
  // }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print(
              'FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
          print(
              'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');
        }
        break;
      case 'unsubscribe':
        {
          print(
              'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".');
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
          print(
              'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.');
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            print('FlutterFire Messaging Example: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            print('FlutterFire Messaging Example: Got APNs token: $token');
          } else {
            print(
                'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.');
          }
        }
        break;
      default:
        break;
    }
  }

  Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthMethods _auth = AuthMethods();
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Cards.settingsCard(
                context: context,
                title: "History",
                iconData: FontAwesome.heartbeat,
                function: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryScreen()),
                  );
                },
              ),
              Cards.settingsCard(
                context: context,
                title: "Save to Google Sheet",
                iconData: Entypo.open_book,
                function: () async {
                  await HelperFunction.getPatientSharedPreference()
                      .then((value) {
                    if (value != null) {
                      DataBaseMethod dbM = DataBaseMethod(pid: value);
                      dbM.saveRecords();
                    }
                  });
                },
              ),
              Cards.settingsCard(
                context: context,
                title: "Select Patient",
                iconData: FontAwesome.user_o,
                function: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PatientScreen()),
                  );
                },
              ),
              Cards.settingsCard(
                context: context,
                title: "Logout",
                iconData: AntDesign.logout,
                function: () async {
                  await _auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Authenticate()),
                  );
                },
              ),
            ],
          ),
          // child: settingsCard(),
        ),
      ),
    );
  }

  Scaffold buildScaffoldNotifications() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Messaging'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: onActionSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'subscribe',
                  child: Text('Subscribe to topic'),
                ),
                const PopupMenuItem(
                  value: 'unsubscribe',
                  child: Text('Unsubscribe to topic'),
                ),
                const PopupMenuItem(
                  value: 'get_apns_token',
                  child: Text('Get APNs token (Apple only)'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          MetaCard('Permissions', Permissions()),
          MetaCard('FCM Token', TokenMonitor((token) {
            _token = token;
            return token == null
                ? const CircularProgressIndicator()
                : Text(token, style: const TextStyle(fontSize: 12));
          })),
          MetaCard('Message Stream', MessageList()),
        ]),
      ),
    );
  }
}

/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child:
                          Text(_title, style: const TextStyle(fontSize: 18))),
                  _children,
                ]))));
  }
}
