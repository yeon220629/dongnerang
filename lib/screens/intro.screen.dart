import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.constants.dart';
import '../widgets/app_button.widget.dart';
import 'login.screen.dart';
import 'mainScreen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          height: Get.size.height,
          width: Get.size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200,),
              const Text(
                "동네랑 로고",
                style: TextStyle(fontSize: 28, color: AppColors.primary),
              ),
              SizedBox(height: 250,),
              SizedBox(
                width: Get.size.width,
                child: AppButton(
                  text: "yeon",
                  onPressed: () {
                    FirebaseAuth.instance.currentUser == null
                        ? Get.offAll(() => const LoginScreen())
                        : Get.offAll(() => const mainScreen());
                        // ? Get.offAll(() => const mainScreen())
                        // : Get.offAll(() => const LoginScreen());
                  },
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
}
