/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/category_model.dart';
import '/service/http_service/category_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '../../provider/fingerprint_provider.dart';
import '../custom_ui_element/show_custom_snackbar.dart';

class CategoryForm extends StatefulWidget {
  final String? categoryId;

  const CategoryForm({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  List<CategoryEditingModel> categoryDataList = [];
  final TextEditingController _categoryNameController = TextEditingController();
  Future<bool>? categoryEditHandler;

  @override
  initState() {
    categoryEditHandler = categoryEditView();
    super.initState();
  }

  Future<bool> categoryEditView() async {
    try {
      setState(() {
        categoryDataList.clear();
      });

      if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
        var resultData = await CategoryService()
            .editCategory(categoryId: widget.categoryId!);

        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var element in resultData["head"]["msg"]) {
            CategoryEditingModel model = CategoryEditingModel();
            model.name = element["category_name"].toString();
            model.companyId = element["category_id"].toString();
            categoryDataList.add(model);
          }
          return true; // Data fetched successfully
        } else if (resultData != null && resultData["head"]["code"] == 400) {
          showCustomSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
        }
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

  submitForm() async {
    var userId = await LocalDBConfig().getUserID();
    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'edit_category_id': widget.categoryId.toString(),
      'category_name': _categoryNameController.text
    };
    try {
      await LocalAuthConfig()
          .checkBiometrics(context, 'Category')
          .then((value) {
        if (value) {
          LoadingOverlay.show(context);
          CategoryService().updateCategory(formData: formData).then((value) {
            LoadingOverlay.hide();
            Navigator.pop(context, true);
            if (value['head']['code'] == 200) {
              showCustomSnackBar(context,
                  content: value['head']['msg'], isSuccess: true);
              NotificationService().showNotification(
                  title: "Category Updated",
                  body: "Category has updated successfully.");
            } else {
              Navigator.pop(context);
              showCustomSnackBar(context,
                  content: value['head']['msg'], isSuccess: false);
            }
          });
        } else {
          showCustomSnackBar(context,
              content: "Auth Failed. Please try again!", isSuccess: false);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  @override
  dispose() {
    _categoryNameController.dispose();
    categoryDataList.clear();

    super.dispose();
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureNetworkError();
          } else {
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          if (snapshot.data != null && snapshot.data!) {
            _categoryNameController.text = categoryDataList.isNotEmpty
                ? categoryDataList[0].name ?? ''
                : '';
            return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    categoryEditHandler = categoryEditView();
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
      child: Form(
        key: _formKey,
        child: categoryForm(context),
      ),
    );
  }

  Column categoryForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Category Name(*)",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _categoryNameController,
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
            hintText: "Category Name",
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixIcon: const Icon(Iconsax.category),
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
              return 'Please enter a category name';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
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
        widget.categoryId != null && widget.categoryId!.isNotEmpty
            ? "Edit Category"
            : "Add Category",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
