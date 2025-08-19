/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

futureLoading(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            color: Color(0xff2F4550),
          ),
        ),
      ),
    ),
  );
}

futureWaitingLoading() {
  return const Center(
    child: CircularProgressIndicator(
      color: Color(0xff2F4550),
    ),
  );
}

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.9),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: const Center(child: CircularProgressIndicator())),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

ListView dataLoading() {
  return ListView.builder(
    padding: const EdgeInsets.all(10),
    itemCount: 10,
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 10,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 10,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 10,
                          width: 100,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 10,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 50,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    },
  );
}
