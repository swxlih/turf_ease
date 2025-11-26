import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<void> sendNotificationToAllUsers(String title, String body) async {
  // Load the service account key from assets
  final serviceAccountString =
      await rootBundle.loadString('assets/service/service-account.json');
  final serviceAccountJson = json.decode(serviceAccountString);

  final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

  // Authorize using OAuth2
  final client = await clientViaServiceAccount(
    credentials,
    ['https://www.googleapis.com/auth/firebase.messaging'],
  );

  final String projectId = serviceAccountJson['project_id'];

  // v1 Endpoint
  final url = Uri.parse(
      "https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

  // Create the notification message
  final message = {
    "message": {
      "topic": "all_users",
      "notification": {
        "title": title,
        "body": body,
      }
    }
  };

  // Send the request
  final response = await client.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(message),
  );

  print("Notification Response: ${response.body}");
}
