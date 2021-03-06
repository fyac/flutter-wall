/*
* Oss工具类
* PostObject方式上传图片官方文档：https://help.aliyun.com/document_detail/31988.html
*/
import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:iap_app/api/api.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:uuid/uuid.dart';

class OssUtil {
  static OssUtil _instance;

  static Dio uploadDio;

  // 工厂模式
  factory OssUtil() => _getInstance();

  static OssUtil get instance => _getInstance();

  OssUtil._internal();

  static OssUtil _getInstance() {
    if (_instance == null) {
      _instance = new OssUtil._internal();
    }
    return _instance;
  }

  static Dio _getUploadDio() {
    if (uploadDio == null) {
      BaseOptions options = new BaseOptions();
      options.responseType = ResponseType.plain;
      options.contentType = "multipart/form-data";
      uploadDio = new Dio(options);
    }
    return uploadDio;
  }

  static const String DEST_TWEET = "tweet";
  static const String DEST_CIRCLE = "circle";
  static const String DEST_TOPIC = "topic";
  static const String DEST_AVATAR = "avatar";
  static const String DEST_CIRCLE_COVER = "circle-cover";

  static Future<Result> requestPostUrls(int count) async {
    String requestUrl =
        "${Api.API_BASE_INF_URL}/?${SharedConstant.ACCOUNT_ID_IDENTIFIER}=" + Application.getAccountId;
    Response response = await httpUtil.dio.post(requestUrl);
    Map<String, dynamic> json = Api.convertResponse(response.data);
    return Result.fromJson(json);
  }

  static Future<String> uploadImage(String fileName, List<int> fileBytes, String destDir,
      {String fixName}) async {
    String newFileName;
    if (StringUtil.isEmpty(fixName)) {
      String prefix =
          !StringUtil.isEmpty(Application.getAccountId) ? Application.getAccountId : Uuid().v1().toString();
      newFileName =
          prefix + "-" + Uuid().v1().substring(0, 8) + fileName.substring(fileName.lastIndexOf("."));
    } else {
      newFileName = fixName;
    }

    String nameKey;

    if (destDir == DEST_AVATAR) {
      nameKey = "almond-donuts/image/avatar/" + newFileName;
    } else {
      String date = DateUtil.formatDate(DateTime.now(), format: "yyyy-MM-dd");
      if (destDir == DEST_CIRCLE_COVER) {
        nameKey = "almond-donuts/image/circle-cover/" + newFileName;
      } else {
        nameKey = "almond-donuts/image/$destDir/$date/" + newFileName;
      }
    }
    String policyText =
        '{"expiration": "2050-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';
    List<int> policyTextUtf8 = utf8.encode(policyText);
    String policyBase64 = base64.encode(policyTextUtf8);
    List<int> policy = utf8.encode(policyBase64);

    // 利用OSSAccessKeySecret签名Policy
    List<int> key = utf8.encode(OssConstant.ACCESS_KEY_SECRET);
    List<int> signaturePre = new Hmac(sha1, key).convert(policy).bytes;
    String signature = base64.encode(signaturePre);

    Dio dio = _getUploadDio();

    FormData data = new FormData.fromMap({
      'key': nameKey,
      'policy': policyBase64,
      'OSSAccessKeyId': OssConstant.ACCESS_KEY_ID,
      'success_action_status': '200',
      'signature': signature,
      'Access-Control-Allow-Origin': '*',
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName)
//      'file': new UploadFileInfo.fromBytes(fileBytes, fileName),
    });
    try {
//      print(object.lengthSync() / 1024 / 1024);
      Response response = await dio.post(OssConstant.POST_URL, data: data);
      print(response.headers);
      print(response.data);
      return OssConstant.POST_URL + "/" + nameKey;
    } on DioError catch (e) {
      print(e.message);
    }
    return "-1";
  }
}
