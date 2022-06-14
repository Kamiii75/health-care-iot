import 'package:flutter/material.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/models/loading.dart';
import 'package:health_care_iot/widgets/ecgChart.dart';
import 'package:health_care_iot/widgets/cards.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream resultStream;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getResults();
  }

  getResults() async {
    await HelperFunction.getPatientSharedPreference().then((value) {
      if (value != null) {
        resultStream = DataBaseMethod(pid: value).getCurrentResults();
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
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
                        snapShot.data.docs[0].data()['ecg'].toString(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Cards.cardBpm(
                          context: context,
                          width: width,
                          val: snapShot.data.docs[0].data()['bpm'].toString(),
                          onTap: () {},
                        ),
                        Cards.cardSpo(
                          context: context,
                          width: width,
                          val: snapShot.data.docs[0].data()['spo'].toString(),
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
                                  snapShot.data.docs[0].data()['tempc'])
                              .round()
                              .toString(),
                          onTap: () {},
                        ),
                        Cards.cardTempF(
                          context: context,
                          width: width,
                          val: double.parse(
                                  snapShot.data.docs[0].data()['tempf'])
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
