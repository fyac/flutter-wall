import 'package:flutter/material.dart';
import 'package:iap_app/res/colors.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/style/text_style.dart';
import 'package:iap_app/util/string.dart';
import 'package:iap_app/util/theme_utils.dart';

class SimpleTag extends StatelessWidget {
  final Color bgColor;
  final Color bgDarkColor;
  final Color textColor;
  final String text;
  final bool round;
  final double horizontalPadding;
  final double verticalPadding;
  final double leftMargin;
  final double radius;

  SimpleTag(this.text,
      {this.bgColor = const Color(0xfff1f0f1),
      this.bgDarkColor = Colours.dark_bg_color_darker,
      this.textColor = Colors.grey,
      this.radius = 0,
      this.round = true,
      this.verticalPadding = 1.0,
      this.horizontalPadding = 5.0,
      this.leftMargin = 0});

  @override
  Widget build(BuildContext context) {
    if (StringUtil.isEmpty(text)) {
      return Gaps.empty;
    }
    bool isDark = ThemeUtils.isDark(context);
    return Container(
        margin: EdgeInsets.only(left: leftMargin),
//        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
            color: isDark ? bgDarkColor : bgColor,
            borderRadius: round
                ? BorderRadius.vertical(top: Radius.circular(radius), bottom: Radius.circular(radius))
                : null),
        child: Text(
          text ?? "",
          style: pfStyle.copyWith(fontSize: Dimens.font_sp13, fontWeight: FontWeight.w300, color: textColor),
        ));
  }
}
