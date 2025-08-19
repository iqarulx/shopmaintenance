/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class CustomerModel {
  String? customerName;
  String? domain;
  int? mobile;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["customer_name"] = customerName;
    mapping["domain"] = domain;
    mapping["mobile"] = mobile;
    return mapping;
  }
}

class CustomerFilterModel {
  int id;
  String customerId;
  String name;
  String mobileNumber;
  String email;
  String city;
  String state;
  CustomerFilterModel({
    required this.id,
    required this.customerId,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.city,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'city': city,
      'state': state,
    };
  }

  factory CustomerFilterModel.fromMap(Map<String, dynamic> map) {
    return CustomerFilterModel(
      id: map['id'] as int,
      customerId: map['customer_id'] as String,
      name: map['name'] as String,
      mobileNumber: (map['mobile_number']).toString(),
      email: map['email'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
    );
  }
}
