import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_iot/firebase_services/database.dart';
import 'package:health_care_iot/helper/helperFunction.dart';
import 'package:health_care_iot/utilities/constants.dart';
import 'package:health_care_iot/utilities/utilities.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String uid;

  late String name;
  late String type;
  /*_UICurrentUser(Message msg) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      margin: EdgeInsets.only(left: 40.0, top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFE3F2FD),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            msg.time,
            style: TextStyle(
              color: Colors.black26,
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            msg.text,
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }

  _buildMsgUI(Message msg) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          margin: EdgeInsets.only(right: 10.0, top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                msg.time,
                style: TextStyle(
                  color: Colors.white30,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                msg.text,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon:
          msg.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          iconSize: 30.0,
          color: msg.isLiked ? Colors.red : Colors.blueGrey,
          onPressed: () {},
        ),
      ],
    );
  }*/
  void inputData(context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    uid = user!.uid;

    await HelperFunction.getUserNameSharedPreference().then((value) {
      if (value != null)
        setState(() {
          name = value;
        });
    });

    await HelperFunction.getUserTypeSharedPreference().then((value) {
      if (value != null)
        setState(() {
          type = value;
        });
    });
    // here you write the codes to input the data into firestore
  }

  late TextEditingController msgController;

  late Stream chatMessageStream;
  @override
  void initState() {
    super.initState();

    msgController = new TextEditingController(text: '');
    getMessages();
  }

  getMessages() async {
    await HelperFunction.getPatientSharedPreference().then((value) {
      if (value != null) {
        chatMessageStream =
            DataBaseMethod(pid: value).getConversationMessages();
      }
    });
  }

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapShot) {
        // print(snapShot.data.docs[0].data()['message'].toString());
        return snapShot.hasData
            ? ListView.builder(
                itemCount: snapShot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      snapShot.data.docs[index].data()['sendBy'].toString(),
                      snapShot.data.docs[index].data()['message'].toString(),
                      snapShot.data.docs[index].data()['type'].toString() ==
                          type);
                })
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    inputData(context);

    // DateTime now = DateTime.now();
    // String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    // final messages = Provider.of<List<Message>>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // appBar: AppBar(
      //    title: Text(widget.receiver.name),
      //   elevation: 0.0,
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.more_horiz),
      //       iconSize: 28.0,
      //       color: Colors.white30,
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: chatMessageList(),
          ),
          Container(
            //color: Colors.white,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      controller: msgController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Send Message ...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: blueColor,
                    iconSize: 30.0,
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      int month = now.month + 1;
                      int hr = now.hour;
                      int mnt = now.minute;
                      String _am = "AM";
                      String zero = "0";
                      if (hr > 12) {
                        hr = hr - 12;
                        _am = "PM";
                      }
                      if (mnt > 9) {
                        zero = "";
                      }
                      String time = "$hr:$zero$mnt $_am";
                      String date = "${now.day}/$month/${now.year}";
                      Map<String, Object> messageMap = {
                        "sendBy": name,
                        "uid": uid,
                        "type": type,
                        "message": msgController.text,
                        "millis": now.microsecondsSinceEpoch,
                        "time": time,
                        "date": date
                      };
                      await HelperFunction.getPatientSharedPreference()
                          .then((value) {
                        if (value != null) {
                          final DataBaseMethod dbService =
                              DataBaseMethod(uid: uid, pid: value);
                          dbService.setConversationMessages(messageMap);
                        }
                      });
                      msgController.clear();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String msg;
  final String name;
  final bool isMe;
  const MessageTile(this.name, this.msg, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: isMe ? 0 : 24, right: isMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: isMe
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)]),
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              msg,
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
