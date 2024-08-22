/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/product_model.dart';
import '/service/http_service/product_service.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '/provider/file_download_provider.dart' as helper;
import 'package:http/http.dart' as http;

class PdfPreview extends StatefulWidget {
  const PdfPreview({super.key});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  List<PdfPreviewModel> pdfList = [];
  Future? dataHandler;

  @override
  void initState() {
    dataHandler = pdfListView();
    super.initState();
  }

  Future<void> pdfListView() async {
    try {
      setState(() {
        pdfList.clear();
      });

      Map formData = {"get_pricelist_pdf": 1};

      return await ProductService()
          .getPdfPreview(formData: formData)
          .then((resultData) async {
        if (resultData.isNotEmpty) {
          if (resultData != null && resultData["head"]["code"] == 200) {
            List<dynamic> apipdfList = resultData["head"]["msg"];

            for (var element in apipdfList) {
              PdfPreviewModel model = PdfPreviewModel();
              model.pdfUrl = element["pdf_url"].toString();
              print(model.pdfUrl);
              setState(() {
                pdfList.add(model);
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

  Future<void> downloadPdf(String url, BuildContext context) async {
    try {
      LoadingOverlay.show(context);
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Uint8List data = Uint8List.fromList(response.bodyBytes);
        LoadingOverlay.hide();
        await helper.saveAndLaunchFile(data, 'Product.pdf');
      } else {
        throw 'Failed to download PDF';
      }
    } catch (e) {
      Navigator.pop(context);
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
          body: body(),
        ));
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
              await pdfListView();
              setState(() {});
            },
            child: SfPdfViewer.network(pdfList[0].pdfUrl!),
          );
        }
      },
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          downloadPdf(pdfList[0].pdfUrl!, context);
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
        "Pdf Preview",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
