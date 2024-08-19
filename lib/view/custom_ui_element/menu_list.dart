/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/view/auth/screen_auth.dart';
import '/view/category/category.dart';
import '/view/company/company.dart';
import '/view/cpin/cpin.dart';
import '/view/custom_ui_element/confrimation_alert_dialog.dart';
import '/view/custom_ui_element/show_custom_snackbar.dart';
import '/view/discount/discount.dart';
import '/view/enquiry/enquiry_listing_view.dart';
import '/view/auth/phone_login_view.dart';
import '/view/product/product.dart';
import '/view/sales_report/sales_report.dart';
import '/view/settings/settings.dart';
import '/view/terms/privacy_policy.dart';
import '/view/terms/terms_and_conditions.dart';
import '/view/wesite_status/website_status.dart';

class MenuList extends StatefulWidget {
  const MenuList({
    super.key,
  });

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  String domain = '';
  String phoneNumber = '';
  String expiryDate = '';
  String? currentVersion;

  @override
  void initState() {
    getUserDetails();

    super.initState();
  }

  getUserDetails() async {
    final dbDomain = await LocalDBConfig().getdomain();
    final dbPhoneNum = await LocalDBConfig().getPhone();
    final dbExpiryDate = await LocalDBConfig().getExpiry();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      domain = dbDomain ?? '';
      phoneNumber = dbPhoneNum ?? '';
      expiryDate = dbExpiryDate ?? '';
      currentVersion = packageInfo.version;
    });
  }

  String changeDate(String timestamp) {
    RegExp regex = RegExp(r"seconds=(\d+)");
    Match? match = regex.firstMatch(timestamp);
    if (match != null) {
      int seconds = int.parse(match.group(1)!);
      DateTime date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      DateFormat formatter = DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(date);

      return formattedDate;
    } else {
      return "";
    }
  }

  watchDemo() async {
    await LocalDBConfig().resetDemoCategory().then((onValue) async {
      await LocalDBConfig().resetDemoCompany().then((onValue) async {
        await LocalDBConfig().resetDemoDiscount().then((onValue) async {
          await LocalDBConfig().resetDemoEnquiry().then((onValue) async {
            await LocalDBConfig().resetDemoProduct().then((onValue) async {
              await LocalDBConfig()
                  .resetDemoProductSales()
                  .then((onValue) async {
                await LocalDBConfig()
                    .resetDemoScreenAuth()
                    .then((onValue) async {
                  await LocalDBConfig()
                      .resetDemoSettings()
                      .then((onValue) async {
                    showCustomSnackBar(context,
                        content: "You can now watch demo in all screens",
                        isSuccess: true);
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  openStatusEdit() async {
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
          return const WebsiteStatus();
        });
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
            )
          ],
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            "Menu",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider(
            //   color: Colors.grey.withOpacity(0.5),
            // ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Image.asset("assets/avatar.png"),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.globe,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            domain.length > 20
                                ? '${domain.substring(0, 20)}...'
                                : domain,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.phone_circle,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                phoneNumber,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.calendar,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Expiry - ${changeDate(expiryDate)}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.5),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    context,
                    title: 'Enquiry',
                    icon: CupertinoIcons.doc_text,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EnquiryListing()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Product Sales',
                    icon: CupertinoIcons.bag,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SalesReport()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Company',
                    icon: CupertinoIcons.building_2_fill,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Company()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Settings',
                    icon: CupertinoIcons.settings,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Website Status',
                    icon: Iconsax.danger,
                    onTap: () {
                      openStatusEdit();
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Category',
                    icon: CupertinoIcons.square_grid_2x2,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CategoryScreen()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Product',
                    icon: CupertinoIcons.shopping_cart,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProductScreen()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Discount',
                    icon: CupertinoIcons.percent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DiscountScreen()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Screen Auth',
                    icon: Iconsax.finger_scan,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenAuth()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'CPIN',
                    icon: Iconsax.key,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Cpin()));
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Watch Demo',
                    icon: Iconsax.video,
                    onTap: () {
                      watchDemo();
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Terms and Conditions',
                    icon: Iconsax.shield,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditions(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Privacy Policy',
                    icon: Iconsax.shield_tick,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Logout',
                    icon: CupertinoIcons.power,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const ConfrimationAlertDialog(
                          title: "Alert",
                          content: "Do you want Confirm to Logout?",
                        ),
                      ).then((result) async {
                        if (result != null && result) {
                          await LocalDBConfig().logoutUser().then((value) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhoneLogin(),
                              ),
                            );
                          });
                        }
                      });
                    },
                  ),
                  if (currentVersion != null)
                    _buildListTile(
                      context,
                      title: 'App version $currentVersion',
                      icon: Iconsax.grid_2,
                      onTap: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title,
      required IconData icon,
      required void Function() onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        leading: Icon(icon, size: 25),
        onTap: onTap,
        // trailing: const Icon(LineIcons.arrowRight),
      ),
    );
  }
}
