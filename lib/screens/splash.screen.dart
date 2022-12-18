import 'dart:async';

import 'package:dongnerang/screens/setting/private.setting.screen.dart';
import 'package:dongnerang/screens/updatedialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:new_version/new_version.dart';
import '../constants/colors.constants.dart';
import '../services/firebase.service.dart';
import 'login.screen.dart';
import 'mainScreenBar.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // FirebaseAuth.instance.signOut();
    // GoogleSignIn().signOut();
    // 버전 코드
    final newVersion = NewVersion(
      androidId: 'com.dongnerang.com.dongnerang',
      iOSId: 'com.dongnerang.com.dongnerang',
    );
    checkNewVersion(newVersion);
    // checkPermissions();
    super.initState();
  }

  void checkNewVersion(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
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
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if(FirebaseAuth.instance.currentUser != null){
        print("FirebaseAuth.instance.currentUser : ${FirebaseAuth.instance.currentUser?.email.runtimeType}");
        if(!await FirebaseService.findUserlocal(FirebaseAuth.instance.currentUser?.email)){
          EasyLoading.showInfo("개인설정을 진행 해 주세요");
          Get.offAll(() => privateSettingScreen());
        }else{
          Get.offAll(() => const mainScreen());
        }
      }else{
        Get.offAll(() => const LoginScreen());
      }
      // print("FirebaseAuth.instance.currentUser : ${FirebaseAuth.instance.currentUser?.email.runtimeType}");
      // if(!await FirebaseService.findUserlocal(FirebaseAuth.instance.currentUser?.email)){
      //   EasyLoading.showInfo("개인설정을 진행 해 주세요");
      //   Get.offAll(() => privateSettingScreen());
      // }else{
      //   FirebaseAuth.instance.currentUser != null
      //       ? Get.offAll(() => const mainScreen())
      //       : Get.offAll(() => const LoginScreen());
      // }
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
