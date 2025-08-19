import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '/service/service.dart';

class Messaging extends FireBaseService {
  static FireBaseService firebase = FireBaseService();

  static const String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/shop-maintenance/messages:send';

  static Future<Map<String, dynamic>> loadServiceAccount() async {
    var response = await http.get(
      Uri.parse(
          'https://sridemoapps.in/sridemoapps.in/arul2024/credentials/shopmaintenance-service-account.json'),
    );
    if (response.statusCode != 200) {
      throw 'Failed to load service account';
    }
    return json.decode(response.body);
  }

  static Future<String> getAccessToken() async {
    final credentials = await loadServiceAccount();
    var accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  static Future sendMessage(
      {required String fcmId,
      required String title,
      required String body,
      required String redirect,
      required String notificationId}) async {
    try {
      final accessToken = await getAccessToken();

      await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "message": {
            "token": fcmId,
            "notification": {"title": title, "body": body},
            "data": {"redirect": redirect, "notification_id": notificationId},
            "android": {"priority": "high"}
          }
        }),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  static Future sendCodeToAdmin(
      {required String code, required String docId}) async {
    String? brandName;
    String? modelName;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      brandName = androidInfo.brand.toString();
      modelName = androidInfo.model.toString();
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      brandName = iosDeviceInfo.name.toString();
      modelName = iosDeviceInfo.model.toString();
    }
    var admins =
        await firebase.admin.where('type', isEqualTo: 'super_admin').get();
    if (admins.docs.isNotEmpty) {
      for (var admin in admins.docs) {
        var fcmId = admin["fcm_id"];
        if (fcmId != null) {
          await sendMessage(
            title: "Access Code Request - Code : $code",
            body: "Brand Name : $brandName\nModel : $modelName",
            fcmId: fcmId,
            redirect: "accesscode",
            notificationId: docId,
          );
        }
      }
    }
  }
}

Future<String?> getFCM() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  return fcmToken;
}
