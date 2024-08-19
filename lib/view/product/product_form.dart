/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/product_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/http_service/product_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '../custom_ui_element/show_custom_snackbar.dart';

class ProductForm extends StatefulWidget {
  final String? productId;

  const ProductForm({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  List<ProductEditModel> productDataList = [];
  List<CategoryListingForProductModel> categoryList = [];
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productCodeController = TextEditingController();
  final TextEditingController productContentController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController productVideoController = TextEditingController();
  String? selectedCategoryName;
  String? selectedCategoryId;

  String? firstCategoryId;
  String? initialCategoryName;

  Future<bool> productEditView() async {
    try {
      setState(() {
        productDataList.clear();
        categoryList.clear();
      });

      var resultData =
          await ProductService().editProduct(productId: widget.productId ?? '');
      if (resultData != null && resultData["head"]["code"] == 200) {
        for (var element in resultData["head"]["msg"]["product_data"]) {
          ProductEditModel model = ProductEditModel();
          model.categoryId = element["category_id"].toString();
          model.productName = element["name"].toString();
          model.productCode = element["product_code"].toString();
          model.productContent = element["product_content"].toString();
          model.price = element["price"].toString();
          model.productVideo = element["product_video"].toString();
          setState(() {
            productDataList.add(model);
          });
        }

        List<dynamic> categoryDataList =
            resultData["head"]["msg"]["category_data"];
        for (var element in categoryDataList) {
          CategoryListingForProductModel model =
              CategoryListingForProductModel();
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

      return true;
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  Future<bool>? categoryEditHandler;

  void submitForm() async {
    if (selectedCategoryId != null) {
      var userId = await LocalDBConfig().getUserID();
      Map<String, String> formData = {
        'creator_id': userId.toString(),
        'edit_product_id': widget.productId ?? '',
        'category_id': selectedCategoryId.toString(),
        'product_name': productNameController.text,
        'product_code': productCodeController.text,
        'product_content': productContentController.text,
        'price': priceController.text,
        'video_url': productVideoController.text
      };
      try {
        await LocalAuthConfig()
            .checkBiometrics(context, 'Product')
            .then((value) {
          if (value) {
            // futureLoading(context),
            LoadingOverlay.show(context);

            ProductService().updateProduct(formData: formData).then((value) => {
                  LoadingOverlay.hide(),
                  if (value['head']['code'] == 200)
                    {
                      showCustomSnackBar(context,
                          content: value['head']['msg'], isSuccess: true),
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context, true);
                      }),
                      NotificationService().showNotification(
                          title: "Product Updated",
                          body: "Product has updated successfully.")
                    }
                  else
                    {
                      showCustomSnackBar(context,
                          content: value['head']['msg'], isSuccess: false)
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
    } else {
      showCustomSnackBar(context, content: "Select Category", isSuccess: false);
    }
  }

  initSettings() {
    for (var model in productDataList) {
      model.categoryId != ''
          ? selectedCategoryId = model.categoryId
          : selectedCategoryId = null;
    }
  }

  @override
  void initState() {
    categoryEditHandler = productEditView().whenComplete(initSettings);
    super.initState();
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
        body: body(),
      ),
    );
  }

  FutureBuilder<bool> body() {
    return FutureBuilder<bool>(
      future: categoryEditHandler,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureWaitingLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureNetworkError();
          } else {
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          if (snapshot.data != null && snapshot.data!) {
            productNameController.text = productDataList.isNotEmpty
                ? productDataList[0].productName ?? ''
                : '';
            productCodeController.text = productDataList.isNotEmpty
                ? productDataList[0].productCode ?? ''
                : '';
            productContentController.text = productDataList.isNotEmpty
                ? productDataList[0].productContent ?? ''
                : '';
            priceController.text = productDataList.isNotEmpty
                ? productDataList[0].price ?? ''
                : '';
            productVideoController.text = productDataList.isNotEmpty
                ? productDataList[0].productVideo ?? ''
                : '';

            firstCategoryId = productDataList.isNotEmpty
                ? productDataList[0].categoryId ?? ''
                : '';

            initialCategoryName = firstCategoryId != ''
                ? categoryList
                    .firstWhere(
                        (category) => category.categoryId == firstCategoryId)
                    .categoryName
                : '';

            return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    categoryEditHandler = productEditView();
                  });
                },
                child: screenView(context));
          } else {
            return const Center(child: Text("Failed to fetch data"));
          }
        }
      },
    );
  }

  Padding screenView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              categoryDropdown(context),
              const SizedBox(height: 14),
              productName(context),
              const SizedBox(height: 14),
              productCode(context),
              const SizedBox(height: 14),
              productContent(context),
              const SizedBox(height: 14),
              priceFeild(context),
              const SizedBox(height: 14),
              videoUrlFeild(context),
            ],
          ),
        ),
      ),
    );
  }

  Column categoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category Name(*)",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        initialCategoryName != ''
            ? CustomDropdown<String>.search(
                initialItem: initialCategoryName,
                hintText: 'Select category',
                items: categoryList
                    .map((category) => category.categoryName!)
                    .toList(),
                decoration: CustomDropdownDecoration(
                  expandedBorderRadius: BorderRadius.circular(10),
                  expandedBorder: Border.all(color: Colors.black),
                  closedBorderRadius: BorderRadius.circular(10),
                  closedBorder: Border.all(color: Colors.black),
                  closedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  expandedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.black,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  listItemStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  searchFieldDecoration: const SearchFieldDecoration(
                    textStyle: TextStyle(
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                overlayHeight: 342,
                onChanged: (value) {
                  setState(() {
                    selectedCategoryName = value;
                  });
                  setState(() {
                    selectedCategoryId = categoryList
                        .firstWhere(
                            (category) => category.categoryName == value)
                        .categoryId;
                  });
                  print(selectedCategoryId);
                },
              )
            : CustomDropdown<String>.search(
                hintText: 'Select category',
                items: categoryList
                    .map((category) => category.categoryName!)
                    .toList(),
                decoration: CustomDropdownDecoration(
                  expandedBorderRadius: BorderRadius.circular(10),
                  expandedBorder: Border.all(color: Colors.black),
                  closedBorderRadius: BorderRadius.circular(10),
                  closedBorder: Border.all(color: Colors.black),
                  closedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  expandedSuffixIcon: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.black,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  listItemStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  searchFieldDecoration: const SearchFieldDecoration(
                    textStyle: TextStyle(
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                overlayHeight: 342,
                onChanged: (value) {
                  setState(() {
                    selectedCategoryName = value;
                  });
                  setState(() {
                    selectedCategoryId = categoryList
                        .firstWhere(
                            (category) => category.categoryName == value)
                        .categoryId;
                  });
                },
              )
      ],
    );
  }

  Column videoUrlFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video Url",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: productVideoController,
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
            hintText: "Video Url",
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixIcon: const Icon(Iconsax.video),
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
    );
  }

  Column priceFeild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price(*)",
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Column productContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Content(*)",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: productContentController,
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
            hintText: "Product Content",
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixIcon: const Icon(Iconsax.text_block),
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
              return 'Please enter a content';
            }
            return null;
          },
        ),
      ],
    );
  }

  Column productCode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Code(*)",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: productCodeController,
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
            hintText: "Product Code",
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixIcon: const Icon(Iconsax.code),
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
              return 'Please enter a product code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Column productName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Name(*)",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: productNameController,
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
            hintText: "Product Name",
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product name';
            }
            return null;
          },
        ),
      ],
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            submitForm();
          }
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
        widget.productId != null && widget.productId!.isNotEmpty
            ? "Edit Product"
            : "Add Product",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
