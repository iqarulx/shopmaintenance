/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '/service/service.dart';
import '/view/view.dart';

class OTPPage extends StatefulWidget {
  final String phoneno;
  final String domain;
  final String docID;
  final int? smsCode;
  final String expiryDate;
  final String adminPath;
  final String serverIP;
  final String server;

  const OTPPage({
    super.key,
    required this.phoneno,
    required this.domain,
    required this.docID,
    required this.smsCode,
    required this.expiryDate,
    required this.adminPath,
    required this.serverIP,
    required this.server,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  int start = 60;
  int currentSeconds = 60;
  Timer? timer;
  String smsCode = '';

  @override
  void initState() {
    smsCode = widget.smsCode.toString();
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

  otpValid() async {
    try {
      LoadingOverlay.show(context);
      if (otp.text.isNotEmpty && otp.text.length == 6) {
        if (smsCode == otp.text) {
          await getDeviceInfo().then(
            (value) async {
              String deviceID = value["deviceid"];
              String brandName = value["brandName"];
              String modelName = value["modelName"];

              await OTPService()
                  .updateDeviceInfo(
                      deviceID: deviceID,
                      modelName: modelName,
                      brandName: brandName,
                      docID: widget.docID)
                  .then(
                (value) async {
                  await LocalDBConfig()
                      .setDomain(
                    domain: widget.domain,
                    adminPath: widget.adminPath,
                    serverIP: widget.serverIP,
                    server: widget.server,
                  )
                      .then(
                    (domain) async {
                      await InitAuthService()
                          .getMemberID(
                              phoneno: widget.phoneno,
                              fcmID: await getFCM() ?? "")
                          .then(
                        (memberID) async {
                          if (memberID.isNotEmpty) {
                            if (memberID["head"]["code"] != null &&
                                memberID["head"]["code"] == 200) {
                              await LocalDBConfig()
                                  .newUserLogin(
                                      phoneNumber: widget.phoneno,
                                      domain: widget.domain,
                                      memberID: memberID["head"]["user_id"]
                                          .toString(),
                                      expiryDate: widget.expiryDate)
                                  .then((localDBResult) {
                                // Navigator.pop(context);
                                LoadingOverlay.hide();
                                // Navigator.pop(context);
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
                          } else {
                            errorSnackbar(context);
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        } else {
          LoadingOverlay.hide();
          showCustomSnackBar(
            context,
            content: "Incorrect OTP",
            isSuccess: false,
          );
        }
      } else {
        // Navigator.pop(context);
        LoadingOverlay.hide();
        showCustomSnackBar(
          context,
          content: "OTP is Must",
          isSuccess: false,
        );
      }
    } catch (e) {
      LoadingOverlay.hide();
      showCustomSnackBar(
        context,
        content: "Error: ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (currentSeconds > 0) {
          currentSeconds--;
        } else {
          timer.cancel();
          // Timer is done, perform any actions you want here
        }
      });
    });
  }

  void codesend(String verificationId, int? smsCode) {
    if (verificationId.isNotEmpty) {
      Navigator.pop(context);
      setState(() {
        currentSeconds = start;
      });
      startTimer();
      showCustomSnackBar(
        context,
        content: "OTP Send SuccessFully",
        isSuccess: true,
      );
    }
  }

  resendOTP() async {
    try {
      // futureLoading(context);
      LoadingOverlay.show(context);

      await OTPService()
          .sendOTP(
        context,
        phoneNumber: widget.phoneno,
      )
          .then((value) {
        setState(() {
          smsCode = value.toString();
        });
        LoadingOverlay.hide();
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xff586F7C),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const BackButton(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Center(
              child: Text(
                "OTP Verification",
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
                "Check your  +91 ${widget.phoneno} to see the verification Code has send",
                // style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xffF4F4F9).withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pinput(
                    // androidSmsAutofillMethod:
                    //     AndroidSmsAutofillMethod.smsRetrieverApi,
                    autofocus: true,
                    controller: otp,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      height: 45,
                      width: 45,
                      textStyle: const TextStyle(color: Colors.white),
                      decoration: BoxDecoration(
                        color: const Color(0xff2F4550),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: () async {
                  otpValid();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  height: 50,
                  width: 164,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Center(
                    child: Text(
                      "Verify OTP",
                      style: TextStyle(
                        color: Color(0xffF4F4F9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Didn't Receive OTP?",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (currentSeconds == 0) {
                      resendOTP();
                    }
                  },
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      color: currentSeconds == 0 ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                Text(
                  "00:$currentSeconds",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
