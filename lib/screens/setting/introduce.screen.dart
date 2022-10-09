import 'package:flutter/material.dart';

class Introduce extends StatelessWidget {
  const Introduce({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          // leading: IconButton(
          //     icon: Icon(Icons.arrow_back_ios_new_outlined),
          //     onPressed: () {
          //         Navigator.pop(ctx);
          //     },
          // ),
          title: Text('동네랑 소개'),
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
          title: Text('"서울시 동작구의 소식부터 넓혀지는 "동네랑"'),
          subtitle: Text('22.11.08'),
          children: <Widget>[
            ListTile(title: Text('동네랑은 2명의 개발자와 함께 알리알라리알리아리리모콘트리아')),
          ],
        ),
      ],
    );
  }
}
