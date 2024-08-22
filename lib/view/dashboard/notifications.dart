/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/notification_model.dart';
import '/service/common_var.dart';
import '/service/http_service/notification_service.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/enquiry/enquiry_listing_view.dart';

class NotificationsList extends StatefulWidget {
  const NotificationsList({super.key});

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  List<NotificationListModel> notificationList = [];
  Future? notificationHandler;

  @override
  void initState() {
    notificationHandler = notificationListView();
    super.initState();
  }

  Future<void> notificationListView() async {
    try {
      setState(() {
        notificationList.clear();
      });

      return await NotificationListService()
          .getNotificationList()
          .then((resultData) async {
        if (resultData.isNotEmpty) {
          if (resultData != null && resultData["head"]["code"] == 200) {
            for (var element in resultData["head"]["msg"]
                ["notification_data"]) {
              NotificationListModel model = NotificationListModel();
              model.dateTime = element["date_time"].toString();
              setState(() {
                notificationList.add(model);
              });
            }
          } else if (resultData["head"]["code"] == 400) {
            showCustomSnackBar(context,
                content: resultData["head"]["msg"].toString(),
                isSuccess: false);
            throw resultData["head"]["msg"].toString();
          }
        } else {
          errorSnackbar(context);
        }
      });
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
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
        appBar: appbar(context),
        body: body(),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: notificationHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return dataLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureNetworkError();
          } else {
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  notificationHandler = notificationListView();
                });
              },
              child: screenView());
        }
      },
    );
  }

  ListView screenView() {
    return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: notificationList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EnquiryListing()));
            },
            child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.notification,
                          color: appbarColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "New Enquiry Received.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat("dd-MM-yyyy hh:mm a").format(
                              DateTime.parse(notificationList[index].dateTime!),
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
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
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        "Notifications",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
