import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high importance channel', //id
    'High Importance Notification', //title
    importance: Importance.high,
    playSound: true
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
      await Firebase.initializeApp();
      print("A bg messaging just showed up :  ${message.messageId} ");
    }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

int _counter =0;


  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          channel.name.toString(),
          channel.description.toString(),
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
              )
          ),
          );
        print(notification.title.toString());
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
           log("A new onMessageOpenedApp event was  published!");
           RemoteNotification? notification = message.notification;
           AndroidNotification? android = message.notification?.android;
           if (notification != null && android != null) {
             showDialog(context: context, builder: (context)=>AlertDialog(
               title: Text(notification.title.toString()),
               content: SingleChildScrollView(
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(notification.body.toString())
                   ],
                 ),
               ),
             ));
           }
          });
      }
    });
    }

void showNotification(){
setState(() {
  _counter++;
});
flutterLocalNotificationsPlugin.show(
  0,
  "Testing $_counter",
  "How You doing ?",
  NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: Importance.high,
      color: Colors.blue,
      playSound: true,
      icon: '@mipmap/ic_launcher')
  ));
}
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("home"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
       );
  }
}
