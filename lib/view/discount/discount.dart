/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/discount_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/auth_service/auth_service.dart';
import '/service/http_service/discount_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/dialog_discount.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/discount/discount_form.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  @override
  void initState() {
    AuthService().accountValid(context);
    discountHandler = discountListView().then((value) async {
      var demoViewed = await LocalDBConfig().getDemoDiscount();
      if (!demoViewed!) {
        createTutorial();
        Future.delayed(Duration.zero, showTutorial);
      }
    });
    super.initState();
  }

  Future discountListView() async {
    try {
      setState(() {
        discountList.clear();
        tmpDiscountList.clear();
      });

      return await DiscountService().getDiscountList().then((resultData) async {
        if (resultData.isNotEmpty) {
          if (resultData != null && resultData["head"]["code"] == 200) {
            List<dynamic> productDataList =
                resultData["head"]["msg"]["discount_data"];

            for (var element in productDataList) {
              DiscountListingModel model = DiscountListingModel();
              model.discountId = element["discount_id"].toString();
              model.discount = element["discount"].toString();
              model.showFrontend = element["show_frontend"].toString();
              model.creator = element["creator_name"].toString();
              setState(() {
                discountList.add(model);
              });
            }

            setState(() {
              tmpDiscountList.addAll(discountList);
            });
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
    return Scaffold(appBar: appbar(), body: body());
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
        future: discountHandler,
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
                  discountList.clear();
                  discountHandler = discountListView();
                });
              },
              child: screenView(context),
            );
          }
        });
  }

  ListView screenView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        searchOption(),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: discountList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  openDiscountEdit(discountList[index].discountId);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Column(
                          children: [
                            Text(
                              "${discountList[index].discount!}%",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Created by: ${discountList[index].creator!}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Transform.scale(
                              key: index == 0 ? showFrontEndGuide : null,
                              scale: 0.6,
                              child: CupertinoSwitch(
                                value: int.parse(discountList[index]
                                            .showFrontend!) ==
                                        0
                                    ? true
                                    : false,
                                onChanged: (value) {
                                  submitFrontend(
                                      discountList[index].discountId!, value);
                                },
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              color: Colors.white,
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  child: IconButton(
                                      onPressed: () {
                                        openDiscountEdit(
                                            discountList[index].discountId);
                                      },
                                      icon: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.green[500],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            "Edit",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      )),
                                ),
                                PopupMenuItem<String>(
                                  child: IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              DeleteDialogDiscount(
                                            discountId:
                                                discountList[index].discountId!,
                                            discountName:
                                                discountList[index].discount!,
                                          ),
                                        ).then((value) => {
                                              if (value != null && value)
                                                {
                                                  deleteDiscount(
                                                      discountList[index]
                                                          .discountId!)
                                                }
                                            });
                                      },
                                      icon: Row(
                                        children: [
                                          Icon(
                                            Iconsax.trash,
                                            color: Colors.red[400],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            "Delete",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Column searchOption() {
    return Column(
      children: [
        TextFormField(
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          // onEditingComplete: () {
          //   setState(() {
          //     FocusManager.instance.primaryFocus!.unfocus();
          //   });
          // },
          // onTapOutside: (event) {
          //   setState(() {
          //     FocusManager.instance.primaryFocus!.unfocus();
          //   });
          // },
          onChanged: (value) {
            setState(() {});
            searchFn();
          },
          decoration: InputDecoration(
            hintText: "Search by name",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Iconsax.search_normal_1),
            suffixIcon: search.text.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        search.clear();
                        discountHandler = discountListView();
                      });
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Color(0xff2F4550),
                      ),
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xff2F4550),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Discount",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
            key: refreshGuide,
            onPressed: () {
              setState(() {
                discountList.clear();
                discountHandler = discountListView();
              });
            },
            icon: const Icon(Iconsax.refresh)),
        IconButton(
          key: editGuide,
          onPressed: () {
            openDiscountEdit(null);
          },
          icon: const Icon(
            Iconsax.add,
            size: 30,
          ),
        )
      ],
    );
  }

  searchFn() {
    if (search.text.isNotEmpty) {
      var dataList = tmpDiscountList.where((element) {
        if (element.discount!.contains(search.text)) {
          return true;
        } else if (element.discount!.startsWith(search.text)) {
          return true;
        } else {
          return false;
        }
      });

      setState(() {
        discountList.clear();
        discountList.addAll(dataList);
      });
    } else {
      setState(() {
        discountList.clear();
        discountList.addAll(tmpDiscountList);
      });
    }
  }

  openDiscountEdit(String? discountId) async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return DiscountForm(discountId: discountId);
        }).then((onValue) {
      if (onValue != null) {
        if (onValue) {
          discountHandler = discountListView();
        }
      }
    });
  }

  submitFrontend(String discountId, bool value) async {
    var userId = await LocalDBConfig().getUserID();
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    Map<String, String> formData = {
      'domain_name': domain!,
      'admin_folder_name': adminPath!,
      'creator_id': userId.toString(),
      'show_hide_discount_id': discountId,
      'show_frontend': value ? 0.toString() : 1.toString(),
    };
    try {
      LoadingOverlay.show(context);
      DiscountService().updateFrontEnd(formData: formData).then((value) {
        LoadingOverlay.hide();

        if (value.isNotEmpty) {
          if (value['head']['code'] == 200) {
            showCustomSnackBar(context,
                content: value['head']['msg'], isSuccess: true);
            Future.delayed(const Duration(seconds: 2), () {
              discountHandler = discountListView();
            });
            NotificationService().showNotification(
                title: "Frontend Updated",
                body: "Frontend has updated successfully.");
          } else {
            showCustomSnackBar(context,
                content: value['head']['msg'], isSuccess: false);
          }
        } else {
          errorSnackbar(context);
        }
      });
    } catch (e) {
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  deleteDiscount(String discountId) async {
    var userId = await LocalDBConfig().getUserID();
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'domain_name': domain!,
      'admin_folder_name': adminPath!,
      'delete_discount_id': discountId,
    };

    try {
      await LocalAuthConfig()
          .checkBiometrics(context, 'Discount')
          .then((value) {
        if (value) {
          LoadingOverlay.show(context);
          DiscountService().deleteDiscount(formData: formData).then((value) {
            LoadingOverlay.hide();
            if (value.isNotEmpty) {
              if (value['head']['code'] == 200) {
                showCustomSnackBar(context,
                    content: value['head']['msg'], isSuccess: true);
                Future.delayed(const Duration(seconds: 2), () {
                  discountHandler = discountListView();
                });
              } else {
                showCustomSnackBar(context,
                    content: value['head']['msg'], isSuccess: false);
              }
            } else {
              errorSnackbar(context);
            }
          });
        } else {
          showCustomSnackBar(context, content: "Auth Failed", isSuccess: false);
        }
      });
    } catch (e) {
      // Navigator.pop(context);
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  createTutorial() async {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.white38,
      textSkip: "SKIP",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        backgroundColor: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      skipWidget: Container(
        height: 40,
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "SKIP",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        LocalDBConfig().setDemoDiscount();
      },
      onSkip: () {
        LocalDBConfig().setDemoDiscount();
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "refreshGuide",
        keyTarget: refreshGuide,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to refresh the page",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "editGuide",
        keyTarget: editGuide,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to add the discount",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "showFrontEndGuide",
        keyTarget: showFrontEndGuide,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to show product in frontend",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  GlobalKey refreshGuide = GlobalKey();
  GlobalKey showFrontEndGuide = GlobalKey();
  GlobalKey editGuide = GlobalKey();

  List<DiscountListingModel> discountList = [];
  List<DiscountListingModel> tmpDiscountList = [];
  TextEditingController search = TextEditingController();
  Future? discountHandler;
  String? selectedCategory;
  bool showSearch = false;
  late TutorialCoachMark tutorialCoachMark;
}
