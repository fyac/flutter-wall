import 'dart:async';
import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iap_app/api/tweet.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/empty_view.dart';
import 'package:iap_app/component/hot_app_bar.dart';
import 'package:iap_app/component/tweet/tweet_hot_card.dart';
import 'package:iap_app/global/oss_canstant.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/model/hot_tweet.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/page/tweet_detail.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/collection.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/umeng_util.dart';

class HotToday extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HotTodayState();
  }
}

class _HotTodayState extends State<HotToday> with AutomaticKeepAliveClientMixin {
  double _expandedHeight = ScreenUtil().setWidth(600);

  UniHotTweet hotTweet;

  // 连接通知器
  LinkHeaderNotifier _headerNotifier;

  Future<void> _onRefresh() async {
    await getData();
  }

  final String defaultCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
  String _currentCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
  String _preCover = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
  List<String> _covers;
  int _currentCoverIndex = 0;
  Timer _loadCoverTimer;

  @override
  void initState() {
    super.initState();
    // _futureTask = getData();
    UMengUtil.userGoPage(UMengUtil.PAGE_TWEET_INDEX_HOT);
    _headerNotifier = LinkHeaderNotifier();
  }

  @override
  void dispose() {
    _headerNotifier.dispose();
    if (_loadCoverTimer != null) {
      // 页面销毁时触发定时器销毁
      if (_loadCoverTimer.isActive) {
        // 判断定时器是否是激活状态
        _loadCoverTimer.cancel();
      }
    }
    super.dispose();
  }

  Future<void> getData() async {
    UniHotTweet ht = await TweetApi.queryOrgHotTweets(Application.getOrgId);

    if (ht == null) {
      ToastUtil.showToast(context, '当前访问人数较多，请稍后重试');
      setState(() {
        this.hotTweet = null;
      });
      return;
    }
    setState(() {
      this.hotTweet = ht;
    });
    extractCovers();
    ToastUtil.showToast(context, '更新完成');
  }

  void loopDisplayCover() {
    _loadCoverTimer?.cancel();
    if (_covers == null || _covers.length == 1) {
      setState(() {
        _currentCover = defaultCover;
      });
      return;
    }
    if (hotTweet == null) {
      return;
    }
    _loadCoverTimer = Timer.periodic(Duration(milliseconds: 3000), (t) {
      if (_currentCoverIndex == _covers.length) {
        _currentCoverIndex = 0;
//        _currentCoverIndex = Random().nextInt(2) == 1 ? 0: 1;
        setState(() {
          _currentCover = _covers[_currentCoverIndex];
          _loadCoverTimer.cancel();
        });
        return;
      }
      setState(() {
        _currentCover = _covers[_currentCoverIndex++];
        if (_currentCoverIndex > 0) {
          _preCover = _covers[_currentCoverIndex - 1];
        }
      });
    });
  }

  void extractCovers() {
    _covers?.clear();
    if (_covers == null) {
      _covers = new List();
    }
    _covers.add(defaultCover);
    if (hotTweet == null) {
      return;
    }
    List<HotTweet> bts = hotTweet.tweets;
    if (bts != null && bts.length > 0) {
      int len = bts.length;
      for (int i = 0; i < len; i++) {
        if (bts[i].cover != null && bts[i].cover.mediaType == Media.TYPE_IMAGE) {
          _covers.add(bts[i].cover.url + OssConstant.THUMBNAIL_SUFFIX);
        }
      }
      // loopDisplayCover();
      setState(() {
        _covers = _covers;
        _currentCover = _covers[0];
        if (!CollectionUtil.isListEmpty(_covers)) {
          _currentCover = _covers[Random().nextInt(_covers.length)];
        }
      });
    }
  }

  get getBackgroundUrl {
    String baseUrl = PathConstant.HOT_COVER_URL + OssConstant.THUMBNAIL_SUFFIX;
    _currentCover = baseUrl;
    if (hotTweet == null) {
      return baseUrl;
    }
    List<HotTweet> bts = hotTweet.tweets;
    if (CollectionUtil.isListEmpty(bts)) {
      return baseUrl;
    }
    Media firstMedia = bts[0].cover;

    if (firstMedia == null || firstMedia.mediaType != Media.TYPE_IMAGE) {
      return baseUrl;
    }

    return firstMedia.url + OssConstant.THUMBNAIL_SUFFIX;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool loadingOrRedisInit = hotTweet == null;
    bool noData = !loadingOrRedisInit && CollectionUtil.isListEmpty(hotTweet.tweets);
    bool showTrend = !noData;
    if (hotTweet != null && hotTweet.lastFetched != null) {
      if (hotTweet.lastFetched.hour == 23 && hotTweet.lastFetched.minute == 30) {
        showTrend = false;
      }
    }
    return SafeArea(
        child: Scaffold(
      backgroundColor: ThemeUtils.isDark(context) ? null : Colors.white,
      body: EasyRefresh.custom(
          header: LinkHeader(
            _headerNotifier,
            extent: 70.0,
            triggerDistance: 70.0,
            // completeDuration: Duration(milliseconds: 5000),
            enableHapticFeedback: true,
          ),
          firstRefresh: true,
          slivers: <Widget>[
            HotAppBarWidget(
              headerNotifier: _headerNotifier,
              backgroundImg: _currentCover,
              // backgroundImgs: (_covers == null || _covers.length == 1) ? null : _covers,
              count: 10,
              cache: true,
              displayLeading: false,
              lightShadow: Colors.black38,
              outerMargin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              outerRadius: BorderRadius.circular(8.0),
              imageRadius: BorderRadius.circular(8.0),
              sigma: 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(5)),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: '${DateUtil.formatDate(DateTime.now(), format: 'dd')} ',
                              style: pfStyle.copyWith(fontSize: Dimens.font_sp15 * 2, color: Colors.white)),
                          TextSpan(
                              text: '/ ${DateUtil.formatDate(DateTime.now(), format: 'MM')}',
                              style: pfStyle.copyWith(fontSize: Dimens.font_sp16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '精选20条校园最热门的内容，每半小时更新一次',
                          softWrap: true,
                          maxLines: 2,
                          style: pfStyle.copyWith(fontSize: Dimens.font_sp14, color: Color(0xddffffff)),
                        ),
                        Gaps.vGap2,
                        Text(
                          '上次更新时间：' +
                              (hotTweet != null
                                  ? DateUtil.formatDate(hotTweet.lastFetched, format: "HH:mm").toString()
                                  : '暂未更新'),
                          style: pfStyle.copyWith(fontSize: Dimens.font_sp13, color: Color(0xddffffff)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              expandedHeight: _expandedHeight,
              title: '',
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 3.0),
              sliver: SliverList(
                  delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (hotTweet == null) {
                    return Gaps.empty;
                  }
                  var tweets = hotTweet.tweets;
                  if (tweets == null || tweets.length == 0) {
                    return EmptyView(
                        lightImg: "no_data", darkImg: "no_data_dark", text: '快去抢占热门吧 ～', topMargin: 50);
                  }
                  return TweetHotCard(tweets[index], index, () => _forwardDetail(tweets[index].id, index + 1),
                      showTrend: showTrend);
                },
                childCount: loadingOrRedisInit ? 0 : (!noData ? hotTweet.tweets.length : 1),
              )),
            )
            // Gaps.vGap5
          ],
          onRefresh: _onRefresh,
          onLoad: null),
    ));
  }

  _forwardDetail(int tweetId, int rank) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TweetDetail(null, tweetId: tweetId, hotRank: rank, newLink: true)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
