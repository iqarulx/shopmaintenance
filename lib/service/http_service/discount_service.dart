/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import '../local_storage_service/local_db_config.dart';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class DiscountService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/discount.php");
    return url;
  }

  Future getDiscountList() async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var url = await getDomain();
      var message = await http.post(
        url,
        body: jsonEncode(
          {
            "get_discount": 1,
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

  Future editDiscount({required discountId}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var url = await getDomain();
      var message = await http.post(
        url,
        body: jsonEncode(
          {
            "show_discount_id": discountId,
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

  Future deleteDiscount({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      if (message.statusCode == 200) {
        var response = json.decode(message.body);
        return response;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future updateDiscount({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      if (message.statusCode == 200) {
        var response = json.decode(message.body);
        return response;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future updateFrontEnd({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
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
