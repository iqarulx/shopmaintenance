/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class ScreenAuth extends StatefulWidget {
  const ScreenAuth({super.key});

  @override
  State<ScreenAuth> createState() => _ScreenAuthState();
}

class _ScreenAuthState extends State<ScreenAuth> {
  List<String>? screenList = [
    'Enquiry',
    'Website Status',
    'Company',
    'Settings',
    'Category',
    'Product',
    'Discount',
  ];
  List<String>? selectedScreensList = [];
  bool fingerPrintSelected = true;
  bool cpinSelected = false;

  @override
  void initState() {
    getScreenStatus();
    super.initState();
  }

  getScreenStatus() async {
    var screenList = await LocalDBConfig().getScreenAuth();
    if (screenList != null) {
      selectedScreensList = screenList;
    }
    var authValue = await LocalDBConfig().getAuth();
    if (authValue == 'FingerPrint') {
      fingerPrintSelected = true;
      cpinSelected = false;
    } else {
      fingerPrintSelected = false;
      cpinSelected = true;
    }
    setState(() {});
  }

  submitForm() async {
    var selectedScreens = selectedScreensList;
    var authValue = '';
    if (fingerPrintSelected) {
      authValue = 'FingerPrint';
    } else {
      authValue = 'Cpin';
    }
    futureWaitingLoading();
    Navigator.pop(context);
    await LocalDBConfig().newAuth(auth: authValue);
    await LocalDBConfig().screenAuth(selectedScreens: selectedScreens!);
    showCustomSnackBar(context,
        content: "Screens Updated Successfully", isSuccess: true);
    NotificationService().showNotification(
        title: "Screens Updated", body: "Screens has updated successfully.");
    Future.delayed(const Duration(seconds: 2), () {
      // Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      bottomNavigationBar: bottomAppbar(context),
      body: screenView(),
    );
  }

  ListView screenView() {
    return ListView(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                "Auth Selection",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Fingerprint",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: fingerPrintSelected,
                        onChanged: (value) {
                          setState(() {
                            fingerPrintSelected = value;
                            cpinSelected = !value;
                          });
                        },
                      ),
                    ),
                    const Text(
                      "Cpin",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: cpinSelected,
                        onChanged: (value) {
                          setState(() {
                            setState(() {
                              fingerPrintSelected = !value;
                              cpinSelected = value;
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const Text(
              "Screen Selection",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: screenList!.length,
              itemBuilder: (context, index) {
                String screenName = screenList![index];
                bool isSelected = selectedScreensList!.contains(screenName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            screenName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                selectedScreensList!.add(screenName);
                              } else {
                                selectedScreensList!.remove(screenName);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          submitForm();
        },
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff2F4550),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Submit",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Screen Auth",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
