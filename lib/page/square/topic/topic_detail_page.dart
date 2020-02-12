import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';
import 'package:iap_app/api/topic.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/common-widget/account_avatar.dart';
import 'package:iap_app/common-widget/imgae_container.dart';
import 'package:iap_app/common-widget/popup_window.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/model/media.dart';
import 'package:iap_app/model/topic/base_tr.dart';
import 'package:iap_app/model/topic/topic.dart';
import 'package:iap_app/page/square/topic/topic_reply_card.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/styles.dart';
import 'package:iap_app/routes/fluro_navigator.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/bottom_sheet_util.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';
import 'package:iap_app/util/time_util.dart';
import 'package:iap_app/util/toast_util.dart';
import 'package:iap_app/util/widget_util.dart';

class TopicDetailPage extends StatefulWidget {
  final int topicId;
  Topic topic;

  TopicDetailPage(this.topicId, {this.topic});

  @override
  State<StatefulWidget> createState() {
    return _TopicDetailPageState(topic);
  }
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  Topic topic;

  _TopicDetailPageState(this.topic);

  bool isDark = false;
  int _sortTypeIndex = 0;
  GlobalKey _sortButtonKey = GlobalKey();

  List _sortTypeList = ["热门排序", "时间排序"];

  Future _getReplyTask;
  List<MainTopicReply> mainTopicReplies;

  Future<void> _onRefresh() async {
    Topic topic = await TopicApi.queryTopicById(widget.topicId);
    await Future.delayed(Duration(seconds: 1));
//    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _fetchTopicIfNullAndExtra();
    _fetchMainReplies();
  }

  void _fetchTopicIfNullAndExtra() async {
    if (topic == null) {
      Topic topic = await TopicApi.queryTopicById(widget.topicId);
      setState(() {
        this.topic = topic;
        _getReplyTask = _fetchMainReplies();
      });
    } else {
      setState(() {
        _getReplyTask = _fetchMainReplies();
      });
    }
  }

