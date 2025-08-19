/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

class EnquiryInputModel {
  // Input Params
  String? equiryAdminUserID;
  int? pageNumber;
  int? pageLimit;
  String? searchText;
  String? fromDate;
  String? toDate;
  String? filterCustomerID;
  String? filterStaffID;
  String? filterOrderType;
  String? filterPromotionCodeID;
  String? filterStatus;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["equiry_admin_user_id"] = equiryAdminUserID;
    mapping["page_number"] = pageNumber;
    mapping["page_limit"] = pageLimit;
    mapping["search_text"] = searchText;
    mapping["from_date"] = fromDate;
    mapping["to_date"] = toDate;
    mapping["filter_customer_id"] = filterCustomerID;
    mapping["filter_staff_id"] = filterStaffID;
    mapping["filter_order_type"] = filterOrderType;
    mapping["filter_promotion_code_id"] = filterPromotionCodeID;
    mapping["filter_status"] = filterStatus;
    return mapping;
  }
}

class EnquiryListingModel {
  String? creatorName;
  String? orderID;
  String? ordertype;
  String? orderNumber;
  String? orderDate;
  String? customerName;
  String? customerMobileNumber;
  String? deliveryAddress;
  int? newOrder;
  int? confirmed;
  int? despatched;
  int? delivered;
  List<EnquiryProductModel>? productList;
  String? deliveryNumber;
  String? deliveryParticulars;

  String? subTotal;
  String? extraDiscount;
  String? extraDiscountValue;
  String? extraDiscountTotal;
  String? couponDiscount;
  String? couponDiscountValue;
  String? couponDiscountTotal;
  String? packingCharges;
  String? packingChargesValue;
  String? grandTotal;
  String? roundOff;
  String? totalAmount;

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["creator_name"] = creatorName;
    mapping["orderID"] = orderID;
    mapping["ordertype"] = ordertype;
    mapping["orderNumber"] = orderNumber;
    mapping["orderDate"] = orderDate;
    mapping["customerName"] = customerName;
    mapping["customerMobileNumber"] = customerMobileNumber;
    mapping["deliveryAddress"] = deliveryAddress;
    mapping["newOrder"] = newOrder;
    mapping["confirmed"] = confirmed;
    mapping["despatched"] = despatched;
    mapping["delivered"] = delivered;
    mapping["productList"] = productList
        ?.map((product) => product)
        .toList(); // Assuming EnquiryProductModel also has a toMap method
    mapping["deliveryNumber"] = deliveryNumber;
    mapping["deliveryParticulars"] = deliveryParticulars;
    mapping["subTotal"] = subTotal;
    mapping["extraDiscount"] = extraDiscount;
    mapping["extraDiscountValue"] = extraDiscountValue;
    mapping["extraDiscountTotal"] = extraDiscountTotal;
    mapping["couponDiscount"] = couponDiscount;
    mapping["couponDiscountValue"] = couponDiscountValue;
    mapping["couponDiscountTotal"] = couponDiscountTotal;
    mapping["packingCharges"] = packingCharges;
    mapping["packingChargesValue"] = packingChargesValue;
    mapping["grandTotal"] = grandTotal;
    mapping["roundOff"] = roundOff;
    mapping["totalAmount"] = totalAmount;
    return mapping; // Add this line to return the mapping
  }
}

class EnquiryProductModel {
  String? code;
  String? name;
  String? content;
  String? productPrice;
  String? quantity;
  String? discount;
  String? amount;
}

class OrderConfirmModel {
  String? confirmedOrderID;
  String? confirmStatus;
  String? despatchedOrderID;
  String? despatchedStatus;
  String? deliveredOrderID;
  String? deliveryStatus;
  String? deliveryNumber;
  String? deliveryParticulars;

  toEnquiryConfirmMap() {
    var mapping = <String, dynamic>{};
    mapping["confirmed_order_id"] = confirmedOrderID;
    mapping["confirm_status"] = confirmStatus;
    return mapping;
  }

  toEnquiryDispatchMap() {
    var mapping = <String, dynamic>{};
    mapping["despatched_order_id"] = despatchedOrderID;
    mapping["despatched_status"] = despatchedStatus;
    return mapping;
  }

  toEnquiryDeliveryMap() {
    var mapping = <String, dynamic>{};
    mapping["delivered_order_id"] = deliveredOrderID;
    mapping["delivery_status"] = deliveryStatus;
    mapping["delivery_number"] = deliveryNumber;
    mapping["delivery_particulars"] = deliveryParticulars;
    return mapping;
  }
}
