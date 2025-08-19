/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/service/service.dart';

class SettingsService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/settings.php");
    return url;
  }

  Future getSettings() async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var url = await getDomain();
      var message = await http.post(
        url,
        body: json.encode(
          {
            "get_settings": 1,
            "domain_name": domain,
            "admin_folder_name": adminPath,
          },
        ),
      );
      if (message.statusCode == 200) {
        var response = json.decode(message.body);
        return response;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future updateSettings({required Map<String, dynamic> formData}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();
    var inputMap = formData;
    inputMap["domain_name"] = domain;
    inputMap["admin_folder_name"] = adminPath;

    try {
      var url = await getDomain();
      var response = await http.post(
        url,
        body: json.encode(inputMap),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
