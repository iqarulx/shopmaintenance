/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '/main.dart';
import '/provider/file_download_provider.dart' as helper;
import '/service/auth_service/auth_service.dart';
import '/service/http_service/enquiry_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/routes/enquiry_route.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/custom_ui_element/enquiry_filter.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/public_variable.dart';
import '/model/enquiry_model.dart';
import 'enquiry_details_view.dart';

EnquiryRoutes enquiryRoutes = EnquiryRoutes();

class EnquiryListing extends StatefulWidget {
  const EnquiryListing({super.key});

  @override
  State<EnquiryListing> createState() => _EnquiryListingState();
}

class _EnquiryListingState extends State<EnquiryListing>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  late Future enquiryHandler;
  List<EnquiryListingModel> enquiryList = [];
  List<EnquiryListingModel> frontEnquiryList = [];
  List<EnquiryListingModel> backEnquiryList = [];
  bool loading = false;
  bool dataComplete = false;
  List<DropdownMenuItem> customerList = [];
  List<DropdownMenuItem> staffList = [];
  List<DropdownMenuItem> orderTypeList = [];
  List<DropdownMenuItem> promotionCodeList = [];
  List<DropdownMenuItem> statusList = [];
  int pageno = 1;
  bool searchView = false;
  final formatCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final ScrollController _controller = ScrollController();

  searchEnquiry() async {
    try {
      EnquiryInputModel model = EnquiryInputModel();
      model.equiryAdminUserID = await LocalDBConfig().getUserID();
      model.pageNumber = 1;
      model.pageLimit = 10;
      model.searchText = search.text;
      model.fromDate = fromDate.text;
      model.toDate = toDate.text;
      model.filterCustomerID = customerID ?? "";
      model.filterStaffID = staffID ?? "";
      model.filterOrderType =
          tabController!.index == 0 ? "" : orderTypeID ?? "";
      model.filterPromotionCodeID = filterPromotionCodeID ?? "";
      model.filterStatus = statusID ?? "";

      setState(() {
        enquiryList.clear();
        frontEnquiryList.clear();
        backEnquiryList.clear();
      });

      await EnquiryService().getEnquiryAPI(enquiryInput: model).then((result) {
        if (result["head"]["code"] == 200) {
          for (var element in result["body"]["orders"]) {
            EnquiryListingModel dataModel = EnquiryListingModel();
            dataModel.orderID = element["order_id"].toString();
            dataModel.ordertype = element["order_type"].toString();
            dataModel.orderNumber = element["order_number"].toString();

            dataModel.orderDate = element["order_date"].toString();
            dataModel.customerName = element["customer_name"].toString();
            dataModel.customerMobileNumber =
                element["customer_mobile_number"].toString();
            dataModel.deliveryAddress = element["delivery_address"].toString();
            dataModel.newOrder = int.parse(element["new_order"].toString());
            dataModel.confirmed = int.parse(element["confirmed"].toString());
            dataModel.despatched = int.parse(element["despatched"].toString());
            dataModel.delivered = int.parse(element["delivered"].toString());
            dataModel.deliveryNumber = element["delivery_number"].toString();
            dataModel.deliveryParticulars =
                element["delivery_particulars"].toString();

            dataModel.subTotal = element["sub_total"].toString();
            dataModel.extraDiscount = element["extra_discount"].toString();
            dataModel.extraDiscountValue =
                element["extra_discount_value"].toString();
            dataModel.extraDiscountTotal =
                element["extra_discount_total"].toString();
            dataModel.couponDiscount = element["coupon_discount"].toString();
            dataModel.couponDiscountValue =
                element["coupon_discount_value"].toString();
            dataModel.couponDiscountTotal =
                element["coupon_discount_total"].toString();
            dataModel.packingCharges = element["packing_charges"].toString();
            dataModel.packingChargesValue =
                element["packing_charges_value"].toString();
            dataModel.grandTotal = element["grand_total"].toString();
            dataModel.roundOff = element["round_off"].toString();
            dataModel.totalAmount = element["total_amount"].toString();
            dataModel.productList = [];
            for (var productElement in element["product_list"]) {
              EnquiryProductModel productModel = EnquiryProductModel();
              productModel.code = productElement["code"].toString();
              productModel.name = productElement["name"].toString();
              productModel.content = productElement["content"].toString();
              productModel.productPrice =
                  productElement["product_price"].toString();
              productModel.quantity = productElement["quantity"].toString();
              productModel.discount = productElement["discount"].toString();
              productModel.amount = productElement["amount"].toString();
              dataModel.productList!.add(productModel);
            }

            setState(() {
              if (tabController!.index == 0) {
              } else if (tabController!.index == 1) {
                frontEnquiryList.add(dataModel);
              } else if (tabController!.index == 2) {
                backEnquiryList.add(dataModel);
              }
            });
          }
          setState(() {
            pageno += 1;
            loading = false;
            dataComplete = false;
          });
        } else if (result["head"]["code"] == 400) {
          setState(() {
            loading = false;
            dataComplete = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Enquiry Data Not Available"),
            ),
          );
        } else {
          setState(() {
            loading = false;
            dataComplete = false;
          });
        }
      });
    } catch (e) {
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
      setState(() {
        loading = false;
      });
    }
  }

  addEnquiry() async {
    try {
      EnquiryInputModel model = EnquiryInputModel();
      model.equiryAdminUserID = await LocalDBConfig().getUserID();
      model.pageNumber = pageno;
      model.pageLimit = 10;
      model.searchText = search.text;
      model.fromDate = fromDate.text;
      model.toDate = toDate.text;
      model.filterCustomerID = customerID ?? "";
      model.filterStaffID = staffID ?? "";
      model.filterOrderType =
          tabController!.index == 0 ? "" : orderTypeID ?? "";
      model.filterPromotionCodeID = filterPromotionCodeID ?? "";
      model.filterStatus = statusID ?? "";

      await EnquiryService().getEnquiryAPI(enquiryInput: model).then((result) {
        if (result["head"]["code"] == 200) {
          for (var element in result["body"]["orders"]) {
            EnquiryListingModel dataModel = EnquiryListingModel();
            dataModel.orderID = element["order_id"].toString();
            dataModel.ordertype = element["order_type"].toString();
            dataModel.orderNumber = element["order_number"].toString();
            dataModel.orderDate = element["order_date"].toString();
            dataModel.customerName = element["customer_name"].toString();
            dataModel.customerMobileNumber =
                element["customer_mobile_number"].toString();
            dataModel.deliveryAddress = element["delivery_address"].toString();
            dataModel.newOrder = int.parse(element["new_order"].toString());
            dataModel.confirmed = int.parse(element["confirmed"].toString());
            dataModel.despatched = int.parse(element["despatched"].toString());
            dataModel.delivered = int.parse(element["delivered"].toString());
            dataModel.deliveryNumber = element["delivery_number"].toString();
            dataModel.deliveryParticulars =
                element["delivery_particulars"].toString();

            dataModel.subTotal = element["sub_total"].toString();
            dataModel.extraDiscount = element["extra_discount"].toString();
            dataModel.extraDiscountValue =
                element["extra_discount_value"].toString();
            dataModel.extraDiscountTotal =
                element["extra_discount_total"].toString();
            dataModel.couponDiscount = element["coupon_discount"].toString();
            dataModel.couponDiscountValue =
                element["coupon_discount_value"].toString();
            dataModel.couponDiscountTotal =
                element["coupon_discount_total"].toString();
            dataModel.packingCharges = element["packing_charges"].toString();
            dataModel.packingChargesValue =
                element["packing_charges_value"].toString();
            dataModel.grandTotal = element["grand_total"].toString();
            dataModel.roundOff = element["round_off"].toString();
            dataModel.totalAmount = element["total_amount"].toString();
            dataModel.productList = [];
            for (var productElement in element["product_list"]) {
              EnquiryProductModel productModel = EnquiryProductModel();
              productModel.code = productElement["code"].toString();
              productModel.name = productElement["name"].toString();
              productModel.content = productElement["content"].toString();
              productModel.productPrice =
                  productElement["product_price"].toString();
              productModel.quantity = productElement["quantity"].toString();
              productModel.discount = productElement["discount"].toString();
              productModel.amount = productElement["amount"].toString();
              dataModel.productList!.add(productModel);
            }
            setState(() {
              if (tabController!.index == 0) {
                enquiryList.add(dataModel);
              } else if (tabController!.index == 1) {
                frontEnquiryList.add(dataModel);
              } else if (tabController!.index == 2) {
                backEnquiryList.add(dataModel);
              }
            });
          }
          setState(() {
            pageno += 1;
            loading = false;
          });
        } else if (result["head"]["code"] == 400) {
          setState(() {
            loading = false;
            dataComplete = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Enquiry Data Not Available"),
            ),
          );
        } else {
          setState(() {
            loading = false;
          });
        }
      });
    } catch (e) {
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
      setState(() {
        loading = false;
      });
    }
  }

  getEnquiry() async {
    try {
      setState(() {
        enquiryList.clear();
        frontEnquiryList.clear();
        backEnquiryList.clear();
        customerList.clear();
        staffList.clear();
        orderTypeList.clear();
        promotionCodeList.clear();
        statusList.clear();
        search.clear();
      });
      EnquiryInputModel model = EnquiryInputModel();
      model.equiryAdminUserID = await LocalDBConfig().getUserID();
      model.pageNumber = pageno;
      model.pageLimit = 10;
      model.searchText = "";
      model.fromDate = fromDate.text;
      model.toDate = toDate.text;
      model.filterCustomerID = customerID ?? "";
      model.filterStaffID = staffID ?? "";
      model.filterOrderType =
          tabController!.index == 0 ? "" : orderTypeID ?? "";
      model.filterPromotionCodeID = filterPromotionCodeID ?? "";
      model.filterStatus = statusID ?? "";
      return await EnquiryService()
          .getEnquiryAPI(enquiryInput: model)
          .then((result) {
        if (result["head"]["code"] == 200 || result["head"]["code"] == 400) {
          if (result["head"]["code"] == 200) {
            for (var element in result["body"]["orders"]) {
              EnquiryListingModel dataModel = EnquiryListingModel();
              dataModel.creatorName = element["creator_name"].toString();
              dataModel.orderID = element["order_id"].toString();
              dataModel.ordertype = element["order_type"].toString();
              dataModel.orderNumber = element["order_number"].toString();
              dataModel.orderDate = element["order_date"].toString();
              dataModel.customerName = element["customer_name"].toString();
              dataModel.customerMobileNumber =
                  element["customer_mobile_number"].toString();
              dataModel.deliveryAddress =
                  element["delivery_address"].toString();
              dataModel.newOrder = int.parse(element["new_order"].toString());
              dataModel.confirmed = int.parse(element["confirmed"].toString());
              dataModel.despatched =
                  int.parse(element["despatched"].toString());
              dataModel.delivered = int.parse(element["delivered"].toString());
              dataModel.deliveryNumber = element["delivery_number"].toString();
              dataModel.deliveryParticulars =
                  element["delivery_particulars"].toString();

              dataModel.subTotal = element["sub_total"].toString();
              dataModel.extraDiscount = element["extra_discount"].toString();
              dataModel.extraDiscountValue =
                  element["extra_discount_value"].toString();
              dataModel.extraDiscountTotal =
                  element["extra_discount_total"].toString();
              dataModel.couponDiscount = element["coupon_discount"].toString();
              dataModel.couponDiscountValue =
                  element["coupon_discount_value"].toString();
              dataModel.couponDiscountTotal =
                  element["coupon_discount_total"].toString();
              dataModel.packingCharges = element["packing_charges"].toString();
              dataModel.packingChargesValue =
                  element["packing_charges_value"].toString();
              dataModel.grandTotal = element["grand_total"].toString();
              dataModel.roundOff = element["round_off"].toString();
              dataModel.totalAmount = element["total_amount"].toString();

              dataModel.productList = [];
              for (var productElement in element["product_list"]) {
                EnquiryProductModel productModel = EnquiryProductModel();
                productModel.code = productElement["code"].toString();
                productModel.name = productElement["name"].toString();
                productModel.content = productElement["content"].toString();
                productModel.productPrice =
                    productElement["product_price"].toString();
                productModel.quantity = productElement["quantity"].toString();
                productModel.discount = productElement["discount"].toString();
                productModel.amount = productElement["amount"].toString();
                dataModel.productList!.add(productModel);
              }
              setState(() {
                if (tabController!.index == 0) {
                  enquiryList.add(dataModel);
                } else if (tabController!.index == 1) {
                  frontEnquiryList.add(dataModel);
                } else if (tabController!.index == 2) {
                  backEnquiryList.add(dataModel);
                }
              });
            }
          }
          for (var customerElement in result["body"]["customer"]) {
            setState(() {
              customerList.add(
                DropdownMenuItem(
                  value: customerElement["filter_customer_id"].toString(),
                  child: Text(customerElement["customer_name"].toString()),
                ),
              );
            });
          }
          for (var staffElement in result["body"]["staff"]) {
            setState(() {
              staffList.add(
                DropdownMenuItem(
                  value: staffElement["filter_staff_id"].toString(),
                  child: Text(staffElement["staff_name"]),
                ),
              );
            });
          }
          for (var enquiryTypeElement in result["body"]["enquiry_type"]) {
            setState(() {
              orderTypeList.add(
                DropdownMenuItem(
                  value: enquiryTypeElement["filter_order_type"].toString(),
                  child: Text(enquiryTypeElement["enquiry_type"]),
                ),
              );
            });
          }
          for (var promotionCodeElement in result["body"]["promotion_code"]) {
            setState(() {
              promotionCodeList.add(
                DropdownMenuItem(
                  value: promotionCodeElement["filter_promotion_code_id"]
                      .toString(),
                  child: Text(promotionCodeElement["promotion_code_name"]),
                ),
              );
            });
          }
          for (var statusElement in result["body"]["status"]) {
            setState(() {
              statusList.add(
                DropdownMenuItem(
                  value: statusElement["filter_status"].toString(),
                  child: Text(statusElement["status"]),
                ),
              );
            });
          }
        }
        return result;
      }).catchError((onError) {
        throw onError;
      });
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  Future<dynamic> onSelectNotification(payload) async {
    Map<String, dynamic> action = jsonDecode(payload);
    _handleMessage(action);
  }

  Future<void> setupInteractedMessage() async {
    await FirebaseMessaging.instance.getInitialMessage().then((value) =>
        _handleMessage(value != null ? value.data : <String, dynamic>{}));
  }

  _handleMessage(Map<String, dynamic> data) {
    setState(() {
      // enquiryHandler = getEnquiry();
    });
    if (data['redirect'] == "notification") {
      setState(() {});
    }
  }

  notificationListen() {
    if (mounted) {
      setState(() {
        // enquiryHandler = getEnquiry();
      });
    }
  }

  showFilterSheet() async {
    var result = await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return EnquiryFilter(
          customerList: customerList,
          orderTypeList: orderTypeList,
          staffList: staffList,
          promotionCodeList: promotionCodeList,
          statusList: statusList,
        );
      },
    );
    if (result != null) {
      enquiryHandler = getEnquiry();

      // filterPromotionCodeID = result["fdate"];
      // filtersEnquiryFun(
      //   result["FromDate"],
      //   result["ToDate"],
      //   result["CustomerID"],
      // );
    }
  }

  @override
  void initState() {
    AuthService().accountValid(context);
    tabController = TabController(length: 3, vsync: this);
    enquiryHandler = getEnquiry();
    enquiryRoutes.addListener(notificationListen);
    setupInteractedMessage();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      // ignore: unused_local_variable
      RemoteNotification? notification = message?.notification!;
    });

    FirebaseMessaging.onMessage.listen((message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      if (notification != null) {
        if (android != null || apple != null) {
          String action = jsonEncode(message.data);

          flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                "channel!.id",
                "channel!.name",
                priority: Priority.high,
                importance: Importance.max,
                setAsGroupSummary: true,
                styleInformation: DefaultStyleInformation(true, true),
                // largeIcon:
                //     const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                channelShowBadge: true,
                autoCancel: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: action,
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _handleMessage(message.data));
    super.initState();
    _controller.addListener(() {
      if (_controller.offset == _controller.position.maxScrollExtent) {
        if (loading == false) {
          if (dataComplete == false) {
            setState(() {
              loading = true;
            });
            addEnquiry();
          }
        }
      }
    });
  }

  String getFilterCount() {
    String result = "0";
    int count = 0;

    if (fromDate.text.isNotEmpty) {
      count += 1;
    }
    if (customerID != null && customerID!.isNotEmpty) {
      count += 1;
    }
    if (staffID != null && staffID!.isNotEmpty) {
      count += 1;
    }
    // if (orderTypeID != null && orderTypeID!.isNotEmpty) {
    //   count += 1;
    // }
    if (filterPromotionCodeID != null && filterPromotionCodeID!.isNotEmpty) {
      count += 1;
    }
    if (statusID != null && statusID!.isNotEmpty) {
      count += 1;
    }
    result = count.toString();
    return result;
  }

  downloadExcel() async {
    try {
      // futureLoading(context);
      LoadingOverlay.show(context);
      List<EnquiryListingModel> dataList = [];
      EnquiryInputModel model = EnquiryInputModel();
      model.equiryAdminUserID = await LocalDBConfig().getUserID();
      model.pageNumber = null;
      model.pageLimit = null;
      model.searchText = "";
      model.fromDate = fromDate.text;
      model.toDate = toDate.text;
      model.filterCustomerID = customerID ?? "";
      model.filterStaffID = staffID ?? "";
      model.filterOrderType =
          tabController!.index == 0 ? "" : orderTypeID ?? "";
      model.filterPromotionCodeID = filterPromotionCodeID ?? "";
      model.filterStatus = statusID ?? "";

      await EnquiryService()
          .getEnquiryAPI(enquiryInput: model)
          .then((result) async {
        if (result["head"]["code"] == 200 || result["head"]["code"] == 400) {
          if (result["head"]["code"] == 200) {
            for (var element in result["body"]["orders"]) {
              EnquiryListingModel dataModel = EnquiryListingModel();
              dataModel.orderID = element["order_id"].toString();
              dataModel.ordertype = element["order_type"].toString();
              dataModel.orderNumber = element["order_number"].toString();
              dataModel.orderDate = element["order_date"].toString();
              dataModel.customerName = element["customer_name"].toString();
              dataModel.customerMobileNumber =
                  element["customer_mobile_number"].toString();
              dataModel.deliveryAddress =
                  element["delivery_address"].toString();
              dataModel.newOrder = int.parse(element["new_order"].toString());
              dataModel.confirmed = int.parse(element["confirmed"].toString());
              dataModel.despatched =
                  int.parse(element["despatched"].toString());
              dataModel.delivered = int.parse(element["delivered"].toString());

              dataModel.subTotal = element["sub_total"].toString();
              dataModel.extraDiscount = element["extra_discount"].toString();
              dataModel.extraDiscountValue =
                  element["extra_discount_value"].toString();
              dataModel.extraDiscountTotal =
                  element["extra_discount_total"].toString();
              dataModel.couponDiscount = element["coupon_discount"].toString();
              dataModel.couponDiscountValue =
                  element["coupon_discount_value"].toString();
              dataModel.couponDiscountTotal =
                  element["coupon_discount_total"].toString();
              dataModel.packingCharges = element["packing_charges"].toString();
              dataModel.packingChargesValue =
                  element["packing_charges_value"].toString();
              dataModel.grandTotal = element["grand_total"].toString();
              dataModel.roundOff = element["round_off"].toString();
              dataModel.totalAmount = element["total_amount"].toString();

              dataModel.productList = [];
              for (var productElement in element["product_list"]) {
                EnquiryProductModel productModel = EnquiryProductModel();
                productModel.code = productElement["code"].toString();
                productModel.name = productElement["name"].toString();
                productModel.content = productElement["content"].toString();
                productModel.productPrice =
                    productElement["product_price"].toString();
                productModel.quantity = productElement["quantity"].toString();
                productModel.discount = productElement["discount"].toString();
                productModel.amount = productElement["amount"].toString();
                dataModel.productList!.add(productModel);
              }
              setState(() {
                dataList.add(dataModel);
              });
            }

            var excel = Excel.createExcel();
            Sheet sheet = excel['Sheet1'];
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
                .value = 'S.No';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
                .value = 'Order Type';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
                .value = 'Order Number';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
                .value = 'Order Date';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
                .value = 'Customer Name';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
                .value = 'Address';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
                .value = 'Mobile Number';
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
                .value = 'Amount';

            for (var i = 0; i < dataList.length; i++) {
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 0, rowIndex: (i + 1)))
                  .value = (i + 1);
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 1, rowIndex: (i + 1)))
                  .value = dataList[i].ordertype ?? "";
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 2, rowIndex: (i + 1)))
                  .value = dataList[i].orderNumber ?? "";
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 3, rowIndex: (i + 1)))
                  .value = dataList[i].orderDate ?? "";
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 4, rowIndex: (i + 1)))
                  .value = dataList[i].customerName ?? "";
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 5, rowIndex: (i + 1)))
                  .value = dataList[i].deliveryAddress ?? "";
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 6, rowIndex: (i + 1)))
                  .value = dataList[i].customerMobileNumber ?? "";
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 7, rowIndex: (i + 1)))
                  .value = dataList[i].totalAmount ?? "";
            }
            Uint8List data = Uint8List.fromList(excel.save()!);
            LoadingOverlay.hide();
            await helper.saveAndLaunchFile(data, 'Enquiry.xlsx');
          } else {
            throw result["head"]["msg"].toString();
          }
        }
      });
    } catch (e) {
      // Navigator.pop(context);
      LoadingOverlay.hide();
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  void dispose() {
    enquiryRoutes.addListener(notificationListen);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const Drawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        // backgroundColor: Colors.white,
        backgroundColor: const Color(0xff586F7C),
        title: const Text(
          "Enquiry List",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              iconColor: Colors.white,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              downloadExcel();
            },
            icon: const Icon(Icons.download_sharp),
            label: const Text(
              "Excel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     setState(() {
          //       searchView = searchView ? false : true;
          //       if (searchView == true) {
          //         search.clear();
          //       }
          //     });
          //   },
          //   icon: const Icon(Iconsax.search_normal_1),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Iconsax.printer),
          // ),
        ],
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabs: const [
            Tab(
              text: "All",
            ),
            Tab(
              text: "Frontend Order",
            ),
            Tab(
              text: "Backend Order",
            ),
          ],
          onTap: (value) {
            setState(() {
              if (value == 1) {
                orderTypeID =
                    '4b316c434e544676554668525a7a4a5061474a4b4f554e6f626e4d77647a3039';
              } else if (value == 2) {
                orderTypeID =
                    '57564270546d4658646d4933633031534e334279645764455931683055543039';
              }
              dataComplete = false;
              pageno = 1;
            });
            enquiryHandler = getEnquiry();
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        onPressed: () {
          showFilterSheet();
        },
        child: Badge(
          label: getFilterCount() == "0"
              ? null
              : Text(
                  getFilterCount(),
                  style: const TextStyle(color: Colors.black),
                ),
          backgroundColor:
              getFilterCount() == "0" ? Colors.transparent : Colors.white,
          child: const Icon(
            Iconsax.filter,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder(
        future: enquiryHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            var list = [];
            switch (tabController!.index) {
              case 0:
                list = enquiryList;
              case 1:
                list = frontEnquiryList;
              case 2:
                list = backEnquiryList;
              default:
                list = [];
            }

            return RefreshIndicator(
              color: const Color(0xff2F4550),
              onRefresh: () async {
                setState(() {
                  dataComplete = false;
                  pageno = 1;
                  fromDate.clear();
                  toDate.clear();
                  customerID = null;
                  staffID = null;
                  orderTypeID = tabController!.index == 0
                      ? null
                      : tabController!.index == 1
                          ? "4b316c434e544676554668525a7a4a5061474a4b4f554e6f626e4d77647a3039"
                          : "57564270546d4658646d4933633031534e334279645764455931683055543039";
                  filterPromotionCodeID = null;
                  statusID = null;
                  enquiryHandler = getEnquiry();
                  searchView = false;
                  search.clear();
                });
              },
              child: ListView(
                // controller: _controller,
                padding: const EdgeInsets.all(15),
                children: [
                  Visibility(
                    visible: searchView,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: search,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: "Search",
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Iconsax.search_normal_1),
                            suffixIcon: search.text.isNotEmpty
                                ? TextButton(
                                    onPressed: () {
                                      setState(() {
                                        search.clear();
                                      });
                                    },
                                    child: const Text(
                                      "Clear",
                                      style: TextStyle(
                                        color: Color(0xff2F4550),
                                      ),
                                    ),
                                  )
                                : null,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xff2F4550),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            searchEnquiry();
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  list.isNotEmpty ? screenView(list) : futureNoDataError(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        icon: const Icon(Iconsax.arrow_square_left),
                        onPressed: () {
                          if (pageno != 1) {
                            pageno = pageno - 1;
                            enquiryHandler = getEnquiry();
                          }
                        }),
                    Text('Page $pageno'),
                    IconButton(
                        icon: const Icon(Iconsax.arrow_right4),
                        onPressed: () {
                          (frontEnquiryList.isNotEmpty ||
                                  enquiryList.isNotEmpty ||
                                  backEnquiryList.isNotEmpty)
                              ? setState(() {
                                  pageno = pageno + 1;
                                  enquiryHandler = getEnquiry();
                                })
                              : null;
                        }),
                  ])
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return futureError(
                title: "Failed", content: snapshot.error.toString());
          } else {
            return futureWaitingLoading();
          }
        },
      ),
    );
  }

  ListView screenView(List<dynamic> list) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: list.length,
      itemBuilder: (context, index) {
        EnquiryListingModel enquiryElement = list[index];
        return GestureDetector(
          onTap: () async {
            try {
              // futureLoading(context);
              LoadingOverlay.show(context);
              if (enquiryElement.newOrder == 1) {
                await EnquiryService()
                    .updateOrderViewStatus(
                        orderID: enquiryElement.orderID ?? "")
                    .then((value) {
                  if (value != null && value["head"]["code"] == 200) {
                    LoadingOverlay.hide();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnquiryDetails(
                          enquiryModel: enquiryElement,
                        ),
                      ),
                    ).then((value) {
                      setState(() {
                        enquiryElement.newOrder = 0;
                      });
                    });
                  } else {
                    throw value["head"]["msg"].toString();
                  }
                });
              } else {
                LoadingOverlay.hide();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnquiryDetails(
                      enquiryModel: enquiryElement,
                    ),
                  ),
                ).then((value) {
                  setState(() {
                    enquiryElement.newOrder = 0;
                  });
                });
              }
            } catch (e) {
              Navigator.pop(context);
              showCustomSnackBar(context,
                  content: e.toString(), isSuccess: false);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: enquiryElement.newOrder == 1
                  ? const Color(0xffB8DBD9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    enquiryElement.newOrder == 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                            child: const Text(
                              "New",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: enquiryElement.confirmed == 1
                                  ? const Color(0xff588157)
                                  : const Color(0xfffb5607),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: enquiryElement.despatched == 1
                                  ? const Color(0xff588157)
                                  : const Color(0xfffb5607),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: enquiryElement.delivered == 1
                                  ? const Color(0xff588157)
                                  : const Color(0xfffb5607),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      enquiryElement.orderNumber ?? "",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      enquiryElement.orderDate ?? "",
                      style: const TextStyle(
                        color: Color(0xff313131),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                Text(
                  "${enquiryElement.customerName ?? ""} - ${enquiryElement.customerMobileNumber ?? ""}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enquiryElement.ordertype ?? "",
                          style: const TextStyle(
                            color: Color(0xff686868),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Visibility(
                          visible: enquiryElement.creatorName!.isNotEmpty,
                          child: Text(
                            "Created by ${enquiryElement.creatorName}",
                            style: const TextStyle(
                              color: Color(0xff686868),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "₹${enquiryElement.totalAmount ?? ""}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
