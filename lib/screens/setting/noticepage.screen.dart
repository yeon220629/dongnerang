import 'package:dongnerang/constants/colors.constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ExpansionTile(
            title: Text('"동네랑"이 출시했어요!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),),
            subtitle: Text('23.1.1'),
            children: <Widget>[
              Lottie.asset(
                'assets/lottie/112431-3d-success.json',
                // width: 10,
                // height: 10,
                fit: BoxFit.fill,
              ),
              ListTile(title:
              Text('앞으로 내가 찾는 우리 동네의 공공소식뿐만 아니라,\n'
                  '동네에서 일어나는 다양한 소식들을 쉽게 접할 수 있게 하는 \'동네랑\'이 되겠습니다.\n\n'
                  '* 현재는 서울시의 소식들만 전달하고 있습니다.')),
            ],
          ),
        ],
      ),
    );
  }
}
