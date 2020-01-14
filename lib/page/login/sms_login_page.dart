import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as prefix2;
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/univer.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/my_button.dart';
import 'package:iap_app/component/text_field.dart';
import 'package:iap_app/config/auth_constant.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/university.dart';
import 'package:iap_app/page/login/reg_temp.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/provider/theme_provider.dart';
import 'package:iap_app/provider/tweet_typs_filter.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/login_router.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<LoginPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _vCodeController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  bool _isClick = false;

  bool _canGetCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SpUtil.getInstance();
      // 由于SpUtil未初始化，所以MaterialApp获取的为默认主题配置，这里同步一下。
      Provider.of<ThemeProvider>(context).syncTheme();
    });
    _phoneController.addListener(_verify);
    _vCodeController.addListener(_verifyCode);
    _vCodeController.addListener(_verify);
  }

  void _verify() {
    String name = _phoneController.text;
    String vCode = _vCodeController.text;
    bool isClick = true;
    if (name.isEmpty || name.length < 11) {
      isClick = false;
    }
    if (vCode.isEmpty || vCode.length < 6) {
      isClick = false;
    }
    if (isClick != _isClick) {
      setState(() {
        _isClick = isClick;
      });
    }
  }

  void _verifyCode() {
    String phone = _phoneController.text;
    bool t = false;
    if (phone.isEmpty || phone.length < 11) {
      t = false;
    } else {
      t = true;
    }
    if (_canGetCode != t) {
      setState(() {
        _canGetCode = t;
      });
    }
  }

  void _login() {
    Utils.showDefaultLoadingWithBounds(context, text: '正在验证');
    MemberApi.login(_phoneController.text).then((res) async {
      if (res.isSuccess && res.code == "1") {
        // 已经存在账户，直接登录
        String token = res.message;
        // 设置token
        SpUtil.putString(SharedConstant.LOCAL_ACCOUNT_TOKEN, token);
        _loadStorageTweetTypes();
        // 查询账户信息
        Account acc = await MemberApi.getMyAccount(token);
        AccountLocalProvider accountLocalProvider = Provider.of<AccountLocalProvider>(context);
        accountLocalProvider.setAccount(acc);
        print(accountLocalProvider.account.toJson());
        Application.setAccount(acc);
        Application.setAccountId(acc.id);

        University university = await UniversityApi.queryUnis(token);
        if (university == null) {
          // 错误，有账户无组织
          print("ERROR , ------------");
          ToastUtil.showToast(context, '数据错误');
        } else {
          SpUtil.putInt(SharedConstant.LOCAL_ORG_ID, university.id);
          SpUtil.putString(SharedConstant.LOCAL_ORG_NAME, university.name);
          Application.setOrgName(university.name);
          Application.setOrgId(university.id);
        }

        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, Routes.index, clearStack: true);
      } else {
        RegTemp.regTemp.phone = _phoneController.text;
        NavigatorUtils.goBack(context);
        NavigatorUtils.push(context, LoginRouter.loginInfoPage);
      }
    });
  }

  Future<void> _loadStorageTweetTypes() async {
    TweetTypesFilterProvider tweetTypesFilterProvider = Provider.of<TweetTypesFilterProvider>(context);
    tweetTypesFilterProvider.updateTypeNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
        body: Container(
      padding: EdgeInsets.only(top: prefix2.ScreenUtil().setHeight(180)),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: const NetworkImage('https://tva1.sinaimg.cn/large/006tNbRwgy1ga9zk4ju6oj30pz0k00vy.jpg'))),
      child: Center(
          heightFactor: 0.1,
          child: defaultTargetPlatform == TargetPlatform.iOS
              ? FormKeyboardActions(
                  child: _buildBody(),
                )
              : SingleChildScrollView(
                  child: _buildBody(),
                )),
    ));
  }

  _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("注册丨登录 到 Wall", style: TextStyles.textBold26.copyWith(color: Colors.white70)),
          Gaps.vGap16,
          MyTextField(
            focusNode: _nodeText1,
            config: Utils.getKeyboardActionsConfig(context, [_nodeText1, _nodeText2]),
            controller: _phoneController,
            maxLength: 11,
            keyboardType: TextInputType.phone,
            hintText: "请输入手机号",
          ),
          Gaps.vGap8,
          MyTextField(
            focusNode: _nodeText2,
            controller: _vCodeController,
            maxLength: 6,
            keyboardType: TextInputType.number,
            hintText: "请输入验证码",
            getVCode: () async {
              String phone = _phoneController.text;
              if (phone.isEmpty || phone.length < 11) {
                ToastUtil.showToast(context, '手机号格式不正确');
                return Future.value(false);
              } else {
                Utils.showDefaultLoadingWithBounds(context);
                Result res = await MemberApi.sendPhoneVerificationCode(_phoneController.text);
                NavigatorUtils.goBack(context);
                if (res.isSuccess) {
                  ToastUtil.showToast(context, '发送成功');
                  return Future.value(true);
                } else {
                  ToastUtil.showToast(context, res.message);
                  return Future.value(false);
                }
              }
            },
          ),
          Gaps.vGap50,
          MyButton(
            onPressed: _isClick ? _login : null,
            text: "登录",
          ),
        ],
      ),
    );
  }
}
