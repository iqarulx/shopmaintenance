/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:firebase_auth/firebase_auth.dart';
import '../../view/custom_ui_element/show_custom_snackbar.dart';
import 'config.dart';

class OTPService {
  FireBaseService firebase = FireBaseService();
  Future sendOTP(context,
      {required String phoneNumber,
      required void Function(String, int?) codeSent,
      required void Function(PhoneAuthCredential) verificationCompleted,
      required int? forceResendingToken}) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          print("Failed to logon: ${e.message}");
          showCustomSnackBar(context,
              content: e.message.toString(), isSuccess: false);
        },
        forceResendingToken: forceResendingToken,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future updateDeviceInfo(
      {required String deviceID,
      required String modelName,
      required String brandName,
      required String docID}) async {
    try {
      return await firebase.customer.doc(docID).update({
        "device.brand_name": brandName,
        "device.device_id": deviceID,
        "device.model_no": modelName,
      });
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

  Future<UserCredential> verifyOTP(
      {required String verificationId, required String smsCode}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
