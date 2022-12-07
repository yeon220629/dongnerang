import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:dongnerang/screens/permission.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.constants.dart';
import 'login.screen.dart';
import 'mainScreenBar.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _authStatus = 'Unknown';

  @override
  void initState() {
    // FirebaseAuth.instance.signOut();
    // GoogleSignIn().signOut();
    checkPermissions();
    super.initState();
  }



  Future<void> checkPermissions() async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      print("FirebaseAuth.instance.currentUser : ${FirebaseAuth.instance.currentUser}");
      FirebaseAuth.instance.currentUser != null
          ? Get.offAll(() => const mainScreen())
          : Get.offAll(() => const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        // bottom: true,
      child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: Column(children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 20),
                  Image.asset("assets/images/app_logo_white.png", width: 180, height: 180,)
                ],
              ),
            ),
            Lottie.asset(
              'assets/lottie/68894-running.json',
              width: 100,
              height: 100,
              fit: BoxFit.fill,
            ),
            const Text(
              "yeon",
              style: TextStyle(fontSize: 20, color: AppColors.white),
            ),
            const SizedBox(height: 20),

          ]),
        ),
      ),
    );
  }
}
