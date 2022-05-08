class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.imageUrl
  });

  String? title;
  String? body;
  String? imageUrl;

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json["data"]["title"],
      body: json["data"]["body"],
      imageUrl: json["data"]["image"]
    );
  }
}