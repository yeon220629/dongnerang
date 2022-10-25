import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

final Uri _url = Uri.parse('https://moored-adasaurus-5d6.notion.site/bbdd58432e9d4f95a0863e691bffe61d');

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
      // body: _launchUrl, [문제인 곳!!!!!]
      // async {
      //   final url = Uri.parse(
      //     'https://dev-yakuza.posstree.com/en/',
      //   );
      //   if (await canLaunchUrl(url)) {
      //     launchUrl(url);
      //   } else {
      //     // ignore: avoid_print
      //     print("Can't launch $url");
      //   }
      // },,
    );
  }
}

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
}



// notion() async {
//   String url = "https://moored-adasaurus-5d6.notion.site/bbdd58432e9d4f95a0863e691bffe61d";
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     Get.snackbar('연결 실패', '어디어디로\n문의 부탁드립니다.',
//         duration: Duration(seconds: 10), backgroundColor: Colors.white);
//   }
// }
// class MyStatefulWidget extends StatefulWidget {
//   const MyStatefulWidget({super.key});
//
//   @override
//   State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
// }
//
// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   bool _customTileExpanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: const <Widget>[
//         ExpansionTile(
//           title: Text('"동네랑"이 드디어 출시되었습니다!'),
//           subtitle: Text('22.10.28'),
//           children: <Widget>[
//             ListTile(title: Text('동네랑은 2명의 개발자와 함께 알리알라리알리아리리모콘트리아')),
//           ],
//         ),
//       ],
//     );
//   }
// }
