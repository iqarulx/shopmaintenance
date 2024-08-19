/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '/provider/permisstion_provider.dart';

class DownloadFileOffline {
  final Uint8List fileData;
  final String fileName;
  final String fileext;
  DownloadFileOffline({
    required this.fileData,
    required this.fileName,
    required this.fileext,
  });
  Future<String?> startDownload() async {
    String? result;
    try {
      bool? permissionResult = await PermissionHandler().storagePermission();
      if (permissionResult != null) {
        Directory? dir;
        if (Platform.isAndroid) {
          dir = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          dir = await getApplicationDocumentsDirectory();
        }

        if (dir != null) {
          String time = DateFormat('dd-MM-yyyy-hh-mm-a')
              .format(DateTime.now())
              .toString();
          String filename = "${dir.absolute.path}/$fileName - $time.$fileext";
          log(filename.toString());
          var file = await File(filename).writeAsBytes(fileData);
          if (await file.exists()) {
            result = file.path;
          } else {
            result = null;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return result;
  }
}
