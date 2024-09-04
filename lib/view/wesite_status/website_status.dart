/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/websitestatus_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/http_service/websitestatus_service.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class WebsiteStatus extends StatefulWidget {
  const WebsiteStatus({super.key});

  @override
  State<WebsiteStatus> createState() => _WebsiteStatusState();
}

class _WebsiteStatusState extends State<WebsiteStatus> {
  List<WebsitestatusModel> websitestatusDataList = [];
  Future? websitestatusEditHandler;
  String? disableSite;
  String? disableForm;

  @override
  void initState() {
    websitestatusEditHandler = websitestatusEditView();
    super.initState();
  }

  Future<bool> websitestatusEditView() async {
    try {
      setState(() {
        websitestatusDataList.clear();
      });

      var resultData = await WebsitestatusService().getStatus();

      if (resultData.isNotEmpty) {
        if (resultData != null && resultData["head"]["code"] == 200) {
          WebsitestatusModel model = WebsitestatusModel();
          Map<String, dynamic> element = resultData["head"]["msg"];
          model.disableSite = element["disable_site"].toString();
          model.enquiryCustomerOrderLink =
              element["enquiry_customer_order_link"].toString();
          model.enquiryCustomerOrderCode =
              element["enquiry_customer_order_code"].toString();
          model.disablePageForm = element["disable_page_form"].toString();
          websitestatusDataList.add(model);

          return true;
        } else if (resultData["head"]["code"] == 400) {
          showCustomSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
        }
      } else {
        errorSnackbar(context);
      }
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
    return false;
  }

  updateStatus(String disableSite, String disableForm) async {
    try {
      Map formData = {
        "update_status": disableSite,
        "disable_form": int.parse(disableForm == '' ? "1" : disableForm),
      };
      await LocalAuthConfig()
          .checkBiometrics(context, 'Website Status')
          .then((value) async {
        if (value) {
          LoadingOverlay.show(context);
          await WebsitestatusService()
              .updateStatus(formData: formData)
              .then((onValue) {
            LoadingOverlay.hide();
            if (onValue.isNotEmpty) {
              if (onValue["head"]["code"] == 200) {
                showCustomSnackBar(context,
                    content: "Status updated successfully", isSuccess: true);
                setState(() {
                  websitestatusEditHandler = websitestatusEditView();
                });
              } else {
                showCustomSnackBar(context, content: "", isSuccess: true);
              }
            } else {
              errorSnackbar(context);
            }
          });
        }
      });
    } catch (e) {
      LoadingOverlay.hide();
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: appbar(context),
          body: body(),
        ),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: websitestatusEditHandler,
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
          if (snapshot.data) {
            return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    websitestatusEditHandler = websitestatusEditView();
                  });
                },
                child: ListView.builder(
                    itemCount: websitestatusDataList.length,
                    itemBuilder: (context, index) {
                      disableForm =
                          websitestatusDataList[index].disablePageForm;
                      disableSite = websitestatusDataList[index].disableSite;
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Column(children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Website Status",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('OFF'),
                                        value: 'Disable Site Yes',
                                        groupValue: disableSite,
                                        onChanged: (value) {
                                          setState(() {
                                            disableSite = value;
                                            updateStatus(
                                                disableSite!, disableForm!);
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('ON'),
                                        value: 'Disable Site No',
                                        groupValue: disableSite,
                                        onChanged: (value) {
                                          setState(() {
                                            disableSite = value;
                                            updateStatus(
                                                disableSite!, disableForm!);
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ])),
                        ),
                        if (websitestatusDataList[index].disableSite ==
                            "Disable Site Yes")
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Column(children: [
                                    Column(children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Enquiry Order Link",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              websitestatusDataList[index]
                                                  .enquiryCustomerOrderLink!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: websitestatusDataList[
                                                            index]
                                                        .enquiryCustomerOrderLink!,
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Iconsax.copy))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ])
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Column(children: [
                                    Column(children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Code",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            websitestatusDataList[index]
                                                .enquiryCustomerOrderCode!,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: websitestatusDataList[
                                                            index]
                                                        .enquiryCustomerOrderCode!,
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Iconsax.copy))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ])
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8.0),
                                        bottomRight: Radius.circular(8.0),
                                      ),
                                    ),
                                    child: Column(children: [
                                      Column(children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Form",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const SizedBox(
                                              width: 50,
                                            ),
                                            Expanded(
                                              child: RadioListTile<String>(
                                                title: const Text('ON'),
                                                value: "1",
                                                groupValue: disableForm,
                                                onChanged: (value) {
                                                  setState(() {
                                                    disableForm = value;
                                                    updateStatus(disableSite!,
                                                        disableForm!);
                                                  });
                                                },
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                            Expanded(
                                              child: RadioListTile<String>(
                                                title: const Text('OFF'),
                                                value: '2',
                                                groupValue: disableForm,
                                                onChanged: (value) {
                                                  setState(() {
                                                    disableForm = value;
                                                    updateStatus(disableSite!,
                                                        disableForm!);
                                                  });
                                                },
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ])
                                    ])),
                              ),
                            ],
                          ),
                      ]);
                    }));
          } else {
            return const Text("Failed to fetch data");
          }
        }
      },
    );
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
      surfaceTintColor: Colors.white,
      title: Text(
        "Website Status",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
