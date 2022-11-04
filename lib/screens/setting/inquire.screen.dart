import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/screens/setting/inquire.googleform.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:core';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/app_appbar_common.widget.dart';

class Inquire extends StatelessWidget {
  const Inquire({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: fnCommnAppbarWidget(title: '동네랑 문의',appBar: AppBar()),
      body: Container(
        color: AppColors.white,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text('동네랑의 궁금한 점을 물어봐주세요.\n피드백도 환영합니다!',
                  style: TextStyle(
                    letterSpacing:2.0,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 25.0,),
            Center(
              child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => inquireGoogleform(),),);
                  },
                // icon: Icon(Icons.question_answer_outlined),
                child: Text('문의 및 피드백'),
                style: TextButton.styleFrom(
                  // backgroundColor: AppColors.primary,
                  // textStyle: TextStyle(fontSize: 16),
                  // textStyle: TextStyle(color: Colors.red),
                  // primary: AppColors.skyBlue,
                  // textStyle: Color(value),
                    // TextStyle(
                    //   fontWeight: FontWeight.bold,
                    //   color: AppColors.black,
                    // )
                  minimumSize: const Size(300, 50),
                  maximumSize: const Size(300, 50),
                  // primary: Colors.bl,
                  // onSurface: Colors.blueAccent, // 비활성화된 버튼 색상도 바꿔줄 수 있음
                )
              ),
            ),
                Expanded(
                  child: Lottie.asset(
                    'assets/lottie/124180-hiworld.json',
                    // width: 10,
                    // height: 10,
                    // fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// class UrlLauncher {
//   final Uri EMAIL = Uri(
//       scheme: 'mailto',
//       path: 'yeon220629@naver.com',
//       queryParameters: {'subject': '문의 드립니다', 'body': '개발자님 안녕하세요?'});
//
//   Future<void> launchURL(url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   Future<void> email() async {
//     if (await canLaunch(EMAIL.toString())) {
//       await launch(EMAIL.toString());
//     } else {
//       throw 'error email';
//     }
//   }
// }

// Future<void> _launchUrl() async {
//   if (!await launchUrl(_url)) {
//     throw 'Could not launch $_url';
//   }
// }
