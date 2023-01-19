import 'package:cloud_firestore/cloud_firestore.dart';

class crawliingModel {
  final String result;
  final int number;
  final String center_name;
  final Timestamp registrationdate;
  final String title;
  final String apperiod;

  crawliingModel ({
    required this.result,
    required this.number,
    required this.center_name,
    required this.registrationdate,
    required this.title,
    required this.apperiod,

  });
  factory crawliingModel.fromJson(Map<String, dynamic> json){
    return crawliingModel(
      result: json['result'] as String,
      number: json['number'] as int,
      center_name: json['center_name '] as String,
      registrationdate: json['registrationdate'] as Timestamp,
      title: json['title'] as String,
      apperiod: json['apperiod'] as String,
    );
  }
}
