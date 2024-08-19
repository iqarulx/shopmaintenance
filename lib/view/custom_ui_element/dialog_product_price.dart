/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProductPriceDialogProduct extends StatefulWidget {
  final String productName;
  final String productId, oldPrice;
  const ProductPriceDialogProduct(
      {super.key,
      required this.productName,
      required this.productId,
      required this.oldPrice});

  @override
  State<ProductPriceDialogProduct> createState() =>
      _ProductPriceDialogProductState();
}

class _ProductPriceDialogProductState extends State<ProductPriceDialogProduct> {
  TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  submitForm() async {
    var data = priceController.text;
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    priceController.text = widget.oldPrice.replaceAll(",", "");
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const Text("Update Price"),
      content: SizedBox(
        height: 115,
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Update price for ${widget.productName}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Price",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(Iconsax.money),
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
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, '');
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
                  if (_formKey.currentState!.validate()) {
                    submitForm();
                  }
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: const Center(
                    child: Text(
                      "Update",
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
