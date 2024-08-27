/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:package_info/package_info.dart';
import '/service/firebase_service/config.dart';

class GetUpdateFromDB {
  FireBaseService firebase = FireBaseService();

  Future<String?> getUpdate({required String platform}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebase.appVersion
          .orderBy('created', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first.data();

        if (platform == 'android') {
          return doc['playstore_version'];
        } else {
          return doc['appstore_version'];
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

class UpdateService {
  static Future<bool> isUpdateAvailable() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      String? latestVersion;
      if (Platform.isAndroid) {
        latestVersion = await GetUpdateFromDB().getUpdate(platform: 'android');
      } else if (Platform.isIOS) {
        latestVersion = await GetUpdateFromDB().getUpdate(platform: 'ios');
      }

      if (latestVersion != null) {
        if (latestVersion == currentVersion) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
