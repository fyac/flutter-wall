import 'dart:core' as prefix1;
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';

class UnlikeAPI {
  static const String UNLIKE_ACCOUNT_API = Api.API_BASE_INF_URL + "/unlikeAcc";
  static const String UNLIKE_ACCOUNT_ADD = UNLIKE_ACCOUNT_API + "/add.do";

  static Future<Result> unlikeAccount(String targetAccountId) async {
    if (StringUtil.isEmpty(targetAccountId)) {
      return Result(isSuccess: false);
    }

    Response response;
    try {
      response = await httpUtil.dio.post(UNLIKE_ACCOUNT_ADD, data: targetAccountId);
      Map<String, dynamic> json = Api.convertResponse(response.data);
      return Result.fromJson(json);
    } on DioError catch (e) {
      Api.formatError(e);
    }
    return null;
  }
}
