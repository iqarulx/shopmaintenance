/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  openStore() async {
    if (Platform.isAndroid) {
      final Uri url = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.srisoftwarez.shopmaintenance');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } else {
      final Uri url =
          Uri.parse('https://apps.apple.com/app/shop-maintenance/id6464564417');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 53, 49, 72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/update.png',
            height: 250,
            width: 250,
          ),
          Text(
            "App Update Available",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Please update app in Playstore / Appstore",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              openStore();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
