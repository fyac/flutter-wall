import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iap_app/application.dart';
import 'package:iap_app/global/color_constant.dart';
import 'package:iap_app/global/size_constant.dart';
import 'package:iap_app/global/text_constant.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/style/color_style.dart';
import 'package:iap_app/util/theme_utils.dart';

class MyDefaultTextStyle {
  static TextStyle getTweetNickStyle(double fontSize,
      {bool bold = true, bool anonymous = false, BuildContext context}) {
    return TextStyle(
        color: ColorConstant.getTweetNickColor(context ?? Application.context),
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal);
  }

  static TextStyle getMainTextBodyStyle(bool isDark, {double fontSize = Dimens.font_sp16}) {
    return TextStyle(
        color: ColorConstant.getTweetBodyColor(isDark),
        height: 1.6,
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT);
  }

  /// 推文相关

  // 推文正文字体
  static TextStyle getTweetBodyStyle(BuildContext context, {double fontSize = Dimens.font_sp16}) {
    return TextStyle(
        color: MyColorStyle.getTweetBodyColor(context: context),
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w400);
  }

  static TextStyle getSubTextBodyStyle(bool isDark, {double fontSize = Dimens.font_sp15}) {
    return TextStyle(
      color: ColorConstant.getSubTextBodyColor(isDark),
      height: 1.6,
      fontSize: fontSize,
      fontFamily: TextConstant.PING_FANG_FONT,
    );
  }

  static TextStyle getTweetTypeStyle(BuildContext context, {double fontSize = Dimens.font_sp16}) {
    return TextStyle(
        fontFamily: TextConstant.PING_FANG_FONT,
        color: !ThemeUtils.isDark(context) ? Colors.white : ColorConstant.TWEET_TYPE_TEXT_DARK,
        fontWeight: FontWeight.w500);
  }

  static TextStyle getTweetReplyNickStyle(BuildContext context, {double fontSize = Dimens.font_sp14}) {
    return TextStyle(
        fontFamily: TextConstant.PING_FANG_FONT,
        color: ColorConstant.getTweetNickColor(context), fontSize: fontSize, fontWeight: FontWeight.w400);
  }

  /// 推文回复相关样式

  // 推文回复：匿名回复 样式
  static TextStyle getTweetReplyAnonymousNickStyle(double fontSize, {BuildContext context}) {
    return TextStyle(
        color: MyColorStyle.getTweetReplyAnonymousNickColor(context: context),
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w400);
  }

  // 推文回复：作者NICK 样式
  static TextStyle getTweetReplyAuthorNickStyle(double fontSize, {BuildContext context}) {
    return TextStyle(
        color: MyColorStyle.getTweetReplyNickColor(context: context),
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w400);
  }

  // 推文回复：'回复' 样式
  static TextStyle getTweetReplyHuiFuTextStyle(double fontSize, {BuildContext context}) {
    if (context == null) {
      context = Application.context;
    }
    return TextStyle(
        color: ThemeUtils.isDark(context) ? Color(0xff888888) : Colors.black87,
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w400);
  }

  // 推文回复：回复正文样式
  static TextStyle getTweetReplyBodyTextStyle(double fontSize, {BuildContext context}) {
    return TextStyle(
        color: MyColorStyle.getTweetReplyBodyColor(context: context),
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w400);
  }

  // 回复 查看更多样式
  static TextStyle getTweetReplyMoreTextStyle(double fontSize, {BuildContext context}) {
    return TextStyle(
        color: MyColorStyle.getTweetReplyMoreColor(context: context),
        fontSize: fontSize,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w300);
  }

  /// 其他相关
  static TextStyle getMainTextBodyStyle2(BuildContext context, {double fontSize = Dimens.font_sp16}) {
    return getTweetBodyStyle(context, fontSize: fontSize);
  }

  static TextStyle getTweetHeadNickStyle(BuildContext context, double fontSize,
      {bool anonymous = false, bool bold = false}) {
    return pfStyle.copyWith(
        fontSize: SizeConstant.TWEET_FONT_SIZE,
        fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
        color: !anonymous ? ColorConstant.getTweetNickColor(context) : Color(0xff828282));
  }

  static TextStyle getTweetSigStyle(BuildContext context, {double fontSize = Dimens.font_sp13}) {
    return pfStyle.copyWith(
        fontSize: fontSize,
        color: ColorConstant.getTweetSigColor(context),
        fontWeight: FontWeight.w400);
  }

  static TextStyle getTweetTimeStyle(BuildContext context, {double fontSize = SizeConstant.TWEET_TIME_SIZE}) {
    return pfStyle.copyWith(
        fontSize: fontSize,
        color: ColorConstant.getTweetTimeColor(context),
        fontWeight: FontWeight.w400);
  }

  static TextStyle getTweetReplyOtherStyle(double fontSize) {
    return pfStyle.copyWith(
      color: Colors.black87,
      fontSize: fontSize,
    );
  }


  ///
  static TextStyle tweetReplyStyleLight() {
    return TextStyle(
        color: ColorConstant.TWEET_REPLY_BODY_COLOR,
        fontSize: Dimens.font_sp14,
        fontFamily: TextConstant.PING_FANG_FONT,
        fontWeight: FontWeight.w400);
  }

  static TextStyle tweetReplyStyleDark() {
    return TextStyle(
        fontFamily: TextConstant.PING_FANG_FONT,
        color: ColorConstant.TWEET_REPLY_BODY_COLOR_DARK,
        fontSize: Dimens.font_sp14,
        fontWeight: FontWeight.w400);
  }

  static TextStyle tweetReplyAuthorNickStyleLight() {
    return TextStyle(
        fontFamily: TextConstant.PING_FANG_FONT,
        color: ColorConstant.TWEET_REPLY_NICK_COLOR,
        fontSize: Dimens.font_sp14,
        fontWeight: FontWeight.w400);
  }

  static TextStyle tweetReplyAuthorNickStyleDark() {
    return TextStyle(
        fontFamily: TextConstant.PING_FANG_FONT,
        color: ColorConstant.TWEET_REPLY_NICK_COLOR_DARK,
        letterSpacing: 1.1,
        fontSize: Dimens.font_sp14,
        fontWeight: FontWeight.w400);
  }
}

const pfStyle = const TextStyle(fontFamily: TextConstant.PING_FANG_FONT);
