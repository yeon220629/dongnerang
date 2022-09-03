import 'package:get/get.dart';

import '../models/app_user.model.dart';
import 'firebase.service.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();
  final currentUser = Rxn<AppUser>();

  @override
  void onInit() {
    getCurrentUser();
    super.onInit();
  }

  Future<void> getCurrentUser() async {
    currentUser.value = await FirebaseService.getCurrentUser();
  }
}