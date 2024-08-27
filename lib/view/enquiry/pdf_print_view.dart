/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:printing/printing.dart';
import '/view/custom_ui_element/future_loading.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class PDFPrintView extends StatefulWidget {
  final String url;
  const PDFPrintView({super.key, required this.url});

  @override
  State<PDFPrintView> createState() => _PDFPrintViewState();
}

class _PDFPrintViewState extends State<PDFPrintView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PrintOut"),
        actions: [
          IconButton(
            onPressed: () async {
              // futureLoading(context);
              LoadingOverlay.show(context);
              await http
                  .get(Uri.parse(widget.url))
                  .then((http.Response response) async {
                // ignore: unused_local_variable
                var pdfData = response.bodyBytes;
                // Navigator.pop(context);
                LoadingOverlay.hide();
                await Printing.layoutPdf(onLayout: (_) async => pdfData);
              });
            },
            icon: const Icon(Iconsax.printer),
          ),
        ],
      ),
      body: SfPdfViewer.network("https://${widget.url}"),
    );
  }
}
