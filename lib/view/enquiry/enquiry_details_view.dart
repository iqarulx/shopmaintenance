/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '/service/http_service/enquiry_pdf_service.dart';
import '/service/http_service/enquiry_service.dart';
import '/view/custom_ui_element/delivery_alert_dialog.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/pdf_dialog.dart';
import '/view/custom_ui_element/printer_ip_port.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/enquiry/pdf_print_view.dart';
import 'package:http/http.dart' as http;
import '../../model/enquiry_model.dart';
import '../custom_ui_element/confrimation_alert_dialog.dart';

class EnquiryDetails extends StatefulWidget {
  final EnquiryListingModel enquiryModel;
  const EnquiryDetails({super.key, required this.enquiryModel});

  @override
  State<EnquiryDetails> createState() => _EnquiryDetailsState();
}

class _EnquiryDetailsState extends State<EnquiryDetails> {
  int getqty() {
    int result = 0;
    for (var element in widget.enquiryModel.productList!) {
      result += int.parse(element.quantity!);
    }
    return result;
  }

  Future getPDF(
      {required String format,
      required String type,
      required bool isPrint}) async {
    try {
      // futureLoading(context);
      LoadingOverlay.show(context);
      return await EnquiryPDFService()
          .getEnquiryPDFAPI(
              printOrderID: widget.enquiryModel.orderID ?? "",
              format: format,
              type: type)
          .then((result) {
        if (result != null && result["head"]["code"] == 200) {
          LoadingOverlay.hide();
          // Navigator.pop(context);
          if (isPrint) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFPrintView(
                  url: result["head"]["printout_file"].toString(),
                ),
              ),
            );
          } else {
            return result["head"]["printout_file"].toString();
          }
        } else {
          throw result["head"]["msg"];
        }
      });
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      // Navigator.pop(context);
      LoadingOverlay.hide();
      throw e.toString();
    }
  }

  statusUpdateFn(
      {required int status, String? deleiveryNo, String? particulars}) async {
    try {
      // futureLoading(context);
      LoadingOverlay.show(context);
      OrderConfirmModel model = OrderConfirmModel();
      model.confirmedOrderID = widget.enquiryModel.orderID;
      model.despatchedOrderID = widget.enquiryModel.orderID;
      model.deliveredOrderID = widget.enquiryModel.orderID;
      model.confirmStatus = "1";
      model.despatchedStatus = "1";
      model.deliveryStatus = "1";
      model.deliveryNumber = deleiveryNo ?? "";
      model.deliveryParticulars = particulars ?? "";
      Map<String, dynamic> data = {};
      if (status == 1) {
        data = model.toEnquiryConfirmMap();
      } else if (status == 2) {
        data = model.toEnquiryDispatchMap();
      } else if (status == 3) {
        data = model.toEnquiryDeliveryMap();
        log(data.toString());
      }

      await EnquiryService().setDeliveryStatusAPI(data: data).then((result) {
        // Navigator.pop(context);
        LoadingOverlay.hide();
        setState(() {
          if (status == 1) {
            widget.enquiryModel.confirmed = 1;
          } else if (status == 2) {
            widget.enquiryModel.despatched = 1;
          } else if (status == 3) {
            widget.enquiryModel.delivered = 1;
          }
        });
        showCustomSnackBar(context,
            content: "Successfully Update the Status", isSuccess: true);
      });
    } catch (e) {
      log(e.toString());
      // Navigator.pop(context);
      LoadingOverlay.hide();
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  showIPAddressDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => const PrinterIPPortDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      body: body(context),
    );
  }

  ListView body(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.enquiryModel.orderNumber ?? "",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.enquiryModel.orderDate ?? "",
              style: const TextStyle(
                color: Color(0xff313131),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffB8DBD9),
            border: Border.all(
              color: const Color(0xff8D99AE),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Customer",
                style: TextStyle(
                  color: Color(0xff586F7C),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.enquiryModel.customerName ?? "",
                style: const TextStyle(
                  color: Color(0xff333333),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${widget.enquiryModel.customerMobileNumber ?? ""}\n${widget.enquiryModel.deliveryAddress ?? ""}",
                // "+91 99327 82219\n37, Velliyan Street, Muthuraman Patti, Virudhunagar, Tamilnadu - 626001",
                style: const TextStyle(
                  color: Color(0xff565656),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Status",
                style: TextStyle(
                  color: Color(0xff1E1E1E),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (widget.enquiryModel.confirmed == 0) {
                        await showDialog(
                          context: context,
                          builder: (context) => const ConfrimationAlertDialog(
                            title: "Alert",
                            content: "Do you want Confirm this Enquiry ?",
                          ),
                        ).then((result) {
                          if (result != null && result) {
                            statusUpdateFn(status: 1);
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: widget.enquiryModel.confirmed == 1
                            ? const Color(0xff588157)
                            : const Color(0xfffb5607),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      if (widget.enquiryModel.confirmed == 1 &&
                          widget.enquiryModel.despatched == 0) {
                        await showDialog(
                          context: context,
                          builder: (context) => const ConfrimationAlertDialog(
                            title: "Alert",
                            content:
                                "Do you want Confirm to dispatch this Enquiry ?",
                          ),
                        ).then((result) {
                          if (result != null && result) {
                            statusUpdateFn(status: 2);
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        // color: widget.enquiryModel.despatched == 1 ? const Color(0xff2F4550) : const Color(0xffD9D9D9),
                        color: widget.enquiryModel.despatched == 1
                            ? const Color(0xff588157)
                            : const Color(0xfffb5607),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      if (widget.enquiryModel.confirmed == 1 &&
                          widget.enquiryModel.despatched == 1 &&
                          widget.enquiryModel.delivered == 0) {
                        await showDialog(
                          context: context,
                          builder: (context) => const DeliveryAlertDialog(),
                        ).then((result) {
                          if (result != null) {
                            statusUpdateFn(
                              status: 3,
                              deleiveryNo: result["no"],
                              particulars: result["particulars"],
                            );
                          }
                        });
                      } else if (widget.enquiryModel.delivered == 1) {
                        await showDialog(
                          context: context,
                          builder: (context) => DeliveryAlertDialog(
                            deliveryNumber: widget.enquiryModel.deliveryNumber,
                            deliveryParticulars:
                                widget.enquiryModel.deliveryParticulars,
                          ),
                        ).then((result) {
                          if (result != null) {
                            statusUpdateFn(
                              status: 3,
                              deleiveryNo: result["no"],
                              particulars: result["particulars"],
                            );
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: widget.enquiryModel.delivered == 1
                            ? const Color(0xff588157)
                            : const Color(0xfffb5607),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Print Option",
                    style: TextStyle(
                      color: Color(0xff1E1E1E),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      iconColor: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      await getPDF(format: 'A4', type: "1", isPrint: false)
                          .then((url) async {
                        // futureLoading(context);
                        LoadingOverlay.show(context);
                        log(url.toString());
                        if (url != null && url.toString().isNotEmpty) {
                          await http
                              .get(Uri.parse(url))
                              .then((http.Response response) async {
                            // ignore: unused_local_variable
                            var pdfData = response.bodyBytes;
                            // Navigator.pop(context);
                            LoadingOverlay.hide();
                            await Printing.sharePdf(bytes: pdfData);
                          });
                        } else {
                          // Navigator.pop(context);
                          LoadingOverlay.hide();
                        }
                      });
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView(
                primary: false,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const PDFDialog(),
                      ).then((result) {
                        if (result != null) {
                          getPDF(
                              format: "A4",
                              type: result.toString(),
                              isPrint: true);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffB8DBD9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "A4",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const PDFDialog(),
                      ).then((result) {
                        if (result != null) {
                          getPDF(
                              format: "A5",
                              type: result.toString(),
                              isPrint: true);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffB8DBD9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "A5",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      getPDF(format: "Thermal", type: "", isPrint: true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffB8DBD9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Thermal",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      showIPAddressDialog();
                      getPDF(format: "3-inch", type: "", isPrint: true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffB8DBD9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "3-inch",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Products (${widget.enquiryModel.productList!.length})",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Items(${getqty()})",
                    style: const TextStyle(
                      color: Color(0xffA5A5A5),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: widget.enquiryModel.productList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.enquiryModel.productList![index].name ??
                                    "",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "₹${widget.enquiryModel.productList![index].productPrice} / ${widget.enquiryModel.productList![index].content}",
                                style: const TextStyle(
                                  color: Color(0xff686868),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${widget.enquiryModel.productList![index].quantity}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            "₹${widget.enquiryModel.productList![index].amount}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Subtotal",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹${widget.enquiryModel.subTotal}",
                    style: const TextStyle(
                      color: Color(0xff545454),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              widget.enquiryModel.extraDiscountValue != "0"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Extra Discount(${widget.enquiryModel.extraDiscount})",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${widget.enquiryModel.extraDiscountValue}",
                          style: const TextStyle(
                            color: Color(0xff545454),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              widget.enquiryModel.extraDiscountTotal != "0"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Extra Discount Total",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${widget.enquiryModel.extraDiscountTotal}",
                          style: const TextStyle(
                            color: Color(0xff545454),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              widget.enquiryModel.couponDiscountValue != "0"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Coupon Discount(${widget.enquiryModel.couponDiscount})",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${widget.enquiryModel.couponDiscountValue}",
                          style: const TextStyle(
                            color: Color(0xff545454),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              widget.enquiryModel.couponDiscountTotal != "0"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Coupon Discount Total",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${widget.enquiryModel.couponDiscountTotal}",
                          style: const TextStyle(
                            color: Color(0xff545454),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              widget.enquiryModel.packingChargesValue != "0"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Packing Charges(${widget.enquiryModel.packingCharges})",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${widget.enquiryModel.packingChargesValue}",
                          style: const TextStyle(
                            color: Color(0xff545454),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Grand Total",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹${widget.enquiryModel.grandTotal}",
                    style: const TextStyle(
                      color: Color(0xff545454),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Round off",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹${widget.enquiryModel.roundOff}",
                    style: const TextStyle(
                      color: Color(0xff545454),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹${widget.enquiryModel.totalAmount}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      // backgroundColor: Colors.white,
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Enquiry Details",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton.icon(
          style: TextButton.styleFrom(
            iconColor: Colors.white,
            foregroundColor: Colors.white30,
          ),
          onPressed: () async {
            await getPDF(format: 'A4', type: "1", isPrint: false)
                .then((url) async {
              // futureLoading(context);
              LoadingOverlay.show(context);
              log(url.toString());
              if (url != null && url.toString().isNotEmpty) {
                await http
                    .get(Uri.parse(url))
                    .then((http.Response response) async {
                  // ignore: unused_local_variable
                  var pdfData = response.bodyBytes;
                  // Navigator.pop(context);
                  LoadingOverlay.hide();
                  await Printing.sharePdf(bytes: pdfData);
                });
              } else {
                // Navigator.pop(context);
                LoadingOverlay.hide();
              }
            });
          },
          icon: const Icon(Icons.share_rounded),
          label: const Text(
            "Share",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
