/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:developer';
import 'http_config.dart';
import 'package:http/http.dart' as http;

class ProductService extends HttpConfig {
  getDomain() async {
    var data = await super.getdomain();
    var url = Uri.parse("$data/product.php");
    return url;
  }

  Future getProductList({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      log(response.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future editProduct({required productId}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url,
          body: jsonEncode({"show_product_id": productId}));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateProduct({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateFrontEnd({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getProductOrder({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateProductOrder({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateProductPrice({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateProductSalesPrice({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future deleteProduct({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getExcelPreview({required formData}) async {
    try {
      var url = await getDomain();
      var message = await http.post(url, body: jsonEncode(formData));
      var response = json.decode(message.body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getPdfPreview({required formData}) async {
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
