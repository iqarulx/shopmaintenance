/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import '../local_storage_service/local_db_config.dart';
import '/model/enquiry_model.dart';
import '/service/http_service/http_config.dart';
import 'package:http/http.dart' as http;

class EnquiryService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/enquiry.php");
    return url;
  }

  getDomainOrderStatus() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/order_status.php");
    return url;
  }

  Future getEnquiryAPI({required EnquiryInputModel enquiryInput}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    var inputMap = enquiryInput.toMap();
    inputMap["domain_name"] = domain;
    inputMap["admin_folder_name"] = adminPath;

    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(inputMap));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future setDeliveryStatusAPI({required Map<String, dynamic> data}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var inputMap = data;
      inputMap["domain_name"] = domain;
      inputMap["admin_folder_name"] = adminPath;

      var url = await getDomainOrderStatus();
      var message = await http.post(url, body: jsonEncode(inputMap));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateOrderViewStatus({required String orderID}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var data = {
        "new_order_id": orderID,
        "domain_name": domain,
        "admin_folder_name": adminPath,
      };
      var url = await getDomainOrderStatus();
      var message = await http.post(url, body: jsonEncode(data));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
