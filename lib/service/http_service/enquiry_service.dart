/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:developer';
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
    try {
      log(enquiryInput.toMap().toString());
      var url = await getDomain();
      var message =
          await http.post(url, body: jsonEncode(enquiryInput.toMap()));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future setDeliveryStatusAPI({required Map<String, dynamic> data}) async {
    try {
      // log(enquiryInput.toMap().toString());
      var url = await getDomainOrderStatus();
      var message = await http.post(url, body: jsonEncode(data));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateOrderViewStatus({required String orderID}) async {
    try {
      var data = {
        "new_order_id": orderID,
      };
      // log(enquiryInput.toMap().toString());
      var url = await getDomainOrderStatus();
      var message = await http.post(url, body: jsonEncode(data));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
