/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/product_model.dart';
import '/service/http_service/product_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '../custom_ui_element/show_custom_snackbar.dart';

class ProductPriceUpdate extends StatefulWidget {
  final String? categoryId, categoryName;

  const ProductPriceUpdate(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  State<ProductPriceUpdate> createState() => _ProductPriceUpdateState();
}

class _ProductPriceUpdateState extends State<ProductPriceUpdate> {
  List<ProductOrderListingModel> productList = [];
  Future? productPriceEditHandler;
  String? selectedOption;
  String enteredValue = '';
  TextEditingController valueController = TextEditingController();

  @override
  void initState() {
    productPriceEditHandler = productListView();
    super.initState();
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  Future productListView() async {
    try {
      setState(() {
        productList.clear();
      });

      return await ProductService().getProductOrder(formData: {
        'get_product_list_ordering': widget.categoryId
      }).then((resultData) async {
        if (resultData != null && resultData["head"]["code"] == 200) {
          for (var element in resultData["head"]["msg"]) {
            ProductOrderListingModel model = ProductOrderListingModel();
            model.productId = element["product_id"].toString();
            model.productName = element["name"].toString();
            model.price = element["actual_price"].toString();
            setState(() {
              productList.add(model);
            });
          }
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
    List<Map<String, String>> priceModified = [];
    for (var i = 0; i < productList.length; i++) {
      var productId = productList[i].productId ?? '';
      var productPrice = productList[i].price ?? '';

      if (selectedOption != null) {
        double modifiedPrice = 0.0;
        if (selectedOption == '+') {
          modifiedPrice =
              double.parse(productPrice) + double.parse(enteredValue);
        } else if (selectedOption == '-') {
          modifiedPrice =
              double.parse(productPrice) - double.parse(enteredValue);
        } else if (selectedOption == 'x') {
          modifiedPrice =
              double.parse(productPrice) * double.parse(enteredValue);
        } else if (selectedOption == '%+') {
          modifiedPrice = double.parse(productPrice) +
              (double.parse(productPrice) * double.parse(enteredValue) / 100);
        } else if (selectedOption == '%-') {
          modifiedPrice = double.parse(productPrice) -
              (double.parse(productPrice) * double.parse(productPrice) / 100);
        } else {
          modifiedPrice = double.parse(productPrice);
        }

        var entry = {
          'product_id': productId.toString(),
          'modified_price': modifiedPrice.toString(),
        };
        priceModified.add(entry);
      } else {
        showCustomSnackBar(context,
            content: 'Please select an action', isSuccess: false);
      }
    }

    if (selectedOption != null) {
      bool hasNegativePrice = priceModified.any((entry) {
        double price = double.parse(entry['modified_price']!);
        return price < 0;
      });

      var userId = await LocalDBConfig().getUserID();
      var formData = {
        'creator_id': userId.toString(),
        'update_product_list_price': priceModified,
      };

      if (hasNegativePrice) {
        showCustomSnackBar(context,
            content: 'Some values have negative entry', isSuccess: false);
      } else {
        // futureLoading(context);
        LoadingOverlay.show(context);
        ProductService().updateProductPrice(formData: formData).then((value) {
          LoadingOverlay.hide();
          if (value['head']['code'] == 200) {
            showCustomSnackBar(context,
                content: value['head']['msg'], isSuccess: true);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context, true);
            });
            NotificationService().showNotification(
                title: "Price Updated",
                body: "Product price has updated successfully.");
          } else {
            showCustomSnackBar(context,
                content: value['head']['msg'], isSuccess: false);
          }
        });
      }
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
        body: body(),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: productPriceEditHandler,
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
                productPriceEditHandler = productListView();
              });
            },
            child: screenView(),
          );
        }
      },
    );
  }

  ListView screenView() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              valueFeild(),
              const SizedBox(
                height: 10,
              ),
              operationDropdown(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.grey.shade200,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'S.No',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Product Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Old Price',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'New Price',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        showCase(),
      ],
    );
  }

  ListView showCase() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      itemCount: productList.length,
      itemBuilder: (context, index) {
        double modifiedPrice = 0.0;

        if (enteredValue.isNotEmpty && double.tryParse(enteredValue) != null) {
          double value = double.parse(enteredValue);

          if (selectedOption == '+') {
            modifiedPrice = double.parse(productList[index].price!) + value;
          } else if (selectedOption == '-') {
            modifiedPrice = double.parse(productList[index].price!) - value;
          } else if (selectedOption == 'x') {
            modifiedPrice = double.parse(productList[index].price!) * value;
          } else if (selectedOption == '%+') {
            modifiedPrice = double.parse(productList[index].price!) +
                (double.parse(productList[index].price!) * value / 100);
          } else if (selectedOption == '%-') {
            modifiedPrice = double.parse(productList[index].price!) -
                (double.parse(productList[index].price!) * value / 100);
          }
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
              Expanded(
                flex: 1,
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  productList[index].productName!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "₹${productList[index].price!}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "₹${modifiedPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DropdownButtonFormField<String> operationDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedOption,
      onChanged: (String? newValue) {
        setState(() {
          selectedOption = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: 'Select operation',
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
          value: '+',
          child: Text('+'),
        ),
        DropdownMenuItem(
          value: '-',
          child: Text('-'),
        ),
        DropdownMenuItem(
          value: 'x',
          child: Text('x'),
        ),
        DropdownMenuItem(
          value: '%+',
          child: Text('%+'),
        ),
        DropdownMenuItem(
          value: '%-',
          child: Text('%-'),
        ),
      ],
    );
  }

  TextFormField valueFeild() {
    return TextFormField(
      controller: valueController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        setState(() {
          FocusManager.instance.primaryFocus!.unfocus();
        });
      },
      onTapOutside: (event) {
        setState(() {
          FocusManager.instance.primaryFocus!.unfocus();
        });
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            enteredValue = value;
          });
        }
      },
      decoration: InputDecoration(
        hintText: "Enter Value",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(
          Iconsax.math,
          size: 20,
        ),
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
    );
  }

  Padding titleContent() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'S.No',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text('Product',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text('Old Price',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text('New Price',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          submitForm();
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
      title: RichText(
        text: TextSpan(
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black, fontSize: 20),
          children: [
            const TextSpan(text: 'Edit '),
            TextSpan(
              text: widget.categoryName,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const TextSpan(text: ' Price'),
          ],
        ),
      ),
    );
  }
}
