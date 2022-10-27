import 'package:flutter/material.dart';
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
      body: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('동네랑 고객센터입니다.\n무엇을 도와드릴까요?',
              style: TextStyle(
                letterSpacing:2.0,
                fontSize: 20.0,
                // fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.0,),
        OutlinedButton.icon(
            onPressed: UrlLauncher().email,
          icon: Icon(Icons.question_mark_outlined),
          label: Text('문의하기'),
          style: TextButton.styleFrom(
            minimumSize: Size(300,50),
            // primary: Colors.bl,
            onSurface: Colors.blueAccent, // 비활성화된 버튼 색상도 바꿔줄 수 있음
          ))
          ],
        ),
      ),
    );
  }
}


class UrlLauncher {
  final Uri EMAIL = Uri(
      scheme: 'mailto',
      path: 'yeon220629@naver.com',
      queryParameters: {'subject': '문의 드립니다', 'body': '개발자님 안녕하세요?'});

  Future<void> launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> email() async {
    if (await canLaunch(EMAIL.toString())) {
      await launch(EMAIL.toString());
    } else {
      throw 'error email';
    }
  }
}

// Future<void> _launchUrl() async {
//   if (!await launchUrl(_url)) {
//     throw 'Could not launch $_url';
//   }
// }
