/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import '../custom_ui_element/error_snackbar.dart';
import '/model/category_model.dart';
import '/service/http_service/category_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class CategoryOrderEdit extends StatefulWidget {
  const CategoryOrderEdit({super.key});

  @override
  State<CategoryOrderEdit> createState() => _CategoryOrderEditState();
}

class _CategoryOrderEditState extends State<CategoryOrderEdit> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  List<CategoryListingModel> categoryList = [];
  List<TextEditingController> _controllers = [];
  Future? categoryHandler;

  @override
  void initState() {
    categoryHandler = categoryListView();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> categoryListView() async {
    try {
      setState(() {
        categoryList.clear();
      });

      return await CategoryService().getcategoryList().then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var element in resultData["head"]["msg"]) {
            CategoryListingModel model = CategoryListingModel();
            model.name = element["category_name"].toString();
            model.creator = element["creator_name"].toString();
            model.categoryId = element["category_id"].toString();
            model.showFrontend = element["show_frontend"].toString();
            setState(() {
              categoryList.add(model);
            });
          }
          _controllers = List.generate(
              categoryList.length, (_) => TextEditingController());
        } else if (resultData["head"]["code"] == 400) {
          showCustomSnackBar(context,
              content: resultData["head"]["msg"].toString(), isSuccess: false);
          throw resultData["head"]["msg"].toString();
        }
      });
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  submitForm() async {
    List<Map<String, String>> orderingText = [];
    Set<String> uniqueEntries = {};

    for (var i = 0; i < categoryList.length; i++) {
      var categoryId = categoryList[i].categoryId ?? '';
      var controllerText = _controllers[i].text.trim();
      if (controllerText.isEmpty) {
        showCustomSnackBar(context,
            content: 'Field cannot be empty', isSuccess: false);
        return;
      }

      if (uniqueEntries.contains(controllerText)) {
        showCustomSnackBar(context,
            content: 'Duplicate entry found: $controllerText',
            isSuccess: false);
        return;
      }

      uniqueEntries.add(controllerText);

      var entry = {
        'category_id': categoryId,
        'controller_text': controllerText,
      };

      orderingText.add(entry);
    }

    var userId = await LocalDBConfig().getUserID();
    var formData = {
      'creator_id': userId.toString(),
      'edit_category_id_ordering': orderingText,
    };

    try {
      LoadingOverlay.show(context);
      CategoryService().updateCategoryOrder(formData: formData).then((value) {
        LoadingOverlay.hide();
        if (value.isNotEmpty) {
          if (value['head']['code'] == 200) {
            Navigator.pop(context, true);
            showCustomSnackBar(context,
                content: value['head']['msg'], isSuccess: true);
            NotificationService().showNotification(
                title: "Category Ordering Updated",
                body: "Category Ordering has updated successfully.");
          } else {
            showCustomSnackBar(context,
                content: value['head']['msg'], isSuccess: false);
          }
        } else {
          errorSnackbar(context);
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
        floatingActionButton: floatingButtons(),
        backgroundColor: Colors.white,
        appBar: appbar(context),
        bottomNavigationBar: bottomAppbar(context),
        body: body(),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: categoryHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureWaitingLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureNetworkError();
          } else {
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  categoryHandler = categoryListView();
                });
              },
              child: screenView());
        }
      },
    );
  }

  Form screenView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ReorderableListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  _controllers[index].text = (index + 1).toString();
                  return ReorderableDragStartListener(
                    index: index,
                    key: ValueKey(index),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            indexList(index),
                            categoryName(index),
                            textFeilds(index),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = categoryList.removeAt(oldIndex);
                    categoryList.insert(newIndex, item);

                    _controllers.clear();
                    for (int i = 0; i < categoryList.length; i++) {
                      _controllers.add(TextEditingController());
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container indexList(int index) {
    return Container(
      height: 35,
      width: 35,
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
    );
  }

  Expanded categoryName(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          categoryList[index].name!,
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SizedBox textFeilds(int index) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
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
            return '(*)';
          }
          if (double.tryParse(value) == null) {
            return '(X)';
          }
          return null;
        },
      ),
    );
  }

  Row floatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          mini: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: const Icon(
            Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          mini: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: const Icon(
            Icons.arrow_downward,
            color: Colors.white,
          ),
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
        "Edit Ordering",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
