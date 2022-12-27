import 'package:pip_services3_commons/pip_services3_commons.dart';

class SubDummySchema extends ObjectSchema {
  SubDummySchema() : super() {
    withRequiredProperty('key', TypeCode.String);
    withOptionalProperty('content', TypeCode.String);
  }
}
