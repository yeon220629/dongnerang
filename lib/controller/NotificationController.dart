import 'dart:async';
import 'package:dongnerang/models/notification.model.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';


class NotificationController extends GetxController {
  static NotificationController get to => Get.find();
  // 최신버전의 초기화 방법
  Rx<RemoteMessage> remoteMessage = const RemoteMessage().obs;
  Rx<DateTime> dateTime = DateTime.now().obs;

  @override
  Future<void> onInit() async {
    // await Firebase.initializeApp();
    _initNotification();

    // FirebaseService.getUserPrivacyProfile(userEmail!).then((value) {
    //   if(value[0]['alramlocalPermission'] == true){
    //   }
    // });
    super.onInit();
  }
  //메시지 클릭 시 이벤트
  Future<void> onSelectNotification(String payload, data) async {
    // print("data : $data");
    //url, post["title"], post['center_name '], dateTime, 0
    
    // print("payload : ${payload.split(",")}");
    final Uri url = Uri.parse('${payload.split(",")[1]}');
    Get.to(
        urlLoadScreen(url, payload.split(",")[3], payload.split(",")[2], payload.split(",")[4], 0)
    );

    // final url = Uri.parse(payload!);
    // if (await canLaunchUrl(url)) {
    //   launchUrl(url, mode: LaunchMode.inAppWebView);
    // }
  }

  void _initNotification() {
    // 앱이 동작중일때 호출됨
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new IOSInitializationSettings();
    var settings = new InitializationSettings(android: android, iOS: IOS);
    flutterLocalNotificationsPlugin.initialize(
        settings, onSelectNotification: (payload) async {
            onSelectNotification(payload!, []);
        });
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        // icon:
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics
    );

    List tempArray = [];
    // 앱이 동작 중일 떄
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      _addNotification(event);
      debugPrint("NotificationController >> message received");
      tempArray.add(
        CustomNotification(
          title: event.notification!.title.toString(),
          link: event.data['link'].toString(),
          center_name: event.data['center_name'].toString(),
          body: event.notification!.body.toString(),
          registrationdate: event.data['registrationdate'].toString(),
        )
      );
      // FirebaseService.saveUserNotificationData(userEmail!,tempArray);

        // push 알림 보기 설정
      flutterLocalNotificationsPlugin.show(0, '${event.notification!.title.toString()}',
          '${event.notification!.body.toString()}',
        // platformChannelSpecifics, payload: event.data['link'].toString(),
        platformChannelSpecifics, payload: tempArray.toString(),
      );
      Future.delayed(Duration(milliseconds : 5000),() {
        tempArray = [];
      });
    });

    // 앱이 background 동작중일때 호출됨, 종료중일때도 호출됨?
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      // FirebaseService.sendUserKeyword(userEmail!, duplicateCheckValue);
      _addNotification(message);
      debugPrint('------------------------Message clicked! : ${message.data['link']}');
      final url = Uri.parse(message.data['link']!);
      if (await canLaunchUrl(url)) {
        launchUrl(url, mode: LaunchMode.inAppWebView);
      }
      onSelectNotification(message.data['link'], message.data);
    });

  }

  // 메시지를 변수에 저장
  Future<void> _addNotification(RemoteMessage event) async {
    // print("data click event : ${event.data}");
    // final url = Uri.parse(event.data['link'].toString());
    dateTime(event.sentTime);
    remoteMessage(event);
    debugPrint(dateTime.toString());
  }
}