import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incom/screens/splash.screen.dart';
import 'package:incom/services/user.service.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'constants/common.constants.dart';

void main() async {
  KakaoSdk.init(nativeAppKey:KAKAO_NATIVE_APP_KEY2);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      initialBinding: BindingsBuilder((){
        Get.put(UserService());
      }),
    );
  }
}
