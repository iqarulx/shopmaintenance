/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';

class DeliveryAlertDialog extends StatefulWidget {
  final String? deliveryNumber;
  final String? deliveryParticulars;
  const DeliveryAlertDialog(
      {super.key, this.deliveryNumber, this.deliveryParticulars});

  @override
  State<DeliveryAlertDialog> createState() => _DeliveryAlertDialogState();
}

class _DeliveryAlertDialogState extends State<DeliveryAlertDialog> {
  TextEditingController deliveryNo = TextEditingController();
  TextEditingController particulars = TextEditingController();

  @override
  void initState() {
    if (widget.deliveryNumber != null && widget.deliveryParticulars != null) {
      deliveryNo.text = widget.deliveryNumber ?? "";
      particulars.text = widget.deliveryParticulars ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const Text("Alert"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Do you want Confirm to Delivery ?",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 15),
          Text(
            'Delivery No',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: deliveryNo,
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
            decoration: InputDecoration(
              hintText: "Delivery Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Particulars',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: particulars,
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
            decoration: InputDecoration(
              hintText: "Particulars",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffF2F2F2),
                  ),
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xff575757),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                  Navigator.pop(context, {
                    "no": deliveryNo.text,
                    "particulars": particulars.text,
                  });
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: const Center(
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: Color(0xffF4F4F9),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
