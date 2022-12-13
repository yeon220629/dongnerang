import 'dart:async';

import 'package:dongnerang/screens/updatedialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    // final newVersion = NewVersion(
    //   androidId: 'com.dongnerang.com.dongnerang',
    //   iOSId: 'com.dongnerang.com.dongnerang',
    // );
    // checkNewVersion(newVersion);
    checkPermissions();
    super.initState();
  }

  void checkNewVersion(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    // print("status canUpdate : ${status?.canUpdate}");
    // print("status appStoreLink : ${status?.appStoreLink}");
    // print("status LocalVersion : ${status?.localVersion}");
    // print("status storeVersion : ${status?.storeVersion}");
    // print("status releaseNotes : ${status?.releaseNotes}");
    if(status != null) {
      // 업데이트 테스트
      // if(!status.canUpdate) {
      if(status.canUpdate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              description: status.releaseNotes!,
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
      }else{
        checkPermissions();
      }
    }
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
