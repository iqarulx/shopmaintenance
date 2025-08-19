/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class SalesReportModel {
  String? productId;
  String? productName;
  String? quantity;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["product_id"] = productId;
    mapping["product_name"] = productName;
    mapping["quantity"] = quantity;
    return mapping;
  }
}

class SalesReportPieModel {
  SalesReportPieModel(this.xData, this.yData, [this.text]);
  final String xData;
  final num yData;
  String? text;
}
