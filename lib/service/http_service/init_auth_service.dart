/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'package:shopmaintenance/service/local_storage_service/local_db_config.dart';

import '/service/http_service/http_config.dart';
import 'package:http/http.dart' as http;

class InitAuthService extends HttpConfig {
  Uri? _authURL;

  InitAuthService() {
    getDomain();
  }

  getDomain() async {
    var data = await super.getdomain();
    _authURL = Uri.parse("$data/auth.php");
  }

  Future checkLogin(
      {required String phoneno,
      required String password,
      required String fcmID}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var data = {
        "domain_name": domain,
        "admin_folder_name": adminPath,
        "mobile_number": phoneno,
        "password": password,
        "fcm_id": fcmID,
      };

      var message = await http.post(_authURL!, body: jsonEncode(data));

      if (message.statusCode == 200) {
        var response = json.decode(message.body);
        return response;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future getMemberID({required String phoneno, required String fcmID}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();
    try {
      var data = {
        "domain_name": domain,
        "admin_folder_name": adminPath,
        "user_mobile_number": phoneno,
        "fcm_id": fcmID,
      };

      var message = await http.post(_authURL!, body: jsonEncode(data));
      if (message.statusCode == 200) {
        var response = json.decode(message.body);
        return response;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
