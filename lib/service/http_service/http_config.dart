/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import '/service/local_storage_service/local_db_config.dart';

class HttpConfig {
  Future<String?> getdomain() async {
    var serverIP = await LocalDBConfig().getServerIP();

    String result = "https://$serverIP/API";
    return result;
  }
}
