/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import '/model/product_model.dart';
import '/provider/file_download_provider.dart' as helper;
import '/service/http_service/product_service.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class ExcelPreview extends StatefulWidget {
  const ExcelPreview({super.key});

  @override
  State<ExcelPreview> createState() => _ExcelPreviewState();
}

class _ExcelPreviewState extends State<ExcelPreview> {
  List<ExcelPreviewModel> categoryList = [];
  Future? dataHandler;

  @override
  void initState() {
    dataHandler = categoryListView();
    super.initState();
  }

  Future<void> categoryListView() async {
    try {
      setState(() {
        categoryList.clear();
      });

      Map formData = {"get_pricelist_excel": 1};

      return await ProductService()
          .getExcelPreview(formData: formData)
          .then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          List<dynamic> apiCategoryList = resultData["head"]["msg"];

          for (var element in apiCategoryList) {
            ExcelPreviewModel model = ExcelPreviewModel();
            model.categoryName = element["category_name"].toString();
            model.productList = element["product_list"];
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

  Future<void> generateExcel() async {
    try {
      // futureLoading(context);
      LoadingOverlay.show(context);
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];
      sheet.appendRow(['S.No', 'Product Name', 'Price']);
      for (var category in categoryList) {
        sheet.appendRow([category.categoryName]);
        for (int i = 0; i < category.productList!.length; i++) {
          var product = category.productList![i];
          sheet.appendRow([
            i + 1,
            product['product_name'],
            product['price'],
          ]);
        }

        sheet.appendRow([]);
      }

      Uint8List data = Uint8List.fromList(excel.save()!);
      await helper.saveAndLaunchFile(data, 'Product.xlsx');

      NotificationService().showNotification(
          body: 'File Downloaded',
          title: 'Product Excel file has been downloaded.');
    } catch (e) {
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
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appbar(context),
            bottomNavigationBar: bottomAppbar(context),
            body: body()));
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: dataHandler,
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
              await categoryListView();
              setState(() {});
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryList[index].categoryName!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            dataTable(index),
          ],
        );
      },
    );
  }

  DataTable dataTable(int index) {
    return DataTable(
      columns: const [
        DataColumn(
            label: Text(
          'S.No',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        )),
        DataColumn(
            label: Text(
          'Product',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        )),
        DataColumn(
            label: Text(
          'Price',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        )),
      ],
      rows: List.generate(
        categoryList[index].productList!.length,
        (rowIndex) => DataRow(
          cells: [
            DataCell(Text((rowIndex + 1).toString())),
            DataCell(Text(categoryList[index]
                .productList![rowIndex]['product_name']
                .toString())),
            DataCell(Text(
                '₹${categoryList[index].productList![rowIndex]['price'].toString()}')),
          ],
        ),
      ),
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          generateExcel();
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
              "Download",
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
        "Excel Preview",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
