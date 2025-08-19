/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class NotificationListModel {
  String? dateTime;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["date_time"] = dateTime;
    return mapping;
  }
}