  Future<List<MainTopicReply>> _fetchMainReplies() async {
    List<MainTopicReply> temp = await TopicApi.queryTopicMainReplies(topic.id, 1, 20,
        order: _sortTypeIndex == 0 ? BaseTopicReply.QUERY_ORDER_HOT : BaseTopicReply.QUERY_ORDER_TIME);
    if (temp == null) {
      return [];
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    isDark = ThemeUtils.isDark(context);
    return Scaffold(
        appBar: AppBar(
          title: Flex(direction: Axis.horizontal, mainAxisSize: MainAxisSize.max, children: <Widget>[
            Expanded(
                flex: 1,
                child: topic == null
                    ? Gaps.empty
                    : Container(
                        alignment: Alignment.bottomLeft,
                        child: AccountAvatar(
                            avatarUrl: topic.author.avatarUrl,
                            size: 34,
                            onTap: () => NavigatorUtils.goAccountProfile(context, topic.author)))),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: const Text('详情'),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
          ]),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => NavigatorUtils.goBack(context)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                _showMoreMenus(context);
              },
            )
          ],
          elevation: 0.2,
        ),
        body: topic == null
            ? Container(alignment: Alignment.topCenter, child: WidgetUtil.getLoadingAnimation())
            : CustomScrollView(slivers: <Widget>[
                SliverToBoxAdapter(
                    child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildBody(),
                      Gaps.vGap12,
                      Gaps.line,
                      _buildCommentRow(),
                      _buildCommentWrap(),
//                      _buildCommentHeader(),
                    ],
                  ),
                ))
              ]));
  }

  Widget _buildBody() {
    bool hasExtra = topic.body != null && topic.body.trim().length != 0;
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        constraints: const BoxConstraints(minHeight: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: topic.title ?? TextConstant.TEXT_UN_CATCH_ERROR,
                      style: MyDefaultTextStyle.getMainTextBodyStyle(isDark))
                ]),
              ),
            ),
            hasExtra
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: topic.body.trim(), style: MyDefaultTextStyle.getSubTextBodyStyle(isDark))
                      ]),
                    ),
                  )
                : Gaps.empty,
            _buildImages(),
            _buildAuthInfo(),
            _buildUniRow(),
            _buildTagsRow(topic.tags),
          ],
        ));
  }

  Widget _buildImages() {
    List<Media> medias = topic.medias;
    if (medias == null || medias.length == 0) {
      return Gaps.empty;
    }
    // TODO 暂不展示图片以外的媒体类型
    medias.removeWhere((media) => media.mediaType != "IMAGE");
//    List<Media> temp = new List.from(medias);
//    medias.addAll(temp);
//    medias.addAll(temp);
    double singleImageWidth = (Application.screenWidth - 40 - 10 - 15) / medias.length;
    return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Wrap(
          children: medias
              .map((media) => Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: ImageContainer(
                      url: media.url,
//                      width: singleImageWidth,
                      maxWidth: singleImageWidth,
                      maxHeight: Application.screenHeight * 0.25,
                      height: singleImageWidth,
                    ),
                  ))
              .toList(),
        ));
  }

  Widget _buildAuthInfo() {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(bottom: 5),
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(children: [
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () => NavigatorUtils.goAccountProfile(context, topic.author),
              text: topic.author.nick,
              style: MyDefaultTextStyle.getTweetNickStyle(context, SizeConstant.TWEET_TIME_SIZE)),
          TextSpan(
              text: ' 发布于 ${TimeUtil.getShortTime(topic.sentTime)}',
              style: MyDefaultTextStyle.getTweetTimeStyle(context))
        ]),
      ),
    );
  }

  Widget _buildUniRow() {
    return Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
          decoration:
              BoxDecoration(color: Colours.app_main.withAlpha(45), borderRadius: BorderRadius.circular(5)),
          child: Text(
            " F " + topic.university.name ?? TextConstant.TEXT_UN_CATCH_ERROR,
            style: MyDefaultTextStyle.getTweetSigStyle(context, fontSize: Dimens.font_sp13),
          ),
        ));
  }

  Widget _buildTagsRow(List<String> tags) {
    if (tags == null || tags.length == 0) {
      return Gaps.empty;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Wrap(alignment: WrapAlignment.start, children: tags.map((t) => _buildSingleTag(t)).toList()),
    );
  }

  Widget _buildSingleTag(String tag) {
    if (tag == null || tag.trim().length == 0) {
      return Gaps.empty;
    }
    return Container(
        decoration: BoxDecoration(
            color: topicTagColors[Random().nextInt(topicTagColors.length - 1)].withAlpha(isDark ? 50 : 150),
            borderRadius: BorderRadius.circular(5.0)),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        child: Text("# $tag", style: TextStyles.textWhite14));
  }

  Widget _buildCommentWrap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildCommentHeader(),
        _buildConcreteComment(),
      ],
    );
  }

  Widget _buildConcreteComment() {
    return Container(
      child: FutureBuilder<List<MainTopicReply>>(
          builder: (context, AsyncSnapshot<List<MainTopicReply>> async) {
            if (async.connectionState == ConnectionState.active ||
                async.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new SpinKitThreeBounce(
                  color: Colors.deepPurple,
                  size: 18,
                ),
              );
            }
            if (async.connectionState == ConnectionState.done) {
              if (async.hasError) {
                return _centerText('拉取评论失败');
              } else if (async.hasData) {
                List<MainTopicReply> list = async.data;
                if (list.length == 0) {
                  return _centerText('暂无评论');
                }
                this.mainTopicReplies = list;
                return Column(
                  children: _buildReplyList(),
                );
              }
            }
            return Gaps.empty;
          },
          future: _getReplyTask),
    );
  }

  List<Widget> _buildReplyList() {
    return mainTopicReplies.map((tr) => Column(crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[
      TopicReplyCardItem(tr, isDark),
      Gaps.line
    ],)).toList();
  }

  Widget _buildCommentHeader() {
    return GestureDetector(
        key: _sortButtonKey,
        onTap: () => _showSortTypeSel(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: Text('${_sortTypeList[_sortTypeIndex]}', style: TextStyles.textGray14),
            ),
            Icon(Icons.keyboard_arrow_down,color: ThemeUtils.getIconColor(context))
          ],
        ));
  }

  Widget _buildTitle(String title, Color underlineColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: underlineColor, width: 1.0))),
      child: Text(title, style: MyDefaultTextStyle.getMainTextBodyStyle(isDark, fontSize: Dimens.font_sp15)),
    );
  }

  Widget _buildCommentRow() {
    return Container(
        alignment: Alignment.centerRight,
        child: FlatButton(
          child: Text('回复',
              style: TextStyle(color: Colors.blueAccent, fontSize: SizeConstant.TWEET_TIME_SIZE + 1)),
          onPressed: () {},
        ));
  }

  void _showSortTypeSel() {
    // 获取点击控件的坐标
    final RenderBox button = _sortButtonKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    // 获得控件左下方的坐标
    print("${button.size}");
    print("${button.localToGlobal(Offset.zero)}");
    var a = button.localToGlobal(Offset(0.0, button.size.height), ancestor: overlay);
    // 获得控件右下方的坐标
    var b = button.localToGlobal(button.size.bottomRight(Offset(0, 0)), ancestor: overlay);
    print("${a.dx}, ${a.dy}");
    print("${b.dx}, ${b.dy}");
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    print("$position");
    TextStyle textStyle = TextStyle(
      fontSize: Dimens.font_sp14,
      color: Theme.of(context).primaryColor,
    );
    showPopupWindow(
      context: context,
      fullWidth: true,
      position: position,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => NavigatorUtils.goBack(context),
        child: Container(
          color: const Color(0x99000000),
          height: Application.screenHeight - b.dy,
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: _sortTypeList.length,
            itemBuilder: (_, index) {
              Color backgroundColor = ThemeUtils.getBackgroundColor(context);
              return Material(
                color: backgroundColor,
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Text(
                      _sortTypeList[index],
                      style: index == _sortTypeIndex ? textStyle : null,
                    ),
                  ),
                  onTap: () {
                    NavigatorUtils.goBack(context);
                    setState(() {
                      _sortTypeIndex = index;
                      _getReplyTask = _fetchMainReplies();
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _centerText(String text) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 10),
        child: Text(
          text ?? "",
          style: TextStyles.textGray14,
        ));
  }

  void _showMoreMenus(BuildContext context) {
    BottomSheetUtil.showBottomSheetView(context, _getSheetItems());
  }

  List<BottomSheetItem> _getSheetItems() {
    List<BottomSheetItem> items = List();

    String accountId = Application.getAccountId;
    if (!StringUtil.isEmpty(accountId) && accountId == widget.topic.author.id) {
      if (topic.status == Topic.STATUS_OPEN) {
        // 添加关闭话题按钮
        items.add(BottomSheetItem(
            Icon(
              Icons.lock_open,
              color: Colors.teal,
            ),
            "关闭话题评论",
            () => {
                  // TODO 关闭话题
                }));
      } else if (topic.status == Topic.STATUS_CLOSE) {
        items.add(BottomSheetItem(
            Icon(
              Icons.lock,
              color: Colors.lightBlueAccent,
            ),
            "打开话题评论",
            () => {
                  // TODO 打开话题
                }));
      }
      // 作者自己的内容
//      items.add(BottomSheetItem(Icon(Icons.delete, color: Colors.redAccent), '删除', () {
//        Navigator.pop(context);
//        _showDeleteBottomSheet();
//      }));
    }
    items.add(BottomSheetItem(
        Icon(
          Icons.warning,
          color: Colors.yellow,
        ),
        '举报', () {
      ToastUtil.showToast(context, '举报成功');
      Navigator.pop(context);
    }));
    return items;
  }
}
