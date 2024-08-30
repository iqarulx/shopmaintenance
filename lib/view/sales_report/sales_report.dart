/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/sales_report_model.dart';
import '/service/auth_service/auth_service.dart';
import '/service/http_service/sales_report_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/sales_report/report_filter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  List<SalesReportModel> salesReportList = [];
  List<SalesReportPieModel> pieData = [];
  Future? salesReportHandler;
  late TutorialCoachMark tutorialCoachMark;

  @override
  initState() {
    AuthService().accountValid(context);
    salesReportHandler = salesReportListView().whenComplete(initGraph)
      ..then((value) async {
        var demoViewed = await LocalDBConfig().getDemoProductSales();
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
        LocalDBConfig().setDemoProductSales();
      },
      onSkip: () {
        LocalDBConfig().setDemoProductSales();
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

    return targets;
  }

  GlobalKey refreshGuide = GlobalKey();

  initGraph() {
    if (salesReportList.isNotEmpty) {
      salesReportList.sort(
          (a, b) => int.parse(b.quantity!).compareTo(int.parse(a.quantity!)));
      List<SalesReportModel> top5Products = salesReportList.take(5).toList();
      pieData.clear();
      for (var data in top5Products) {
        pieData.add(
            SalesReportPieModel(data.productName!, int.parse(data.quantity!)));
      }
    }
  }

  Future salesReportListView(
      {String? fromDate, String? toDate, String? status}) async {
    try {
      setState(() {
        salesReportList.clear();
      });

      Map<String, dynamic> formData = {
        "get_product_sales_list": 1,
        "from_date": DateFormat('dd-MM-yyyy')
            .format(DateTime.now().subtract(const Duration(days: 7))),
        "to_date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
        "status": status,
      };

      return await SalesReportService()
          .getSalesList(formData: formData)
          .then((resultData) async {
        if (resultData.isNotEmpty) {
          if (resultData != null && resultData["head"]["code"] == 200) {
            for (var element in resultData["head"]["msg"]) {
              SalesReportModel model = SalesReportModel();

              model.productId = element["product_id"].toString();
              model.productName = element["product_name"].toString();
              model.quantity = element["quantity"].toString();

              setState(() {
                salesReportList.add(model);
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
      throw e.toString();
    }
  }

  openFilterOptions() async {
    var result = await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const SizedBox(height: 400, child: ReportFilter());
      },
    );

    if (result != null) {
      setState(() {
        salesReportList.clear();
        salesReportHandler = salesReportListView(
                fromDate: result['from_date'],
                toDate: result['to_date'],
                status: result['status'])
            .whenComplete(initGraph);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(),
        // floatingActionButton: filterOption(),
        body: body());
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: salesReportHandler,
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
                salesReportList.clear();
                salesReportHandler = salesReportListView();
              });
            },
            child:
                salesReportList.isNotEmpty ? screenView() : futureNoDataError(),
          );
        }
      },
    );
  }

  FloatingActionButton filterOption() {
    return FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: Colors.black,
      onPressed: () {
        openFilterOptions();
      },
      child: const Icon(
        Iconsax.filter,
        color: Colors.white,
      ),
    );
  }

  ListView screenView() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.info_circle,
              size: 17,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
                'Showing ${DateFormat('dd-MM-yyyy').format(DateTime.now().subtract(const Duration(days: 7)))} to ${DateFormat('dd-MM-yyyy').format(DateTime.now())} Sales',
                style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
        chartView(),
        productListing(),
      ],
    );
  }

  Padding productListing() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const Text('Product Sales List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
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
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          "S.No",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          "Product Name",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          "Qty",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ])),
          ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: salesReportList.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
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
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                salesReportList[index].productName!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                salesReportList[index].quantity!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ]));
              })
        ],
      ),
    );
  }

  SfCircularChart chartView() {
    return SfCircularChart(
        title: ChartTitle(
            text: 'Top 5 Enquired Products',
            textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        legend: const Legend(isVisible: true),
        series: <PieSeries<SalesReportPieModel, String>>[
          PieSeries<SalesReportPieModel, String>(
              explode: true,
              explodeIndex: 0,
              dataSource: pieData,
              xValueMapper: (SalesReportPieModel data, _) => data.xData,
              yValueMapper: (SalesReportPieModel data, _) => data.yData,
              dataLabelMapper: (SalesReportPieModel data, _) => data.text,
              dataLabelSettings: const DataLabelSettings(isVisible: true)),
        ]);
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Product Sales",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
            key: refreshGuide,
            onPressed: () {
              setState(() {
                salesReportList.clear();
                salesReportHandler = salesReportListView();
              });
            },
            icon: const Icon(Iconsax.refresh)),
      ],
    );
  }
}
