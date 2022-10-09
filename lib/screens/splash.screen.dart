import 'package:dongnerang/screens/permission.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/colors.constants.dart';
import 'login.screen.dart';
import 'mainScreenBar.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    FirebaseAuth.instance.signOut();
    // GoogleSignIn().signOut();
    checkPermissions();
    super.initState();
  }

  Future<void> checkPermissions() async {
    // if ((await Permission.location.status != PermissionStatus.granted) ||
    //     (await Permission.camera.status != PermissionStatus.granted) ||
    //     (await Permission.photos.status != PermissionStatus.granted) ||
    //     (await Permission.notification.status != PermissionStatus.granted) ||
    //     (await Permission.storage.status != PermissionStatus.granted)) {
    //   Future.delayed(const Duration(milliseconds: 1000), () {
    //     Get.to(() => const PermissionScreen());
    //   });
    // } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        print(FirebaseAuth.instance);
        print(FirebaseAuth.instance.currentUser?.email);
        FirebaseAuth.instance.currentUser != null
            // ? Get.offAll(() => const mainScreen())
            // : Get.offAll(() => const LoginScreen());
            ? Get.offAll(() => const LoginScreen())
            : Get.offAll(() => const mainScreen());
      });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: Column(children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 20),
                  Image.asset("assets/images/app_logo.png", width: 150, height: 150,)
                ],
              ),
            ),
            const Text(
              "동네랑",
              style: TextStyle(fontSize: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
