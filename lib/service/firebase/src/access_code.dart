import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '/service/service.dart';

class AccessCode extends FireBaseService {
  static FireBaseService firebase = FireBaseService();

  static String _generateRedeemCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<Map<String, dynamic>> createAccessCode() async {
    try {
      String? deviceid;
      String? brandName;
      String? modelName;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        brandName = androidInfo.brand.toString();
        deviceid = androidInfo.id.toString();
        modelName = androidInfo.model.toString();
      } else if (Platform.isIOS) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        brandName = iosDeviceInfo.name.toString();
        deviceid = iosDeviceInfo.identifierForVendor.toString();
        modelName = iosDeviceInfo.model.toString();
      }
      String code = _generateRedeemCode();
      DocumentReference docRef = await firebase.redeemCode.add({
        'code': code,
        'created_at': DateTime.now(),
        'is_cleared': false,
        'expired_at': DateTime.now().add(const Duration(minutes: 5)),
        'device_id': deviceid,
        'device_name': brandName,
        'model_name': modelName,
      });

      return {"code": code, "doc_id": docRef.id};
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static Future expireCode({required String code}) async {
    try {
      var result =
          await firebase.redeemCode.where('code', isEqualTo: code).get();
      if (result.docs.isNotEmpty) {
        for (var data in result.docs) {
          await firebase.redeemCode.doc(data.id).update({'is_cleared': true});
        }
      }
    } on Exception catch (e) {
      throw e.toString();
    }
  }
}
