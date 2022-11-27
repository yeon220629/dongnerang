import 'dart:io';

import 'package:dongnerang/screens/law/law1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import '../constants/colors.constants.dart';
import '../models/main_view_model.dart';
import '../services/kakao_login.dart';
import 'package:flutter/gestures.dart';

import 'law/law2.dart';
import 'law/law3.dart';

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
            //   child:
            // Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Column(
                children: [
                  SizedBox(height: size.height / 6.5,),
                  Image.asset('assets/images/logo.png',fit: BoxFit.cover,
                    height: size.height / 11.8,
                  ),
                  SizedBox(height: 8,),
                  const Text(
                    "내가 찾는 우리 동네의 공공소식",
                    style: TextStyle(fontSize: 15, color: AppColors.primary),
                  ),
                  SizedBox(height: size.height / 3.0,),
                  InkWell(
                      onTap: () async {
                        await viewModel.login();
                      },
                      child:
                      Image.asset('assets/images/kakao_login_large_wide.png', width: size.width/1.25,)
                  ),
                  SizedBox(height: size.height / 50,),
                  InkWell(
                    onTap: () {
                      if (Platform.isAndroid) {
                        Get.snackbar('애플 로그인 오류', '현재 안드로이드 기기에서 \n애플 로그인은 지원되지 않습니다.', snackPosition: SnackPosition.BOTTOM);
                      } else if (Platform.isIOS) {
                        Get.snackbar("애플 로그인", "현재 기기는 애플입니다.", snackPosition: SnackPosition.BOTTOM);
                        // signInWithApple();
                      }
                    },
                    child: Container(
                      width: size.width * 0.8,
                      height: size.height / 16.5,
                      child: Image.asset("assets/images/appleid_button_text@2x.png"),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                    child: RichText(
                      text: TextSpan(
                        text: '가입 진행 시 동네랑의 ', style: TextStyle(color: Colors.black54),
                        children: <TextSpan>[
                          TextSpan(text: '서비스 이용약관,',
                            style: TextStyle(color: AppColors.primary),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => law1Widget(),),);
                              },
                          ),
                          TextSpan(text: ' 개인정보 취급방침,', style: TextStyle(color: AppColors.primary),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => law2Widget(),),);
                              },),
                          TextSpan(text: ' 마케팅 정보 수신동의', style: TextStyle(color: AppColors.primary),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => law3Widget(),),);
                              },),
                          TextSpan(text: '에 동의하신것으로 확인합니다.', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: 10,),
                  SizedBox(height: size.height/20,),
                  Expanded(child:Lottie.asset(
                    'assets/lottie/24849-driving-car.json',
                    width: size.width,
                    // height: size.height,
                    height: size.height,
                    fit: BoxFit.fill,
                  ),)

                  // const SizedBox(height: 20),
                ]),
            // ),
          ),
        )
    );
  }
}

