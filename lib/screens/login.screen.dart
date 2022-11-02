import 'package:dongnerang/screens/law/law1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
                  SizedBox(height: size.height / 2.5,),
                  InkWell(
                      onTap: () async {
                        await viewModel.login();
                      },
                      child:
                      Image.asset('assets/images/kakao_login_large_wide.png', width: size.width/1.25,)
                  ),
                  SizedBox(height: 10,),
                  // IconButton(
                  //   onPressed: () async {
                  //     await viewModel.login();
                  //   },
                  //   icon: Image.asset('assets/images/kakao_login_large_wide.png', fit: BoxFit.fill,
                  //   height: size.height,
                  //   width: size.width,),
                  // ),
                  // new Center(
                  //   child: new RichText(
                  //     text: new TextSpan(
                  //       children: [
                  //         new TextSpan(
                  //           text: 'This is no Link, ',
                  //           style: new TextStyle(color: Colors.black),
                  //         ),
                  //         new TextSpan(
                  //           text: 'but this is',
                  //           style: new TextStyle(color: Colors.blue),
                  //           recognizer: new TapGestureRecognizer()
                  //             ..onTap = ()  { launch('https://www.thisplace.kr');
                  //             },
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
            // InkWell(
            //   onTap: () {
            //     Navigator.pushNamed(context, "write your route");
            //   },
            //   child: new Text("Click Here", style: TextStyle(fontWeight: FontWeight.bold)),
            // ),
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

                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => law1Widget(),),);
                  //     },
                  //     child: Text("가입 진행 시 동네랑의 서비스 이용약관, 개인정보 취급방침, 마케팅 정보 수신동의에 동의하신것으로 확인합니다."),
                  // ),
                  // Text("가입 진행 시 동네랑의 서비스 이용약관, 개인정보 취급방침, 마케팅 정보 수신동의에 동의하신것으로 확인합니다."),
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

