import 'package:dongnerang/screens/mainScreen.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool isFirebaseReady = true;

void main() async {
  // KakaoSdk.init(nativeAppKey:KAKAO_NATIVE_APP_KEY2);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((e){
    isFirebaseReady = false;
    print("error flutter firebase service : $e");
  });
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const SplashScreen(),
      home: const mainScreen(),
      initialBinding: BindingsBuilder((){
        Get.put(UserService());
      }),
    );
  }
}
