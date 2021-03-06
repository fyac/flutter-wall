import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iap_app/api/member.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/api/unlike.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/component/tweet/tweet_card.dart';
import 'package:iap_app/component/tweet_delete_bottom_sheet.dart';
import 'package:iap_app/component/widget_sliver_future_builder.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/account/account_display_info.dart';
import 'package:iap_app/model/page_param.dart';
import 'package:iap_app/model/result.dart';
import 'package:iap_app/model/tweet.dart';
import 'package:iap_app/page/common/report_page.dart';
import 'package:iap_app/provider/tweet_provider.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/common_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';
import 'package:provider/provider.dart';

class AccountProfilePage extends StatefulWidget {
  final String nick;
  final String avatarUrl;
  final String accountId;

  AccountProfilePage(this.accountId, this.nick, this.avatarUrl);

  @override
  State<StatefulWidget> createState() {
    return _AccountProfilePageState();
  }
}

class _AccountProfilePageState extends State<AccountProfilePage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  var _pageList;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);

    _pageList = <StatefulWidget>[
      AccountProfileInfoPageView(
        accountId: widget.accountId,
        loadFinishCallback: () {},
      ),
      AccountProfileTweetPageView(
        accountId: widget.accountId,
      )
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => _sliverBuilder(context, innerBoxIsScrolled),
      body: AccountProfileTweetPageView(),
    );
    return Stack(
      children: <Widget>[
        DefaultTabController(
            length: 2,
            child: Scaffold(
                body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  _sliverBuilder(context, innerBoxIsScrolled),
              body: TabBar(

                  // onPageChanged: _onPageChanged,
                  controller: _tabController,
                  tabs: _pageList),
            ))),
      ],
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: false,
        // ????????????
        elevation: 0.3,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            onPressed: () {
              List<BottomSheetItem> items = List();
              items.add(BottomSheetItem(
                  Icon(
                    Icons.warning,
                    color: Colors.grey,
                  ),
                  '??????', () {
                Navigator.pop(context);
                NavigatorUtils.goReportPage(context, ReportPage.REPORT_ACCOUNT, widget.accountId, "????????????");
              }));
              if (Application.getAccountId != null && Application.getAccountId != widget.accountId) {
                items.add(
                    BottomSheetItem(Icon(Icons.do_not_disturb_on, color: Colors.orangeAccent), '????????????', () {
                  Navigator.pop(context);
                  _showShieldedAccountBottomSheet();
                }));
              }
              BottomSheetUtil.showBottomSheetView(context, items);
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.maybePop(context);
          },
          icon: Image.asset(PathConstant.ICON_GO_BACK_ARROW, color: Colors.white, width: 20),
        ),
        expandedHeight: 200,
        floating: false,
        pinned: true,
        snap: false,
        // bottom: new TabBar(
        //     labelColor: Colors.white,
        //     unselectedLabelColor: Colors.white70,
        //     isScrollable: false,
        //     indicatorSize: TabBarIndicatorSize.label,
        //
        //     // indicatorColor: Colors.black87,
        //     controller: _tabController,
        //     labelPadding: const EdgeInsets.all(0.0),
        //     tabs: [
        //       const Tab(child: Text('????????????', style: TextStyle(color: null))),
        //       const Tab(child: Text('????????????', style: TextStyle(color: null)))
        //     ]),

        flexibleSpace: Container(
          child: Text("123"),
        ),
        // flexibleSpace: FlexibleDetailBar(
        //     content: Padding(
        //       padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
        //       child: Center(
        //           child: Hero(
        //               tag: 'avatar',
        //               child: AccountAvatar(
        //                   avatarUrl: widget.avatarUrl + OssConstant.THUMBNAIL_SUFFIX,
        //                   whitePadding: true,
        //                   size: SizeConstant.TWEET_PROFILE_SIZE * 1.6,
        //                   cache: true,
        //                   onTap: () {
        //                     Navigator.push(context, PageRouteBuilder(pageBuilder:
        //                         (BuildContext context, Animation animation, Animation secondaryAnimation) {
        //                       return new FadeTransition(
        //                           opacity: animation, child: AvatarOriginPage(widget.avatarUrl));
        //                     }));
        //                   }))),
        //     ),
        //     background: Container(
        //         decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(25))),
        //         child: Stack(children: <Widget>[
        //           Utils.showNetImage(
        //             widget.avatarUrl,
        //             width: double.infinity,
        //             height: double.infinity,
        //             fit: BoxFit.cover,
        //           ),
        //           BackdropFilter(
        //             filter: ImageFilter.blur(
        //               sigmaY: 5,
        //               sigmaX: 5,
        //             ),
        //             child: Container(
        //               color: Colors.black38,
        //               width: double.infinity,
        //               height: double.infinity,
        //             ),
        //           ),
        //         ])))
      )
    ];
  }

  _showShieldedAccountBottomSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleConfirmBottomSheet(
            tip: "????????????????????????????????????????????????????????????????????????",
            onTapDelete: () async {
              Utils.showDefaultLoading(Application.context);
              Result r = await UnlikeAPI.unlikeAccount(widget.accountId.toString());
              NavigatorUtils.goBack(Application.context);
              if (r == null) {
                ToastUtil.showToast(Application.context, TextConstant.TEXT_SERVICE_ERROR);
              } else {
                if (r.isSuccess) {
                  final _tweetProvider = Provider.of<TweetProvider>(Application.context);
                  _tweetProvider.deleteByAccount(widget.accountId);
                  ToastUtil.showToast(Application.context, '??????????????????????????????????????????????????????');
                  NavigatorUtils.goBack(Application.context);
                } else {
                  ToastUtil.showToast(Application.context, "??????????????????");
                }
              }
            });
      },
    );
  }
}

