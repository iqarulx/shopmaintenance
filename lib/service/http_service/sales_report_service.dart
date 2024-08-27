/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import '../local_storage_service/local_db_config.dart';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class SalesReportService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/product_sales_data.php");
    return url;
  }

  Future getSalesList({required formData}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();
    var inputMap = formData;
    inputMap["domain_name"] = domain;
    inputMap["admin_folder_name"] = adminPath;

    try {
      var url = await getDomain();

      var message = await http.post(url, body: jsonEncode(inputMap));
      if (message.statusCode == 200) {
        var response = json.decode(message.body);
        return response;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
