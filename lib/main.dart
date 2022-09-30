import 'package:dongnerang/screens/mainScreen.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'constants/common.constants.dart';
import 'firebase_options.dart';

bool isFirebaseReady = true;

void main() async {
  KakaoSdk.init(nativeAppKey:KAKAO_NATIVE_APP_KEY);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).catchError((e){
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
      builder: EasyLoading.init(),
    );
  }
}
