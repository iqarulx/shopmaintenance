/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class SettingsEditingModel {
  Map<String, dynamic>? settingsList;
  Map<String, dynamic>? stateNameList;
  String? layout;
  List<dynamic>? categoryList;
  List<dynamic>? productList;

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping['settings_list'] = settingsList;
    mapping['state_name_list'] = stateNameList;
    mapping['layout'] = layout;
    mapping['category_list'] = categoryList;
    mapping['product_list'] = productList;
    return mapping;
  }
}
