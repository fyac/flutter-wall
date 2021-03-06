import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iap_app/global/path_constant.dart';
import 'package:iap_app/util/theme_utils.dart';

final String fallbackTweetType = "FALLBACK";
final tweetTypeMap = {
  "LOVE_CONFESSION": TweetTypeEntity.LOVE_CONFESSION,
  "ASK_FOR_MARRIAGE": TweetTypeEntity.ASK_FOR_MARRIAGE,
  "SOMEONE_FIND": TweetTypeEntity.SOMEONE_FIND,
  "QUESTION_CONSULT": TweetTypeEntity.QUESTION_CONSULT,
  "COMPLAINT": TweetTypeEntity.COMPLAINT,
  "GOSSIP": TweetTypeEntity.GOSSIP,
  "HAVE_FUN": TweetTypeEntity.HAVE_FUN,
  "SHARE": TweetTypeEntity.SHARE,
  "LOST_AND_FOUND": TweetTypeEntity.LOST_AND_FOUND,
  "HELP_AND_REWARD": TweetTypeEntity.HELP_AND_REWARD,
  "SECOND_HAND_TRANSACTION": TweetTypeEntity.SECOND_HAND_TRANSACTION,
  "OTHER": TweetTypeEntity.OTHER,
  "OFFICIAL": TweetTypeEntity.OFFICIAL,
  "CAMPUS_OFFICIAL": TweetTypeEntity.CAMPUS_OFFICIAL,
  "FALLBACK": TweetTypeEntity.FALLBACK,
  "AD": TweetTypeEntity.AD,
};

class TweetTypeUtil {
  static Map getFilterableTweetTypeMap() {
    final filteredMap = new Map.fromIterable(
        tweetTypeMap.keys.where((k) => tweetTypeMap[k].filterable && tweetTypeMap[k].visible),
        value: (k) => tweetTypeMap[k]);
    return filteredMap;
  }

  static Map<dynamic, TweetTypeEntity> getVisibleTweetTypeMap() {
    final visibleMap = new Map.fromIterable(tweetTypeMap.keys.where((k) => tweetTypeMap[k].visible),
        value: (k) => tweetTypeMap[k]);
    return visibleMap;
  }

  static Map<dynamic, TweetTypeEntity> getPushableTweetTypeMap() {
    final visibleMap = new Map.fromIterable(tweetTypeMap.keys.where((k) => tweetTypeMap[k].pushable),
        value: (k) => tweetTypeMap[k]);
    return visibleMap;
  }

  static String getTweetEntityCoverUrl(TweetTypeEntity entity) {
    if (entity == null) {
      entity == TweetTypeEntity.FALLBACK;
    }
    return "https://iutr-media.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/tweet-type-covers/${entity.name.toUpperCase()}.jpg";
  }

  static String getTweetTypeCover(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);
    return "https://iutr-media.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/tweet-type-covers/${isDark ? 'TYPE_COVER_DARK' : 'TYPE_COVER'}.jpg";
  }

  static TweetTypeEntity getRandomTweetType() {
    List<TweetTypeEntity> entities = getPushableTweetTypeMap().values.toList();
    return entities[Random().nextInt(entities.length)];
  }

// static Map getAllTweetTypeMap() {
//   return Map.from(tweetTypeMap);
// }
}

class TweetTypeEntity {
  final String name;
  final String zhTag;
  final Color color;
  final String coverUrl;
  final IconData iconData;
  final Color iconColor;
  final String intro;
  final String typeImage;

  // ??????????????????????????????
  final bool filterable;

  // ???????????????????????????????????????????????????
  final bool pushable;

  // ?????????????????????????????????
  final bool canUnSubscribe;

  // ??????????????????
  final bool visible;

  // ??????????????????????????????
  final bool renderBg;

  const TweetTypeEntity(
      {this.iconData,
      this.iconColor,
      this.name,
      this.zhTag,
      this.color,
      this.coverUrl,
      this.intro = "??????????????????",
      this.filterable = true,
      this.pushable = true,
      this.canUnSubscribe = true,
      this.typeImage = PathConstant.APP_LAUNCH_IMAGE,
      this.visible = true,
      this.renderBg = false});

