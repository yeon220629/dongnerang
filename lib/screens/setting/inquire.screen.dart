import 'package:flutter/material.dart';


class Inquire extends StatelessWidget {
  const Inquire({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text('동네랑 문의'),
      ),
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
          onPressed: (){}, // null값을 주면 비활성화 된다.
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
