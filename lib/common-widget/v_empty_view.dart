import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VEmptyView extends StatelessWidget {
  final double height;

  VEmptyView(this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(height),
    );
  }
}

class VEmptyViewWithBg extends StatelessWidget {
  final double height;

  VEmptyViewWithBg(this.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Color(0xffe7e8ea),
    );
  }
}
