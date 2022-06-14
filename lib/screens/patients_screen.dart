import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/screens/history_details.dart';
import 'package:health_care_iot/widgets/cards.dart';
import 'package:intl/intl.dart';

class PatientScreen extends StatefulWidget {
  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  late Stream patientMessageStream;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getPatients();
  }

  getPatients() async {
    patientMessageStream = DataBaseMethod().getAllPatients();
    setState(() {
      isLoading = false;
    });
  }

  Widget patientsList() {
    return StreamBuilder(
      stream: patientMessageStream,
      builder: (context, snapShot) {
        // print(snapShot.data.docs[0].data()['name'].toString());
        // print(snapShot.data.docs.length);

        return snapShot.hasData
            ? ListView.builder(
                itemCount: snapShot.data.docs.length,
                itemBuilder: (context, index) {
                  return Cards.settingsCard(
                    context: context,
                    title: snapShot.data.docs[index].data()['name'].toString(),
                    iconData: FontAwesome.user_o,
                    function: () {
                      HelperFunction.savePatientSharedPreference(
                          snapShot.data.docs[index].data()['pid'].toString());
                      Navigator.of(context).pop();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => HistoryDetails(
                      //       snapShot.data.docs[index]
                      //           .data()['updatedAt']
                      //           .toString(),
                      //     ),
                      //   ),
                      // );
                    },
                  );
                })
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // DateTime now = DateTime.now();
    // String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    // final messages = Provider.of<List<Message>>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("Patients"),
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.more_horiz),
          //   iconSize: 28.0,
          //   color: Colors.white30,
          //   onPressed: () {},
          // ),
        ],
      ),
      body: SafeArea(
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: Loading(),
                )
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: patientsList(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
