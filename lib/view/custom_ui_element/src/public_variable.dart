/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';

TextEditingController fromDate = TextEditingController();
TextEditingController toDate = TextEditingController();
TextEditingController search = TextEditingController();

List<DropdownMenuItem> customerList = [];
List<DropdownMenuItem> staffList = [];
List<DropdownMenuItem> orderTypeList = [];
List<DropdownMenuItem> promotionCodeList = [];
List<DropdownMenuItem> statusList = [];
String? customerID;
String? staffID;
String? orderTypeID;
String? filterPromotionCodeID;
String? statusID;
