/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/dashboard_model.dart';
import '/service/auth_service/auth_service.dart';
import '/service/http_service/dashboard_service.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/menu_list.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/dashboard/notifications.dart';
import '/view/enquiry/enquiry_listing_view.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<DashboardModel> dashboardList = [];
  Future? dashboardHandler;

  @override
  void initState() {
    AuthService().accountValid(context);
    dashboardHandler = dashboardListView();
    super.initState();
  }

  Future<void> dashboardListView() async {
    try {
      setState(() {
        dashboardList.clear();
      });

      return await DashboardService()
          .getDashboardList()
          .then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var element in resultData["head"]["msg"]) {
            DashboardModel model = DashboardModel();
            model.todayOrdersCount = element["today_orders_count"].toString();
            model.todayOrdersAmount = element["today_orders_amount"].toString();
            model.todayOnlineOrdersCount =
                element["today_online_orders_count"].toString();
            model.todayOnlineOrdersAmount =
                element["today_online_orders_amount"].toString();
            model.todayOfflineOrdersCount =
                element["today_offline_orders_count"].toString();
            model.todayOfflineOrdersAmount =
                element["today_offline_orders_amount"].toString();
            setState(() {
              dashboardList.add(model);
            });
          }
        } else if (resultData["head"]["code"] == 400) {
          showCustomSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
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

  showMenuSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const MenuList();
      },
    );
  }

  showNotificationSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const NotificationsList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
      floatingActionButton: floatingButton(),
    );
  }

  FloatingActionButton floatingButton() {
    return FloatingActionButton(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xff586F7C),
      shape: const CircleBorder(),
      onPressed: () {
        showMenuSheet();
      },
      child: const Icon(CupertinoIcons.list_bullet),
    );
  }

  ListView screenView() {
    return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: dashboardList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Quick Info",
              //       style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              //           color: Colors.black,
              //           fontWeight: FontWeight.bold,
              //           fontSize: 18),
              //     ),
              //     const SizedBox(
              //       height: 5,
              //     ),
              //     Text(
              //       "Today(${DateFormat("dd-MM-yyyy").format(DateTime.now())})",
              //       style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              //           color: Colors.grey,
              //           fontWeight: FontWeight.bold,
              //           fontSize: 16),
              //     ),
              //   ],
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Container(
              //       width: double.infinity,
              //       height: 100,
              //       decoration: BoxDecoration(
              //         gradient: const LinearGradient(
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight,
              //           colors: [
              //             Color(0xff7FDBDA),
              //             Color(0xffADE498),
              //             Color(0xffEDE682),
              //             Color(0xffFEBF63)
              //           ],
              //         ),
              //         borderRadius: BorderRadius.circular(10),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(0.2),
              //             spreadRadius: 5,
              //             blurRadius: 4,
              //             offset: const Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Row(
              //           children: [
              //             Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 const Text(
              //                   "No. of Enquiry",
              //                   style: TextStyle(
              //                       color: Colors.black, fontSize: 18),
              //                 ),
              //                 const SizedBox(
              //                   height: 5,
              //                 ),
              //                 Text(
              //                   dashboardList[index].todayOrdersCount!,
              //                   style: const TextStyle(
              //                       color: Colors.black,
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.bold),
              //                 )
              //               ],
              //             ),
              //             const Text("0", style: TextStyle(fontSize: 20))
              //           ],
              //         ),
              //       )),
              // ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xff586F7C),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Quick Info",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                            ),
                            Text(
                              "Today",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "No.of\nEnquiry",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                dashboardList[index].todayOrdersCount!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Rs.${dashboardList[index].todayOrdersAmount!}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Online\nEnquiry",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                dashboardList[index].todayOnlineOrdersCount!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Rs.${dashboardList[index].todayOnlineOrdersAmount!}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Offline\nEnquiry",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                dashboardList[index].todayOfflineOrdersCount!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Rs.${dashboardList[index].todayOfflineOrdersAmount!}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EnquiryListing()));
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xff586F7C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "View Enquiry",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: dashboardHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureWaitingLoading();
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
                  dashboardHandler = dashboardListView();
                });
              },
              child: screenView());
        }
      },
    );
  }

  AppBar appbar() {
    return AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        // backgroundColor: Colors.white,
        backgroundColor: const Color(0xff586F7C),
        automaticallyImplyLeading: false,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              icon: const Icon(Iconsax.notification),
              onPressed: () {
                showNotificationSheet();
              })
        ]);
  }
}
