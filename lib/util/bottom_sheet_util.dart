import 'package:flutter/material.dart';

class BottomSheetItem {
  final Icon icon;
  final String text;
  final callback;
  BottomSheetItem(this.icon, this.text, this.callback);
}

class BottomSheetUtil {
  static void showBottmSheetView(
      BuildContext context, List<BottomSheetItem> items) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Color(0xfff4f5f7),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Row(children: _renderItems(context, items)),
              )
            ],
          );
        });
  }

  static List<Widget> _renderItems(
      BuildContext context, List<BottomSheetItem> items) {
    return items.map((f) => _renderSingleItem(context, f)).toList();
  }

  static Widget _renderSingleItem(BuildContext context, BottomSheetItem item) {
    return Container(
        margin: EdgeInsets.only(right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                item.callback();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                padding: EdgeInsets.all(20),
                child: item.icon,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10), child: Text(item.text))
          ],
        ));
  }
}