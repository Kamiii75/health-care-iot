import 'package:flutter/material.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/widgets/cards.dart';
import 'package:health_care_iot/widgets/ecgChart.dart';

class HistoryDetails extends StatefulWidget {
  final String docId;
  HistoryDetails(this.docId);

  @override
  _HistoryDetailsState createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  late Stream resultStream;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getResults();
  }

  getResults() async {
    print("docId : ${widget.docId}");
    await HelperFunction.getPatientSharedPreference().then((value) {
      if (value != null) {
        resultStream = DataBaseMethod(pid: value).getCurrentHistoryResults(widget.docId);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Details"),
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
      body:isLoading
          ? Center(
        child: Loading(),
      )
          : SafeArea(child: resultsContainer(context)),
    );
  }

  Widget resultsContainer(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: resultStream,
      builder: (context, snapShot) {

        return snapShot.hasData
            ? Container(
          margin: EdgeInsets.only(top: 0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 2,
                          offset: Offset(0, 5),
                          color: Theme.of(context).shadowColor)
                    ]),
                child: CartasianLine(
                  snapShot.data.data()['ecg'].toString(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Cards.cardBpm(
                    context: context,
                    width: width,
                    val: snapShot.data.data()['bpm'].toString(),
                    onTap: () {},
                  ),
                  Cards.cardSpo(
                    context: context,
                    width: width,
                    val: snapShot.data.data()['spo'].toString(),
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Cards.cardTempC(
                    context: context,
                    width: width,
                    val: double.parse(
                        snapShot.data.data()['tempc'])
                        .round()
                        .toString(),
                    onTap: () {},
                  ),
                  Cards.cardTempF(
                    context: context,
                    width: width,
                    val: double.parse(
                        snapShot.data.data()['tempf'])
                        .round()
                        .toString(),
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        )
            : Container();
      },
    );
  }
}
