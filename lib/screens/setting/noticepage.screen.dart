import 'package:dongnerang/constants/colors.constants.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_appbar_common.widget.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: fnCommnAppbarWidget(title: '공지사항',appBar: AppBar()),
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
          title: Text('"동네랑"이 드디어 출시되었습니다!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),),
          subtitle: Text('22.11.5'),
          children: <Widget>[
            ListTile(title: Text('앞으로 동네의 공공소식뿐만 아니라, 동네에서 일어나는 많은 일들을 접할 수 있게 하는 동네랑이 되겠습니다.')),
          ],
        ),
      ],
    );
  }
}
