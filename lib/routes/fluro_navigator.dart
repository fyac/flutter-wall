import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/account/simple_account.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';

import '../application.dart';

/// fluro的路由跳转工具类
class NavigatorUtils {
  static push(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transitionType = TransitionType.native}) {
    FocusScope.of(context).unfocus();
    Application.router.navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      transition: transitionType,
    );
  }

  static pushResult(BuildContext context, String path, Function(Object) function,
      {bool replace = false, bool clearStack = false}) {
    FocusScope.of(context).unfocus();
    Application.router
        .navigateTo(context, path,
            replace: replace, clearStack: clearStack, transition: TransitionType.native)
        .then((result) {
      // 页面返回result为null
      if (result == null) {
        return;
      }
      function(result);
    }).catchError((error) {
      print("$error");
    });
  }

  /// 返回
  static void goBack(BuildContext context) {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  /// 带参数返回
  static void goBackWithParams(BuildContext context, result) {
    FocusScope.of(context).unfocus();
    Navigator.pop(context, result);
  }

  // 跳到WebView页
  static goWebViewPage(BuildContext context, String title, String url) {
    //fluro 不支持传中文,需转换
    push(
        context, '${Routes.webViewPage}?title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}');
  }

  static void goAccountProfile(BuildContext context, SimpleAccount account) {
    if (account == null) {
      return;
    }
    push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs(
                {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }

  static void goAccountProfile2(BuildContext context, Account account) {
    if (account == null) {
      return;
    }
    push(
        context,
        Routes.accountProfile +
            Utils.packConvertArgs(
                {'nick': account.nick, 'accId': account.id, 'avatarUrl': account.avatarUrl}));
  }

  static void goReportPage(BuildContext context, String type, String refId, String title) {
    if (type == null || refId == null) {
      return;
    }
    push(context,
        Routes.reportPage + "?refId=" + Uri.encodeComponent(refId) + "&type=" + type + "&title=" + Uri.encodeComponent(title));
  }
}
