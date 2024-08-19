/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/view/auth/login.dart';
import '/view/dashboard/dashboard.dart';

import '../../view/custom_ui_element/app_update_view.dart';

class EnquiryRoutes with ChangeNotifier {
  bool _reload = false;
  get reload => _reload;

  topChanged(bool tapped) {
    _reload = tapped;
    notifyListeners();
  }
}

class RouterService {
  GoRouter getRouterConfig(bool appUpdate, bool isLogin) {
    return GoRouter(
      initialLocation: appUpdate
          ? isLogin
              ? '/dashboard'
              : '/login'
          : '/app-update',
      routes: <RouteBase>[
        GoRoute(
          path: '/app-update',
          builder: (BuildContext context, GoRouterState state) {
            return const AppUpdateScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const Login();
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const Dashboard();
          },
        ),
      ],
    );
  }
}
