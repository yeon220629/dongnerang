import 'dart:async';

import 'package:dongnerang/screens/setting/private.setting.birth.gender.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
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
    checkPermissions();
    super.initState();
  }

  Future<void> checkPermissions() async {
    Future.delayed(const Duration(milliseconds: 800), () async {
      if(FirebaseAuth.instance.currentUser != null){
        print("FirebaseAuth.instance.currentUser : ${FirebaseAuth.instance.currentUser?.email.runtimeType}");
        if(!await FirebaseService.findUserlocal(FirebaseAuth.instance.currentUser?.email)){
          EasyLoading.showInfo("개인설정을 진행 해 주세요");
          Get.offAll(() => privateSettingBirthGenderScreen());
        }else{
          Get.offAll(() => const mainScreen());
        }
      }else{
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                  Image.asset("assets/images/firstLogo.png", width: 280, height: 280,)
                ],
              ),
            ),
            Lottie.asset(
              'assets/lottie/68894-running.json',
              width: 100,
              height: 100,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
