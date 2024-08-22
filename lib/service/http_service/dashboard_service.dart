/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class DashboardService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/dashboard.php");
    return url;
  }

  Future getDashboardList() async {
    try {
      var url = await getDomain();
      var message =
          await http.post(url, body: jsonEncode({"get_dashboard_list": 1}));
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
