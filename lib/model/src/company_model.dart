/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class CompanyListingModel {
  String? companyId;
  String? name;
  String? creator;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["company_id"] = companyId;
    mapping["name"] = name;
    mapping["creator"] = creator;
    return mapping;
  }
}

class CompanyEditingModel {
  String? companyId;
  String? name;
  String? logo;
  String? address;
  String? whatsappNumber;
  String? callUsNumber;
  String? contactNumber1;
  String? contactNumber2;
  String? contactNumber3;
  String? mobileNumber;
  String? email;
  String? acName;
  String? acNumber;
  String? acType;
  String? bankName;
  String? ifscCode;
  String? runningText;
  String? runningTextBackColor;
  String? runningTextColor;
  String? runningTextDuration;
  String? orderPrefix;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["company_id"] = companyId;
    mapping["name"] = name;
    mapping["logo"] = logo;
    mapping["address"] = address;
    mapping["whatsapp_number"] = whatsappNumber;
    mapping["call_us_number"] = callUsNumber;
    mapping["contact_number1"] = contactNumber1;
    mapping["contact_number2"] = contactNumber2;
    mapping["contact_number3"] = contactNumber3;
    mapping["mobile_number"] = mobileNumber;
    mapping["email"] = email;
    mapping["ac_name"] = acName;
    mapping["ac_number"] = acNumber;
    mapping["ac_type"] = acType;
    mapping["bank_name"] = bankName;
    mapping["ifsc_code"] = ifscCode;
    mapping["running_text"] = runningText;
    mapping["running_text_back_color"] = runningTextBackColor;
    mapping["running_text_color"] = runningTextColor;
    mapping["running_text_duration"] = runningTextDuration;
    mapping["order_prefix"] = orderPrefix;
    return mapping;
  }
}
