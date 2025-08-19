/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import '/service/service.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class OTPService {
  FireBaseService firebase = FireBaseService();

  Future<int> sendOTP(context, {required String phoneNumber}) async {
    try {
      var otp = Random().nextInt(1000000).toString().padLeft(6, '0');
      var url = 'https://www.fast2sms.com/dev/bulkV2';

      var params = {
        "sender_id": "SRISOF",
        "message": "131030",
        "variables_values": otp,
        "route": "dlt",
        "numbers": phoneNumber
      };

      var response = await http.post(
        Uri.parse(url),
        body: json.encode(params),
        headers: {
          "Authorization":
              "VFxWy81QjDk3S2b6qo0JRNHaYCcZs4nmA5Xl7KMuGtwpTIPiUBV6LM5aSg7x84mfP2XyJtshdoFGEBrK",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        return int.parse(otp);
      } else {
        throw "Failed to send OTP";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateDeviceInfo(
      {required String deviceID,
      required String modelName,
      required String brandName,
      required String docID}) async {
    try {
      var isTestMode = await LocalDBConfig().checkTestMode();
      if (!isTestMode) {
        return await firebase.customer.doc(docID).update({
          "device.brand_name": brandName,
          "device.device_id": deviceID,
          "device.model_no": modelName,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future updateLoginTimeByDomain(
      {required DateTime loginTime, required String? domain}) async {
    try {
      var querySnapshot =
          await firebase.customer.where('domain', isEqualTo: domain).get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        var docRef = firebase.customer.doc(doc.id);
        await docRef.update({
          "last_login": loginTime,
        });
      } else {
        throw "User not found";
      }
    } catch (e) {
      rethrow;
    }
  }
}
