import 'dart:async';
import 'package:dongnerang/models/notification.model.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';


class NotificationController extends GetxController {
  static NotificationController get to => Get.find();
  // 최신버전의 초기화 방법
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  Rx<RemoteMessage> remoteMessage = const RemoteMessage().obs;
  Rx<DateTime> dateTime = DateTime.now().obs;

  @override
  Future<void> onInit() async {
    // await Firebase.initializeApp();
    FirebaseService.getUserPrivacyProfile(userEmail!).then((value) {
      if(value[0]['alramlocalPermission'] == true){
        _initNotification();
      }
    });
    // 토큰을 알면 특정 디바이스에게 문자를 전달가능
    super.onInit();
  }

  void _initNotification() {
    // 앱이 동작중일때 호출됨
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new IOSInitializationSettings();
    var settings = new InitializationSettings(android: android, iOS: IOS);
    flutterLocalNotificationsPlugin.initialize(settings);

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
      // debugPrint('Title >> ${event.notification!.title.toString()}');
      // debugPrint('Body >> ${event.notification!.body.toString()}');
      // debugPrint('link >> ${event.data['link'].toString()}');
      tempArray.add(
        CustomNotification(
          title: event.notification!.title.toString(),
          link: event.data['link'].toString(),
          center_name: event.data['center_name'].toString(),
          body: event.notification!.body.toString(),
          registrationdate: event.data['registrationdate'].toString(),
        )
      );
      FirebaseService.saveUserNotificationData(userEmail!,tempArray);
      // 5초 뒤에 해당 배열 비우기
      Future.delayed(Duration(milliseconds : 5000),() {
        tempArray = [];
      });
        // push 알림 보기 설정
      flutterLocalNotificationsPlugin.show(0, '${event.notification!.title.toString()}',
          '${event.notification!.body.toString()}',
          platformChannelSpecifics, payload: 'Default_Sound'
      );
    });

    // 앱이 background 동작중일때 호출됨, 종료중일때도 호출됨?
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // FirebaseService.sendUserKeyword(userEmail!, duplicateCheckValue);
      _addNotification(message);
      debugPrint('------------------------Message clicked! :');
    });
  }



  // 메시지를 변수에 저장
  Future<void> _addNotification(RemoteMessage event) async {
    dateTime(event.sentTime);
    remoteMessage(event);
    debugPrint(dateTime.toString());
  }
}