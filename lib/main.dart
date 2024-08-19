/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'dart:developer';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import '/view/auth/login.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/service/firebase_service/otp_serivce.dart';
import '/service/local_storage_service/local_db_config.dart';
import '/service/update_service/update_service.dart';
import '/view/custom_ui_element/app_update_view.dart';
import '/view/dashboard/dashboard.dart';
import '/view/enquiry/enquiry_listing_view.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void notificationTapBackground(NotificationResponse notificationResponse) {
  log('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');

  // Map valueMap = json.decode(notificationResponse.payload!);
  enquiryRoutes.topChanged(true);
  // log("its Worked");
  // if (valueMap['redirect'] == "notification") {
  //   // log("its 11");
  //   // appDrawerChanger.chanageIndex(11);
  // }

  if (notificationResponse.input?.isNotEmpty ?? false) {
    log('notification action tapped with input: ${notificationResponse.input}');
  }
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

late FirebaseMessaging messaging;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var isLogin = await LocalDBConfig().checkLogin();

  messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //If subscribe based sent notification then use this token
  await messaging.getToken();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iOS = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: android, iOS: iOS);

  isLogin
      ? await flutterLocalNotificationsPlugin!.initialize(
          initSettings,
          onDidReceiveNotificationResponse:
              isLogin ? notificationTapBackground : null,
          onDidReceiveBackgroundNotificationResponse:
              isLogin ? notificationTapBackground : null,
        )
      : null;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  if (isLogin) {
    var domain = await LocalDBConfig().getdomain();
    await OTPService()
        .updateLoginTimeByDomain(loginTime: DateTime.now(), domain: domain);
  }

  final appUpdate = await UpdateService.isUpdateAvailable();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    MyApp(
        isLogin: isLogin, appUpdate: appUpdate, savedThemeMode: savedThemeMode),
  );
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  final bool isLogin;
  final bool appUpdate;
  const MyApp(
      {super.key,
      required this.isLogin,
      required this.appUpdate,
      this.savedThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          secondary: Colors.white,
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          secondary: const Color(0xFF393840),
        ),
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Shop Maintenance',
        theme: theme,
        darkTheme: darkTheme,
        home: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Shop Maintenance",
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xffEEEEEE),
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff586F7C)),
          ),
          home: widget.appUpdate
              ? widget.isLogin
                  ? const Dashboard()
                  : const Login()
              : const AppUpdateScreen(),
        ),
        debugShowCheckedModeBanner: false,
      ),
      debugShowFloatingThemeButton: false,
    );
  }
}
