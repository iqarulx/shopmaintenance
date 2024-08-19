/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:developer';
import '/provider/pin_provider.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class LocalAuthConfig {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> checkBiometrics(BuildContext context, String screen) async {
    final authValue = await LocalDBConfig().getAuth();
    final authScreen = await LocalDBConfig().getScreenAuth();
    final cpin = await LocalDBConfig().getCpin();

    if (authScreen != null && authScreen.contains(screen)) {
      try {
        if (authValue != null) {
          if (authValue == 'FingerPrint') {
            if (await auth.canCheckBiometrics) {
              return authenticate();
            } else {
              return false;
            }
          } else {
            if (cpin != null) {
              return PinProvider().openPinInput(context);
            } else {
              showCustomSnackBar(context,
                  content: "Please set cpin first", isSuccess: false);
              return false;
            }
          }
        } else {
          showCustomSnackBar(context,
              content: "Please set pin or fingerprint", isSuccess: false);
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authendicate to submit data',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      log('Error during authentication: $e');
      authenticated = false;
    }
    return authenticated;
  }
}
