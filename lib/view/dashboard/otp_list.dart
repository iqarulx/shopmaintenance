import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopmaintenance/service/http_service/dashboard_service.dart';
import '../../model/dashboard_model.dart';
import '/view/custom_ui_element/future_loading.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';

class OtpList extends StatefulWidget {
  const OtpList({super.key});

  @override
  State<OtpList> createState() => _OtpListState();
}

class _OtpListState extends State<OtpList> {
  List<OtpModel> otpList = [];
  Future? otpHandler;

  @override
  void initState() {
    otpHandler = otpListView();
    super.initState();
  }

  Future<void> otpListView() async {
    try {
      setState(() {
        otpList.clear();
      });

      await DashboardService().getOTP().then((resultData) async {
        if (resultData.isNotEmpty) {
          if (resultData != null && resultData["head"]["code"] == 200) {
            for (var element in resultData["head"]["msg"]["otp_data"]) {
              OtpModel model = OtpModel();
              model.otp = element["otp_number"].toString();
              model.createdAt = element["send_date_time"].toString();
              model.phoneNumber = element["phone_number"].toString();
              setState(() {
                otpList.add(model);
              });
            }
          } else if (resultData["head"]["code"] == 400) {
            showCustomSnackBar(context,
                content: resultData["head"]["msg"].toString(),
                isSuccess: false);
            throw resultData["head"]["msg"].toString();
          }
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffEEEEEE),
        appBar: appbar(context),
        body: body(),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: otpHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureWaitingLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return const Center(
              child: Text("Network Error"),
            );
          } else {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                otpHandler = otpListView();
              });
            },
            child: otpList.isNotEmpty
                ? screenView()
                : const Center(
                    child: Text("No data found"),
                  ),
          );
        }
      },
    );
  }

  ListView screenView() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: otpList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "OTP : ${otpList[index].otp ?? ''}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Mobile No : ${otpList[index].phoneNumber ?? ''}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Created : ${DateFormat("dd-MM-yyyy hh:mm a").format(
                    DateTime.parse(otpList[index].createdAt!),
                  )}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        "OTP List",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
