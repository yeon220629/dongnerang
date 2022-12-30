import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdMob extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BannerAdMob();
}

class _BannerAdMob extends State<BannerAdMob> {
  //애드몹 테스트 ID
  String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
  String androidTestId = 'ca-app-pub-3940256099942544/6300978111';

  //애드몹 찐 ID
  String iOSRealId = 'ca-app-pub-3415104781631988/3367223383';
  String androidRealId = 'ca-app-pub-3415104781631988/9379594822';
  BannerAd? banner;

  @override
  void initState() {
    super.initState();
    banner = BannerAd(
      size: AdSize.fullBanner,
      // adUnitId: Platform.isIOS ? iOSRealId : androidRealId,
      adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
      listener: BannerAdListener(),
      request: AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    super.dispose();
    banner?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: banner == null
            ? Container()
            : AdWidget(
                ad: banner!,
              ),
      ),
    );
  }
}
