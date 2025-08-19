/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class CategoryListingModel {
  String? categoryId;
  String? name;
  String? showFrontend;
  String? creator;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["category_id"] = categoryId;
    mapping["name"] = name;
    mapping["show_frontend"] = showFrontend;
    mapping["creator"] = creator;
    return mapping;
  }
}

class CategoryEditingModel {
  String? companyId;
  String? name;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["company_id"] = companyId;
    mapping["name"] = name;
    return mapping;
  }
}
