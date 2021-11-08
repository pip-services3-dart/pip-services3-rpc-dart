import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'SubDummy.dart';

class Dummy implements IStringIdentifiable, ICloneable {
  @override
  String? id;
  String? key;
  String? content;
  List<SubDummy>? array;

  Dummy({String? id, String? key, String? content, List<SubDummy>? array})
      : id = id,
        key = key,
        content = content,
        array = array;

  factory Dummy.fromJson(Map<String, dynamic> json) {
    return Dummy(
        id: json['id'],
        key: json['key'],
        content: json['content'],
        array: json['array']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'key': key, 'content': content};
  }

  void fromJson(Map<String, dynamic> json) {
    id = json['id'];
    key = json['key'];
    content = json['content'];
  }

  @override
  Dummy clone() {
    return Dummy(id: id, key: key, content: content);
  }
}
