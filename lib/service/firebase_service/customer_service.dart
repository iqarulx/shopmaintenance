/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:cloud_firestore/cloud_firestore.dart';

import 'config.dart';

class CustomerService {
  FireBaseService firebase = FireBaseService();
  Future<QuerySnapshot<Map<String, dynamic>>> findPhoneNumber(
      {required String phoneNumber}) async {
    try {
      return await firebase.customer
          .where('mobile', isEqualTo: int.parse(phoneNumber))
          .get()
          .then((result) {
        return result;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> accountValid(
      {required String domain, required String phoneNumber}) async {
    try {
      return await firebase.customer
          .where('domain', isEqualTo: domain)
          .where('mobile', isEqualTo: int.parse(phoneNumber))
          .get()
          .then((result) {
        return result;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future saveOTP(
      {required String domain,
      required String phoneNumber,
      required String sms}) async {
    try {
      return await firebase.customerOTP.add({
        "domain": domain,
        "mobile": phoneNumber,
        "otp": sms,
        "created_at": DateTime.now()
      });
    } catch (e) {
      rethrow;
    }
  }
}
