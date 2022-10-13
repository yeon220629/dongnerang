import 'package:dongnerang/screens/setting/introduce.screen.dart';
import 'package:flutter/material.dart';
import 'package:dongnerang/screens/noticepage.screen.dart';
import 'package:dongnerang/screens/notification.screen.dart';
import 'setting/inquire.screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
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
                  MaterialPageRoute(builder: (context) => NotificationScreen(),),);
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Introduce(),),);
              },
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

