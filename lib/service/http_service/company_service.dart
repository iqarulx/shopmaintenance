/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:developer';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class CompanyService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/company.php");
    return url;
  }

  Future getCompanyList() async {
    try {
      var url = await getDomain();
      var message =
          await http.post(url, body: jsonEncode({"get_company_list": 1}));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future editCompany({required companyId}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url,
          body: jsonEncode({"show_company_id": companyId}));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateCompany({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
