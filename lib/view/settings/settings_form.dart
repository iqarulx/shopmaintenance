/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import '/model/settings_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/http_service/settings_service.dart';
import '/service/notification_service/local_notification.dart';
import '/service/state_city.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  List<SettingsEditingModel> settingsDataList = [];

  Future? settingsEditHandler;

  Color listTopbarBackgroundColor = Colors.black,
      listTopbarTextColor = Colors.black,
      listCategoryBackgroundColor = Colors.black,
      listCategoryTextColor = Colors.black,
      listRupeesBackgroundColor = Colors.black,
      listRupeesTextColor = Colors.black,
      listTableHeadColor = Colors.black,
      listTableTextColor = Colors.black,
      listTableStrikeColor = Colors.black,
      listTableBorderColor = Colors.black,
      listTableCategoryBackgroundColor = Colors.black,
      listTableCategoryTextColor = Colors.black,
      listProductRow1Color = Colors.black,
      listProductRow2Color = Colors.black,
      listProductTextColor = Colors.black,
      gridTopbarBackgroundColor = Colors.black,
      gridTopbarTextColor = Colors.black,
      gridCategoryBackgroundColor = Colors.black,
      gridCategoryTextColor = Colors.black,
      gridRupeesBackgroundColor = Colors.black,
      gridRupeesTextColor = Colors.black,
      gridTableCategoryBackgroundColor = Colors.black,
      gridTableTextColor = Colors.black,
      gridProductRow1Color = Colors.black,
      gridProductRow2Color = Colors.black,
      gridProductTextColor = Colors.black,
      gridRateBackgroundColor = Colors.black,
      gridRateTextColor = Colors.black,
      gridProductCodeBackgroundColor = Colors.black,
      gridProductCodeTextColor = Colors.black,
      gridCardStrikeColor = Colors.black,
      gridCardBorderColor = Colors.black,
      boxTopbarBackgroundColor = Colors.black,
      boxTopbarTextColor = Colors.black,
      boxCategoryBackgroundColor = Colors.black,
      boxCategoryTextColor = Colors.black,
      boxRupeesBackgroundColor = Colors.black,
      boxRupeesTextColor = Colors.black,
      boxBottomCategoryBackgroundColor = Colors.black,
      boxBottomCategoryTextColor = Colors.black,
      boxProductBackgroundColor = Colors.black,
      boxProductTextColor = Colors.black,
      boxBoxColor = Colors.black,
      newArrivalsBackgroundColor = Colors.black,
      newArrivalsTextColor = Colors.black,
      newArrivalsStrikeColor = Colors.black,
      newArrivalsButtonBackgroundColor = Colors.black,
      newArrivalsButtonTextColor = Colors.black;

  bool deskToplayoutBoxSelected = false;
  bool isLayoutTypeExpanded = false;
  bool isLayoutColorExpanded = false;
  bool isProductDisplayExpanded = false;
  bool isnewArrivalsExpanded = false;
  bool isWebsiteStatusExpanded = false;
  bool isPageListFeaturesExpanded = false;
  bool isPriceFormatExpanded = false;
  bool isPdfFormatExpanded = false;

  int? desktopBoxCount;

  String? desktopLayoutType,
      tabLayoutType,
      mobileLayoutType,
      priceListDisplayHomePage,
      downloadPricelistPdf,
      productCode,
      discountRow,
      categoryFilter,
      searchFilter,
      pdfFontSize,
      disableSite,
      showPromotionCode,
      otpVerification,
      pricelistFormat,
      printoutFormat,
      stateName,
      allCities;

  final TextEditingController footerMessageController = TextEditingController();
  final TextEditingController thankyouMessageController =
      TextEditingController();
  final TextEditingController termsAndConditionsController =
      TextEditingController();
  final TextEditingController minimumOrderController = TextEditingController();
  final TextEditingController packingChargesController =
      TextEditingController();

  List<String> selectedStates = [];
  List<List<String>> selectedCities = [];
  List<dynamic> newArrivalsHeading = [];
  List<List<String>> selectedNewArrivalsRows = [];
  List<Map<String, String>> productsForNewArrivals = [];
  List<List<Map<String, dynamic>>> previousProductsForNewArrivals = [];
  List<List<dynamic>> selectedProductsForNewArrivals = [];
  List<TextEditingController> newArrivalsNameController = [];

  List<List<String>> termsRows = [];
  List<TextEditingController> termsController = [];

  Future<bool> settingsEditView() async {
    try {
      setState(() {
        settingsDataList.clear();
      });

      var resultData = await SettingsService().getSettings();
      if (resultData != null && resultData["head"]["code"] == 200) {
        for (var element in resultData["head"]["msg"]) {
          SettingsEditingModel model = SettingsEditingModel();
          List<dynamic> settingsList =
              element["settings_list"] as List<dynamic>;
          List<dynamic> stateNameList =
              element["state_name_list"] as List<dynamic>;
          List<dynamic> categoryList =
              element["category_list"] as List<dynamic>;
          List<dynamic> productList = element["product_list"] as List<dynamic>;
          if (settingsList.isNotEmpty) {
            model.settingsList = settingsList[0] as Map<String, dynamic>;
          }
          if (stateNameList.isNotEmpty) {
            model.stateNameList = stateNameList[0] as Map<String, dynamic>;
          }
          if (categoryList.isNotEmpty) {
            model.categoryList = categoryList;
          }
          if (productList.isNotEmpty) {
            model.productList = productList;
          }
          model.layout = element["layout"].toString();

          settingsDataList.add(model);
        }
        return true;
      } else if (resultData["head"]["code"] == 400) {
        showCustomSnackBar(context, content: 'Failed', isSuccess: false);
        throw resultData["head"]["msg"];
      }
    } on SocketException catch (e) {
      log(e.toString());
      throw "Network Error";
    } catch (e) {
      throw e.toString();
    }
    return false;
  }

  @override
  void initState() {
    settingsEditHandler = settingsEditView().whenComplete(initSettings);
    super.initState();
  }

  Color changeHexToARGB(String color) {
    return Color(int.parse('FF${color.replaceAll('#', '')}', radix: 16));
  }

  // String colorToHex(Color color) {
  //   return color.toString().replaceAll('Color(0xff', '#').replaceAll(')', '');
  // }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  initSettings() {
    for (var model in settingsDataList) {
      if (model.settingsList != null &&
          model.settingsList!.containsKey("list_color")) {
        var listColor = model.settingsList!["list_color"];

        listTopbarBackgroundColor =
            changeHexToARGB(listColor["list_topbar_background_color"]);
        listTopbarTextColor =
            changeHexToARGB(listColor["list_topbar_text_color"]);
        listCategoryBackgroundColor =
            changeHexToARGB(listColor["list_topbar_category_background_color"]);
        listCategoryTextColor =
            changeHexToARGB(listColor["list_topbar_category_text_color"]);

        listRupeesBackgroundColor =
            changeHexToARGB(listColor["list_topbar_rupees_background_color"]);
        listRupeesTextColor =
            changeHexToARGB(listColor["list_topbar_rupees_text_color"]);
        listTableHeadColor =
            changeHexToARGB(listColor["list_table_head_color"]);
        listTableTextColor =
            changeHexToARGB(listColor["list_table_head_text_color"]);
        listTableStrikeColor = changeHexToARGB(listColor["list_strike_color"]);
        listTableBorderColor = changeHexToARGB(listColor["list_border_color"]);
        listTableCategoryBackgroundColor =
            changeHexToARGB(listColor["list_category_background_color"]);
        listTableCategoryTextColor =
            changeHexToARGB(listColor["list_category_text_color"]);
        listProductRow1Color =
            changeHexToARGB(listColor["list_product_color1"]);
        listProductRow2Color =
            changeHexToARGB(listColor["list_product_color2"]);
        listProductTextColor = changeHexToARGB(listColor["list_text_color"]);

        print({
          "list_topbar_background_color": listTopbarBackgroundColor,
          "list_topbar_text_color": listTopbarTextColor,
          "list_category_background_color": listCategoryBackgroundColor,
          "list_category_text_color": listCategoryTextColor,
          "list_rupees_background_color": listRupeesBackgroundColor,
          "list_rupees_text_color": listRupeesTextColor,
          "list_table_head_color": listTableHeadColor,
          "list_table_text_color": listTableTextColor,
          "list_table_strike_color": listTableStrikeColor,
          "list_table_border_color": listTableBorderColor,
        });
      }

      if (model.settingsList != null &&
          model.settingsList!.containsKey("grid_color")) {
        var gridColor = model.settingsList!["grid_color"];
        gridTopbarBackgroundColor =
            changeHexToARGB(gridColor["grid_topbar_background_color"]);
        gridTopbarTextColor =
            changeHexToARGB(gridColor["grid_topbar_text_color"]);
        gridCategoryBackgroundColor =
            changeHexToARGB(gridColor["grid_topbar_category_background_color"]);
        gridCategoryTextColor =
            changeHexToARGB(gridColor["grid_topbar_category_text_color"]);
        gridRupeesBackgroundColor =
            changeHexToARGB(gridColor["grid_topbar_rupees_background_color"]);
        gridRupeesTextColor =
            changeHexToARGB(gridColor["grid_topbar_rupees_text_color"]);
        gridTableCategoryBackgroundColor =
            changeHexToARGB(gridColor["grid_category_background_color"]);
        gridTableTextColor =
            changeHexToARGB(gridColor["grid_category_text_color"]);
        gridProductRow1Color =
            changeHexToARGB(gridColor["grid_product_color1"]);
        gridProductRow2Color =
            changeHexToARGB(gridColor["grid_product_color2"]);
        gridProductTextColor = changeHexToARGB(gridColor["grid_text_color"]);
        gridRateBackgroundColor =
            changeHexToARGB(gridColor["rate_background_color"]);
        gridRateTextColor = changeHexToARGB(gridColor["rate_text_color"]);
        gridProductCodeBackgroundColor =
            changeHexToARGB(gridColor["grid_product_code_background_color"]);
        gridProductCodeTextColor =
            changeHexToARGB(gridColor["grid_product_code_text_color"]);
        gridCardStrikeColor = changeHexToARGB(gridColor["grid_strike_color"]);
        gridCardBorderColor = changeHexToARGB(gridColor["grid_border_color"]);

        print({
          "grid_topbar_background_color": gridTopbarBackgroundColor,
          "grid_topbar_text_color": gridTopbarTextColor,
          "grid_category_background_color": gridCategoryBackgroundColor,
          "grid_category_text_color": gridCategoryTextColor,
          "grid_rupees_background_color": gridRupeesBackgroundColor,
          "grid_rupees_textColor": gridRupeesTextColor,
          "grid_table_category_background_color":
              gridTableCategoryBackgroundColor,
          "grid_table_text_color": gridTableTextColor,
          "grid_product_row1_color": gridProductRow1Color,
          "grid_product_row2_color": gridProductRow2Color,
          "grid_product_text_color": gridProductTextColor,
          "grid_rate_background_color": gridRateBackgroundColor,
          "grid_rate_text_color": gridRateTextColor,
          "grid_product_code_background_color": gridProductCodeBackgroundColor,
          "grid_product_code_text_color": gridProductCodeTextColor,
          "grid_strike_color": gridCardStrikeColor,
          "grid_border_color": gridCardBorderColor,
        });
      }

      if (model.settingsList != null &&
          model.settingsList!.containsKey("box_color")) {
        var boxColor = model.settingsList!["box_color"];
        boxTopbarBackgroundColor =
            changeHexToARGB(boxColor["box_topbar_background_color"]);
        boxTopbarTextColor = changeHexToARGB(boxColor["box_topbar_text_color"]);
        boxCategoryBackgroundColor =
            changeHexToARGB(boxColor["box_topbar_category_background_color"]);
        boxCategoryTextColor =
            changeHexToARGB(boxColor["box_topbar_category_text_color"]);
        boxRupeesBackgroundColor =
            changeHexToARGB(boxColor["box_topbar_rupees_background_color"]);
        boxRupeesTextColor =
            changeHexToARGB(boxColor["box_topbar_rupees_text_color"]);
        boxBottomCategoryBackgroundColor =
            changeHexToARGB(boxColor["box_category_background_color"]);
        boxBottomCategoryTextColor =
            changeHexToARGB(boxColor["box_category_text_color"]);
        boxProductBackgroundColor =
            changeHexToARGB(boxColor["box_product_code_background_color"]);
        boxProductTextColor =
            changeHexToARGB(boxColor["box_product_code_text_color"]);
        boxBoxColor = changeHexToARGB(boxColor["box_strike_color"]);

        print({
          "box_topbar_background_color": boxTopbarBackgroundColor,
          "box_topbar_text_color": boxTopbarTextColor,
          "box_category_background_color": boxCategoryBackgroundColor,
          "box_category_text_color": boxCategoryTextColor,
          "box_rupees_background_color": boxRupeesBackgroundColor,
          "box_rupees_text_color": boxRupeesTextColor,
          "box_bottom_category_background_color":
              boxBottomCategoryBackgroundColor,
          "box_bottom_category_text_color": boxBottomCategoryTextColor,
          "box_product_background_color": boxProductBackgroundColor,
          "box_product_text_color": boxProductTextColor,
          "box_box_color": boxBoxColor,
        });
      }

      if (model.settingsList != null &&
          model.settingsList!.containsKey("new_arrivals")) {
        for (var i = 0;
            i <
                model.settingsList!["new_arrivals"]["new_arrivals_headings"]
                    .length;
            i++) {
          selectedNewArrivalsRows.add([]);
          newArrivalsNameController.add(TextEditingController());
          selectedProductsForNewArrivals.add([]);
          previousProductsForNewArrivals.add([]);

          newArrivalsNameController[i].text =
              model.settingsList!["new_arrivals"]["new_arrivals_headings"][i];
          List<dynamic> productIds = List<dynamic>.from(
              model.settingsList!["new_arrivals"]["new_arrivals_products"][i]);
          selectedProductsForNewArrivals[i] = List<String>.from(productIds);
          for (var id in productIds) {
            var product = model.productList!.firstWhere(
              (product) => product["product_id"] == id,
              orElse: () => null,
            );
            if (product != null) {
              previousProductsForNewArrivals[i].add(product);
            }
          }
        }

        newArrivalsBackgroundColor = changeHexToARGB(
            model.settingsList!["new_arrivals"]
                ["new_arrivals_category_background_color"]);

        newArrivalsTextColor = changeHexToARGB(model
            .settingsList!["new_arrivals"]["new_arrivals_category_text_color"]);

        newArrivalsStrikeColor = changeHexToARGB(
            model.settingsList!["new_arrivals"]["new_arrivals_strike_color"]);

        newArrivalsButtonBackgroundColor = changeHexToARGB(
            model.settingsList!["new_arrivals"]
                ["new_arrivals_enquiry_button_background_color"]);

        newArrivalsButtonTextColor = changeHexToARGB(
            model.settingsList!["new_arrivals"]
                ["new_arrivals_enquiry_button_text_color"]);
      }

      if (model.settingsList != null &&
          model.settingsList!.containsKey("layout")) {
        var layout = model.settingsList!["layout"];
        desktopLayoutType = layout['desktop_layout'];
        tabLayoutType = layout['tab_layout'];
        mobileLayoutType = layout['mobile_layout'];
        desktopBoxCount = layout['desktop_box_count'];
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("product_display")) {
        var productDisplay = model.settingsList!["product_display"];
        priceListDisplayHomePage =
            productDisplay['pricelist_display_in_home_page'].toString();
        downloadPricelistPdf =
            productDisplay['download_pricelist_pdf_in_frontend'].toString();
        productCode = productDisplay['show_product_code'].toString();
        discountRow = productDisplay['show_discoun_row'].toString();
        categoryFilter = productDisplay['show_category_filter'].toString();
        searchFilter = productDisplay['show_search_filter'].toString();
        pdfFontSize = productDisplay['pdf_font_size'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("website_status")) {
        var websiteStatus = model.settingsList!["website_status"];
        disableSite = websiteStatus['disable_site'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("message")) {
        var message = model.settingsList!["message"];
        footerMessageController.text =
            message['footer_content_message'].toString();
        thankyouMessageController.text = message['thankyou_message'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("pricelist_page_features")) {
        var priceListPageFeatures =
            model.settingsList!["pricelist_page_features"];
        showPromotionCode =
            priceListPageFeatures['show_promotion_code'].toString();
        otpVerification = priceListPageFeatures['otp_verification'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("price_format")) {
        var priceFormat = model.settingsList!["price_format"];
        pricelistFormat =
            priceFormat['product_price_display_format'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("price_format")) {
        var priceFormat = model.settingsList!["price_format"];
        pricelistFormat =
            priceFormat['product_price_display_format'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("printout_format")) {
        var dbPrintoutFormat = model.settingsList!["printout_format"];
        printoutFormat = dbPrintoutFormat['printout_format'].toString();
      }
      if (model.settingsList != null &&
          model.settingsList!.containsKey("terms_conditions")) {
        termsController.clear();
        var termsList = model.settingsList!["terms_conditions"];
        for (var i = 0; i < termsList.length; i++) {
          termsRows.add([]);
          TextEditingController controller = TextEditingController();
          controller.text = termsList[i].toString();
          termsController.add(controller);
        }
      }
    }
  }

  changeColor(Color color, ValueChanged<Color> updateColor) {
    updateColor(color);
  }

  submitForm() async {
    List<String> newArrivalsHeading = [];
    for (var controller in newArrivalsNameController) {
      newArrivalsHeading.add(controller.text);
    }

    List<String> terms = [];
    for (var controller in termsController) {
      terms.add(controller.text);
    }

    print({
      "list_topbar_background_color": colorToHex(listTopbarBackgroundColor),
      "list_topbar_text_color": colorToHex(listTopbarTextColor),
      "list_category_background_color": colorToHex(listCategoryBackgroundColor),
      "list_category_text_color": colorToHex(listCategoryTextColor),
      "list_rupees_background_color": colorToHex(listRupeesBackgroundColor),
      "list_rupees_text_color": colorToHex(listRupeesTextColor),
      "list_table_head_color": colorToHex(listTableHeadColor),
      "list_table_text_color": colorToHex(listTableTextColor),
      "list_table_strike_color": colorToHex(listTableStrikeColor),
      "list_table_border_color": colorToHex(listTableBorderColor),
    });

    print({
      "grid_topbar_background_color": colorToHex(gridTopbarBackgroundColor),
      "grid_topbar_text_color": colorToHex(gridTopbarTextColor),
      "grid_category_background_color": colorToHex(gridCategoryBackgroundColor),
      "grid_category_text_color": colorToHex(gridCategoryTextColor),
      "grid_rupees_background_color": colorToHex(gridRupeesBackgroundColor),
      "grid_rupees_textColor": colorToHex(gridRupeesTextColor),
      "grid_table_category_background_color":
          colorToHex(gridTableCategoryBackgroundColor),
      "grid_table_text_color": colorToHex(gridTableTextColor),
      "grid_product_row1_color": colorToHex(gridProductRow1Color),
      "grid_product_row2_color": colorToHex(gridProductRow2Color),
      "grid_product_text_color": colorToHex(gridProductTextColor),
      "grid_rate_background_color": colorToHex(gridRateBackgroundColor),
      "grid_rate_text_color": colorToHex(gridRateTextColor),
      "grid_product_code_background_color":
          colorToHex(gridProductCodeBackgroundColor),
      "grid_product_code_text_color": colorToHex(gridProductCodeTextColor),
      "grid_strike_color": colorToHex(gridCardStrikeColor),
      "grid_border_color": colorToHex(gridCardBorderColor),
    });

    print({
      "box_topbar_background_color": colorToHex(boxTopbarBackgroundColor),
      "box_topbar_text_color": colorToHex(boxTopbarTextColor),
      "box_category_background_color": colorToHex(boxCategoryBackgroundColor),
      "box_category_text_color": colorToHex(boxCategoryTextColor),
      "box_rupees_background_color": colorToHex(boxRupeesBackgroundColor),
      "box_rupees_text_color": colorToHex(boxRupeesTextColor),
      "box_bottom_category_background_color":
          colorToHex(boxBottomCategoryBackgroundColor),
      "box_bottom_category_text_color": colorToHex(boxBottomCategoryTextColor),
      "box_product_background_color": colorToHex(boxProductBackgroundColor),
      "box_product_text_color": colorToHex(boxProductTextColor),
      "box_box_color": colorToHex(boxBoxColor),
    });

    Map<String, dynamic> settingsMap = {
      "layout": {
        "desktop_layout_type": desktopLayoutType.toString(),
        "tab_layout_type": tabLayoutType.toString(),
        "mobile_layout": mobileLayoutType.toString(),
        "desktop_box_count": desktopBoxCount.toString(),
      },
      "list_color": {
        "list_topbar_background_color": colorToHex(listTopbarBackgroundColor),
        "list_topbar_text_color": colorToHex(listTopbarTextColor),
        "list_category_background_color":
            colorToHex(listCategoryBackgroundColor),
        "list_category_text_color": colorToHex(listCategoryTextColor),
        "list_rupees_background_color": colorToHex(listRupeesBackgroundColor),
        "list_rupees_text_color": colorToHex(listRupeesTextColor),
        "list_table_head_color": colorToHex(listTableHeadColor),
        "list_table_text_color": colorToHex(listTableTextColor),
        "list_table_strike_color": colorToHex(listTableStrikeColor),
        "list_table_border_color": colorToHex(listTableBorderColor),
        "list_table_category_background_color":
            colorToHex(listTableCategoryBackgroundColor),
        "list_table_category_text_color":
            colorToHex(listTableCategoryTextColor),
        "list_product_row1_color": colorToHex(listProductRow1Color),
        "list_product_row2_color": colorToHex(listProductRow2Color),
        "list_product_text_color": colorToHex(listProductTextColor),
      },
      "grid_color": {
        "grid_topbar_background_color": colorToHex(gridTopbarBackgroundColor),
        "grid_topbar_text_color": colorToHex(gridTopbarTextColor),
        "grid_category_background_color":
            colorToHex(gridCategoryBackgroundColor),
        "grid_category_text_color": colorToHex(gridCategoryTextColor),
        "grid_rupees_background_color": colorToHex(gridRupeesBackgroundColor),
        "grid_rupees_textColor": colorToHex(gridRupeesTextColor),
        "grid_table_category_background_color":
            colorToHex(gridTableCategoryBackgroundColor),
        "grid_table_text_color": colorToHex(gridTableTextColor),
        "grid_product_row1_color": colorToHex(gridProductRow1Color),
        "grid_product_row2_color": colorToHex(gridProductRow2Color),
        "grid_product_text_color": colorToHex(gridProductTextColor),
        "grid_rate_background_color": colorToHex(gridRateBackgroundColor),
        "grid_rate_text_color": colorToHex(gridRateTextColor),
        "grid_product_code_background_color":
            colorToHex(gridProductCodeBackgroundColor),
        "grid_product_code_text_color": colorToHex(gridProductCodeTextColor),
        "grid_strike_color": colorToHex(gridCardStrikeColor),
        "grid_border_color": colorToHex(gridCardBorderColor),
      },
      "box_color": {
        "box_topbar_background_color": colorToHex(boxTopbarBackgroundColor),
        "box_topbar_text_color": colorToHex(boxTopbarTextColor),
        "box_category_background_color": colorToHex(boxCategoryBackgroundColor),
        "box_category_text_color": colorToHex(boxCategoryTextColor),
        "box_rupees_background_color": colorToHex(boxRupeesBackgroundColor),
        "box_rupees_text_color": colorToHex(boxRupeesTextColor),
        "box_bottom_category_background_color":
            colorToHex(boxBottomCategoryBackgroundColor),
        "box_bottom_category_text_color":
            colorToHex(boxBottomCategoryTextColor),
        "box_product_background_color": colorToHex(boxProductBackgroundColor),
        "box_product_text_color": colorToHex(boxProductTextColor),
        "box_box_color": colorToHex(boxBoxColor),
      },
      "product_display": {
        "price_list_display_home_page": priceListDisplayHomePage.toString(),
        "download_pricelist_pdf": downloadPricelistPdf.toString(),
        "product_code": productCode.toString(),
        "discount_row": discountRow.toString(),
        "category_filter": categoryFilter.toString(),
        "search_filter": searchFilter.toString(),
        "pdf_font_size": pdfFontSize.toString(),
      },
      "website_status": {"disable_site": disableSite.toString()},
      "new_arrivals": {
        "new_arrivals_heading": newArrivalsHeading,
        "new_arrivals_categories": selectedProductsForNewArrivals,
        "new_arrivals_background_color": colorToHex(newArrivalsBackgroundColor),
        "new_arrivals_text_color": colorToHex(newArrivalsTextColor),
        "new_arrivals_strike_color": colorToHex(newArrivalsStrikeColor),
        "new_arrivals_button_background_color":
            colorToHex(newArrivalsButtonBackgroundColor),
        "new_arrivals_button_text_color":
            colorToHex(newArrivalsButtonTextColor),
      },
      "message": {
        "footer_content_message": footerMessageController.text,
        "thankyou_message": thankyouMessageController.text
      },
      "pricelist_page_features": {
        "show_promotion_code": showPromotionCode.toString(),
        "otp_verification": otpVerification.toString(),
      },
      "price_format": {
        "product_price_display_format": pricelistFormat.toString(),
      },
      "printout_format": {
        "printout_format": printoutFormat.toString(),
      },
      "terms_conditions": terms
    };

    Map<String, dynamic> stateNamelistMap = {
      "minimum_order_amount": minimumOrderController.text,
      "packing_charges": packingChargesController.text,
      "selected_states": selectedStates,
      "selected_cities": selectedCities,
    };

    Map<String, dynamic> updateFormData = {
      "update_settings": 1,
      "settings_list": settingsMap,
      "state_name_list": [stateNamelistMap],
    };

    try {
      await LocalAuthConfig()
          .checkBiometrics(context, 'Settings')
          .then((value) async {
        if (value) {
          LoadingOverlay.show(context);
          await SettingsService()
              .updateSettings(formData: updateFormData)
              .then((value) => {
                    LoadingOverlay.hide(),
                    showCustomSnackBar(context,
                        content: 'Updated Successfully', isSuccess: true)
                  });
          NotificationService().showNotification(
              title: "Settings Updated",
              body: "Settings has updated successfully.");
        } else {
          showCustomSnackBar(context,
              content: 'Auth Failed. Please try again!', isSuccess: false);
        }
      });
    } catch (e) {
      print(e);
      showCustomSnackBar(context,
          content: "Updation Failed $e", isSuccess: false);
    }
  }

  addTermsAndConditions() {
    setState(() {
      termsRows.add([]);
      termsController.add(TextEditingController());
    });
  }

  removeTermsAndConditions(int index) {
    setState(() {
      termsController[index].dispose();
      termsRows.removeAt(index);
      termsController.removeAt(index);
    });
  }

  addNewArrival() {
    setState(() {
      selectedNewArrivalsRows.add([]);
      newArrivalsNameController.add(TextEditingController());
      selectedProductsForNewArrivals.add([]);
    });
  }

  removeNewArrival(int index) {
    setState(() {
      newArrivalsNameController[index].dispose();
      selectedNewArrivalsRows.removeAt(index);
      selectedProductsForNewArrivals.removeAt(index);
      newArrivalsNameController.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        bottomNavigationBar: bottomAppBar(context),
        body: body(),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: settingsEditHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return dataLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureNetworkError();
          } else {
            print(snapshot.error);
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          if (snapshot.data) {
            return Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Layout'),
                    Tab(text: 'Product'),
                    Tab(text: 'Message'),
                    Tab(text: 'Terms'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      layoutView(),
                      productView(),
                      messageView(),
                      taskView()
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No Data Found"));
          }
        }
      },
    );
  }

  Padding taskView() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            child: ListView.builder(
                itemCount: settingsDataList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      for (var i = 0; i < termsRows.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 10),
                              Text(
                                "Terms and Conditions",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      onEditingComplete: () {
                                        setState(() {
                                          FocusManager.instance.primaryFocus!
                                              .unfocus();
                                        });
                                      },
                                      onTapOutside: (event) {
                                        setState(() {
                                          FocusManager.instance.primaryFocus!
                                              .unfocus();
                                        });
                                      },
                                      controller: termsController[i],
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                          hintText: "Terms and Conditions",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xff2F4550),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          suffixIcon: IconButton(
                                              icon: const Icon(
                                                Iconsax.close_circle,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                removeTermsAndConditions(i);
                                              })),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              addTermsAndConditions();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              backgroundColor: const Color(0xff2F4550),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Add New",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                })));
  }

  ListView layoutView() {
    return ListView.builder(
        itemCount: settingsDataList.length,
        itemBuilder: (context, index) {
          SettingsEditingModel model = settingsDataList[index];
          String? layoutOptions =
              model.settingsList!["layout"]["desktop_layout"];
          String? tabOptions = model.settingsList!["layout"]["tab_layout"];
          String? mobileOptions =
              model.settingsList!["layout"]["mobile_layout"];
          int? dbDesktopBoxCount =
              model.settingsList!["layout"]["desktop_box_count"];
          desktopLayoutType ??= layoutOptions;
          tabLayoutType ??= tabOptions;
          mobileLayoutType ??= mobileOptions;
          desktopBoxCount ??= dbDesktopBoxCount;
          // Set colors from db

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      layoutType(context),
                      layoutColors(context)
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  Padding layoutColors(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isLayoutColorExpanded = !isLayoutColorExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Layout Colors',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isLayoutColorExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isLayoutColorExpanded)
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "List Layout Colors",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Top Bar",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  listTopbarBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTopbarBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTopbarBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listTopbarTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTopbarTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTopbarTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Category
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  listCategoryBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listCategoryBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listCategoryBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  listCategoryTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listCategoryTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listCategoryTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Rupees
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Rupees",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  listRupeesBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listRupeesBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listRupeesBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listRupeesTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listRupeesTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listRupeesTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Table
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Table",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Head",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listTableHeadColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTableHeadColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTableHeadColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listTableTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTableTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTableTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Strike",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listTableStrikeColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTableStrikeColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTableStrikeColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Border",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listTableBorderColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTableBorderColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTableBorderColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Category
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  listTableCategoryBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTableCategoryBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTableCategoryBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  listTableCategoryTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listTableCategoryTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listTableCategoryTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Product
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Product",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Row",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listProductRow1Color,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listProductRow1Color =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listProductRow1Color,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Row 2",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listProductRow2Color,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listProductRow2Color =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listProductRow2Color,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: listProductTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    listProductTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: listProductTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Grid View
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Text(
                          "Grid Layout Colors",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Top Bar",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridTopbarBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridTopbarBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridTopbarBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridTopbarTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridTopbarTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridTopbarTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Category
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridCategoryBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridCategoryBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridCategoryBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridCategoryTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridCategoryTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridCategoryTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Rupees
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Rupees",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridRupeesBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridRupeesBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridRupeesBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridRupeesTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridRupeesTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridRupeesTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Category
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridTableCategoryBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridTableCategoryBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridTableCategoryBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridTableTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridTableTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridTableTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Product
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Product",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Row",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridProductRow1Color,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridProductRow1Color =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridProductRow1Color,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Row 2",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridProductRow2Color,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridProductRow2Color =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridProductRow2Color,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridProductTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridProductTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridProductTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Rate
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Rate",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridRateBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridRateBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridRateBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridRateTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridRateTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridRateTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Product Code
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Product Code",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridProductCodeBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridProductCodeBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridProductCodeBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  gridProductCodeTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridProductCodeTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridProductCodeTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Card
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Card",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Strike",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridCardStrikeColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridCardStrikeColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridCardStrikeColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Border",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: gridCardBorderColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    gridCardBorderColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: gridCardBorderColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Box Layout View
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Text(
                          "Box Layout Colors",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Top Bar",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  boxTopbarBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxTopbarBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxTopbarBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: boxTopbarTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxTopbarTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxTopbarTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Category
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  boxCategoryBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxCategoryBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxCategoryBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: boxCategoryTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxCategoryTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxCategoryTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Rupees
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Rupees",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  boxRupeesBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxRupeesBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxRupeesBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: boxRupeesTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxRupeesTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxRupeesTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Category
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  boxBottomCategoryBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxBottomCategoryBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxBottomCategoryBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  boxBottomCategoryTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxBottomCategoryTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxBottomCategoryTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Product Code
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Product Code",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Background",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor:
                                                  boxProductBackgroundColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxProductBackgroundColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxProductBackgroundColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: boxProductTextColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxProductTextColor =
                                                        newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxProductTextColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        //Box
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Box",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.black54),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Strike",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Pick a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: boxBoxColor,
                                              onColorChanged: (color) {
                                                changeColor(color, (newColor) {
                                                  setState(() {
                                                    boxBoxColor = newColor;
                                                  });
                                                });
                                              },
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: boxBoxColor,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ],
                )),
        ],
      ),
    );
  }

  ListView productView() {
    return ListView.builder(
        itemCount: settingsDataList.length,
        itemBuilder: (context, index) {
          SettingsEditingModel model = settingsDataList[index];

          if (model.productList != null && model.productList is List<dynamic>) {
            productsForNewArrivals =
                (model.productList as List<dynamic>).map((product) {
              return {
                'product_name': product['product_name'].toString(),
                'product_id': product['product_id'].toString(),
              };
            }).toList();
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  productDisplay(context),
                  newArrivals(context, productsForNewArrivals),
                  // webisteStatus(context),
                  pageListFeatures(context),
                  priceFormat(context),
                  pdfFormat(context),
                ],
              ),
            ),
          );
        });
  }

  ListView statusView() {
    return ListView.builder(
        itemCount: settingsDataList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      webisteStatus(context),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  ListView messageView() {
    return ListView.builder(
        itemCount: settingsDataList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      message(context),
                      // termsAndConditions(context),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  ListView stateView() {
    return ListView.builder(
        itemCount: settingsDataList.length,
        itemBuilder: (context, index) {
          List<dynamic> stateNames = stateCityList.keys.toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        selectStateOption(context, stateNames)
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Padding selectStateOption(BuildContext context, List<dynamic>? stateList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff586F7C),
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'State',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Select State",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      MultiSelectDropDown(
                        onOptionSelected: (options) {
                          setState(() {
                            for (var option in options) {
                              var selectedValue = option.value.toString();
                              if (!selectedStates.contains(selectedValue)) {
                                selectedStates.add(selectedValue);
                              }
                            }
                          });
                        },
                        onOptionRemoved: (index, option) {
                          setState(() {
                            selectedStates.removeAt(index);
                            selectedCities.removeAt(index);
                          });
                        },
                        options: stateList != null
                            ? stateList
                                .map((state) => ValueItem(
                                    label: state.toString(),
                                    value: state.toString()))
                                .toList()
                            : [],
                        selectionType: SelectionType.multi,
                        fieldBackgroundColor: Colors.grey[200],
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        dropdownHeight: 300,
                        optionTextStyle: const TextStyle(fontSize: 16),
                        selectedOptionIcon: const Icon(Icons.check_circle),
                        hint: 'Select State',
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: selectedStates.map((state) {
              return selectCityOption(state, context);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Column selectCityOption(String state, BuildContext context) {
    Set<String>? citiesList = stateCityList[state];
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff586F7C),
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
                Row(
                  children: [
                    Text(
                      "Select All",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Transform.scale(
                        scale: 0.7,
                        child: CupertinoSwitch(
                            value: true, onChanged: (value) {})),
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Min.Order",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                controller: minimumOrderController,
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
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Min.Order",
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Packing",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                controller: packingChargesController,
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
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Packing Charges",
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Select City",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    MultiSelectDropDown(
                      onOptionSelected: (options) {
                        setState(() {
                          for (var option in options) {
                            var selectedValue = option.value.toString();
                            bool alreadyExists = false;
                            for (var city in selectedCities) {
                              if (city[0] == state &&
                                  city[1] == selectedValue) {
                                alreadyExists = true;
                                break;
                              }
                            }
                            if (!alreadyExists) {
                              selectedCities.add([state, selectedValue]);
                            }
                          }
                        });
                        print(selectedCities);
                      },

                      onOptionRemoved: (index, option) {
                        setState(() {});
                      },
                      // selectedOptions: selectedCities,
                      options: citiesList != null
                          ? citiesList
                              .map((city) => ValueItem(
                                  label: city.toString(),
                                  value: city.toString()))
                              .toList()
                          : [],
                      selectionType: SelectionType.multi,
                      fieldBackgroundColor: Colors.grey[200],
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      dropdownHeight: 300,
                      optionTextStyle: const TextStyle(fontSize: 16),
                      selectedOptionIcon: const Icon(Icons.check_circle),
                      hint: 'Select City',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column message(BuildContext context) {
    return Column(children: [
      Column(children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          "Thank You Message",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: thankyouMessageController,
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
            maxLines: 10,
            decoration: InputDecoration(
              hintText: "Thank You Message",
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade500,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade500,
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
        ),
        //
        const SizedBox(
          height: 10,
        ),
        Text(
          "Footer Content Message",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            maxLines: 10,
            controller: footerMessageController,
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
              hintText: "Footer Content Message",
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade500,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade500,
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
        ),
      ])
    ]);
  }

  // Column termsAndConditions(BuildContext context) {
  //   return Column(
  //     children: [
  //       Text(
  //         "Terms and Conditions",
  //         style: Theme.of(context)
  //             .textTheme
  //             .bodyLarge!
  //             .copyWith(color: Colors.black54, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(
  //         height: 8,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: TextFormField(
  //           controller: termsAndConditionsController,
  //           maxLines: 10,
  //           decoration: InputDecoration(
  //             hintText: "Terms and conditions",
  //             filled: true,
  //             fillColor: Colors.grey.shade200,
  //             enabledBorder: OutlineInputBorder(
  //               borderSide: BorderSide(
  //                 color: Colors.grey.shade300,
  //               ),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             border: OutlineInputBorder(
  //               borderSide: BorderSide(
  //                 color: Colors.grey.shade300,
  //               ),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: const BorderSide(
  //                 color: Color(0xff2F4550),
  //               ),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Padding pdfFormat(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isPdfFormatExpanded = !isPdfFormatExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pdf Format Display',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isPdfFormatExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isPdfFormatExpanded)
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(children: [
                  Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Pdf Format Display",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Short'),
                            value: '1',
                            groupValue: printoutFormat,
                            onChanged: (value) {
                              setState(() {
                                printoutFormat = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Detail'),
                            value: '2',
                            groupValue: printoutFormat,
                            onChanged: (value) {
                              setState(() {
                                printoutFormat = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ])
                ]))
        ]));
  }

  Padding priceFormat(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isPriceFormatExpanded = !isPriceFormatExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price Format',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isPriceFormatExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isPriceFormatExpanded)
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(children: [
                  Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Product Price Display",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Discount'),
                            value: '1',
                            groupValue: pricelistFormat,
                            onChanged: (value) {
                              setState(() {
                                pricelistFormat = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Net Rate'),
                            value: '2',
                            groupValue: pricelistFormat,
                            onChanged: (value) {
                              setState(() {
                                pricelistFormat = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ])
                ]))
        ]));
  }

  Padding pageListFeatures(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isPageListFeaturesExpanded = !isPageListFeaturesExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pricelist Price Features',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isPageListFeaturesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isPageListFeaturesExpanded)
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(children: [
                  Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Promotion Code",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Yes'),
                            value: '1',
                            groupValue: showPromotionCode,
                            onChanged: (value) {
                              setState(() {
                                showPromotionCode = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('No'),
                            value: '2',
                            groupValue: showPromotionCode,
                            onChanged: (value) {
                              setState(() {
                                showPromotionCode = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),

                    //
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "OTP Verification",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Yes'),
                            value: '1',
                            groupValue: otpVerification,
                            onChanged: (value) {
                              setState(() {
                                otpVerification = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('No'),
                            value: '2',
                            groupValue: otpVerification,
                            onChanged: (value) {
                              setState(() {
                                otpVerification = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ])
                ]))
        ]));
  }

  Padding webisteStatus(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isWebsiteStatusExpanded = !isWebsiteStatusExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Website Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isWebsiteStatusExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isWebsiteStatusExpanded)
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(children: [
                  Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Website Status",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('OFF'),
                            value: 'Disable Site Yes',
                            groupValue: disableSite,
                            onChanged: (value) {
                              setState(() {
                                disableSite = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('ON'),
                            value: 'Disable Site No',
                            groupValue: disableSite,
                            onChanged: (value) {
                              setState(() {
                                disableSite = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ])
                ]))
        ]));
  }

  Padding newArrivals(
      BuildContext context, List<Map<String, String>> productList) {
    List<ValueItem<Object?>> valueItems = productList.map((product) {
      return ValueItem<Object?>(
        label: product['product_name']!,
        value: product['product_id'],
      );
    }).toList();

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isnewArrivalsExpanded = !isnewArrivalsExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Arrivals',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isnewArrivalsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isnewArrivalsExpanded)
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(children: [
                  Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "New Arrivals",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Background",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick a color'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor:
                                              newArrivalsBackgroundColor,
                                          onColorChanged: (color) {
                                            changeColor(color, (newColor) {
                                              setState(() {
                                                newArrivalsBackgroundColor =
                                                    newColor;
                                              });
                                            });
                                          },
                                          showLabel: true,
                                          pickerAreaHeightPercent: 0.8,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: newArrivalsBackgroundColor,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Text",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick a color'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: newArrivalsTextColor,
                                          onColorChanged: (color) {
                                            changeColor(color, (newColor) {
                                              setState(() {
                                                newArrivalsTextColor = newColor;
                                              });
                                            });
                                          },
                                          showLabel: true,
                                          pickerAreaHeightPercent: 0.8,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: newArrivalsTextColor,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Strike",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick a color'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: newArrivalsStrikeColor,
                                          onColorChanged: (color) {
                                            changeColor(color, (newColor) {
                                              setState(() {
                                                newArrivalsStrikeColor =
                                                    newColor;
                                              });
                                            });
                                          },
                                          showLabel: true,
                                          pickerAreaHeightPercent: 0.8,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: newArrivalsStrikeColor,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enquiry Button",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Background",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick a color'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor:
                                              newArrivalsButtonBackgroundColor,
                                          onColorChanged: (color) {
                                            changeColor(color, (newColor) {
                                              setState(() {
                                                newArrivalsButtonBackgroundColor =
                                                    newColor;
                                              });
                                            });
                                          },
                                          showLabel: true,
                                          pickerAreaHeightPercent: 0.8,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: newArrivalsButtonBackgroundColor,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Text",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick a color'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor:
                                              newArrivalsButtonTextColor,
                                          onColorChanged: (color) {
                                            changeColor(color, (newColor) {
                                              setState(() {
                                                newArrivalsButtonTextColor =
                                                    newColor;
                                              });
                                            });
                                          },
                                          showLabel: true,
                                          pickerAreaHeightPercent: 0.8,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: newArrivalsButtonTextColor,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedNewArrivalsRows.length < 3) {
                              addNewArrival();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            backgroundColor: const Color(0xff2F4550),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                "Add New",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < selectedNewArrivalsRows.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 10),
                              Text(
                                "New Arrivals Name",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: newArrivalsNameController[i],
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
                                      decoration: InputDecoration(
                                        hintText: "New Arrivals Name",
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
                                        prefixIcon: const Icon(Iconsax.note),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xff2F4550),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        removeNewArrival(i);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        backgroundColor: Colors.red.shade300,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              Text(
                                "New Arrivals Type",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.black54),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              MultiSelectDropDown(
                                onOptionSelected: (options) {
                                  List<String> selectedOptions = [];
                                  for (var option in options) {
                                    String selectedId = option.value.toString();
                                    selectedOptions.add(selectedId);
                                  }

                                  setState(() {
                                    selectedProductsForNewArrivals[i] =
                                        selectedOptions;
                                  });
                                  print(selectedProductsForNewArrivals);
                                },
                                onOptionRemoved: (index, option) {},
                                options: valueItems,
                                selectedOptions:
                                    i < previousProductsForNewArrivals.length
                                        ? previousProductsForNewArrivals[i]
                                            .map((product) {
                                            return ValueItem<Object?>(
                                              label: product['product_name'],
                                              value: product['product_id'],
                                            );
                                          }).toList()
                                        : [],
                                selectionType: SelectionType.multi,
                                fieldBackgroundColor: Colors.grey[200],
                                chipConfig:
                                    const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                optionTextStyle: const TextStyle(fontSize: 16),
                                selectedOptionIcon:
                                    const Icon(Icons.check_circle),
                                hint: 'Select Category',
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                            ],
                          ),
                        ),
                      )
                  ])
                ]))
        ]));
  }

  Padding productDisplay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isProductDisplayExpanded = !isProductDisplayExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Display',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isProductDisplayExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isProductDisplayExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Pricelist Display In Home Page",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: '1',
                                groupValue: priceListDisplayHomePage,
                                onChanged: (value) {
                                  setState(() {
                                    priceListDisplayHomePage = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: '2',
                                groupValue: priceListDisplayHomePage,
                                onChanged: (value) {
                                  setState(() {
                                    priceListDisplayHomePage = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Download Pricelist PDF In Frontend",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: '1',
                                groupValue: downloadPricelistPdf,
                                onChanged: (value) {
                                  setState(() {
                                    downloadPricelistPdf = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: '2',
                                groupValue: downloadPricelistPdf,
                                onChanged: (value) {
                                  setState(() {
                                    downloadPricelistPdf = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Product Code",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: '1',
                                groupValue: productCode,
                                onChanged: (value) {
                                  setState(() {
                                    productCode = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: '2',
                                groupValue: productCode,
                                onChanged: (value) {
                                  setState(() {
                                    productCode = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Discount Row",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: '1',
                                groupValue: discountRow,
                                onChanged: (value) {
                                  setState(() {
                                    discountRow = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: '2',
                                groupValue: discountRow,
                                onChanged: (value) {
                                  setState(() {
                                    discountRow = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Category Filter",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: '1',
                                groupValue: categoryFilter,
                                onChanged: (value) {
                                  setState(() {
                                    categoryFilter = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: '2',
                                groupValue: categoryFilter,
                                onChanged: (value) {
                                  setState(() {
                                    categoryFilter = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Search Filter",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: '1',
                                groupValue: searchFilter,
                                onChanged: (value) {
                                  setState(() {
                                    searchFilter = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: '2',
                                groupValue: searchFilter,
                                onChanged: (value) {
                                  setState(() {
                                    searchFilter = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "PDF Font Size (pixels)",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('8'),
                                value: '8',
                                groupValue: pdfFontSize,
                                onChanged: (value) {
                                  setState(() {
                                    pdfFontSize = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('8.5'),
                                value: '8.5',
                                groupValue: pdfFontSize,
                                onChanged: (value) {
                                  setState(() {
                                    pdfFontSize = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('9'),
                                value: '9',
                                groupValue: pdfFontSize,
                                onChanged: (value) {
                                  setState(() {
                                    pdfFontSize = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Padding layoutType(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isLayoutTypeExpanded = !isLayoutTypeExpanded;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Color(0xff586F7C),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Layout Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    isLayoutTypeExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isLayoutTypeExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Desktop Layout",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('List'),
                                value: 'List',
                                groupValue: desktopLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    desktopLayoutType = value;

                                    deskToplayoutBoxSelected = false;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Grid'),
                                value: 'Grid',
                                groupValue: desktopLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    desktopLayoutType = value;
                                    deskToplayoutBoxSelected = false;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Box'),
                                value: 'Box',
                                groupValue: desktopLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    desktopLayoutType = value;
                                    deskToplayoutBoxSelected = true;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: deskToplayoutBoxSelected,
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: DropdownButton<int>(
                                  value: desktopBoxCount!,
                                  onChanged: (newValue) {
                                    setState(() {
                                      desktopBoxCount = newValue;
                                    });
                                  },
                                  items: [6, 8].map((value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Text(
                                          '$value',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  underline: Container(),
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  iconSize: 36.0,
                                  elevation: 8,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                  ),
                                  dropdownColor: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Tab Layout",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('List'),
                                value: 'List',
                                groupValue: tabLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    tabLayoutType = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Grid'),
                                value: 'Grid',
                                groupValue: tabLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    tabLayoutType = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Box'),
                                value: 'Box',
                                groupValue: tabLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    tabLayoutType = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Mobile Layout",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('List'),
                                value: 'List',
                                groupValue: mobileLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    mobileLayoutType = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Grid'),
                                value: 'Grid',
                                groupValue: mobileLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    mobileLayoutType = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Box'),
                                value: 'Box',
                                groupValue: mobileLayoutType,
                                onChanged: (value) {
                                  setState(() {
                                    mobileLayoutType = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  BottomAppBar bottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
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
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