  static const LOVE_CONFESSION = const TweetTypeEntity(
      iconData: Icons.favorite,
      iconColor: Color(0xffcd9cf2),
      name: "LOVE_CONFESSION",
      zhTag: "??????",
      color: Color(0xffcd9cf2),
      intro: "????????????????????????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      renderBg: true,
      coverUrl:
          "https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/type_cover_confession.png");
  static const ASK_FOR_MARRIAGE = const TweetTypeEntity(
      iconData: Icons.people_alt_sharp,
      iconColor: Color(0xffCD5C5C),
      name: "ASK_FOR_MARRIAGE",
      zhTag: "??????",
      intro: "??????????????????????????????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      color: Color(0xffCD5C5C),
      renderBg: true,
      coverUrl:
          "https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/type_cover_marriage.png");
  static const SOMEONE_FIND = const TweetTypeEntity(
      iconData: Icons.person_search,
      iconColor: Colors.lightBlue,
      name: "SOMEONE_FIND",
      intro: "??????????????????????????????????????????",
      zhTag: "??????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      color: Colors.lightBlue);

  static const QUESTION_CONSULT = const TweetTypeEntity(
      iconData: Icons.local_library,
      iconColor: Color(0xffFF82AB),
      name: "QUESTION_CONSULT",
      intro: "???????????????????????????",
      color: Color(0xffFF82AB),
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      zhTag: "??????");

  static const COMPLAINT = const TweetTypeEntity(
      iconData: Icons.mood,
      iconColor: Color(0xffaa7aaF),
      name: "COMPLAINT",
      zhTag: "??????",
      color: Color(0xffaa7aaF),
      intro: "?????????????????????????????????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbzief4r7j31900u0ws4.jpg",
      coverUrl:
          "https://iutr-image.oss-cn-hangzhou.aliyuncs.com/almond-donuts/default/type_cover_complaint.png");
  static const GOSSIP = const TweetTypeEntity(
      iconData: Icons.free_breakfast,
      iconColor: Color(0xff99bb93),
      intro: "????????????????????????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      name: "GOSSIP",
      color: Color(0xff99bb93),
      coverUrl: 'https://tva1.sinaimg.cn/large/006y8mN6ly1g870g0gah7j30qo0xbwl7.jpg',
      zhTag: "??????");

  static const HAVE_FUN = const TweetTypeEntity(
      iconData: Icons.toys,
      iconColor: Color(0xffDEB887),
      intro: "???????????????????????????????????????????????????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      name: "HAVE_FUN",
      color: Color(0xffDEB887),
      zhTag: "??????");

  static const SHARE = const TweetTypeEntity(
      iconData: Icons.star,
      iconColor: Color(0xffCCBB60),
      intro: "??????????????????????????????????????????",
      name: "SHARE",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      color: Color(0xffCCBB60),
      zhTag: "??????");

  static const LOST_AND_FOUND = const TweetTypeEntity(
      iconData: Icons.local_florist,
      iconColor: Color(0xffCDB5CD),
      intro: "????????????????????????????????????",
      name: "LOST_AND_FOUND",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      color: Color(0xffCDB5CD),
      zhTag: "????????????");

  static const HELP_AND_REWARD = const TweetTypeEntity(
      iconData: Icons.transfer_within_a_station,
      iconColor: Color(0xFFCD96CD),
      name: "HELP_AND_REWARD",
      intro: "???????????????????????????",
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      color: Color(0xFFCD96CD),
      zhTag: "??????");

  static const SECOND_HAND_TRANSACTION = const TweetTypeEntity(
      iconData: Icons.attach_money_sharp,
      iconColor: Colors.blue,
      name: "SECOND_HAND_TRANSACTION",
      intro: "?????????????????????",
      color: Colors.blue,
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      zhTag: "????????????");

  static const OTHER = const TweetTypeEntity(
      iconData: Icons.wb_sunny_rounded,
      iconColor: Color(0xff66CDAA),
      intro: "??????????????????????????????",
      name: "OTHER",
      color: Color(0xff66CDAA),
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      zhTag: "??????");

  static const OFFICIAL = const TweetTypeEntity(
      iconData: Icons.check_circle,
      iconColor: Color(0xff8470FF),
      name: "OFFICIAL",
      color: Color(0xff8470FF),
      zhTag: "??????",
      canUnSubscribe: false,
      pushable: false,
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      filterable: false);

  static const CAMPUS_OFFICIAL = const TweetTypeEntity(
      iconData: Icons.check_circle,
      iconColor: Color(0xff8470FF),
      name: "CAMPUS_OFFICIAL",
      color: Color(0xff8470FF),
      zhTag: "??????",
      canUnSubscribe: false,
      pushable: false,
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      filterable: false);

  static const FALLBACK = const TweetTypeEntity(
      iconData: Icons.blur_circular,
      iconColor: Color(0xffFF6EB4),
      name: "FALLBACK",
      color: Color(0xffFF6EB4),
      zhTag: "??????",
      canUnSubscribe: false,
      pushable: false,
      typeImage: "https://tva1.sinaimg.cn/large/007S8ZIlgy1gjbz0jt9h9j31910u0k49.jpg",
      filterable: false,
      visible: false);

  static const AD = const TweetTypeEntity(
      iconData: Icons.school,
      iconColor: Color(0xffA2B5CD),
      name: "AD",
      color: Color(0xffA2B5CD),
      zhTag: "??????",
      canUnSubscribe: false,
      pushable: false,
      filterable: false,
      visible: false);
}
