/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseService {
  final CollectionReference<Map<String, dynamic>> customer =
      FirebaseFirestore.instance.collection('customer');
  final CollectionReference<Map<String, dynamic>> customerOTP =
      FirebaseFirestore.instance.collection('customer_otp');
  final CollectionReference<Map<String, dynamic>> domainList =
      FirebaseFirestore.instance.collection('domain_list');
  final CollectionReference<Map<String, dynamic>> appVersion =
      FirebaseFirestore.instance.collection('app_version');
}
