/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import '../local_storage_service/local_db_config.dart';
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
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var data = {
        "domain_name": domain,
        "admin_folder_name": adminPath,
        "print_order_id": printOrderID,
        "format": format,
        "type": type,
      };

      var url = await getDomain();

      var message = await http.post(url, body: jsonEncode(data));
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
