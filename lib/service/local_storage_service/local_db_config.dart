/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:shared_preferences/shared_preferences.dart';

class LocalDBConfig {
  Future<SharedPreferences> connectLocalDb() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> checkLogin() async {
    var connection = await connectLocalDb();
    bool? result = connection.getBool('login');
    if (result == null) {
      return false;
    } else {
      return result;
    }
  }

  Future newUserLogin(
      {required String phoneNumber,
      required String domain,
      required String memberID,
      required String expiryDate}) async {
    var connection = await connectLocalDb();
    connection.setString('phone', phoneNumber);
    connection.setString('member_id', memberID);
    connection.setString('domain', domain);
    connection.setString('expiry_date', expiryDate);
    connection.setBool('login', true);
    connection.setBool('view_demo_enquiry', false);
    connection.setBool('view_demo_product_sales', false);
    connection.setBool('view_demo_company', false);
    connection.setBool('view_demo_settings', false);
    connection.setBool('view_demo_category', false);
    connection.setBool('view_demo_product', false);
    connection.setBool('view_demo_discount', false);
    connection.setBool('view_demo_screen_auth', false);
  }

  Future setDomain({required String domain}) async {
    var connection = await connectLocalDb();
    connection.setString('domain', domain);
  }

  Future<String?> getExpiry() async {
    var connection = await connectLocalDb();
    return connection.getString('expiry_date');
  }

  Future newCpin({required String cpin}) async {
    var connection = await connectLocalDb();
    connection.setString('cpin', cpin);
  }

  Future<String?> getCpin() async {
    var connection = await connectLocalDb();
    return connection.getString('cpin');
  }

  Future newAuth({required String auth}) async {
    var connection = await connectLocalDb();
    connection.setString('auth', auth);
  }

  Future<String?> getAuth() async {
    var connection = await connectLocalDb();
    return connection.getString('auth');
  }

  Future screenAuth({required List<String> selectedScreens}) async {
    var connection = await connectLocalDb();
    connection.setStringList('screen_auth', selectedScreens);
  }

  Future<List<String>?> getScreenAuth() async {
    var connection = await connectLocalDb();
    return connection.getStringList('screen_auth');
  }

  Future<String?> getdomain() async {
    var connection = await connectLocalDb();
    return connection.getString('domain');
  }

  Future<String?> getUserID() async {
    var connection = await connectLocalDb();
    return connection.getString('member_id');
  }

  Future<String?> getPhone() async {
    var connection = await connectLocalDb();
    return connection.getString('phone');
  }

  Future<bool> logoutUser() async {
    var connection = await connectLocalDb();
    connection.clear();
    return true;
  }

  Future resetDemoScreenAuth() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_screen_auth', false);
  }

  Future setDemoScreenAuth() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_screen_auth', true);
  }

  Future<bool?> getDemoScreenAuth() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_screen_auth');
  }

  Future resetDemoDiscount() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_discount', false);
  }

  Future setDemoDiscount() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_discount', true);
  }

  Future<bool?> getDemoDiscount() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_discount');
  }

  Future resetDemoProduct() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_product', false);
  }

  Future setDemoProduct() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_product', true);
  }

  Future<bool?> getDemoProduct() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_product');
  }

  Future resetDemoCategory() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_category', false);
  }

  Future setDemoCategory() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_category', true);
  }

  Future<bool?> getDemoCategory() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_category');
  }

  Future resetDemoSettings() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_settings', false);
  }

  Future setDemoSettings() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_settings', true);
  }

  Future<bool?> getDemoSettings() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_settings');
  }

  Future resetDemoCompany() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_company', false);
  }

  Future setDemoCompany() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_company', true);
  }

  Future<bool?> getDemoCompany() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_company');
  }

  Future resetDemoProductSales() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_product_sales', false);
  }

  Future setDemoProductSales() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_product_sales', true);
  }

  Future<bool?> getDemoProductSales() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_product_sales');
  }

  Future resetDemoEnquiry() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_enquiry', false);
  }

  Future setDemoEnquiry() async {
    var connection = await connectLocalDb();
    connection.setBool('view_demo_enquiry', true);
  }

  Future<bool?> getDemoEnquiry() async {
    var connection = await connectLocalDb();
    return connection.getBool('view_demo_enquiry');
  }
}
