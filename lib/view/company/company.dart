/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/company_model.dart';
import '/service/auth_service/auth_service.dart';
import '/service/http_service/company_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/company/company_form.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Company extends StatefulWidget {
  const Company({super.key});

  @override
  State<Company> createState() => _CompanyState();
}

class _CompanyState extends State<Company> {
  List<CompanyListingModel> companyList = [];
  Future? companyHandler;
  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    AuthService().accountValid(context);
    companyHandler = companyListView().then((value) async {
      var demoViewed = await LocalDBConfig().getDemoCompany();
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
        LocalDBConfig().setDemoCompany();
      },
      onSkip: () {
        LocalDBConfig().setDemoCompany();
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
                      "Click to edit the company",
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
  GlobalKey editGuide = GlobalKey();

  Future<void> companyListView() async {
    try {
      setState(() {
        companyList.clear();
      });

      return await CompanyService().getCompanyList().then((resultData) async {
        if (resultData.isNotEmpty) {
          if (resultData != null && resultData["head"]["code"] == 200) {
            for (var element in resultData["head"]["msg"]) {
              CompanyListingModel model = CompanyListingModel();
              model.name = element["name"];
              model.creator = element["creator_name"];
              model.companyId = element["company_id"];
              setState(() {
                companyList.add(model);
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

  openCompanyEdit(String companyId) async {
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
          return CompanyForm(
            companyId: companyId,
          );
        });
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
      future: companyHandler,
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
                companyHandler = companyListView();
              });
            },
            child: screenView(),
          );
        }
      },
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Company",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
            key: refreshGuide,
            onPressed: () {
              setState(() {
                companyHandler = companyListView();
              });
            },
            icon: const Icon(Iconsax.refresh)),
      ],
    );
  }

  ListView screenView() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: companyList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            openCompanyEdit(companyList[index].companyId!);
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
                          companyList[index].name!,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Created by: ${companyList[index].creator!}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        key: index == 0 ? editGuide : null,
                        onPressed: () {
                          openCompanyEdit(companyList[index].companyId!);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.red[400],
                        ))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
