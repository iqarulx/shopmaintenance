/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/service/service.dart';

class CompanyService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/company.php");
    return url;
  }

  Future getCompanyList() async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var url = await getDomain();

      var message = await http.post(
        url,
        body: json.encode(
          {
            "get_company_list": 1,
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

  Future editCompany({required companyId}) async {
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    try {
      var url = await getDomain();
      var message = await http.post(
        url,
        body: json.encode(
          {
            "show_company_id": companyId,
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

  Future updateCompany({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: json.encode(formData));
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
