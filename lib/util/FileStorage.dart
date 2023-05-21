import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class FileStorage extends GetxController {
  late FirebaseStorage storage; //= FirebaseStorage.instance; //storage instance
  late Reference storageRef; //= storage.ref().child(''); //storage

  FileStorage() {
    storage = FirebaseStorage.instance;
  }

  Future<String> uploadFile(String? filePath, String uploadPath) async {
    File file = File(filePath!);
    try {
      storageRef = storage.ref(uploadPath);
      await storageRef.putFile(file);
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      return '-1';
    }
  }
}