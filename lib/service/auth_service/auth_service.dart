/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/service/firebase_service/customer_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/auth/login.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class AuthService {
  Future accountValid(context) async {
    try {
      await LocalDBConfig().getPhone().then((value) async {
        var domain = await LocalDBConfig().getdomain();
        if (value != null) {
          await CustomerService()
              .accountValid(domain: domain!, phoneNumber: value)
              .then((dataResult) async {
            if (dataResult.docs.isNotEmpty) {
              if (dataResult.docs.first["block_At"] == false) {
                log("Account Not Bloacked");
                Timestamp timestamp = dataResult.docs.first["expiry_date"];
                DateTime dateTime = timestamp.toDate();
                if (DateTime.now().isBefore(dateTime)) {
                  if (dataResult.docs.first["device"]["device_id"] == null &&
                      dataResult.docs.first["device"]["brand_name"] == null &&
                      dataResult.docs.first["device"]["model_no"] == null) {
                    logoutFn(context);
                    log("First time This Account was Login");
                  }
                } else {
                  logoutFn(context);
                }
              } else {
                logoutFn(context);
              }
            } else {
              logoutFn(context);
            }
          });
        }
      });
    } catch (e) {
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  logoutFn(context) async {
    try {
      await LocalDBConfig().logoutUser().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
        showCustomSnackBar(context,
            content: "Security reasons for your account logout",
            isSuccess: false);
      });
    } catch (e) {
      rethrow;
    }
  }
}
