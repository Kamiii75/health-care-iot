import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_care_iot/models/records_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class DataBaseMethod {
  String uid="";
  String pid = "patient_test";

  DataBaseMethod({String? uid ,String? pid } );

  final CollectionReference _refUser =
      FirebaseFirestore.instance.collection('users');

  getUserByUserName(String username) async {
    return await _refUser.where("name", isEqualTo: username).get();
  }

  getUserByUserEmail(String email) async {
    return await _refUser.where("email", isEqualTo: email).get();
  }

  updateUserInfo(userMap) {
    _refUser.add(userMap);
  }

  Future updateUser(String name, String deviceToken, String type) async {
    return await _refUser.doc(uid).set({
      'device_token': deviceToken,
      'name': name,
      'type': type,
      'uid': uid,
    });
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((onError) {
      print(onError.toString());
    });
  }

  setConversationMessages(messageMap) {
    FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection("chats")
        .add(messageMap)
        .catchError((onError) {
      print(onError.toString());
    });
  }

  getConversationMessages() {
    return FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getAllHistory() {
    return FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection("history")
        .orderBy("createdAt", descending: false)
        .snapshots();
  }

  getAllPatients() {
    return FirebaseFirestore.instance.collection("Patients").snapshots();
  }

  getChatRooms(String userName) {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .where('users', arrayContains: userName)
        .snapshots();
  }

  List<Records> _recordsListFromSnapShots(QuerySnapshot snapshot) {
    print('object');
    return snapshot.docs.map((doc) {
      return Records(
        bpm: doc.get("bpm") ?? '',
        temp: doc.get('temp') ?? '',
        spo: doc.get('spo') ?? '',
        ecg: doc.get('ecg') ?? '',
        online: doc.get('online') ?? '',
      );
    }).toList();
  }

  Stream<List<Records>> get allRecords {
    return FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection('records')
        .snapshots()
        .map(_recordsListFromSnapShots);
  }
  //////////////////////////////////////////////////////////////////////////////////////////

  getCurrentResults() {
    return FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection("results")
        .snapshots();
  }

  getCurrentHistoryResults(String docId) {

    return FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection("history")
        .doc(docId)
        .snapshots();
  }

  saveResults(String urlRecords, String pName) async {
    QuerySnapshot recordSnapShots = await FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection('history')
        .get();
    recordSnapShots.docs.forEach((records) async {
      var bpm = records.get('bpm').toString();
      var spo = records.get('spo').toString();
      var tempc = records.get('tempc').toString();
      var tempf = records.get('tempf').toString();
      var ecg = records.get('ecg').toString();
      var timestamp = records.get('updatedAt').toString();

      var date = readTimestamp(timestamp);

      print(date);
      String toParams =
          "?name=$pName&bpm=$bpm&spo=$spo&tempc=$tempc&tempf=$tempf&ecg=$ecg&date=$date";

      try {
        await http
            .get(Uri.parse(urlRecords + toParams))
            .then((response) => convert.jsonDecode(response.body)['status']);
      } catch (e) {
        print(e);
      }
    });
  }

  saveChats(String urlRecords, String pName) async {
    QuerySnapshot chatSnapShots = await FirebaseFirestore.instance
        .collection("Patients")
        .doc(pid)
        .collection('chats')
        .get();

    chatSnapShots.docs.forEach((chat) async {
      var doc = chat.get('sendBy').toString();
      var type = chat.get('type').toString();
      var msg = chat.get('message').toString();
      var date = chat.get('date').toString();

      String toParam = "?name=$pName&doc=$doc&type=$type&msg=$msg&date=$date";

      try {
        await http
            .post(Uri.parse(urlRecords + toParam))
            .then((response) => convert.jsonDecode(response.body)['status']);
      } catch (e) {
        print(e);
      }
    });
  }

  saveRecords() async {
    String urlRecords =
        "https://script.google.com/macros/s/AKfycbzyJwqYMVsw7SEkwLObYaGcEHEovB8EP46ql7V6Ban0p9PcL0fNJc7n6V-6QLoxFcof/exec";
    String pName = pid;

    try {
      saveResults(urlRecords, pName);
    } finally {
      saveChats(urlRecords, pName);
    }
  }

  String readTimestamp(String text) {
    int? timestamp = int.tryParse(text);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp!);
    int day = date.day;
    int month = date.month;
    int year = date.year;
    String time = "${day}_${month}_$year";

    return time;
  }
}
