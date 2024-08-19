/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '/view/custom_ui_element/public_variable.dart';

class EnquiryFilter extends StatefulWidget {
  final List<DropdownMenuItem> customerList;
  final List<DropdownMenuItem> staffList;
  final List<DropdownMenuItem> orderTypeList;
  final List<DropdownMenuItem> promotionCodeList;
  final List<DropdownMenuItem> statusList;
  const EnquiryFilter({
    super.key,
    required this.customerList,
    required this.staffList,
    required this.orderTypeList,
    required this.promotionCodeList,
    required this.statusList,
  });

  @override
  State<EnquiryFilter> createState() => _EnquiryFilterState();
}

class _EnquiryFilterState extends State<EnquiryFilter> {
  Future<DateTime?> datePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    return picked;
  }

  fromDatePicker() async {
    final DateTime? picked = await datePicker();
    if (picked != null) {
      setState(() {
        fromDate.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  toDatePicker() async {
    final DateTime? picked = await datePicker();

    if (picked != null) {
      setState(() {
        toDate.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  String? error;

  bool active() {
    if (fromDate.text.isEmpty &&
        toDate.text.isEmpty &&
        customerID == null &&
        staffID == null &&
        orderTypeID == null) {
      return false;
    } else if (fromDate.text.isNotEmpty && toDate.text.isEmpty) {
      return false;
    } else if (fromDate.text.isEmpty && toDate.text.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }

  clearNow() {
    setState(() {
      fromDate.clear();
      toDate.clear();
      customerID = null;
      staffID = null;
      orderTypeID = null;
      filterPromotionCodeID = null;
      statusID = null;
    });
  }

  applyNow() {
    // if (fromDate.text.isEmpty && toDate.text.isEmpty && customerID == null && staffID == null && orderTypeID == null) {
    //   setState(() {
    //     error = "";
    //   });
    // } else if (fromDate.text.isNotEmpty && toDate.text.isEmpty) {
    // } else if (fromDate.text.isEmpty && toDate.text.isNotEmpty) {
    // } else {
    //   var data = {
    //     "fdate": fromDate.text,
    //     "tdate": toDate.text,
    //     "customer": customerID ?? "",
    //     "staff": staffID ?? "",
    //     "order": orderTypeID ?? "",
    //   };
    //   Navigator.pop(context, data);
    // }

    if (fromDate.text.isNotEmpty && toDate.text.isEmpty) {
      error = "";
    } else if (fromDate.text.isEmpty && toDate.text.isNotEmpty) {
    } else {
      var data = {
        "fdate": fromDate.text,
        "tdate": toDate.text,
        "customer": customerID ?? "",
        "staff": staffID ?? "",
        "order": orderTypeID ?? "",
      };
      Navigator.pop(context, data);
    }
  }

  @override
  void dispose() {
    customerList.clear();
    orderTypeList.clear();
    staffList.clear();
    promotionCodeList.clear();
    statusList.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    customerList.add(const DropdownMenuItem(
      value: null,
      child: Text(
        "Select a Customer",
        style: TextStyle(color: Colors.grey),
      ),
    ));
    customerList.addAll(widget.customerList);
    orderTypeList.add(const DropdownMenuItem(
      value: null,
      child: Text(
        "Select a Order Type",
        style: TextStyle(color: Colors.grey),
      ),
    ));
    orderTypeList.addAll(widget.orderTypeList);
    staffList.add(const DropdownMenuItem(
      value: null,
      child: Text(
        "Select a Staff",
        style: TextStyle(color: Colors.grey),
      ),
    ));
    staffList.addAll(widget.staffList);
    promotionCodeList.add(const DropdownMenuItem(
      value: null,
      child: Text(
        "Select a Promotion Code",
        style: TextStyle(color: Colors.grey),
      ),
    ));
    promotionCodeList.addAll(widget.promotionCodeList);
    statusList.add(const DropdownMenuItem(
      value: null,
      child: Text(
        "Select a Status",
        style: TextStyle(color: Colors.grey),
      ),
    ));
    statusList.addAll(widget.statusList);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                splashRadius: 20,
                constraints: const BoxConstraints(
                  maxWidth: 40,
                  maxHeight: 40,
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            "Enquiry Fillter",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    clearNow();
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Clear",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    applyNow();
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xff2F4550),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Apply Now",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "From Date",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                controller: fromDate,
                                // onEditingComplete: () {
                                //   setState(() {
                                //     FocusManager.instance.primaryFocus!
                                //         .unfocus();
                                //   });
                                // },
                                // onTapOutside: (event) {
                                //   setState(() {
                                //     FocusManager.instance.primaryFocus!
                                //         .unfocus();
                                //   });
                                // },
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Form Date",
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  prefixIcon: const Icon(Iconsax.calendar_1),
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
                                onTap: () => fromDatePicker(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "To Date",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                controller: toDate,
                                // onEditingComplete: () {
                                //   setState(() {
                                //     FocusManager.instance.primaryFocus!
                                //         .unfocus();
                                //   });
                                // },
                                // onTapOutside: (event) {
                                //   setState(() {
                                //     FocusManager.instance.primaryFocus!
                                //         .unfocus();
                                //   });
                                // },
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "To Date",
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  prefixIcon: const Icon(Iconsax.calendar_1),
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
                                onTap: () => toDatePicker(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      "Choose Customer",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.black54),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    DropdownButtonFormField(
                      value: customerID,
                      isExpanded: true,
                      items: customerList,
                      onChanged: (onChanged) {
                        setState(() {
                          customerID = onChanged;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Choose Customer",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Iconsax.user),
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
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      "Choose Staff",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.black54),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    DropdownButtonFormField(
                      value: staffID,
                      isExpanded: true,
                      items: staffList,
                      onChanged: (onChanged) {
                        setState(() {
                          staffID = onChanged;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Choose Staff",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Iconsax.user),
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
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    // Text(
                    //   "Choose Order Type",
                    //   style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54),
                    // ),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    // DropdownButtonFormField(
                    //   value: orderTypeID,
                    //   isExpanded: true,
                    //   items: orderTypeList,
                    //   onChanged: (onChanged) {
                    //     setState(() {
                    //       orderTypeID = onChanged;
                    //     });
                    //   },
                    //   decoration: InputDecoration(
                    //     hintText: "Choose Order Type",
                    //     filled: true,
                    //     fillColor: Colors.grey.shade200,
                    //     prefixIcon: const Icon(Iconsax.box),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderSide: BorderSide(
                    //         color: Colors.grey.shade300,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(
                    //         color: Colors.grey.shade300,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide: const BorderSide(
                    //         color: Color(0xff2F4550),
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 14,
                    // ),
                    Text(
                      "Promotion Code",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.black54),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    DropdownButtonFormField(
                      value: filterPromotionCodeID,
                      isExpanded: true,
                      items: promotionCodeList,
                      onChanged: (onChanged) {
                        setState(() {
                          filterPromotionCodeID = onChanged;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Promotion Code",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Iconsax.box),
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
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      "Status",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.black54),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    DropdownButtonFormField(
                      value: statusID,
                      isExpanded: true,
                      items: statusList,
                      onChanged: (onChanged) {
                        setState(() {
                          statusID = onChanged;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Status",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Iconsax.box),
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
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
