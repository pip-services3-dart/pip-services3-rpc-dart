import 'package:pip_services3_commons/pip_services3_commons.dart';

class SubDummy implements ICloneable {
  String? key;
  String? content;
  SubDummy({this.key, this.content});

  factory SubDummy.fromJson(Map<String, dynamic> json) {
    return SubDummy(key: json['key'], content: json['content']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'key': key, 'content': content};
  }

  void fromJson(Map<String, dynamic> json) {
    key = json['key'];
    content = json['content'];
  }

  @override
  SubDummy clone() {
    return SubDummy(key: key, content: content);
  }
}
