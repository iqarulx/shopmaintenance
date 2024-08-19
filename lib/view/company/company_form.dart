/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';
import '/model/company_model.dart';
import '/provider/fingerprint_provider.dart';
import '/service/http_service/company_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/notification_service/local_notification.dart';
import '/view/custom_ui_element/future_error.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class CompanyForm extends StatefulWidget {
  final String companyId;
  const CompanyForm({super.key, required this.companyId});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final _formKey = GlobalKey<FormState>();
  List<CompanyEditingModel> companyDataList = [];
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactNumber1Controller =
      TextEditingController();
  final TextEditingController _contactNumber2Controller =
      TextEditingController();
  final TextEditingController _contactNumber3Controller =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _callUsController = TextEditingController();
  final TextEditingController _enquiryPrefixController =
      TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _acNameController = TextEditingController();
  final TextEditingController _acNumberController = TextEditingController();
  final TextEditingController _acTypeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _runningTextController = TextEditingController();
  final TextEditingController _runningTextDurationController =
      TextEditingController();
  TabController? tabController;
  Future? companyEditHandler;
  Color backgroundColor = Colors.black;
  Color textColor = Colors.black;

  @override
  void initState() {
    companyEditHandler = companyEditView().whenComplete(initData);
    super.initState();
  }

  initData() {
    for (var model in companyDataList) {
      backgroundColor = Color(int.parse(
          model.runningTextBackColor!
              .replaceAll('#', '')
              .replaceRange(0, 0, 'FF'),
          radix: 16));
      textColor = Color(int.parse(
          model.runningTextColor!.replaceAll('#', '').replaceRange(0, 0, 'FF'),
          radix: 16));
      _companyNameController.text = model.name!;
      _contactNumber1Controller.text = model.contactNumber1!;
      _contactNumber2Controller.text = model.contactNumber2!;
      _contactNumber3Controller.text = model.contactNumber3!;
      _addressController.text = model.address!;
      _whatsappController.text = model.whatsappNumber!;
      _callUsController.text = model.callUsNumber!;
      _enquiryPrefixController.text = model.orderPrefix!;
      _mobileNumberController.text = model.mobileNumber!;
      _emailController.text = model.email!;
      _acNameController.text = model.acName!;
      _acNumberController.text = model.acNumber!;
      _acTypeController.text = model.acType!;
      _bankNameController.text = model.bankName!;
      _ifscCodeController.text = model.ifscCode!;
      _runningTextController.text = model.runningText!;
      _runningTextDurationController.text = model.runningTextDuration!;
    }
  }

  Future<bool> companyEditView() async {
    try {
      setState(() {
        companyDataList.clear();
      });

      var resultData =
          await CompanyService().editCompany(companyId: widget.companyId);

      if (resultData != null && resultData["head"]["code"] == 200) {
        for (var element in resultData["head"]["msg"]) {
          CompanyEditingModel model = CompanyEditingModel();
          model.name = element["name"].toString();
          model.logo = element["logo"].toString();
          model.address = element["address"].toString();
          model.whatsappNumber = element["whatsapp_number"].toString();
          model.callUsNumber = element["call_us_number"].toString();
          model.contactNumber1 = element["contact_number1"].toString();
          model.contactNumber2 = element["contact_number2"].toString();
          model.contactNumber3 = element["contact_number3"].toString();
          model.mobileNumber = element["mobile_number"].toString();
          model.email = element["email"].toString();
          model.acName = element["ac_name"].toString();
          model.acNumber = element["ac_number"].toString();
          model.acType = element["ac_type"].toString();
          model.bankName = element["bank_name"].toString();
          model.ifscCode = element["ifsc_code"].toString();
          model.runningText = element["running_text"].toString();
          model.runningTextBackColor =
              element["running_text_back_color"].toString();
          model.runningTextDuration =
              element["running_text_duration"].toString();
          model.orderPrefix = element["order_prefix"].toString();
          model.runningTextColor = element["running_text_color"].toString();
          companyDataList.add(model);
        }
        return true;
      } else if (resultData["head"]["code"] == 400) {
        showCustomSnackBar(context,
            content: resultData["head"]["msg"].toString(), isSuccess: false);
        throw resultData["head"]["msg"].toString();
      }
    } on SocketException catch (e) {
      print(e);
      throw "Network Error";
    } catch (e) {
      print(e);
      throw e.toString();
    }
    return false;
  }

  void changeColor(Color color, ValueChanged<Color> updateColor) {
    updateColor(color);
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  void submitForm() async {
    if (_companyNameController.text.isNotEmpty &&
        _contactNumber1Controller.text.isNotEmpty &&
        _contactNumber2Controller.text.isNotEmpty &&
        _contactNumber3Controller.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _whatsappController.text.isNotEmpty &&
        _callUsController.text.isNotEmpty &&
        _enquiryPrefixController.text.isNotEmpty &&
        _mobileNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _runningTextController.text.isNotEmpty) {
      var userId = await LocalDBConfig().getUserID();
      Map<String, String> formData = {
        'creator_id': userId.toString(),
        'edit_company_id': widget.companyId,
        'company_name': _companyNameController.text,
        'contact_number1': _contactNumber1Controller.text,
        'contact_number2': _contactNumber2Controller.text,
        'contact_number3': _contactNumber3Controller.text,
        'address': _addressController.text,
        'whatsapp': _whatsappController.text,
        'call_us': _callUsController.text,
        'enquiry_prefix': _enquiryPrefixController.text,
        'mobile_number': _mobileNumberController.text,
        'email': _emailController.text,
        'ac_name': _acNameController.text,
        'ac_number': _acNumberController.text,
        'ac_type': _acTypeController.text,
        'bank_name': _bankNameController.text,
        'ifsc_code': _ifscCodeController.text,
        'running_text': _runningTextController.text,
        'running_text_back_color': colorToHex(backgroundColor),
        'running_text_color': colorToHex(textColor),
        'running_text_duration': _runningTextDurationController.text,
      };

      try {
        await LocalAuthConfig()
            .checkBiometrics(context, 'Company')
            .then((value) {
          if (value) {
            LoadingOverlay.show(context);

            CompanyService().updateCompany(formData: formData).then((value) {
              LoadingOverlay.hide();
              if (value['head']['code'] == 200) {
                Navigator.pop(context);
                showCustomSnackBar(context,
                    content: "Updated Successfully", isSuccess: true);

                NotificationService().showNotification(
                    title: "Company Updated",
                    body: "Company has updated successfully.");
              } else {
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
        LoadingOverlay.hide();
        showCustomSnackBar(context,
            content: "Updation Failed $e", isSuccess: false);
      }
    } else {
      showCustomSnackBar(context,
          content: "Please enter all feilds", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appbar(context),
            bottomNavigationBar: bottomAppbar(context),
            body: body()),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
        future: companyEditHandler,
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
            if (snapshot.data) {
              return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      companyEditHandler = companyEditView();
                    });
                  },
                  child: screenView(context));
            } else {
              return const Text("Failed to fetch data");
            }
          }
        });
  }

  Form screenView(BuildContext context) {
    return Form(
        key: _formKey,
        child: TabBarView(children: [
          ListView(
            children: [
              companyDetails(context),
            ],
          ),
          ListView(
            children: [
              contactNumbers(context),
            ],
          ),
          ListView(
            children: [
              smsAndEmail(context),
            ],
          ),
          ListView(
            children: [
              bankDetails(context),
            ],
          ),
          ListView(
            children: [runningText(context)],
          )
        ]));
  }

  Padding runningText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            "Running Text and Colors",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "Running Text(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _runningTextController,
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
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Running Text",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.message),
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
            // inputFormatters: [
            //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z&\s]')),
            // ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter running text';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Duration",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Colors.black54),
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: _runningTextDurationController,
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  hintText: "Duration",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Iconsax.clock),
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
          const SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
                                pickerColor: backgroundColor,
                                onColorChanged: (color) {
                                  changeColor(color, (newColor) {
                                    setState(() {
                                      backgroundColor = newColor;
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
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: backgroundColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
                                pickerColor: textColor,
                                onColorChanged: (color) {
                                  changeColor(color, (newColor) {
                                    setState(() {
                                      textColor = newColor;
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
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: textColor,
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
        ],
      ),
    );
  }

  Padding bankDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Text(
            "Bank Details",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "A/C Name",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _acNameController,
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
              hintText: "A/C Name",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.key),
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
          const SizedBox(
            height: 8,
          ),
          Text(
            "A/C Number",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _acNumberController,
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
              hintText: "A/C Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.key1),
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
          const SizedBox(
            height: 8,
          ),
          Text(
            "A/C Type",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _acTypeController,
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
              hintText: "A/C Type",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.key_square),
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
          const SizedBox(
            height: 8,
          ),
          Text(
            "Bank Name",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _bankNameController,
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
              hintText: "Bank Name",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.building),
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
          const SizedBox(
            height: 8,
          ),
          Text(
            "IFSC Code",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _ifscCodeController,
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
              hintText: "IFSC Code",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.building),
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
    );
  }

  Padding smsAndEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Text(
            "We Use this details for SMS and Email",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "Mobile(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _mobileNumberController,
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
              hintText: "Mobile Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.call),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Email(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _emailController,
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
              hintText: "Email",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
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
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Padding contactNumbers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Text(
            "Whatsapp Number(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _whatsappController,
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
              hintText: "Whatsapp Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.message),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter whatsapp number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Call Us Number(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _callUsController,
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
              hintText: "Call Us Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.call),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter call us number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Enquiry Prefix(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _enquiryPrefixController,
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
              hintText: "Enquiry Prefix",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.note),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z&\s]')),
              LengthLimitingTextInputFormatter(5),
              UpperCaseTextFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter enquiry prefix';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
        ],
      ),
    );
  }

  Padding companyDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Text(
            "Company Name(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
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
            controller: _companyNameController,
            decoration: InputDecoration(
              hintText: "Company Name",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.building),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z&\s]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company name';
              }
              if (!RegExp(r'^[a-zA-Z&\s]+$').hasMatch(value)) {
                return 'Company name can only contain letters, spaces, and &';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Contact Number 1(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _contactNumber1Controller,
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
              hintText: "Contact Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Icons.phone),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Contact Number 2(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _contactNumber2Controller,
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
              hintText: "Contact Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.call),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Contact Number 3(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
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
            controller: _contactNumber3Controller,
            decoration: InputDecoration(
              hintText: "Contact Number",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.call),
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            "Address(*)",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.black54),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _addressController,
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
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Address",
              filled: true,
              fillColor: Colors.grey.shade200,
              prefixIcon: const Icon(Iconsax.location),
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
                return 'Please enter address';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 14,
          ),
        ],
      ),
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
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
        surfaceTintColor: Colors.white,
        title: Text(
          "Edit Company",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.black,
              ),
        ),
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black38,
          isScrollable: true,
          tabs: const [
            Tab(
              text: "Company Details",
            ),
            Tab(
              text: "Quick Numbers",
            ),
            Tab(
              text: "SMS and Email",
            ),
            Tab(
              text: "Bank Details",
            ),
            Tab(
              text: "Running Text",
            ),
          ],
        ));
  }
}
