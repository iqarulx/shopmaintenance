/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class ProductListingModel {
  String? productId;
  String? productCode;
  String? categoryName;
  String? productName;
  String? actualPrice;
  String? salesPrice;
  String? showFrontend;
  String? creator;
  toMap() {
    var mapping = <String, dynamic>{};
    mapping['product_id'] = productId;
    mapping['product_code'] = productCode;
    mapping['category_name'] = categoryName;
    mapping['product_name'] = productName;
    mapping['actual_price'] = actualPrice;
    mapping['sales_price'] = salesPrice;
    mapping['show_frontend'] = showFrontend;
    mapping['creator'] = creator;
    return mapping;
  }
}

class CategoryListingForProductModel {
  String? categoryId;
  String? categoryName;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping['category_id'] = categoryId;
    mapping['category_name'] = categoryName;
    return mapping;
  }
}

class ProductOrderListingModel {
  String? productId;
  String? productName;
  String? ordering;
  String? price;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping['product_id'] = productId;
    mapping['product_name'] = productName;
    mapping['ordering'] = ordering;
    mapping['price'] = price;
    return mapping;
  }
}

class ProductEditModel {
  String? categoryId;
  String? productName;
  String? productCode;
  String? productContent;
  String? price;
  String? productVideo;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping['category_id'] = categoryId;
    mapping['product_name'] = productName;
    mapping['product_code'] = productCode;
    mapping['price'] = price;
    mapping['product_content'] = productContent;
    mapping['product_video'] = productVideo;
    return mapping;
  }
}

class ExcelPreviewModel {
  String? categoryName;
  List<dynamic>? productList;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping['category_name'] = categoryName;
    mapping['product_list'] = productList;
    return mapping;
  }
}

class PdfPreviewModel {
  String? pdfUrl;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping['pdf_url'] = pdfUrl;
    return mapping;
  }
}
