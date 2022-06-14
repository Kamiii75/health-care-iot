import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care_iot/screens/main_page.dart';

import 'helper/authentication.dart';
import 'helper/helperFunction.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  // flutterLocalNotificationsPlugin.show(
  //     message.notification.hashCode,
  //     message.notification.title,
  //     message.notification.body,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channel.description,
  //         // TODO add a proper drawable resource to android, for now using
  //         //      one that already exists in example app.
  //         icon: 'launch_background',
  //       ),
  //     ));

  AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: 1,
        channelKey: 'big_picture',
        title: message.data['title'],
        body: message.data['body'],
        bigPicture: message.data['image'],
        // icon: 'resource://mipmap/ic_launcher',
        notificationLayout: NotificationLayout.BigPicture),
  );
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title/ description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
            channelKey: 'badge_channel',
            channelName: 'Badge indicator notifications',
            channelDescription:
            'Notification channel to activate badge indicator',
            channelShowBadge: true,
            importance: NotificationImportance.High,
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.yellow),
        NotificationChannel(
            channelKey: 'high_intensity',
            channelName: 'High intensity notifications',
            channelDescription:
            'Notification channel for notifications with high intensity',
            defaultColor: Colors.red,
            importance: NotificationImportance.High,
            ledColor: Colors.red,
            vibrationPattern: highVibrationPattern),
        NotificationChannel(
            channelKey: "private_channel",
            channelName: "Privates notification channel",
            channelDescription: "Privates notification from lock screen",
            playSound: true,
            defaultColor: Colors.red,
            importance: NotificationImportance.High,
            ledColor: Colors.red,
            vibrationPattern: lowVibrationPattern,
            defaultPrivacy: NotificationPrivacy.Private),
        NotificationChannel(
            icon: 'resource://drawable/res_power_ranger_thunder',
            channelKey: "custom_sound",
            channelName: "Custom sound notifications",
            channelDescription: "Notifications with custom sound",
            playSound: true,
            soundSource: 'resource://raw/res_morph_power_rangers',
            defaultColor: Colors.red,
            ledColor: Colors.red,
            importance: NotificationImportance.High,
            vibrationPattern: lowVibrationPattern),
        NotificationChannel(
            icon: 'resource://drawable/res_media_icon',
            channelKey: 'media_player',
            channelName: 'Media player controller',
            channelDescription: 'Media player controller',
            defaultPrivacy: NotificationPrivacy.Public,
            enableVibration: false,
            enableLights: false,
            importance: NotificationImportance.High,
            playSound: false,
            locked: true),
        NotificationChannel(
            icon: 'resource://drawable/res_download_icon',
            channelKey: 'progress_bar',
            channelName: 'Progress bar notifications',
            channelDescription: 'Notifications with a progress bar layout',
            defaultColor: Colors.deepPurple,
            ledColor: Colors.deepPurple,
            importance: NotificationImportance.High,
            vibrationPattern: lowVibrationPattern,
            onlyAlertOnce: true),
      ],
      debug: true);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  await Firebase.initializeApp();
// ...

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  late bool userIsLoggedIn;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      // if (message != null) {
      //   Navigator.pushNamed(context, '/message',
      //       arguments: MessageArguments(message, true));
      // }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // RemoteNotification notification = message.notification;
      // AndroidNotification android = message.notification?.android;
      // if (notification != null && android != null) {
      //   flutterLocalNotificationsPlugin.show(
      //       notification.hashCode,
      //       notification.title,
      //       notification.body,
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           channel.id,
      //           channel.name,
      //           channel.description,
      //           // TODO add a proper drawable resource to android, for now using
      //           //      one that already exists in example app.
      //           icon: 'launch_background',
      //         ),
      //       ));
      // }

      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: 'big_picture',
            title: message.data['title'],
            body: message.data['body'],
            bigPicture: message.data['image'],
            // icon: 'resource://mipmap/ic_launcher',
            notificationLayout: NotificationLayout.BigPicture),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });

    getLoggedInState();
  }

  //

  // @override
  // void initState() {
  //   super.initState();
  // }

  getLoggedInState() async {
    await HelperFunction.getUserLoggedInSharedPreference().then((value) {
      if (value != null)
        setState(() {
          userIsLoggedIn = value;
        });
    });

    await HelperFunction.getTopicSharedPreference().then((value) {
      if (value != null)
        setState(() async {
          await FirebaseMessaging.instance.subscribeToTopic(value);
        });
      else
        setState(() async {
          await FirebaseMessaging.instance.subscribeToTopic("patient_test");
        });
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF32475A),
        accentColor: Color(0xFF5D7287),
        cardColor: Color(0xFF072031),
        hoverColor: Color(0xFF527DAA),
        scaffoldBackgroundColor: Color(0xFF32475A),
        shadowColor: Colors.black.withOpacity(0.07),
        textTheme: ThemeData.dark().textTheme,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn != null
          ? userIsLoggedIn
          ? MainPage()
          : Authenticate()
          : Authenticate(),
    );
  }
}
