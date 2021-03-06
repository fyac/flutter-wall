import 'package:flutter/material.dart';
import 'package:iap_app/model/account.dart';
import 'package:iap_app/res/dimens.dart';
import 'package:iap_app/style/text_style.dart';

class TweetPraiseItem extends StatelessWidget {
  static const TextSpan emptyTs = TextSpan(text: '');
  final Account account;
  final Function onTapAccount;

  TweetPraiseItem({@required this.account, @required this.onTapAccount});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
            onTap: onTapAccount != null ? onTapAccount(account) : null,
            child: Text("${account.nick}",
                style: MyDefaultTextStyle.getTweetNickStyle(Dimens.font_sp14, bold: false))));
  }
}
