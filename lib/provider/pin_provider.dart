/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class PinProvider {
  Future<bool> openPinInput(BuildContext context) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const PinInputForm();
      },
    );
  }
}

class PinInputForm extends StatefulWidget {
  const PinInputForm({Key? key}) : super(key: key);

  @override
  State<PinInputForm> createState() => _PinInputFormState();
}

class _PinInputFormState extends State<PinInputForm> {
  TextEditingController cpinController = TextEditingController();

  Future<bool> verifyPin(String inputPin) async {
    var localPin = await LocalDBConfig().getCpin();
    if (inputPin.length == 4) {
      if (inputPin == localPin.toString()) {
        showCustomSnackBar(context, content: "Pin Verified", isSuccess: true);
        return true;
      } else {
        showCustomSnackBar(context, content: "Incorrect Pin", isSuccess: false);
      }
    } else {
      showCustomSnackBar(context, content: "Invalid Pin", isSuccess: false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                splashRadius: 20,
                constraints: const BoxConstraints(
                  maxWidth: 40,
                  maxHeight: 40,
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            "Enter CPIN to submit data",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  bool pinVerified = await verifyPin(cpinController.text);
                  if (pinVerified) {
                    Navigator.pop(context, true);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
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
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
