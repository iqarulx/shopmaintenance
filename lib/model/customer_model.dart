/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class CustomerModel {
  String? customerName;
  String? domain;
  int? mobile;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["customer_name"] = customerName;
    mapping["domain"] = domain;
    mapping["mobile"] = mobile;
    return mapping;
  }
}
