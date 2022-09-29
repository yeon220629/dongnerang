import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
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
                const SizedBox(height: 175),
                const Text(
                    "동네랑 로고",
                    style: TextStyle(fontSize: 28, color: AppColors.primary),
                  ),
                const SizedBox(height: 325),
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return IconButton(iconSize: size.height * 0.1,onPressed: () async {
                        await viewModel.login();
                        setState(() {});
                      }, icon: Image.asset('assets/images/kakao_login_large_wide.png'));
                    }
                    return IconButton(
                      iconSize: size.height * 0.1,
                      onPressed: () async {

                      },
                      icon: Image.asset('assets/images/kakao_login_large_wide.png'));
                  }
                ),
              const SizedBox(height: 20),
            ]),
          ),
        ));
  }
}