class AccountProfileInfoPageView extends StatefulWidget {
  final String accountId;
  final loadFinishCallback;

  AccountProfileInfoPageView({this.accountId, this.loadFinishCallback});

  @override
  _AccountProfileInfoPageView createState() => _AccountProfileInfoPageView();
}

class _AccountProfileInfoPageView extends State<AccountProfileInfoPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<AccountProfileInfoPageView> {
  String _nullText = "???????????????";
  double _iconSize = 25;
  Function _getProfileTask;
  bool isDark;

  Future<AccountDisplayInfo> getProfileInfo(BuildContext context) async {
    AccountDisplayInfo account = await MemberApi.getAccountDisplayProfile(widget.accountId);
    return account;
  }

  @override
  void initState() {
    super.initState();
    _getProfileTask = getProfileInfo;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    isDark = ThemeUtils.isDark(context);
    return CustomSliverFutureBuilder(
      futureFunc: (context) => _getProfileTask(context),
      builder: (context, data) => _buildBody(data),
    );
  }

  Widget _buildBody(AccountDisplayInfo account) {
    if (account == null) {
      return Center(child: Text('????????????????????????'));
    }
    return Scaffold(
      // backgroundColor: Color(0xff191970),
      // ????????????????????? appbar??????????????????????????????????????????
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // _buildAvatarItem(account.avatarUrl),
            _titleItem('????????????'),
            _buildNick(account),
            _buildSig(account.signature),

            Gaps.vGap30,
            _titleItem('????????????'),
            _buildPersonInfo('line_in_circle', Colors.brown, account.name, account.displayName,
                fallbackText: "???????????????"),
            _buildPersonInfo(
                'voice', Colors.lightBlue, account.age > 0 ? "${account.age}???" : null, account.displayAge,
                fallbackText: "???????????????"),
            _buildPersonInfo('search', Colors.green, _getRegionText(account), account.displayRegion,
                fallbackText: "???????????????"),
            _buildPersonInfo(
                'count',
                Colors.green,
                _getCampusInfoText(account),
                account.displayInstitute ||
                    account.displayCla ||
                    account.displayMajor ||
                    account.displayGrade,
                fallbackText: "?????????????????????"),

            Gaps.vGap30,
            _titleItem('????????????'),
            _buildContactItem('phone', Colors.brown, account.mobile, account.displayPhone),
            _buildContactItem('qq25', Colors.lightBlue, account.qq, account.displayQQ),
            _buildContactItem('wechat', Colors.green, account.wechat, account.displayWeChat),

            // _buildItem('??????', account.profile.name),
          ],
        ),
      )),
    );
  }

  Widget _buildNick(AccountDisplayInfo account) {
    String male;
    if (account.displaySex) {
      if (account.gender != null) {
        male = account.gender.toUpperCase();
      }
    }
    return Container(
      margin: EdgeInsets.only(top: 15),
      alignment: Alignment.centerLeft,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(
            'people_nick',
            width: _iconSize - 5,
            height: _iconSize - 5,
            color: Colors.lightBlue,
          )),
          Gaps.hGap10,
          Flexible(
            flex: 8,
            child: Text(account.nick ?? TextConstant.TEXT_UN_CATCH_ERROR,
                softWrap: true,
                style: MyDefaultTextStyle.getTweetNickStyle(Dimens.font_sp14, context: context, bold: false)),
          ),
          Gaps.hGap10,
          (male == null || male == "UNKNOWN")
              ? Gaps.empty
              : (male == "MALE"
                  ? Flexible(
                      flex: 1,
                      child: LoadAssetSvg('male', width: _iconSize, height: _iconSize, color: Colors.blue))
                  : Flexible(
                      flex: 1,
                      child: LoadAssetSvg('female',
                          width: _iconSize, height: _iconSize, color: Colors.pinkAccent)))
        ],
      ),
    );
  }

  Widget _buildSig(String sig) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(
            'wenjian',
            width: _iconSize,
            height: _iconSize,
            color: Colors.lightBlue,
          )),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(sig ?? '???????????????',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.grey, fontSize: Dimens.font_sp14, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  _titleItem(String title) {
    return Container(child: Text(title, style: TextStyle(color: Colors.grey)));
  }

  _buildPersonInfo(String svgName, Color color, String value, bool display, {String fallbackText = "?????????"}) {
    bool hasVal = value != null && value.trim().length > 0;

    return Container(
      // margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(svgName, width: _iconSize, height: _iconSize, color: color)),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(display ? (hasVal ? value : '???????????????') : fallbackText,
                softWrap: true,
                style: TextStyle(
                    color: !hasVal || !display ? Colors.grey : null,
                    fontSize: hasVal && display ? Dimens.font_sp15 : Dimens.font_sp14,
                    fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  String _getRegionText(AccountDisplayInfo profile) {
    if (StringUtil.isEmpty(profile.province)) {
      return null;
    } else {
      if (StringUtil.isEmpty(profile.city)) {
        return profile.province;
      } else {
        if (StringUtil.isEmpty(profile.district)) {
          return profile.province + "???" + profile.city;
        } else {
          return profile.province + "???" + profile.city + "???" + profile.district;
        }
      }
    }
  }

  String _getCampusInfoText(AccountDisplayInfo profile) {
    StringBuffer sb = StringBuffer();
    bool writeBefore = false;
    if (profile.displayInstitute) {
      if (!StringUtil.isEmpty(profile.instituteName)) {
        sb.write(_writeSomething(writeBefore, profile.instituteName));
        writeBefore = true;
      }
    }
    if (profile.displayMajor) {
      if (!StringUtil.isEmpty(profile.major)) {
        sb.write(_writeSomething(writeBefore, profile.major));

        writeBefore = true;
      }
    }
    if (profile.displayCla) {
      if (!StringUtil.isEmpty(profile.cla)) {
        sb.write(_writeSomething(writeBefore, profile.cla));

        writeBefore = true;
      }
    }
    if (profile.displayGrade) {
      if (!StringUtil.isEmpty(profile.grade)) {
        sb.write(_writeSomething(writeBefore, profile.grade));
      }
    }
    return sb.toString();
  }

  _writeSomething(bool writeBefore, String value) {
    return writeBefore ? "???$value" : "$value";
  }

  _buildContactItem(String svgName, Color color, String value, bool display) {
    bool isNull = StringUtil.isEmpty(value);
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // direction: Axis.horizontal,
        children: <Widget>[
          _wrapIcon(LoadAssetSvg(
            '$svgName',
            width: _iconSize,
            height: _iconSize,
            color: color,
          )),
          Gaps.hGap10,
          Flexible(
            flex: 1,
            child: Text(!display ? '???????????????' : (value ?? _nullText),
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isNull ? Colors.grey : null,
                    fontSize: isNull ? Dimens.font_sp14 : Dimens.font_sp15,
                    fontWeight: FontWeight.w400)),
          ),
          _getCopyWidget(value)
        ],
      ),
    );
  }

  _wrapIcon(Widget icon) {
    return Container(
      width: 20,
      child: icon,
    );
  }

  _getCopyWidget(String value) {
    if (StringUtil.isEmpty(value)) {
      return Container(height: 0);
    } else {
      return GestureDetector(
        child: Padding(padding: EdgeInsets.only(left: 5), child: Images.copy),
        onTap: () {
          Utils.copyTextToClipBoard(value);
          ToastUtil.showToast(context, '????????????');
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class AccountProfileTweetPageView extends StatefulWidget {
  final String accountId;

  AccountProfileTweetPageView({Key key, this.accountId});

  @override
  _AccountProfileTweetPageView createState() => _AccountProfileTweetPageView();
}

class _AccountProfileTweetPageView extends State<AccountProfileTweetPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<AccountProfileTweetPageView> {
  Function _onLoad;

  int _currentPage = 1;

  bool display = false;
  bool initialing = true;
  List<BaseTweet> _accountTweets;

  EasyRefreshController _easyRefreshController;

  Future<List<BaseTweet>> _getTweets() async {
    List<BaseTweet> tweets =
        await TweetApi.queryOtherTweets(PageParam(_currentPage, pageSize: 5), widget.accountId);

    return tweets;
  }

  Future<void> _initRefresh() async {
    setState(() {
      _currentPage = 1;
    });
    List<BaseTweet> tweets = await _getTweets();
    if (!CollectionUtil.isListEmpty(tweets)) {
      _currentPage++;
      setState(() {
        if (_accountTweets == null) {
          _accountTweets = List();
        }
        this._accountTweets.addAll(tweets);
        this.initialing = false;
      });
      _easyRefreshController.finishRefresh(success: true, noMore: false);
    } else {
      setState(() {
        this._accountTweets = List();
        this.initialing = false;
      });
      _easyRefreshController.finishRefresh(success: true, noMore: true);
    }
  }

  void _loadMoreData() async {
    List<BaseTweet> tweets = await _getTweets();
    if (!CollectionUtil.isListEmpty(tweets)) {
      _currentPage++;
      setState(() {
        this._accountTweets.addAll(tweets);
      });
      _easyRefreshController.finishLoad(success: true, noMore: false);
    } else {
      _easyRefreshController.finishLoad(success: true, noMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _initRefresh();
    _easyRefreshController = EasyRefreshController();
    _onLoad = _loadMoreData;
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    _accountTweets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (initialing || _accountTweets == null) {
      return WidgetUtil.getLoadingAnimation();
    }

    if (_accountTweets.length == 0) {
      return Container(
          margin: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          constraints: BoxConstraints(maxHeight: 100),
          color: Colors.white,
          child: Text(
            '???????????????????????????????????????',
            style: const TextStyle(fontSize: Dimens.font_sp14),
          ));
    }

    return EasyRefresh(
        controller: _easyRefreshController,
        enableControlFinishLoad: true,
        footer: ClassicalFooter(
            textColor: Colors.grey,
            extent: 40.0,
            noMoreText: '??????????????????',
            loadedText: '????????????',
            loadFailedText: '????????????',
            loadingText: '????????????',
            loadText: '????????????',
            loadReadyText: '????????????',
            showInfo: false,
            enableHapticFeedback: true,
            enableInfiniteLoad: true),
        onLoad: () => _onLoad(),
        child: _accountTweets == null
            ? SpinKitThreeBounce(color: Colors.lightBlueAccent)
            : _accountTweets.length == 0
                ? Container(
                    margin: EdgeInsets.only(top: 50),
                    alignment: Alignment.topCenter,
                    constraints: BoxConstraints(maxHeight: 100),
                    child: Text('??????????????????????????????', style: pfStyle.copyWith(color: Colors.grey)))
                : ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: _accountTweets.length,
                    itemBuilder: (context, index) {
                      return TweetCard2(_accountTweets[index],
                          displayLink: false, upClickable: false, downClickable: false, displayPraise: true);
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}
