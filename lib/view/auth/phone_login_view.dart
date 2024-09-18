/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info/package_info.dart';
import 'package:pinput/pinput.dart';
import '/service/firebase_service/otp_serivce.dart';
import '/view/auth/login.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/service/common_var.dart';
import '/service/firebase_service/customer_service.dart';
import '/view/custom_ui_element/alert_dialog.dart';
import '/view/custom_ui_element/future_loading.dart';
import 'otp_view.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  TextEditingController phoneNumber = TextEditingController();
  String? domain, adminPath, serverIP, server;
  String? docID;
  String? expiryDate;
  var formKeyState = GlobalKey<FormState>();

  verificationCompleted(PhoneAuthCredential credential) {
    if (credential.smsCode != null) {
      otp.setText(credential.smsCode!);
    }
  }

  codesend(String verificationId, int? smsCode) {
    showCustomSnackBar(context,
        content: "Verification Completed", isSuccess: true);

    if (verificationId.isNotEmpty) {
      // Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            verificationId: verificationId,
            phoneno: phoneNumber.text,
            domain: domain ?? '',
            docID: docID ?? '',
            smsCode: smsCode ?? 123456,
            expiryDate: expiryDate!,
            adminPath: adminPath ?? '',
            serverIP: serverIP ?? '',
            server: server ?? '',
          ),
        ),
      );
    }
  }

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
    try {
      // futureLoading(context);
      LoadingOverlay.show(context);
      FocusManager.instance.primaryFocus!.unfocus();
      await CustomerService()
          .findPhoneNumber(phoneNumber: phoneNumber.text)
          .then((dataResult) async {
        LoadingOverlay.hide();

        if (dataResult.docs.isNotEmpty) {
          setState(() {
            docID = dataResult.docs.first.id;
          });
          if (dataResult.docs.first["block_At"] == false) {
            Timestamp timestamp = dataResult.docs.first["expiry_date"];
            setState(() {
              expiryDate = timestamp.toString();
            });
            DateTime dateTime = timestamp.toDate();
            if (DateTime.now().isBefore(dateTime)) {
              await getDeviceInfo().then((value) async {
                if (dataResult.docs.first["device"]["device_id"] == null &&
                    dataResult.docs.first["device"]["brand_name"] == null &&
                    dataResult.docs.first["device"]["model_no"] == null) {
                  setState(() {
                    domain = dataResult.docs.first["domain"].toString();
                    adminPath = dataResult.docs.first["admin_path"].toString();
                    serverIP = dataResult.docs.first["server_ip"].toString();
                    server = dataResult.docs.first["server"].toString();
                  });

                  await OTPService().sendOTP(
                    context,
                    phoneNumber: phoneNumber.text,
                    codeSent: codesend,
                    verificationCompleted: verificationCompleted,
                    forceResendingToken: null,
                  );
                  showCustomSnackBar(
                    context,
                    content: "You will receive otp when verfication complete",
                    isSuccess: true,
                  );
                } else if (value["deviceid"] ==
                        dataResult.docs.first["device"]["device_id"] &&
                    value["brandName"] ==
                        dataResult.docs.first["device"]["brand_name"] &&
                    value["modelName"] ==
                        dataResult.docs.first["device"]["model_no"]) {
                  setState(() {
                    domain = dataResult.docs.first["domain"];
                    adminPath = dataResult.docs.first["admin_path"].toString();
                    serverIP = dataResult.docs.first["server_ip"].toString();
                  });
                  showCustomSnackBar(
                    context,
                    content: "You will receive otp when verfication complete",
                    isSuccess: true,
                  );
                  await OTPService().sendOTP(
                    context,
                    phoneNumber: phoneNumber.text,
                    codeSent: codesend,
                    verificationCompleted: verificationCompleted,
                    forceResendingToken: null,
                  );
                } else {
                  showCustomSnackBar(
                    context,
                    content: "Your account was Login Another Device",
                    isSuccess: false,
                  );
                }
              });
            } else {
              showCustomSnackBar(
                context,
                content: "Account was expired",
                isSuccess: false,
              );
            }
          } else {
            // Navigator.pop(context);
            showCustomSnackBar(
              context,
              content: "Unable to Login this Account",
              isSuccess: false,
            );
          }
        } else {
          showCustomSnackBar(
            context,
            content: "User Details Not Found",
            isSuccess: false,
          );
        }
      });
    } catch (e) {
      LoadingOverlay.hide();
      showCustomSnackBar(
        context,
        content: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<String> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              // const SizedBox(
              //   height: 50,
              // ),
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
                height: 10,
              ),
              Center(
                child: Text(
                  "You will receive a 6 digit code to verify next",
                  // style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xffF4F4F9).withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                child: Form(
                  key: formKeyState,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: phoneNumber,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
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
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xff2F4550)),
                        decoration: const InputDecoration(
                          filled: true,
                          // fillColor: Color(0xff2F4550),
                          fillColor: Colors.white,
                          prefixIcon: Icon(Iconsax.call),
                          prefixIconColor: Color(0xff9B9B9B),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Phone Number",
                          hintStyle: TextStyle(color: Color(0xff9B9B9B)),
                          errorStyle: TextStyle(color: Colors.white),
                        ),
                        cursorColor: Colors.white,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone Number is Must";
                          } else if (value.length != 10) {
                            return "Phone Number is Not Valid";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const EnquiryListing(),
                    //   ),
                    // );
                    if (formKeyState.currentState!.validate()) {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return ContrimationDialog(phoneno: phoneNumber.text);
                        },
                      ).then((result) {
                        if (result != null && result) {
                          phoneNumberValid();
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfffba302),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 50,
                    width: 164,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        const Center(
                          child: Text(
                            "Send OTP",
                            style: TextStyle(
                              // color: Color(0xffF4F4F9),
                              color: Color(0xffb02a29),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 36,
                          width: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff2B2B2B),
                          ),
                          child: const Center(
                            child: Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Login with ',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'password',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: getAppInfo(),
                builder: (builder, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return const Text("App Version : ----");
                  } else {
                    return Center(
                      child: Text(
                        "App Version : ${snapshot.data}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
