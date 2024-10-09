class PushNotification {
  final String targetUserId;
  final String notificationTitle;
  final String notificationBody;

  PushNotification({
    required this.targetUserId,
    required this.notificationTitle,
    required this.notificationBody,
  });

  Map<String, dynamic> toJson() {
    return {
      "targetUserId": targetUserId,
      "notificationTitle": notificationTitle,
      "notificationBody": notificationBody,
    };
  }

}