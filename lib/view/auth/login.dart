/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '/service/firebase_service/customer_service.dart';
import '/service/firebase_service/get_fcm.dart';
import '/service/firebase_service/otp_serivce.dart';
import '/service/http_service/init_auth_service.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/auth/phone_login_view.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/dashboard/dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool passwordvisable = true;
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  String? domain;
  String? docID;
  var formKeyState = GlobalKey<FormState>();

  Future getDeviceInfo() async {
    String? deviceid;
    String? brandName;
    String? modelName;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      brandName = androidInfo.brand.toString();
      deviceid = androidInfo.id.toString();
      modelName = androidInfo.model.toString();
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      brandName = iosDeviceInfo.name.toString();
      deviceid = iosDeviceInfo.identifierForVendor.toString();
      modelName = iosDeviceInfo.model.toString();
    }

    return {
      "deviceid": deviceid,
      "brandName": brandName,
      "modelName": modelName,
    };
  }

  phoneNumberValid() async {
    LoadingOverlay.show(context);
    try {
      FocusManager.instance.primaryFocus!.unfocus();
      await CustomerService()
          .findPhoneNumber(phoneNumber: phoneNumber.text)
          .then((dataResult) async {
        if (dataResult.docs.isNotEmpty) {
          setState(() {
            docID = dataResult.docs.first.id;
          });
          if (dataResult.docs.first["block_At"] == false) {
            Timestamp timestamp = dataResult.docs.first["expiry_date"];
            DateTime dateTime = timestamp.toDate();
            if (DateTime.now().isBefore(dateTime)) {
              await getDeviceInfo().then((value) async {
                if (dataResult.docs.first["device"]["device_id"] == null &&
                    dataResult.docs.first["device"]["brand_name"] == null &&
                    dataResult.docs.first["device"]["model_no"] == null) {
                  setState(() {
                    domain = dataResult.docs.first["domain"].toString();
                  });
                  await OTPService()
                      .updateDeviceInfo(
                          deviceID: value["deviceid"],
                          modelName: value["modelName"],
                          brandName: value["brandName"],
                          docID: docID!)
                      .then((value) async {
                    await LocalDBConfig()
                        .setDomain(domain: dataResult.docs.first["domain"])
                        .then((domain) async {
                      await InitAuthService()
                          .checkLogin(
                              password: password.text,
                              phoneno: phoneNumber.text,
                              fcmID: await getFCM() ?? "")
                          .then((memberID) async {
                        if (memberID["head"]["code"] != null &&
                            memberID["head"]["code"] == 200) {
                          await LocalDBConfig()
                              .newUserLogin(
                                  phoneNumber: phoneNumber.text,
                                  domain: dataResult.docs.first["domain"],
                                  memberID:
                                      memberID["head"]["user_id"].toString(),
                                  expiryDate: dataResult
                                      .docs.first["expiry_date"]
                                      .toString())
                              .then((localDBResult) {
                            LoadingOverlay.hide();

                            showCustomSnackBar(context,
                                content: "Login Successfully", isSuccess: true);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Dashboard(),
                              ),
                            );
                          });
                        } else {
                          throw memberID["head"]["msg"];
                        }
                      });
                    });
                  });
                } else if (value["deviceid"] ==
                        dataResult.docs.first["device"]["device_id"] &&
                    value["brandName"] ==
                        dataResult.docs.first["device"]["brand_name"] &&
                    value["modelName"] ==
                        dataResult.docs.first["device"]["model_no"]) {
                  setState(() {
                    domain = dataResult.docs.first["domain"];
                  });

                  await LocalDBConfig()
                      .setDomain(domain: dataResult.docs.first["domain"])
                      .then((domain) async {
                    await InitAuthService()
                        .checkLogin(
                            password: password.text,
                            phoneno: phoneNumber.text,
                            fcmID: await getFCM() ?? "")
                        .then((memberID) async {
                      if (memberID["head"]["code"] != null &&
                          memberID["head"]["code"] == 200) {
                        await LocalDBConfig()
                            .newUserLogin(
                                phoneNumber: phoneNumber.text,
                                domain: dataResult.docs.first["domain"],
                                memberID:
                                    memberID["head"]["user_id"].toString(),
                                expiryDate: dataResult.docs.first["expiry_date"]
                                    .toString())
                            .then((localDBResult) {
                          LoadingOverlay.hide();
                          showCustomSnackBar(context,
                              content: "Login Successfully", isSuccess: true);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Dashboard(),
                            ),
                          );
                        });
                      } else {
                        throw memberID["head"]["msg"];
                      }
                    });
                  });
                } else {
                  LoadingOverlay.hide();
                  showCustomSnackBar(context,
                      content: "You are already logged with another device",
                      isSuccess: false);
                }
              });
            } else {
              LoadingOverlay.hide();
              showCustomSnackBar(context,
                  content: "Account was expired", isSuccess: false);
            }
          } else {
            LoadingOverlay.hide();

            showCustomSnackBar(context,
                content: "Unable to Login this Account", isSuccess: false);
          }
        } else {
          LoadingOverlay.hide();

          showCustomSnackBar(context,
              content: "User Details Not Found", isSuccess: false);
        }
      });
    } catch (e) {
      LoadingOverlay.hide();
      showCustomSnackBar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // backgroundColor: const Color(0xff586F7C),
        body: SafeArea(
          child: Form(
            key: formKeyState,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
                const Center(
                  child: Text(
                    "Sign in to your Account",
                    // style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xffF4F4F9),
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  child: TextFormField(
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    controller: phoneNumber,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorStyle: const TextStyle(color: Colors.white),
                      hintText: "Mobile Number",
                      filled: true,
                      fillColor: Colors.white,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter mobile number";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  child: TextFormField(
                    controller: password,
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
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorStyle: const TextStyle(color: Colors.white),
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
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
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordvisable = !passwordvisable;
                          });
                        },
                        icon: Icon(
                            passwordvisable ? Iconsax.eye_slash : Iconsax.eye),
                        color: const Color(0xff686868),
                      ),
                    ),
                    obscureText: passwordvisable,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter password";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    if (formKeyState.currentState!.validate()) {
                      phoneNumberValid();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFAA916),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 50,
                    width: double.infinity,
                    child: const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneLogin(),
                      ),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Login with ',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'otp',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white)),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
