class CustomNotification {
  late String title;
  late String link;
  late String? center_name;

  CustomNotification({
    required this.title,
    required this.link,
    required this.center_name,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'link': link,
      'center_name': center_name,
    };
  }

  factory CustomNotification.fromJson(Map<String, dynamic> json) {
    return CustomNotification(
      title: json['title'],
      link: json['link'],
      center_name: json['center_name'],
    );
  }

  CustomNotification.fromMap(Map<dynamic, dynamic>? map) {
    title = map?['title'];
    link = map?['link'];
    center_name = map?['center_name'];
  }

  @override
  String toString() {
    return 'Notification ==> '
        '(title: $title, link: $link, center_name: $center_name)';
  }
}
