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
    return result ?? false;
  }

  Future<int> checkLoginAttempts() async {
    // Assume connectLocalDb() returns an object with methods to get data
    var connection = await connectLocalDb();

    // Fetch the timestamp when the device was blocked
    String? deviceBlocked = connection.getString('device_block_at');

    if (deviceBlocked == null) {
      // Device is not blocked, so return the number of login attempts
      int? result = connection.getInt('login_attempts');
      return result ?? 0;
    } else {
      // Device is blocked, check if the block period has expired
      var deviceBlockedTime = DateTime.parse(deviceBlocked);
      var now = DateTime.now();
      var blockEndTime = deviceBlockedTime.add(const Duration(hours: 24));

      if (now.isBefore(blockEndTime)) {
        // Reset value to zero
        await connection.setInt('login_attempts', 0);
        // Device is still within the block period, return a blocked status
        return 5; // Or any value that represents a blocked status
      } else {
        // Block period is over, clear the block and return the login attempts
        await connection.remove('device_block_at');
        int? result = connection.getInt('login_attempts');
        return result ?? 0;
      }
    }
  }

  Future addLoginAttempt() async {
    // Get previous attempt count
    var previousAttempts = await LocalDBConfig().checkLoginAttempts();
    var connection = await connectLocalDb();
    if (previousAttempts == 5) {
      await LocalDBConfig().blockDevice(); // Block the device
    } else {
      return connection.setInt('login_attempts', previousAttempts + 1);
    }
  }

  Future blockDevice() async {
    var connection = await connectLocalDb();
    return connection.setString('device_block_at', DateTime.now().toString());
  }

  Future getblockDevice() async {
    var connection = await connectLocalDb();
    return connection.getString('device_block_at');
  }

  Future newUserLogin({
    required String phoneNumber,
    required String domain,
    required String memberID,
    required String expiryDate,
  }) async {
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

  Future setDomain({
    required String domain,
    required String adminPath,
    required String serverIP,
  }) async {
    var connection = await connectLocalDb();
    connection.setString('domain', domain);
    connection.setString('admin_path', adminPath);
    connection.setString('server_ip', serverIP);
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

  Future<String?> getAdminPath() async {
    var connection = await connectLocalDb();
    return connection.getString('admin_path');
  }

  Future<String?> getServerIP() async {
    var connection = await connectLocalDb();
    return connection.getString('server_ip');
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
