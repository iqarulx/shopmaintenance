/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class DashboardModel {
  String? todayOrdersCount;
  String? todayOrdersAmount;
  String? todayOnlineOrdersCount;
  String? todayOnlineOrdersAmount;
  String? todayOfflineOrdersCount;
  String? todayOfflineOrdersAmount;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["today_orders_count"] = todayOrdersCount;
    mapping["today_orders_amount"] = todayOrdersAmount;
    mapping["today_online_orders_count"] = todayOnlineOrdersCount;
    mapping["today_online_orders_amount"] = todayOnlineOrdersAmount;
    mapping["today_offline_orders_count"] = todayOfflineOrdersCount;
    mapping["today_offline_orders_amount"] = todayOfflineOrdersAmount;
    return mapping;
  }
}
