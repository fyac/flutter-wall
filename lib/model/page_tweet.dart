import 'package:iap_app/model/page.dart';
import 'package:iap_app/model/tweet.dart';

// @JsonSerializable()
class PageTweet extends Page<BaseTweet> {
  PageTweet.fromJson(Map<String, dynamic> json) : super.fromJsonSelf(json) {
    this.data = (json['data'] as List)?.map((e) => e as BaseTweet)?.toList();
  }
}
