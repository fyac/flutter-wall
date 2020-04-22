import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/util/http_util.dart';

class ReportAPI {
  static const String API_SEND_REPORT = Api.API_BASE_INF_URL + "/report/s";

  static Future<Result> sendReport(String type, String refId, String content) async {
    print("send report -> $API_SEND_REPORT");
    var json = {
      "content": "REPORT_$type [ 参照ID： \_$refId ]: $content",
      "sentTime": DateUtil.formatDate(DateTime.now(), format: "yyyy-MM-dd HH:mm:ss")
    };
    try {
      Response response = await httpUtil.dio.post(API_SEND_REPORT, data: json);
      print(response);
      return Result.fromJson(Api.convertResponse(response.data));
    } on DioError catch (e) {
      String error = Api.formatError(e);
      Result r = new Result();
      r.isSuccess = false;
      r.message = error;
      return r;
    }
  }
}
