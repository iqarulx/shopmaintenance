/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

futureError({required String title, required String content}) {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          content,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    ),
  );
}

futureDisplayError({required String content}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/error.json', frameRate: const FrameRate(100)),
        const Text(
          "Error",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          content,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

futureNoDataError() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/not-found.json',
            height: 150, width: 150, frameRate: const FrameRate(100)),
        const Text(
          "Not Found",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Sorry! No data available to show",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

futureNetworkError() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/error.json',
            height: 150, width: 150, frameRate: const FrameRate(100)),
        const Text(
          "Network Error",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Please check your network",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

// futureNoDataError() {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Lottie.asset('assets/not-found.json',
//             height: 150, width: 150, frameRate: const FrameRate(100)),
//         const Text(
//           "No Data Found",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//       ],
//     ),
//   );
// }
