/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:developer';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class SettingsService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/settings.php");
    return url;
  }

  Future getSettings() async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode({"get_settings": 1}));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateSettings({required Map<String, dynamic> formData}) async {
    try {
      var url = await getDomain();
      var response = await http.post(
        url,
        body: jsonEncode(formData),
      );

      return response.body;
    } catch (e) {
      rethrow;
    }
  }
}
