/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '/view/custom_ui_element/public_variable.dart';

class ReportFilter extends StatefulWidget {
  const ReportFilter({
    super.key,
  });

  @override
  State<ReportFilter> createState() => _ReportFilterState();
}

class _ReportFilterState extends State<ReportFilter> {
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

  clearNow() {
    setState(() {
      fromDate.clear();
      toDate.clear();
      selectedOption = null;
    });
  }

  applyNow() {
    if (fromDate.text.isEmpty) {
      fromDate.text = DateFormat('dd-MM-yyyy')
          .format(DateTime.now().subtract(const Duration(days: 30)));
    }
    if (toDate.text.isEmpty) {
      toDate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
    var data = {
      "from_date": fromDate.text,
      "to_date": toDate.text,
      "status": selectedOption ?? ''
    };
    Navigator.pop(context, data);
  }

  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appbar(context),
        bottomNavigationBar: bottomAppbar(context),
        body: body(context),
      ),
    );
  }

  ListView body(BuildContext context) {
    return ListView(
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
                            //     FocusManager.instance.primaryFocus!.unfocus();
                            //   });
                            // },
                            // onTapOutside: (event) {
                            //   setState(() {
                            //     FocusManager.instance.primaryFocus!.unfocus();
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
                            //     FocusManager.instance.primaryFocus!.unfocus();
                            //   });
                            // },
                            // onTapOutside: (event) {
                            //   setState(() {
                            //     FocusManager.instance.primaryFocus!.unfocus();
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
                  "Status",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.black54),
                ),
                const SizedBox(
                  height: 8,
                ),
                DropdownButtonFormField<String>(
                  value: selectedOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Status',
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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: '1',
                      child: Text('Confirmed'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text('Despatched'),
                    ),
                    DropdownMenuItem(
                      value: '3',
                      child: Text('Delivered'),
                    ),
                    DropdownMenuItem(
                      value: '4',
                      child: Text('Status Not Updated'),
                    ),
                    DropdownMenuItem(
                      value: '5',
                      child: Text('New Order'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
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
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
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
        "Sales Report Fillter",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
