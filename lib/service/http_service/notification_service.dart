/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:developer';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class NotificationListService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/notification.php");
    return url;
  }

  Future getNotificationList() async {
    try {
      var url = await getDomain();
      var message =
          await http.post(url, body: jsonEncode({"get_notifications": "1"}));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
