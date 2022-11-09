import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserProfileCircleImage extends StatelessWidget {
  const UserProfileCircleImage(
      {Key? key, required this.imageUrl, this.size})
      : super(key: key);

  final String? imageUrl;
  final double? size;

  @override
  Widget build(BuildContext context) {
    File f = File(imageUrl!);
    return ClipOval(
      child: SizedBox.fromSize(
        size: Size.fromRadius(45),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Image.asset(
                "assets/images/default-profile.png",
                width: size,
                fit: BoxFit.fill,
              )
            : imageUrl!.contains('http')
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.fill,
                )
              : imageUrl!.contains('assets/images/default-profile.png')
                ? Image.asset(imageUrl!,width: size, fit: BoxFit.fill,)
                : Image.file(f,width: size, fit: BoxFit.fill,)
            // : Image.file(f,width: size, fit: BoxFit.fill,)
            // : Image.asset(imageUrl!,width: size, fit: BoxFit.fill,)
      ));
  }
}


