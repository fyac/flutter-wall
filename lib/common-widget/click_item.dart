import 'package:flutter/material.dart';
import 'package:iap_app/common-widget/v_empty_view.dart';
import 'package:iap_app/res/gaps.dart';
import 'package:iap_app/res/resources.dart';

class ClickItem extends StatelessWidget {
  const ClickItem(
      {Key key,
      this.onTap,
      @required this.title,
      this.content: "",
      this.prefixWidget,
      this.textAlign: TextAlign.start,
      this.maxLines: 1})
      : super(key: key);

  final GestureTapCallback onTap;
  final String title;
  final String content;
  final TextAlign textAlign;
  final int maxLines;
  final Widget prefixWidget;

  @override
  Widget build(BuildContext context) {
    return ClickItemCommon(
      onTap: onTap,
      title: title,
      textAlign: TextAlign.start,
      maxLines: maxLines,
      prefixWidget: prefixWidget == null? null:Padding(
        child: prefixWidget,
        padding: const EdgeInsets.only(right: 4),
      ),
      widget: Text(content,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 14.0)),
    );
    // return Material(
    //     child: InkWell(
    //   onTap: onTap,
    //   child: Container(
    //     margin: const EdgeInsets.only(left: 15.0),
    //     padding: const EdgeInsets.fromLTRB(0, 15.0, 15.0, 15.0),
    //     constraints:
    //         BoxConstraints(maxHeight: double.infinity, minHeight: 50.0),
    //     width: double.infinity,
    //     decoration: BoxDecoration(
    //         border: Border(
    //       bottom: Divider.createBorderSide(context, width: 0.6),
    //     )),
    //     child: Row(
    //       //为了数字类文字居中
    //       crossAxisAlignment: maxLines == 1
    //           ? CrossAxisAlignment.center
    //           : CrossAxisAlignment.start,
    //       children: <Widget>[
    //         Text(
    //           title,
    //         ),
    //         const Spacer(),
    //         Expanded(
    //           flex: 4,
    //           child: Padding(
    //             padding: const EdgeInsets.only(right: 8.0, left: 16.0),
    //             child: Text(content,
    //                 maxLines: maxLines,
    //                 textAlign: TextAlign.right,
    //                 overflow: TextOverflow.ellipsis,
    //                 style: Theme.of(context)
    //                     .textTheme
    //                     .subtitle
    //                     .copyWith(fontSize: 14.0)),
    //           ),
    //         ),
    //         Opacity(
    //           // 无点击事件时，隐藏箭头图标
    //           opacity: onTap == null ? 0 : 1,
    //           child: Padding(
    //             padding: EdgeInsets.only(top: maxLines == 1 ? 0.0 : 2.0),
    //             child: Images.arrowRight,
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // ));
  }
}

class ClickItemCommon extends StatelessWidget {
  const ClickItemCommon(
      {Key key,
      this.onTap,
      @required this.title,
      this.widget,
      this.prefixWidget,
      this.textAlign: TextAlign.start,
      this.maxLines: 1})
      : super(key: key);

  final GestureTapCallback onTap;
  final String title;
  final Widget widget;
  final Widget prefixWidget;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // margin: const EdgeInsets.only(left: 15.0),
        padding: const EdgeInsets.fromLTRB(15, 15.0, 15.0, 15.0),
        constraints: BoxConstraints(maxHeight: double.infinity, minHeight: 50.0),
        width: double.infinity,
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border(
            bottom: Divider.createBorderSide(context, width: 0.6),
          ),
          // color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          //为了数字类文字居中
          crossAxisAlignment: CrossAxisAlignment.end ,
//          crossAxisAlignment: maxLines == 1 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: <Widget>[
            prefixWidget ?? Gaps.empty,
            Text(
              title,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
            const Spacer(),
            Expanded(
              flex: 4,
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 16.0),
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: widget ?? VEmptyView(0),
                  )),
            ),
            Opacity(
              // 无点击事件时，隐藏箭头图标
              opacity: onTap == null ? 0 : 1,
              child: Padding(
                padding: EdgeInsets.only(top: maxLines == 1 ? 0.0 : 2.0),
                child: Images.arrowRight,
              ),
            )
          ],
        ),
      ),
    );
  }
}
