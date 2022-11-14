// import 'package:dongnerang/firebase_options.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/screens/splash.screen.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/common.constants.dart';

bool isFirebaseReady = true;

void fcmSetting() async {
  // firebase core 기능 사용을 위한 필수 initializing
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true);

  // foreground에서의 푸시 알림 표시를 위한 알림 중요도 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  // foreground에서의 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
          iOS: IOSInitializationSettings()),
      onSelectNotification: (String? payload) async {});

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));
    }
  });

  // 사용자가 푸시 알림을 허용했는지 확인 (optional)
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isFCMEnabled = await prefs.getBool('FCM_ENABLED');
  String? firebaseToken = await FirebaseMessaging.instance.getToken();
  if (isFCMEnabled == null || isFCMEnabled) {
    // firebase token 발급
    String? firebaseToken = await FirebaseMessaging.instance.getToken();
    // 서버로 firebase token 갱신
    // if (firebaseToken != null) {
    //   var dio = Dio();
    //   final firebaseTokenUpdateResponse = await dio.put(
    //       '/token',
    //       data: {'token': firebaseToken});
    // }
  }
}

void main() async {
  KakaoSdk.init(nativeAppKey:KAKAO_NATIVE_APP_KEY);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class ColorService { //기본 컬러 설정
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '동네랑',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        primarySwatch: ColorService.createMaterialColor(const Color(0xff5B88E2)),
      ),
      home: const SplashScreen(),
      // home: const mainScreen(),
      initialBinding: BindingsBuilder((){
        Get.put(UserService());
      }),
      builder: EasyLoading.init(),
    );
  }
}
