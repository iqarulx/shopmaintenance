/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/discount_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/http_service/discount_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '../custom_ui_element/show_custom_snackbar.dart';

class DiscountForm extends StatefulWidget {
  final String? discountId;

  const DiscountForm({Key? key, required this.discountId}) : super(key: key);

  @override
  State<DiscountForm> createState() => _DiscountFormState();
}

class _DiscountFormState extends State<DiscountForm> {
  final _formKey = GlobalKey<FormState>();
  List<DiscountEditingModel> discountDataList = [];
  List<CategoryListingForDiscountModel> categoryList = [];
  final TextEditingController discountController = TextEditingController();
  String? selectedCategoryName;
  String? selectedCategoryId;

  String? firstCategoryId;
  String? initialCategoryName;

  Future<bool> discountEditView() async {
    try {
      setState(() {
        discountDataList.clear();
        categoryList.clear();
      });

      var resultData = await DiscountService()
          .editDiscount(discountId: widget.discountId ?? '');
      if (resultData.isNotEmpty) {
        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var element in resultData["head"]["msg"]["discount_data"]) {
            DiscountEditingModel model = DiscountEditingModel();
            model.discount = element["discount"].toString();
            model.categoryIds = element["category_ids"];

            setState(() {
              discountDataList.add(model);
            });
          }

          List<dynamic> categoryDataList =
              resultData["head"]["msg"]["category_list"];
          for (var element in categoryDataList) {
            CategoryListingForDiscountModel model =
                CategoryListingForDiscountModel();
            model.categoryId = element["category_id"].toString();
            model.categoryName = element["category_name"].toString();

            setState(() {
              categoryList.add(model);
            });
          }
          return true;
        } else if (resultData != null && resultData["head"]["code"] == 400) {
          showCustomSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
        }
      } else {
        errorSnackbar(context);
      }
      return true;
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  Future<bool>? discountEditHandler;
  List<dynamic> categoryIds = [];

  initSettings() async {
    setState(() {
      categoryIds = discountDataList[0].categoryIds!;
      discountController.text = discountDataList[0].discount!;
    });
  }

  @override
  void initState() {
    discountEditHandler = discountEditView().whenComplete(initSettings);
    super.initState();
  }

  submitForm() async {
    var userId = await LocalDBConfig().getUserID();
    var domain = await LocalDBConfig().getdomain();
    var adminPath = await LocalDBConfig().getAdminPath();

    Map<String, String> formData = {
      'domain_name': domain ?? '',
      'admin_folder_name': adminPath ?? '',
      'creator_id': userId.toString(),
      'edit_discount_id': widget.discountId ?? '',
      'discount': discountController.text,
      'category_ids': categoryIds
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(' ', ''),
    };

    try {
      await LocalAuthConfig()
          .checkBiometrics(context, 'Discount')
          .then((value) {
        if (value) {
          LoadingOverlay.show(context);
          DiscountService().updateDiscount(formData: formData).then((value) {
            LoadingOverlay.hide();
            if (value.isNotEmpty) {
              if (value['head']['code'] == 200) {
                showCustomSnackBar(context,
                    content: value['head']['msg'], isSuccess: true);
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pop(context, true);
                });
                NotificationService().showNotification(
                    title: "Discount Updated",
                    body: "Discount has updated successfully.");
              } else {
                showCustomSnackBar(context,
                    content: value['head']['msg'], isSuccess: false);
              }
            } else {
              errorSnackbar(context);
            }
          });
        } else {
          showCustomSnackBar(context,
              content: "Auth Failed. Please try again!", isSuccess: false);
        }
      });
    } catch (e) {
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
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
        appBar: appbar(context),
        bottomNavigationBar: bottomAppbar(context),
        body: FutureBuilder<bool>(
          future: discountEditHandler,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              if (snapshot.error == 'Network Error') {
                return futureNetworkError();
              } else {
                return futureDisplayError(content: snapshot.error.toString());
              }
            } else {
              if (snapshot.data != null && snapshot.data!) {
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      discountEditHandler = discountEditView();
                    });
                  },
                  child: screenView(context),
                );
              } else {
                return const Center(child: Text("Failed to fetch data"));
              }
            }
          },
        ),
      ),
    );
  }

  ListView screenView(BuildContext context) {
    return ListView(
      children: [
        Form(key: _formKey, child: discountFeild(context)),
        categoryOptions(),
      ],
    );
  }

  ListView categoryOptions() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final category = categoryList[index];
        final categoryId = category.categoryId.toString();

        bool switchValue = false;
        if (discountDataList.isNotEmpty &&
            discountDataList[0].categoryIds != null) {
          switchValue = discountDataList[0].categoryIds!.contains(categoryId);
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Text(
                categoryList[index].categoryName!.length > 20
                    ? '${categoryList[index].categoryName!.substring(0, 20)}...'
                    : categoryList[index].categoryName!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoSwitch(
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      categoryIds.add(categoryList[index].categoryId);
                    } else {
                      categoryIds.remove(categoryList[index].categoryId);
                    }
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }

  Padding discountFeild(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Discount",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: discountController,
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Discount",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.percentage_circle),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a discount';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          // if (_formKey.currentState!.validate()) {
          submitForm();
          // }
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
              "Submit",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
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
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        widget.discountId != null && widget.discountId!.isNotEmpty
            ? "Edit Discount"
            : "Add Discount",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
