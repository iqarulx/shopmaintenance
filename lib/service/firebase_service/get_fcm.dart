/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFCM() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  return fcmToken;
}
