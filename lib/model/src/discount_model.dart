/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class DiscountListingModel {
  String? discountId;
  String? discount;
  String? showFrontend;
  String? creator;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["discount_id"] = discountId;
    mapping["discount"] = discount;
    mapping["show_frontend"] = showFrontend;
    mapping["creator"] = creator;
    return mapping;
  }
}

class DiscountEditingModel {
  String? discountId;
  String? discount;
  List<dynamic>? categoryIds;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["discount_id"] = discountId;
    mapping["discount"] = discount;
    mapping["category_ids"] = categoryIds;
    return mapping;
  }
}

class CategoryListingForDiscountModel {
  String? categoryId;
  String? categoryName;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["category_id"] = categoryId;
    mapping["category_name"] = categoryName;
    return mapping;
  }
}
