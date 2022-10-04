import 'package:flutter/material.dart';
import 'package:dongnerang/screens/noticepage.screen.dart';
import 'notification.screen.dart';
import 'inquire.screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
        title: Text('설정'),
      ),
      body: ListView(
        children: <Widget>[
     ListTile(
          leading: Icon(Icons.info_outline_rounded),
          title: Text('공지사항'),
          onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoticePage(),),);
            },
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
            leading:  Icon(Icons.notifications_none_outlined),
            title: Text('알림 설정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(),),);
              },
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
            leading:  Icon(Icons.mode_comment_outlined),
            title: Text('동네랑 문의'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Inquire(),),);
              },
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
            leading: Icon(Icons.perm_device_info),
            title: Text('동네랑 소개'),
            trailing:Icon(Icons.arrow_forward_ios_outlined),
        ),
      ListTile(
          leading:  Icon(Icons.star_border_outlined),
          title: Text('현재버전 1.1'),
        ),
        ],
      )
    );
  }
}