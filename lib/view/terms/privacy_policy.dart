/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('http://www.srisoftwarez.com/privacypolicy.php'),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff586F7C),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
