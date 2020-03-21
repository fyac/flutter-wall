import 'dart:io';
import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/message.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/app_bar.dart';
import 'package:iap_app/common-widget/click_item.dart';
import 'package:iap_app/common-widget/exit_dialog.dart';
import 'package:iap_app/common-widget/simple_confirm.dart';
import 'package:iap_app/common-widget/text_clickable_iitem.dart';
import 'package:iap_app/component/bottom_sheet_choic_item.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/account_edit_param.dart';
import 'package:iap_app/model/gender.dart';
import 'package:iap_app/model/message/asbtract_message.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/page/common/image_crop.dart';
import 'package:iap_app/part/notification/my_sn_card.dart';
import 'package:iap_app/part/notification/system_card.dart';
import 'package:iap_app/provider/account_local.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/routes/routes.dart';
import 'package:iap_app/routes/setting_router.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/image_utils.dart';
import 'package:iap_app/util/oss_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SystemNotificationMainPage extends StatefulWidget {
  @override
  _SystemNotificationMainPageState createState() => _SystemNotificationMainPageState();
}

class _SystemNotificationMainPageState extends State<SystemNotificationMainPage> {
  bool isDark = false;

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  int currentPage = 1;
  int pageSize = 25;

  List<Widget> sysMsgList;

  @override
  void initState() {
    super.initState();
  }

  void _fetchSystemMessages() async {
    print('--------------------------请求系统消息---------------');
    currentPage = 1;
    List<AbstractMessage> msgs = await getData(1, pageSize);
    if (msgs == null || msgs.length == 0) {
      _refreshController.refreshCompleted(resetFooterState: true);
      setState(() {
        this.sysMsgList = [];
      });
      return;
    }

    List<Widget> cards = msgs.map((absMsg) {
      print(absMsg.toJson());
      return SystemCardItem(absMsg);
    }).toList();
    setState(() {
      if (this.sysMsgList != null) {
        this.sysMsgList.clear();
      } else {
        this.sysMsgList = List();
      }
      this.sysMsgList.addAll(cards);
    });
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  void _loadMore() async {
    List<AbstractMessage> msgs = await getData(++currentPage, pageSize);
    if (msgs == null || msgs.length == 0) {
      _refreshController.loadNoData();
      return;
    }
    List<Widget> cards = msgs.map((absMsg) {
      print(absMsg.toJson());
      return SystemCardItem(absMsg);
    }).toList();
    setState(() {
      if (this.sysMsgList == null) {
        this.sysMsgList = List();
      }
      this.sysMsgList.addAll(cards);
    });
    _refreshController.loadComplete();
  }

  Future<List<AbstractMessage>> getData(int currentPage, int pageSize) async {
    return await MessageAPI.querySystemMsg(currentPage, pageSize);
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
//        backgroundColor: isDark ? Colours.dark_bg_color : Colours.bg_color,
        appBar: MyAppBar(
          centerTitle: "系统消息",
          isBack: true,
        ),
        body: SafeArea(
            top: false,
            child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: Colors.pinkAccent,
                  complete: const Text('刷新完成'),
                ),
                footer: ClassicFooter(
                  loadingText: '正在加载更多消息...',
                  canLoadingText: '释放以加载更多',
                  noDataText: '没有更多消息了',
                  idleText: '继续上滑',
                ),
                onLoading: _loadMore,
                onRefresh: _fetchSystemMessages,
                child: SingleChildScrollView(
                    child: sysMsgList != null && sysMsgList.length > 0
                        ? Column(children: sysMsgList)
                        : sysMsgList == null
                            ? Gaps.empty
                            : Container(
                                alignment: Alignment.topCenter,
                                margin: const EdgeInsets.only(top: 50),
                                child: Text('暂无消息'),
                              )))));
  }
}

class SystemCard extends StatelessWidget {
  final String title;
  final String cover;
  final String content;
  final String jumpUrl;
  final Function onClick;
  final DateTime date;

  final bool isDark;

  SystemCard(
      {this.title, this.cover, this.content, this.jumpUrl, this.onClick, this.isDark = false, this.date});

  @override
  Widget build(BuildContext context) {
    return MyShadowCard(
        onClick: onClick,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _dateTimeContainer(context),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    title ?? "系统通知",
                    style: MyDefaultTextStyle.getMainTextBodyStyle(isDark),
                  )),
                  onClick != null
                      ? Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          height: 8.0,
                          width: 8.0,
                          decoration: BoxDecoration(
                            color: Colours.app_main,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        )
                      : Gaps.empty,
                  onClick != null ? Images.arrowRight : Gaps.empty
                ],
              ),
              Gaps.vGap8,
              Gaps.line,
              cover != null
                  ? Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 180,
                      ),
                      child: ClipRRect(
                        child: FadeInImage(
                          placeholder: ImageUtils.getImageProvider('https://via.placeholder.com/180'),
                          image: NetworkImage(cover),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(const Radius.circular(10)),
                      ),
                    )
                  : Gaps.empty,
              Gaps.vGap8,
              Text(content ?? '', style: MyDefaultTextStyle.getSubTextBodyStyle(isDark)),
            ],
          ),
        ));
  }

  _dateTimeContainer(context) {
    return date != null
        ? Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(TimeUtil.getShortTime(date), style: MyDefaultTextStyle.getTweetTimeStyle(context)),
          )
        : Gaps.empty;
  }
}
