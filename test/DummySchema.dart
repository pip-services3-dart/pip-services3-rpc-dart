import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'SubDummySchema.dart';

class DummySchema extends ObjectSchema {
  DummySchema() : super() {
    withOptionalProperty('id', TypeCode.String);
    withRequiredProperty('key', TypeCode.String);
    withOptionalProperty('content', TypeCode.String);
    withOptionalProperty('array', ArraySchema(SubDummySchema()));
  }
}
