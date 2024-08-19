/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '/service/auth_service/auth_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class Cpin extends StatefulWidget {
  const Cpin({super.key});

  @override
  State<Cpin> createState() => _CpinState();
}

class _CpinState extends State<Cpin> {
  TextEditingController cpinController = TextEditingController();
  TextEditingController cpinConfirmController = TextEditingController();
  bool isCreated = false;
  bool isConfirm = false;

  @override
  void initState() {
    AuthService().accountValid(context);
    getPinStatus();
    super.initState();
  }

  getPinStatus() async {
    var cpin = await LocalDBConfig().getCpin();
    if (cpin != null) {
      setState(() {
        cpinController.text = cpin;
        isCreated = true;
      });
    }
  }

  submitPin() async {
    var entredCpin = cpinController.text;
    var confirmCpin = cpinConfirmController.text;

    if (entredCpin.isNotEmpty && confirmCpin.isNotEmpty) {
      if (confirmCpin == entredCpin) {
        await LocalDBConfig().newCpin(cpin: entredCpin).then((value) => {
              showCustomSnackBar(context,
                  content: "Pin Changed Successfully", isSuccess: true),
              NotificationService().showNotification(
                  title: "Pin Updated",
                  body: "Your Pin has updated successfully.")
            });
        Navigator.pop(context);
      } else {
        showCustomSnackBar(context, content: "Pin not match", isSuccess: false);
      }
    } else {
      showCustomSnackBar(context, content: "Invalid CPIN", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appbar(),
        body: isConfirm ? confirmPin() : createUpdatePin());
  }

  Column createUpdatePin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isCreated ? 'Update CPIN' : 'Create CPIN',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Pinput(
                autofocus: true,
                controller: cpinController,
                length: 4,
                defaultPinTheme: PinTheme(
                  height: 45,
                  width: 45,
                  textStyle: const TextStyle(color: Colors.white),
                  decoration: BoxDecoration(
                    color: const Color(0xff2F4550),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: GestureDetector(
            onTap: () async {
              setState(() {
                isConfirm = true;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff586F7C),
                borderRadius: BorderRadius.circular(100),
              ),
              height: 50,
              width: 164,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Center(
                child: Text(
                  "Go",
                  style: TextStyle(
                    color: Color(0xffF4F4F9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Column confirmPin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Confirm CPIN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Pinput(
                autofocus: true,
                controller: cpinConfirmController,
                length: 4,
                defaultPinTheme: PinTheme(
                  height: 45,
                  width: 45,
                  textStyle: const TextStyle(color: Colors.white),
                  decoration: BoxDecoration(
                    color: const Color(0xff2F4550),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isConfirm = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  height: 50,
                  width: 164,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Center(
                    child: Text(
                      "Back",
                      style: TextStyle(
                        color: Color(0xffF4F4F9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () async {
                  submitPin();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff586F7C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  height: 50,
                  width: 164,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Color(0xffF4F4F9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "CPIN",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
