import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/colors.constants.dart';
import '../models/main_view_model.dart';
import '../services/kakao_login.dart';

final googleSignIn = GoogleSignIn(
  scopes: ['email'],
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final viewModel = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: Column(
            children: [
            const SizedBox(height: 200),
            Image.asset('assets/images/app_logo.png',fit: BoxFit.cover,
              height: size.height / 6.8,
            ),
            const SizedBox(height: 50),
              // const Text(
            //     "동네랑 로고",
            //     style: TextStyle(fontSize: 28, color: AppColors.primary),
            //   ),
           IconButton(
             onPressed: () async {
               await viewModel.login();
             },
             icon: Image.asset('assets/images/kakao_login_large_wide.png'),iconSize: 300,
            ),
            const SizedBox(height: 20),
          ]),
        ),
      )
    );
  }
}

