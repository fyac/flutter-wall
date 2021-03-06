import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/util/theme_utils.dart';

class ColorConstant {
  // 昵称颜色
  static const Color TWEET_NICK_COLOR = Color(0xff4575AB);
  static const Color TWEET_NICK_COLOR_DARK = Color(0xff708090);

  /// 推文相关
  // 推文body颜色
  static const Color TWEET_BODY_COLOR = Color(0xff000000);
  static const Color TWEET_BODY_COLOR_DARK = Color(0xffa0a0a0);

  /// 回复相关

  // 回复正常昵称颜色
  static const Color TWEET_REPLY_NICK_COLOR = Color(0xff4575AB);
  static const Color TWEET_REPLY_NICK_COLOR_DARK = Color(0xff708090);

  // 推文回复正文颜色
  static const Color TWEET_REPLY_BODY_COLOR = Color(0xff000000);
  static const Color TWEET_REPLY_BODY_COLOR_DARK = Color(0xff999999);

  // 推文匿名回复的昵称颜色
  static const Color TWEET_REPLY_ANONYMOUS_NICK_COLOR = Color(0xff444444);
  static const Color TWEET_REPLY_ANONYMOUS_NICK_COLOR_DARK = Color(0xff666666);

  // 推文查看更多回复颜色
  static const Color TWEET_REPLY_REPLY_MORE_COLOR = Color(0xff696d7d);
  static const Color TWEET_REPLY_REPLY_MORE_COLOR_DARK = Color(0xff696969);

  // sub text 副文本颜色
  static const Color SUB_TEXT_COLOR = Color(0xff4f4f4f);
  static const Color SUB_TEXT_COLOR_DARK = Color(0xff808080);

  // 推文签名颜色
  static const Color TWEET_SIG_COLOR = Color(0xff828282);
  static const Color TWEET_SIG_COLOR_DARK = Color(0xff787878);

  static const Color TWEET_STATISTICS_COLOR = Color(0xff828282);
  static const Color TWEET_DISABLE_COLOR_TEXT_COLOR = Color(0xffD2B48C);

  // 推文时间颜色
  static const Color TWEET_TIME_COLOR = Color(0xffADADAD);
  static const Color TWEET_TIME_COLOR_DARK = Color(0xff707070);

  // 饿了么的字体颜色
  static const Color TEXT_COMMON = Color(0xff606266);
  static const Color TEXT_MAIN = Color(0xff303133);

  // 推文富链接背景颜色
  static const Color TWEET_RICH_BG = Color(0xffF5F4F5);
  static const Color TWEET_RICH_BG_DARK = Color(0xff202122);

  // 推文富链接背景颜色稍浅
  static const Color TWEET_RICH_BG_2 = Color(0xffF8F7F8);

  static const Color MAIN_BG = Color(0xffFFFEFF);
  static const Color MAIN_BG_DARK = Color(0xff121314);
  static const Color MAIN_BG_DARKER = Color(0xff212121);

  static const Color TWEET_TYPE_TEXT_DARK = Colors.white60;

  static const Color DEFAULT_BACK_COLOR = Color(0xffeef2f6);

  static const Color DEFAULT_BAR_BACK_COLOR = Color(0xfff9f9f9);
  static const Color DEFAULT_BAR_BACK_COLOR_DARK = Color(0xff202122);

  static const Color QQ_BLUE = Color(0xff19a9fc);
  static const Color LINK = Color(0xff02376a);

  static const Color MAIN_BAR_COLOR = Color(0xfff9f9f9);

  static const Color TWEET_DETAIL_REPLY_ROW_COLOR = Colors.amberAccent;
  static const Color TWEET_DETAIL_PRAISE_ROW_COLOR = Colors.amberAccent;

//  static const Color TWEET_DETAIL_PRAISE_ROW_COLOR = Color(0xffFF1493);

  static Color getTweetNickColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_NICK_COLOR_DARK : TWEET_NICK_COLOR;
  }

  static Color getTweetBodyColor(bool isDark) {
    return isDark ? TWEET_BODY_COLOR_DARK : TWEET_BODY_COLOR;
  }

  static Color getSubTextBodyColor(bool isDark) {
    return isDark ? SUB_TEXT_COLOR_DARK : SUB_TEXT_COLOR;
  }

  static Color getTweetSigColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_SIG_COLOR_DARK : TWEET_SIG_COLOR;
  }

  static Color getTweetTimeColor(BuildContext context) {
    return ThemeUtils.isDark(context) ? TWEET_TIME_COLOR_DARK : TWEET_TIME_COLOR;
  }

  static Color getNormalTextColor({BuildContext context}) {
    return ThemeUtils.isDark(context ?? Application.context) ? SUB_TEXT_COLOR_DARK : SUB_TEXT_COLOR;
  }

  static Color getCommonText({BuildContext context}) {
    return ThemeUtils.isDark(context ?? Application.context) ? Colors.grey : TEXT_COMMON;
  }

  static Color getMainText({BuildContext context}) {
    return ThemeUtils.isDark(context ?? Application.context) ? Colors.grey : TEXT_MAIN;
  }
}
