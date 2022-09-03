class crawliingModel {
  final String imgLink;
  final String imgLinkA;
  final List<String> imgStatus;
  final String imgStringTitle;

  crawliingModel ({
    required this.imgLink,
    required this.imgLinkA,
    required this.imgStatus,
    required this.imgStringTitle,

  });
  factory crawliingModel.fromJson(Map<String, dynamic> json){
    return crawliingModel(
      imgLink: json['imgLink'] as String,
      imgLinkA: json['imgLinkA'] as String,
      imgStatus: json['imgStatus'] as List<String>,
      imgStringTitle: json['imgStringTitle'] as String,
    );
  }
}
