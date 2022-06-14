import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/models/records_model.dart';
import 'package:health_care_iot/screens/chat_screen.dart';
import 'package:health_care_iot/screens/home_screen.dart';
import 'package:health_care_iot/screens/settings_screen.dart';
import 'package:health_care_iot/utilities/size_config.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

//AuthMethods _auth = AuthMethods();

class _MainPageState extends State<MainPage> {
  late String pid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPatientId();
  }

  getPatientId() async {
    await HelperFunction.getPatientSharedPreference().then((value) {
      if (value != null)
        pid = value;
      else {
        pid = "patient_test";
        HelperFunction.savePatientSharedPreference(pid);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return isLoading
        ? Center(
            child: Loading(),
          )
        : StreamProvider<List<Records>>.value(
            value: DataBaseMethod(pid: pid).allRecords,
            initialData: [],
            child: Scaffold(
              // appBar: AppBar(
              //   actions: <Widget>[
              //     TextButton.icon(
              //         onPressed: () async {
              //           await _auth.signOut();
              //           Navigator.pushReplacement(
              //             context,
              //             MaterialPageRoute(builder: (_) => Authenticate()),
              //           );
              //         },
              //         icon: Icon(Icons.person),
              //         label: Text('Logout'))
              //   ],
              // ),
              // body: UsersList(),

              body: index == 0
                  ? HomePage()
                  : index == 1
                      ? ChatScreen()
                      : SettingsPage(),
              bottomNavigationBar: CurvedNavigationBar(
                //buttonBackgroundColor: Colors.red,
                //color: Colors.red,
                backgroundColor: Theme.of(context).primaryColor,
                items: <Widget>[
                  Icon(
                    Icons.home,
                    color: Theme.of(context).primaryColor,
                  ),
                  Icon(
                    Icons.chat,
                    color: Theme.of(context).primaryColor,
                  ),
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
                onTap: (indx) {
                  print("Current index : $indx");
                  setState(() {
                    index = indx;
                  });
                },
              ),
            ),
          );
  }
}
