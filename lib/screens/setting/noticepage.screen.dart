import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: Text('공지사항'),
        ),
        body: const MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool _customTileExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        ExpansionTile(
          title: Text('"동네랑"이 드디어 출시되었습니다!'),
          subtitle: Text('22.10.28'),
          children: <Widget>[
            ListTile(title: Text('동네랑은 2명의 개발자와 함께 알리알라리알리아리리모콘트리아')),
          ],
        ),
      ],
    );
  }
}
