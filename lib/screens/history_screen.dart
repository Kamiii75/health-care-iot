import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/screens/history_details.dart';
import 'package:health_care_iot/widgets/cards.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Stream historyMessageStream;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  getHistory() async {
    await HelperFunction.getPatientSharedPreference().then((value) {
      if (value != null) {
        historyMessageStream = DataBaseMethod(pid: value).getAllHistory();
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Widget historyList() {
    return StreamBuilder(
      stream: historyMessageStream,
      builder: (context, snapShot) {
        // print(snapShot.data.docs[0].data()['message'].toString());
        return snapShot.hasData
            ? ListView.builder(
                itemCount: snapShot.data.docs.length,
                itemBuilder: (context, index) {
                  print(
                      snapShot.data.docs[index].data()['createdAt'].toString());
                  return Cards.settingsCard(
                    context: context,
                    title: readTimestamp(
                      snapShot.data.docs[index].data()['updatedAt'].toString(),
                    ),
                    iconData: FontAwesome.history,
                    function: () {

                      print("docId : ${snapShot.data.docs[index]
                          .data()['updatedAt']
                          .toString()}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetails(
                            snapShot.data.docs[index]
                                .data()['updatedAt']
                                .toString(),
                          ),
                        ),
                      );
                    },
                  );
                })
            : Container();
      },
    );
  }

  String readTimestamp(String text) {
    int? timestamp = int.tryParse(text);
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp!);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + 'DAY AGO';
      } else {
        time = diff.inDays.toString() + 'DAYS AGO';
      }
    }

    return time;
  }

  @override
  Widget build(BuildContext context) {
    // DateTime now = DateTime.now();
    // String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    // final messages = Provider.of<List<Message>>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("History"),
        elevation: 0.0,
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
                      child: historyList(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
