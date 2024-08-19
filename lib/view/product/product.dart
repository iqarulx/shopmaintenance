/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/product_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/auth_service/auth_service.dart';
import '/service/http_service/product_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/dialog_product.dart';
import '/view/custom_ui_element/dialog_product_price.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/product/excel_preview.dart';
import '/view/product/pdf_preview.dart';
import '/view/product/product_form.dart';
import '/view/product/product_order.dart';
import '/view/product/product_price.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductListingModel> productList = [];
  List<ProductListingModel> tmpProductList = [];
  List<CategoryListingForProductModel> categoryList = [];
  TextEditingController search = TextEditingController();
  Future? productHandler;
  String? selectedCategory;
  bool showFilter = false;
  String pageLimit = '10';
  int? pageNumber;
  String selectedPageNumber = '1';
  late TutorialCoachMark tutorialCoachMark;

  @override
  initState() {
    AuthService().accountValid(context);
    productHandler = productListView().then((onValue) async {
      var demoViewed = await LocalDBConfig().getDemoProduct();
      if (!demoViewed!) {
        createTutorial();
        Future.delayed(Duration.zero, showTutorial);
      }
    });
    super.initState();
  }

  showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  createTutorial() async {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.white38,
      textSkip: "SKIP",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        backgroundColor: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      skipWidget: Container(
        height: 40,
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "SKIP",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        LocalDBConfig().setDemoProduct();
      },
      onSkip: () {
        LocalDBConfig().setDemoProduct();
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "filterGuide",
        keyTarget: filterGuide,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to use filters",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "addProductGuide",
        keyTarget: addProductGuide,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to add new product",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "downloadProductGuide",
        keyTarget: downloadProductGuide,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to download product as excel/pdf",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "refreshGuide",
        keyTarget: refreshGuide,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to refresh page",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "netRateGuide",
        keyTarget: netRateGuide,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to change net rate",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "showFrontEndGuide",
        keyTarget: showFrontEndGuide,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      "Click to show product in frontend",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  searchFn() {
    String searchText = search.text.toLowerCase();

    if (searchText.isNotEmpty) {
      var dataList = tmpProductList.where((element) {
        String productName = element.productName?.toLowerCase() ?? '';
        return productName.contains(searchText) ||
            productName.startsWith(searchText);
      }).toList();

      setState(() {
        productList.clear();
        productList.addAll(dataList);
      });
    } else {
      setState(() {
        productList.clear();
        productList.addAll(tmpProductList);
      });
    }
  }

  Future productListView(
      {String? sendPagenumber,
      String? sendPageLimit,
      String? categoryId}) async {
    try {
      setState(() {
        productList.clear();
        tmpProductList.clear();
      });

      Map formData = {
        "page_number": sendPagenumber ?? 1,
        "page_limit": sendPageLimit ?? 10,
        "filter_category_id": categoryId ?? "",
        "get_product_list": 1
      };

      return await ProductService()
          .getProductList(formData: formData)
          .then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          int dataLength = resultData["head"]["msg"]["data_length"];
          int limit = (dataLength / int.parse(pageLimit)).ceil();
          setState(() {
            pageNumber = limit;
          });

          List<dynamic> productDataList =
              resultData["head"]["msg"]["product_data"];

          for (var element in productDataList) {
            ProductListingModel model = ProductListingModel();
            model.productId = element["product_id"].toString();
            model.productCode = element["product_code"].toString();
            model.categoryName = element["category_name"].toString();
            model.productName = element["name"].toString();
            model.actualPrice = element["actual_price"].toString();
            model.salesPrice = element["sales_price"].toString();
            model.showFrontend = element["show_frontend"].toString();
            model.creator = element["creator_name"].toString();
            setState(() {
              productList.add(model);
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
          setState(() {
            tmpProductList.addAll(productList);
          });
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

  openProductOrderEdit() async {
    var selectedCategoryModel = categoryList.firstWhere(
      (element) => element.categoryName == selectedCategory,
    );
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return ProductOrderEdit(
            categoryId: selectedCategoryModel.categoryId,
            categoryName: selectedCategory,
          );
        }).then((value) {
      if (value != null) {
        if (value) {
          productHandler = productListView();
          setState(() {});
        }
      }
    });
  }

  openProductPriceEdit() async {
    var selectedCategoryModel = categoryList.firstWhere(
      (element) => element.categoryName == selectedCategory,
    );
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return ProductPriceUpdate(
            categoryId: selectedCategoryModel.categoryId,
            categoryName: selectedCategory,
          );
        }).then((value) {
      if (value != null) {
        if (value) {
          productHandler = productListView();
          setState(() {});
        }
      }
    });
  }

  openProductEdit(String? productId) async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return ProductForm(productId: productId);
        }).then((value) {
      if (value != null) {
        if (value) {
          setState(() {
            productHandler = productListView();
          });
        }
      }
    });
  }

  submitFrontend(String productId, bool value) async {
    var userId = await LocalDBConfig().getUserID();

    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'edit_product_id_frontend': productId,
      'value': value ? 0.toString() : 1.toString(),
    };
    try {
      LoadingOverlay.show(context);
      ProductService().updateFrontEnd(formData: formData).then((value) {
        LoadingOverlay.hide();
        if (value['head']['code'] == 200) {
          showCustomSnackBar(context,
              content: "Updated Successfully", isSuccess: true);
          Future.delayed(const Duration(seconds: 2), () {
            productHandler = productListView();
          });
          NotificationService().showNotification(
              title: "Frontend Updated",
              body: "Frontend has updated successfully.");
        } else {
          showCustomSnackBar(context,
              content: value['head']['msg'], isSuccess: false);
        }
      });
    } catch (e) {
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  deleteProduct(String productId) async {
    var userId = await LocalDBConfig().getUserID();

    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'delete_product_id': productId,
    };
    try {
      await LocalAuthConfig().checkBiometrics(context, 'Product').then((value) {
        if (value) {
          LoadingOverlay.show(context);
          ProductService().deleteProduct(formData: formData).then((value) {
            LoadingOverlay.hide();

            if (value['head']['code'] == 200) {
              showCustomSnackBar(context,
                  content: "Product Deleted Successfully", isSuccess: true);
              Future.delayed(const Duration(seconds: 2), () {
                productHandler = productListView();
              });
            } else {
              showCustomSnackBar(context,
                  content: value['head']['msg'], isSuccess: false);
            }
          });
        } else {
          showCustomSnackBar(context, content: "Auth Failed", isSuccess: false);
        }
      });
    } catch (e) {
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  openExcelPreview() async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return const ExcelPreview();
        });
  }

  openPdfPreview() async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return const PdfPreview();
        });
  }

  updateProductPrice(value, productId) async {
    var userId = await LocalDBConfig().getUserID();
    Map<String, String> formData = {
      'creator_id': userId.toString(),
      'price_change_product_id': productId,
      'change_price': value
    };
    try {
      LoadingOverlay.show(context);
      ProductService()
          .updateProductSalesPrice(formData: formData)
          .then((value) {
        LoadingOverlay.hide();
        if (value['head']['code'] == 200) {
          showCustomSnackBar(context,
              content: "Price updated", isSuccess: true);
          Future.delayed(const Duration(seconds: 2), () {
            NotificationService().showNotification(
                title: "Price update",
                body: "Prduct price has updated successfully");
          });
          setState(() {
            productHandler = productListView();
          });
        } else {
          showCustomSnackBar(context,
              content: value['head']['msg'], isSuccess: false);
        }
      });
    } catch (e) {
      showCustomSnackBar(context, content: "Error: $e", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(), floatingActionButton: floatingButton(), body: body());
  }

  GlobalKey filterGuide = GlobalKey();
  GlobalKey addProductGuide = GlobalKey();
  GlobalKey downloadProductGuide = GlobalKey();
  GlobalKey refreshGuide = GlobalKey();
  GlobalKey netRateGuide = GlobalKey();
  GlobalKey showFrontEndGuide = GlobalKey();

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
        future: productHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return dataLoading();
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
                  productList.clear();
                  categoryList.clear();
                  productHandler = productListView();
                });
              },
              child: screenView(context),
            );
          }
        });
  }

  FloatingActionButton floatingButton() {
    return FloatingActionButton(
      key: refreshGuide,
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xff586F7C),
      shape: const CircleBorder(),
      onPressed: () {
        setState(() {
          productList.clear();
          categoryList.clear();
          productHandler = productListView();
        });
      },
      child: const Icon(Iconsax.refresh),
    );
  }

  ListView screenView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        TextFormField(
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
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
          onChanged: (value) {
            setState(() {});
            searchFn();
          },
          decoration: InputDecoration(
            hintText: "Search by name",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Iconsax.search_normal_1),
            suffixIcon: search.text.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        search.clear();
                        productList.addAll(tmpProductList);
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
        ),
        if (showFilter) filterOptions(context),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: productList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                openProductEdit(productList[index].productId);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Code : ${productList[index].productCode.toString()}",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "Name : ${productList[index].productName.toString()}",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "Category : ${productList[index].categoryName.toString()}",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Colors.black,
                                ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Actual : ₹${productList[index].actualPrice.toString()}",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        ProductPriceDialogProduct(
                                      productId: productList[index].productId!,
                                      productName:
                                          productList[index].productName!,
                                      oldPrice: productList[index].salesPrice!,
                                    ),
                                  ).then((value) {
                                    if (value.isNotEmpty) {
                                      updateProductPrice(
                                          value, productList[index].productId);
                                    }
                                  });
                                },
                                child: Text(
                                  key: index == 0 ? netRateGuide : null,
                                  "Net : ₹${productList[index].salesPrice.toString()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Created by: ${productList[index].creator!}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          color: Colors.white,
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    openProductEdit(
                                        productList[index].productId);
                                  },
                                  icon: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.green[500],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "Edit",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  )),
                            ),
                            PopupMenuItem<String>(
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await showDialog(
                                      context: context,
                                      builder: (context) => DeleteDialogProduct(
                                        productId:
                                            productList[index].productId!,
                                        productName:
                                            productList[index].productName!,
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        if (value) {
                                          deleteProduct(
                                              productList[index].productId!);
                                        }
                                      }
                                    });
                                  },
                                  icon: Row(
                                    children: [
                                      Icon(
                                        Iconsax.trash,
                                        color: Colors.red[400],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "Delete",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                        Transform.scale(
                          key: index == 0 ? showFrontEndGuide : null,
                          scale: 0.6,
                          child: CupertinoSwitch(
                            value:
                                int.parse(productList[index].showFrontend!) == 0
                                    ? true
                                    : false,
                            onChanged: (value) {
                              submitFrontend(
                                  productList[index].productId!, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  FadeInDown filterOptions(BuildContext context) {
    return FadeInDown(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          DropdownButtonFormField<String>(
            menuMaxHeight: 300,
            decoration: InputDecoration(
              labelText: 'Select category',
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
            items: categoryList
                .where((model) =>
                    selectedCategory == null ||
                    model.categoryName != selectedCategory)
                .map<DropdownMenuItem<String>>((model) {
              return DropdownMenuItem<String>(
                value: model.categoryName,
                child: Text(model.categoryName!),
              );
            }).toList(),
            onChanged: (String? selectedItem) {
              if (selectedItem != null) {
                var selectedCategoryModel = categoryList.firstWhere(
                  (element) => element.categoryName == selectedItem,
                );
                setState(() {
                  selectedCategory = selectedItem;
                  productList.clear();
                  categoryList.clear();
                  productHandler = productListView(
                      categoryId: selectedCategoryModel.categoryId);
                });
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          if (selectedCategory == null)
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: pageLimit,
                  decoration: InputDecoration(
                    labelText: 'Page Limit',
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
                  items: <String>['10', '25', '50', '100']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? selectedItem) {
                    setState(() {
                      productHandler =
                          productListView(sendPageLimit: selectedItem);
                      pageLimit = selectedItem!;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: selectedPageNumber,
                  decoration: InputDecoration(
                    labelText: 'Page Number',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff2F4550)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: List.generate(pageNumber!, (index) {
                    return DropdownMenuItem<String>(
                      value: (index + 1).toString(),
                      child: Text((index + 1).toString()),
                    );
                  }),
                  onChanged: (String? selectedItem) {
                    productHandler =
                        productListView(sendPagenumber: selectedItem);
                    setState(() {
                      selectedPageNumber = selectedItem!;
                    });
                  },
                )
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (selectedCategory != null) {
                            openProductOrderEdit();
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
                              "Ordering",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (selectedCategory != null) {
                            openProductPriceEdit();
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
                              "Price Update",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          productList.clear();
                          categoryList.clear();
                          selectedCategory = null;
                          productHandler = productListView();
                        });
                      },
                      child: Container(
                        height: 43,
                        width: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Iconsax.close_circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                        ),
                    children: [
                      const TextSpan(text: 'Showing '),
                      TextSpan(
                        text: '$selectedCategory',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const TextSpan(text: ' items'),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff586F7C),
      title: const Text(
        "Product",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          key: filterGuide,
          onPressed: () {
            setState(() {
              showFilter = !showFilter;
            });
          },
          icon: const Icon(Iconsax.filter),
        ),
        IconButton(
          key: addProductGuide,
          onPressed: () {
            openProductEdit(null);
          },
          icon: const Icon(
            Iconsax.add,
            size: 30,
          ),
        ),
        PopupMenuButton<String>(
          key: downloadProductGuide,
          icon: const Icon(Iconsax.arrow_down),
          color: Colors.white,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openExcelPreview();
                  },
                  icon: Row(
                    children: [
                      Icon(
                        Iconsax.document_download,
                        color: Colors.green[500],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Excel",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )),
            ),
            PopupMenuItem<String>(
              child: IconButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    openPdfPreview();
                  },
                  icon: Row(
                    children: [
                      Icon(
                        Iconsax.document_download4,
                        color: Colors.red[400],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Pdf",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
