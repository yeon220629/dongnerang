import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/colors.constants.dart';

class noticemainpage extends StatefulWidget {
  const noticemainpage({Key? key}) : super(key: key);

  @override
  State<noticemainpage> createState() => _noticemainpageState();
}

class _noticemainpageState extends State<noticemainpage> {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    final double categoryHeight = size.height * 0.30;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: AppColors.black
        ),
      ),
    );
  }
}
