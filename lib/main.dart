import 'dart:ui';
import 'package:dongnerang/firebase_options.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/screens/splash.screen.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants/common.constants.dart';
import 'controller/NotificationController.dart';
import 'models/notification.model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey:KAKAO_NATIVE_APP_KEY);
  MobileAds.instance.initialize();      // 모바일 광고 SDK 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.notification.isDenied.then((value) {
    if (value) { Permission.notification.request(); }
  });
  if(FirebaseAuth.instance.currentUser?.email != null){
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // 앱이 죽었을떄
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
  var IOS = new IOSInitializationSettings();
  var settings = new InitializationSettings(android: android, iOS: IOS);
  flutterLocalNotificationsPlugin.initialize(settings);

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'Notification id',
      'Notification name',
      importance: Importance.max,
      priority: Priority.high
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
  );

  debugPrint("NotificationController >> message received");
  debugPrint('Title >> ${message.notification!.title.toString()}');
  debugPrint('Body >> ${message.notification!.body.toString()}');
  FirebaseService.saveUserNotificationData(userEmail!,CustomNotification(title: message.notification!.title.toString(), link: message.data['link'].toString(), center_name: message.data['center_name'].toString()));

  // push 알림 보기 설정
  await flutterLocalNotificationsPlugin.show(0, '${message.notification!.title.toString()}',
      '${message.notification!.body.toString()}',
      platformChannelSpecifics, payload: 'Default_Sound'
  );
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
    //앱 상태바 색상(appbar 없는 화면)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '동네랑',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          //앱 상태바 색상(appbar 있는 화면)
          systemOverlayStyle: SystemUiOverlayStyle.dark,),
        iconTheme: IconThemeData( color: Colors.black),
        primaryColor: AppColors.primary,
        primarySwatch: ColorService.createMaterialColor(const Color(0xff5B88E2)),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      home: const SplashScreen(),
      // home: const mainScreen(),
      initialBinding: BindingsBuilder((){
        Get.put(UserService());
        Get.put(NotificationController());
      }),
      builder: EasyLoading.init(
        //폰트 사이즈 고정
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: child!,
          );
        },
      ),
    );
  }

}
