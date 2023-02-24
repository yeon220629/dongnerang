import 'dart:io';

import 'package:dongnerang/models/space.model.dart';
import 'package:hive/hive.dart';

class HiveBoxes {

  static Box<Space> getHiveSpace() => Hive.box('hiveSpace');
}
