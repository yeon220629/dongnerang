import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../constants/colors.constants.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

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
              "로그인 중 입니다..",
              style: TextStyle(fontSize: 20, color: AppColors.white),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
