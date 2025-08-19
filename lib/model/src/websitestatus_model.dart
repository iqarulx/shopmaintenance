/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class WebsitestatusModel {
  String? disableSite;
  String? enquiryCustomerOrderLink;
  String? enquiryCustomerOrderCode;
  String? disablePageForm;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["disable_site"] = disableSite;
    mapping["enquiry_customer_order_link"] = enquiryCustomerOrderLink;
    mapping["enquiry_customer_order_code"] = enquiryCustomerOrderCode;
    mapping["disable_page_form"] = disablePageForm;
    return mapping;
  }
}
