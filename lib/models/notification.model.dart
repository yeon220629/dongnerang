class CustomNotification {
  late String title;
  late String link;
  late String? center_name;
  late String? body;
  late String? registrationdate;

  CustomNotification({
    required this.title,
    required this.link,
    required this.center_name,
    required this.body,
    required this.registrationdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'link': link,
      'center_name': center_name,
      'body': body,
      'registrationdate': registrationdate,
    };
  }

  factory CustomNotification.fromJson(Map<String, dynamic> json) {
    return CustomNotification(
      title: json['title'],
      link: json['link'],
      center_name: json['center_name'],
        body: json['body'],
        registrationdate: json['registrationdate']
    );
  }

  CustomNotification.fromMap(Map<dynamic, dynamic>? map) {
    title = map?['title'];
    link = map?['link'];
    center_name = map?['center_name'];
    body = map?['body'];
    registrationdate = map?['registrationdate'];
  }

  @override
  String toString() {
    return 'Notification ==> '
        '(title: $title, link: $link, center_name: $center_name, body: $body, registrationdate: $registrationdate)';
  }
}
