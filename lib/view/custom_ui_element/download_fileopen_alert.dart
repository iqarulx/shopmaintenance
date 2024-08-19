/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';

downloadFileSnackBarCustom(context,
    {required bool isSuccess, required String msg, required String path}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      content: Text(
        msg.toString(),
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: "Open",
        onPressed: () async {
          log("path = $path");
          try {
            await OpenFile.open(path);
          } catch (e) {
            log(e.toString());
          }
        },
      ),
    ),
  );
}
