import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix2;
import 'package:iap_app/api/api.dart';
import 'package:iap_app/api/invite.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/result_code.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/http_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/version_utils.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<LoginPage> {
  static const String _TAG = "_SMSLoginPageState";

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _vCodeController = TextEditingController();
  TextEditingController _iCodeController = TextEditingController();

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();

  bool _canGetCode = false;
  bool _codeWaiting = false;

  bool _showCodeInput = false;
  bool _showInvitationCodeInput = false;

  /// ???????????????
  final int second = 90;

  /// ????????????
  int s;
  StreamSubscription _subscription;

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    isDark = false;
    VersionUtils.checkUpdate().then((result) {
      if (result != null) {
        VersionUtils.displayUpdateDialog(result, slient: true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SpUtil.getInstance();
      // ??????SpUtil?????????????????????MaterialApp??????????????????????????????????????????????????????
      Provider.of<ThemeProvider>(context, listen: false).syncTheme();
    });
    _phoneController.addListener(_verifyPhone);
//    _vCodeController.addListener(_verifyCode);
  }

  void _verifyPhone() {
    if (!_codeWaiting) {
      String phone = _phoneController.text;
      bool isCodeClick = true;
      if (phone.isEmpty || phone.length < 11) {
        isCodeClick = false;
      }
      setState(() {
        this._canGetCode = isCodeClick;
      });
    }
  }

  void _verifyCode(String val) {
    String phone = _phoneController.text;
    String vCode = _vCodeController.text;
    if (phone.isEmpty || phone.length < 11 || vCode.isEmpty || vCode.length != 6) {
      return;
    }
    _login();
  }

  void _verifyInvitationCode(String val) async {
    String phone = _phoneController.text;
    String vCode = _vCodeController.text;
    String iCode = _iCodeController.text;
    if (phone.isEmpty ||
        phone.length < 11 ||
        iCode.isEmpty ||
        iCode.length != 6 ||
        vCode.isEmpty ||
        vCode.length != 6) {
      return;
    }
    await InviteAPI.checkCodeValid(iCode).then((res) {
      if (res != null && res.isSuccess) {
        RegTemp.regTemp.invitationCode = iCode;
        _login();
      } else {
        ToastUtil.showToast(context, '??????????????????');
      }
    });
  }

  void _login() async {
    Utils.showDefaultLoadingWithBounds(context, text: '????????????');
    Result r = await MemberApi.checkVerificationCode(_phoneController.text, _vCodeController.text);
    if (!r.isSuccess) {
      NavigatorUtils.goBack(context);
      ToastUtil.showToast(context, '??????????????????');
      return;
    }
    MemberApi.login(_phoneController.text).then((res) async {
      if (res.isSuccess) {
        // ?????????????????????????????????
        String token = res.data ?? res.message;
        // ??????token
        Application.setLocalAccountToken(token);
        httpUtil.updateAuthToken(token);
        httpUtil2.updateAuthToken(token);
        await SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);

        // _loadStorageTweetTypes();
        // ??????????????????
        Account acc = await MemberApi.getMyAccount(token);
        if (acc == null) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '????????????????????????????????????');
          return;
        }
        // ????????????????????????????????????????????????
        AccountLocalProvider accountLocalProvider = Provider.of<AccountLocalProvider>(context, listen: false);
        accountLocalProvider.setAccount(acc);
        LogUtil.e(accountLocalProvider.account.toJson(), tag: _TAG);
        Application.setAccount(acc);
        Application.setAccountId(acc.id);

        // ?????????????????????????????????
        University university = await UniversityApi.queryUnis(token);
        if (university == null) {
          // ???????????????????????????
          ToastUtil.showToast(context, '????????????');
          return;
        } else {
          // ????????????????????????????????????????????????
          SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, university.id);
          SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, university.name);
          Application.setOrgName(university.name);
          Application.setOrgId(university.id);
        }
        _subscription?.cancel();
        // ???????????????
        NavigatorUtils.push(context, Routes.splash, clearStack: true);
      } else {
        if (res.code == ResultCode.INVALID_PHONE) {
          NavigatorUtils.goBack(context);
          ToastUtil.showToast(context, '?????????????????????????????????');
          return;
        }
        if (res.code == ResultCode.UN_REGISTERED_PHONE) {
          // ???????????????
          NavigatorUtils.goBack(context);
          Result r = await InviteAPI.checkIsInInvitation();
          if (r.isSuccess && StringUtil.isEmpty(RegTemp.regTemp.invitationCode)) {
            // ????????????
            setState(() {
              this._showInvitationCodeInput = true;
            });
            return;
          }
          RegTemp.regTemp.phone = _phoneController.text;
          RegTemp.regTemp.invitationCode = _iCodeController.text;
          // ???????????????????????????
          NavigatorUtils.push(context, LoginRouter.loginInfoPage);
        } else {
          NavigatorUtils.goBack(context);
          if (StringUtil.isEmpty(res.message)) {
            ToastUtil.showServiceExpToast(context);
          } else {
            ToastUtil.showToast(context, res.message);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          padding: EdgeInsets.only(top: prefix2.ScreenUtil().setHeight(200)),
          child: defaultTargetPlatform == TargetPlatform.iOS
              ? KeyboardActions(
                  child: _buildBody(),
                  config: KeyboardActionsConfig(actions: []),
                )
              : SingleChildScrollView(
                  child: _buildBody(),
                )),
    );
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("?????????????????????Wall", style: TextStyles.textBold24),
          // Gaps.vGap5,
          // Text("?????????????????????????????????", style: TextStyles.textBold14),
          _renderSubBody(),
          Gaps.vGap30,
          Container(
            decoration: BoxDecoration(
                color: isDark ? ColorConstant.TWEET_RICH_BG_DARK : Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('+ 86', style: TextStyles.textSize16),
                ),
                Gaps.vLine,
                Expanded(
                  child: MyTextField(
                    focusNode: _nodeText1,
                    controller: _phoneController,
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                    hintText: "??????????????????",
                  ),
                )
              ],
            ),
          ),
          _showCodeInput
              ? Container(
                  color: !isDark ? Color(0xfff7f8f8) : Colours.dark_bg_color_darker,
                  margin: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: const EdgeInsets.only(right: 10),
                        child: Text('?????????', style: TextStyles.textSize16),
                      ),
                      Gaps.vLine,
                      Expanded(
                        child: MyTextField(
                          focusNode: _nodeText2,
                          controller: _vCodeController,
                          maxLength: 6,
                          keyboardType: TextInputType.phone,
                          hintText: "??????????????????",
                          onChange: _verifyCode,
                        ),
                      )
                    ],
                  ),
                )
              : Gaps.empty,

          _showInvitationCodeInput
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _renderHit('????????????????????????????????????', color: Colors.lightGreen),
                    Container(
                        color: !isDark ? Color(0xfff7f8f8) : Colours.dark_bg_color_darker,
                        margin: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              margin: const EdgeInsets.only(right: 10),
                              child: Text('?????????', style: TextStyles.textSize16),
                            ),
                            Gaps.vLine,
                            Expanded(
                              child: MyTextField(
                                focusNode: _nodeText3,
                                controller: _iCodeController,
                                maxLength: 6,
                                keyboardType: TextInputType.text,
                                hintText: "??????????????????",
                                onChange: _verifyInvitationCode,
                              ),
                            )
                          ],
                        ))
                  ],
                )
              : Gaps.empty,
          _renderHit('???????????????????????????????????????????????????'),
          Gaps.vGap8,
          _renderGetCodeLine(),
          Gaps.vGap30,
          // _renderOtherLine(),
        ],
      ),
    );
  }

  _renderSubBody() {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: RichText(
          softWrap: true,
          maxLines: 8,
          text: TextSpan(children: [
            TextSpan(text: "????????????????????? ", style: TextStyles.textGray14),
            TextSpan(
                text: "Wall????????????",
                style: TextStyles.textClickable,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => NavigatorUtils.goWebViewPage(context, "Wall????????????", Api.API_AGREEMENT)),
          ]),
        ));
  }

  _renderHit(String text, {Color color = Colours.text_gray, double size = Dimens.font_sp14}) {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        child: Text('$text',
            style: TextStyle(
              color: color,
              fontSize: size,
            )));
  }

  _renderGetCodeLine() {
    return Container(
        width: double.infinity,
//        color: _canGetCode ? Colors.amber : (!isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker),
        margin: const EdgeInsets.only(top: 15),
        child: FlatButton(
          child: Text(!_codeWaiting ? '?????????????????????' : '???????????? $s(s)', style: TextStyle(color: Colors.white)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: _canGetCode
              ? Colors.amber
              : !isDark
                  ? Color(0xffD7D6D9)
                  : ColorConstant.TWEET_RICH_BG_DARK,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          disabledColor: !isDark ? Color(0xffD7D6D9) : Colours.dark_bg_color_darker,
          onPressed: _codeWaiting
              ? null
              : () async {
                  String phone = _phoneController.text;
                  if (phone.isEmpty || phone.length < 11) {
                    ToastUtil.showToast(context, '????????????????????????');
                    return Future.value(false);
                  } else {
                    Utils.showDefaultLoadingWithBounds(context);
                    Result res = await MemberApi.sendPhoneVerificationCode(_phoneController.text);
                    NavigatorUtils.goBack(context);
                    if (res == null) {
                      ToastUtil.showToast(context, TextConstant.TEXT_SERVICE_ERROR);
                      return;
                    }
                    if (res.isSuccess) {
                      ToastUtil.showToast(context, '????????????');
                      _nodeText1.unfocus();
                      _nodeText2.requestFocus();
                      setState(() {
                        s = second;
                        this._showCodeInput = true;
                        this._canGetCode = false;
                        _codeWaiting = true;
                      });
                      _subscription = Stream.periodic(Duration(seconds: 1), (int i) {
                        setState(() {
                          s = second - i - 1;
                          if (s < 1) {
                            _canGetCode = true;
                            _codeWaiting = false;
                          }
                        });
                      }).take(second).listen((event) {});
                      // _subscription =
                      //     Observable.periodic(Duration(seconds: 1), (i) => i).take(second).listen((i) {
                      //       setState(() {
                      //         s = second - i - 1;
                      //         if (s < 1) {
                      //           _canGetCode = true;
                      //           _codeWaiting = false;
                      //         }
                      //       });
                      // });
                      return Future.value(true);
                    } else {
                      ToastUtil.showToast(context, res.message);
                      return Future.value(false);
                    }
                  }
                },
        ));
  }

  _renderOtherLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RichText(
          softWrap: true,
          maxLines: 1,
          text: TextSpan(children: [
            TextSpan(
                text: "??????????????????",
                style: TextStyles.textClickable,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    ToastUtil.showToast(context, '???????????????????????????');
                  }),
          ]),
        )
      ],
    );
  }
}
