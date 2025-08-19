/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/service/service.dart';

class InitAuthService {
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
      var serverIP = await LocalDBConfig().getServerIP();
      var server = await LocalDBConfig().getServer();

      var authURL = Uri.parse("$server://$serverIP/API/auth.php");

      var message = await http.post(authURL, body: json.encode(data));

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
      var serverIP = await LocalDBConfig().getServerIP();
      var server = await LocalDBConfig().getServer();

      var authURL = Uri.parse("$server://$serverIP/API/auth.php");

      var message = await http.post(authURL, body: json.encode(data));
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
