import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
                children: [
                  SizedBox(height: size.height / 6.5,),
                  Image.asset('assets/images/logo.png',fit: BoxFit.cover,
                    height: size.height / 11.8,
                  ),
                  SizedBox(height: 10,),
                  const Text(
                    "내가 찾는 우리 동네의 공공소식",
                    style: TextStyle(fontSize: 15, color: AppColors.primary),
                  ),
                  SizedBox(height: 85,),
                  IconButton(
                    onPressed: () async {
                      await viewModel.login();
                    },
                    icon: Image.asset('assets/images/kakao_login_large_wide.png'),iconSize: 300,
                  ),
                  Expanded(child:Lottie.asset(
                    'assets/lottie/24849-driving-car.json',
                    width: size.width,
                    // height: size.height/2,
                    fit: BoxFit.fill,
                  ),)

                  // const SizedBox(height: 20),
                ]),
            ),
        ),
      )
    );
  }
}

