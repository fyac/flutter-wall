/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/page/webview_page.dart';
import 'package:iap_app/routes/router_init.dart';
import 'package:iap_app/routes/setting_router.dart';
import './route_handlers.dart';

class Routes {
  static String index = "/";
  static String home = "/home";

  static String webViewPage = "/webview";

  static String hot = "/hot";
  static String create = "/home/create";
  static String filter = "/home/filter";

  static String inputTextPage = "/iptxtPage";

  static String cardToGallery = "/home/cardTogallery";
  static String detailToGallery = "/home/card/detailTogallery";

  static List<IRouterProvider> _listRouter = [];

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE HANDLER WAS NOT FOUND !!!");
    });

    router.define(webViewPage, handler: Handler(handlerFunc: (_, params) {
      String title = params['title']?.first;
      String url = params['url']?.first;
      return WebViewPage(title: title, url: url);
    }));

    router.define(index, handler: indexHander);
    router.define(home, handler: homeHandler);

    router.define(create, handler: createHandler);
    router.define(inputTextPage, handler: inputPageHander);

    router.define(cardToGallery, handler: galleryViewHandler);
    router.define(detailToGallery, handler: galleryViewHandler);

    // router.define(hot,
    //     handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    // router.define(create, handler: demoFunctionHandler);
    // router.define(filter, handler: deepLinkHandler);

    _listRouter.clear();

    /// 各自路由由各自模块管理，统一在此添加初始化

    _listRouter.add(SettingRouter());

    /// 初始化路由
    _listRouter.forEach((routerProvider) {
      routerProvider.initRouter(router);
    });
  }
}