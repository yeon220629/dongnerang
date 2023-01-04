import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NotificationController extends GetxController {
  static NotificationController get to => Get.find();
  // 최신버전의 초기화 방법
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Rx<RemoteMessage> remoteMessage = const RemoteMessage().obs;
  // remoteMessage 가 obx 에서 검출이 잘되지 않아서 dateTime 을 추가함
  Rx<DateTime> dateTime = DateTime.now().obs;

  @override
  Future<void> onInit() async {
    _initNotification();
    // 토큰을 알면 특정 디바이스에게 문자를 전달가능
    _getToken();
    super.onInit();
  }

  Future<void> _getToken() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    _messaging.getToken().then((token) async {
      debugPrint('token~: [$token]');
      await FirebaseFirestore.instance.collection("users").doc(userEmail).update(({
        'usertoken': token,
      }));
    });
  }

  Future<void> _initNotification() async {
    // await Firebase.initializeApp();
    // NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: true,
    //   provisional: false,
    //   sound: false,
    // );
    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   print('User granted permission');
    // } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    //   print('User granted provisional permission');
    // } else {
    //   print('User declined or has not accepted permission');
    // }
    // 앱이 동작중일때 호출됨
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      _addNotification(event);
      debugPrint("NotificationController >> message received");
      debugPrint('Title >> ${event.notification!.title.toString()}');
      debugPrint('Body >> ${event.notification!.body.toString()}');
    });

    // 앱이 background 동작중일때 호출됨, 종료중일때도 호출됨?
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // FirebaseService.sendUserKeyword(userEmail!, duplicateCheckValue);
      _addNotification(message);
      debugPrint('------------------------Message clicked! :');
    });
  }
  // 메시지를 변수에 저장
  void _addNotification(RemoteMessage event) {
    dateTime(event.sentTime);
    remoteMessage(event);
    debugPrint(dateTime.toString());
  }
}