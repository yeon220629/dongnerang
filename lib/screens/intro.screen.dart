import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                const Text(
                  "test\nintro",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: Get.size.width,
                  child: AppButton(
                    text: "완료",
                    onPressed: () {
                      FirebaseAuth.instance.currentUser == null
                          ? Get.offAll(() => const LoginScreen())
                          : Get.offAll(() => const mainScreen());
                    },
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
