/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:developer';
import '/service/http_service/http_config.dart';
import 'package:http/http.dart' as http;

class EnquiryPDFService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/print_out.php");
    return url;
  }

  Future getEnquiryPDFAPI(
      {required String printOrderID,
      required String format,
      required String type}) async {
    try {
      var data = {
        "print_order_id": printOrderID,
        "format": format,
        "type": type,
      };
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(data));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
