import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/colors.constants.dart';
import '../screens/mainScreenBar.dart';
import '../services/firebase.service.dart';

class fnCommnAppbarCallback extends StatelessWidget implements PreferredSizeWidget {
  const fnCommnAppbarCallback({
    required this.appBar,
    required this.title,
    this.center = false,
    required this.email,
    required this.ListData,
    required this.keyName,
  });

  final AppBar appBar;
  final String title;
  final bool center;
  final String email;
  final List ListData;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: AppColors.black,
      ),
      backgroundColor: AppColors.white,
      centerTitle: true,
      elevation: 0.0,
      title: Text('$title', style: TextStyle(color: AppColors.black),),
      actions: [
        TextButton(onPressed: (){
          FirebaseService.savePrivacyProfile(email, ListData, keyName);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (BuildContext context) =>
                  mainScreen()), (route) => false);
        }, child: Text("완료", style: TextStyle(color: AppColors.black),))
      ],
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}

class fnCommnAppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const fnCommnAppbarWidget({
    required this.appBar,
    required this.title,
  });

  final AppBar appBar;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: AppColors.black,
      ),
      backgroundColor: AppColors.white,
      centerTitle: true,
      elevation: 0.0,
      title: Text('$title', style: TextStyle(color: AppColors.black),),
      actions: [
      ],
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}