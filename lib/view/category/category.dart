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
import '/model/category_model.dart';
import '/service/auth_service/auth_service.dart';
import '/service/http_service/category_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/category/category_form.dart';
import '/view/category/category_order.dart';
import '/view/custom_ui_element/confrimation_alert_dialog.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryListingModel> categoryList = [];
  Future? categoryHandler;
  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    AuthService().accountValid(context);
    categoryHandler = categoryListView().then((value) async {
      var demoViewed = await LocalDBConfig().getDemoCategory();
      if (!demoViewed!) {
        createTutorial();
        Future.delayed(Duration.zero, showTutorial);
      }
    });
    super.initState();
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
        LocalDBConfig().setDemoCategory();
      },
      onSkip: () {
        LocalDBConfig().setDemoCategory();
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
        identify: "orderingGuide",
        keyTarget: orderingGuide,
        alignSkip: Alignment.topLeft,
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
                      "Click to change category ordering",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                      textAlign: TextAlign.center,
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
        identify: "addCategoryGuide",
        keyTarget: addCategoryGuide,
        alignSkip: Alignment.topLeft,
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
                      "Click to add new Category",
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
        keyTarget: showFrontendGuide,
        alignSkip: Alignment.bottomLeft,
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

  GlobalKey orderingGuide = GlobalKey();
  GlobalKey addCategoryGuide = GlobalKey();
  GlobalKey refreshGuide = GlobalKey();
  GlobalKey showFrontendGuide = GlobalKey();

  Future categoryListView() async {
    try {
      setState(() {
        categoryList.clear();
      });

      return await CategoryService().getcategoryList().then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var element in resultData["head"]["msg"]) {
            CategoryListingModel model = CategoryListingModel();
            model.name = element["category_name"].toString();
            model.creator = element["creator_name"].toString();
            model.categoryId = element["category_id"].toString();
            model.showFrontend = element["show_frontend"].toString();
            setState(() {
              categoryList.add(model);
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

  openCategoryEdit(String? categoryId) async {
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
          return CategoryForm(
            categoryId: categoryId,
          );
        }).then((onValue) {
      if (onValue != null) {
        if (onValue) {
          setState(() {
            categoryHandler = categoryListView();
          });
        }
      }
    });
  }

  openCategoryOrderEdit() async {
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
        return const CategoryOrderEdit();
      },
    ).then((onValue) {
      if (onValue != null) {
        if (onValue) {
          categoryHandler = categoryListView();
        }
      }
    });
  }

  submitFrontend(String categoryId, bool value) async {
    var userId = await LocalDBConfig().getUserID();
    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'edit_category_id_frontend': categoryId,
      'value': value ? 0.toString() : 1.toString(),
    };
    try {
      LoadingOverlay.show(context);
      CategoryService().updateFrontEnd(formData: formData).then((value) {
        LoadingOverlay.hide();
        if (value['head']['code'] == 200) {
          showCustomSnackBar(context,
              content: "Updated Successfully", isSuccess: true);
          categoryHandler = categoryListView();
          NotificationService().showNotification(
              title: "Frontend Updated",
              body: "Frontend has updated successfully.");
        } else {
          showCustomSnackBar(context,
              content: value['head']['msg'], isSuccess: false);
        }
      });
    } catch (e) {
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  deleteCategory(String categoryId) async {
    var userId = await LocalDBConfig().getUserID();
    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'delete_category_id': categoryId,
    };
    try {
      LoadingOverlay.show(context);
      CategoryService().deleteCategory(formData: formData).then((value) {
        LoadingOverlay.hide();
        if (value['head']['code'] == 200) {
          showCustomSnackBar(context,
              content: "Category Deleted Successfully", isSuccess: true);
          categoryHandler = categoryListView();
        } else {
          showCustomSnackBar(context,
              content: value['head']['msg'], isSuccess: false);
        }
      });
    } catch (e) {
      showCustomSnackBar(context,
          content: "Deleted Failed $e", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: categoryHandler,
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
                categoryHandler = categoryListView();
              });
            },
            child: screenView(),
          );
        }
      },
    );
  }

  ListView screenView() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            openCategoryEdit(categoryList[index].categoryId!);
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
                          categoryList[index].name!,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Created by: ${categoryList[index].creator!}",
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
                          key: index == 0 ? showFrontendGuide : null,
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value:
                                int.parse(categoryList[index].showFrontend!) ==
                                        0
                                    ? true
                                    : false,
                            onChanged: (value) {
                              submitFrontend(
                                  categoryList[index].categoryId!, value);
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
                                    Navigator.pop(context);
                                    openCategoryEdit(
                                        categoryList[index].categoryId!);
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) =>
                                                const ConfrimationAlertDialog(
                                                    title: "Delete",
                                                    content:
                                                        "Are you sure want to delete category?"))
                                        .then((value) {
                                      if (value) {
                                        deleteCategory(
                                            categoryList[index].categoryId!);
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
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Category",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
            key: refreshGuide,
            onPressed: () {
              setState(() {
                categoryHandler = categoryListView();
              });
            },
            icon: const Icon(Iconsax.refresh)),
        IconButton(
            key: orderingGuide,
            onPressed: () {
              openCategoryOrderEdit();
            },
            icon: const Icon(Iconsax.menu)),
        IconButton(
            key: addCategoryGuide,
            onPressed: () {
              openCategoryEdit(null);
            },
            icon: const Icon(Iconsax.add))
      ],
    );
  }
}
