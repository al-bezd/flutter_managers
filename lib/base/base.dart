import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BaseClass extends Object {}

class MainManager extends BaseClass {
  StreamController streamController = StreamController.broadcast();
  StreamController get sc => streamController;
  Map<String, BaseManager> managers = {};

  Route<dynamic>? route(RouteSettings routeSettings) {
    for (String key in managers.keys) {
      BaseManager manager = managers[key]!;
      Route<dynamic>? page = manager.route(routeSettings);
      if (page != null) {
        return page;
      }
    }
    return null;
  }

  void runTests() {
    for (String key in managers.keys) {
      BaseManager manager = managers[key]!;
      manager.runTest();
    }
  }

  void addManager(String name, BaseManager manager) {
    managers.addAll({name: manager});
    managers[name]!.initManager();
  }

  Future<bool> initialization() async {
    return true;
  }

  void initManager() {}

  void update() {
    sc.add(this);
  }
}

class BaseManager extends BaseClass with BaseUrls {
  BaseManager({this.routes, this.tests});
  StreamController streamController = StreamController.broadcast();
  StreamController get sc => streamController;
  BaseRoutes? routes;
  BaseTests? tests;

  Route<dynamic>? route(RouteSettings routeSettings) {
    if (routes != null) {
      return routes!.route(routeSettings);
    }
    return null;
  }

  void runTest() {
    if (tests != null) {
      tests!.runTest();
    } else {
      log('no tests');
    }
  }

  void initManager() {}

  void update() {
    sc.add(this);
  }
}

class BaseModel extends BaseClass {}

mixin BaseUrls implements BaseClass {
  Future<Response?> getHttp(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await Dio().get(path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);
      return response;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<Response?> postHttp(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    dynamic data,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      var response = await Dio().post(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}

class BaseRoutes extends BaseClass {
  // Route<dynamic>? route(RouteSettings routeSettings) {
  //   List<String> path = getPathToListString(routeSettings);
  //   if (path[1] == 'settings') {
  //     return go(const SettingsPage());
  //   }
  //   return null;
  // }
  Route<dynamic>? route(RouteSettings routeSettings) {
    return null;
  }

  Route<dynamic>? go(Widget page) =>
      MaterialPageRoute(builder: (BuildContext context) => page);

  List<String> getPathToListString(RouteSettings rs) => rs.name!.split('/');
}

class BaseTests extends BaseClass {
  List<Test> tests = [];

  void runTest() async {
    for (Test test in tests) {
      await test.run();
    }
  }
}

class Test {
  Future<String> run() async {
    log('ok');
    return 'ok';
  }
}
