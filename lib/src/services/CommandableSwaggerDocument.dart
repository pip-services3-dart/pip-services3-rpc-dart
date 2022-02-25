import 'package:pip_services3_commons/pip_services3_commons.dart';

class CommandableSwaggerDocument {
  String _content = '';

  List<ICommand> commands = [];

  String version = '3.0.2';
  String baseRoute = '';

  String? infoTitle;
  String? infoDescription;
  String infoVersion = '1';
  String? infoTermsOfService;

  String? infoContactName;
  String? infoContactUrl;
  String? infoContactEmail;

  String? infoLicenseName;
  String? infoLicenseUrl;

  Map<String, dynamic> objectType = {'type': 'object'};

  CommandableSwaggerDocument(
      String baseRoute, ConfigParams? config, List<ICommand> commands) {
    this.baseRoute = baseRoute;
    this.commands = commands;

    config = config ?? ConfigParams();
    infoTitle = config.getAsStringWithDefault('name', 'CommandableHttpService');
    infoDescription = config.getAsStringWithDefault(
        'description"', 'Commandable microservice');
  }

  @override
  String toString() {
    var data = <String, dynamic>{
      'openapi': version,
      'info': <String, dynamic>{
        'title': infoTitle,
        'description': infoDescription,
        'version': infoVersion,
        'termsOfService': infoTermsOfService,
        'contact': <String, dynamic>{
          'name': infoContactName,
          'url': infoContactUrl,
          'email': infoContactEmail
        },
        'license': <String, dynamic>{
          'name': infoLicenseName,
          'url': infoLicenseUrl
        }
      },
      'paths': _createPathsData()
    };

    writeData(0, data);
    return _content;
  }

  Map<String, dynamic> _createPathsData() {
    var data = <String, dynamic>{};
    for (var index = 0; index < commands.length; index++) {
      var command = commands[index];

      var path = baseRoute + '/' + command.getName();
      if (!path.startsWith('/')) path = '/' + path;

      data[path] = <String, dynamic>{
        'post': <String, dynamic>{
          'tags': [baseRoute],
          'operationId': command.getName(),
          'requestBody': _createRequestBodyData(command),
          'responses': _createResponsesData()
        }
      };
    }

    return data;
  }

  Map<String, dynamic>? _createRequestBodyData(ICommand command) {
    var schemaData = _createSchemaData(command);
    return schemaData == null
        ? null
        : <String, dynamic>{
            'content': <String, dynamic>{
              'application/json': <String, dynamic>{'schema': schemaData}
            }
          };
  }

  Map<String, dynamic>? _createSchemaData(ICommand command) {
    ObjectSchema? schema;

    try {
      schema = (command as dynamic).schema_;
    } on NoSuchMethodError {
      schema = null;
    }

    if (schema == null || schema.getProperties().isEmpty) {
      return null;
    }

    return _createPropertyData(schema, true);
  }

  Map<String, dynamic> _createPropertyData(
      ObjectSchema schema, bool includeRequired) {
    var properties = <String, dynamic>{};
    var required = [];

    for (var property in schema.getProperties()) {
      if (property.getType() == null) {
        properties[property.getName()!] = objectType;
      } else {
        var propertyName = property.getName();
        var propertyType = property.getType();

        if (propertyType is ArraySchema) {
          properties[propertyName!] = {
            'type': 'array',
            'items': _createPropertyTypeData(propertyType.getValueType())
          };
        } else {
          properties[propertyName!] = _createPropertyTypeData(propertyType);
        }

        if (includeRequired && property.isRequired()) {
          required.add(propertyName);
        }
      }
    }

    var data = <String, dynamic>{'properties': properties};

    if (required.isNotEmpty) {
      data['required'] = required;
    }
    return data;
  }

  String toSupportedSwaggerType(String typeName) {
    switch (typeName) {
      case 'String':
        return 'string';
      case 'bool':
        return 'boolean';
      case 'int':
        return 'integer';
      case 'double':
        return 'number';
      case 'List':
        return 'array';
      default:
        return typeName;
    }
  }

  Map<String, dynamic> _createPropertyTypeData(dynamic propertyType) {
    if (propertyType is ObjectSchema) {
      var objectMap = _createPropertyData(propertyType, false);
      var result = <String, dynamic>{};
      result.addAll(objectType);
      result.addAll(objectMap);
      return result;
    } else {
      TypeCode typeCode;

      if (propertyType is TypeCode) {
        typeCode = propertyType;
      } else {
        typeCode = TypeConverter.toTypeCode(propertyType);
      }

      if (typeCode == TypeCode.Unknown || typeCode == TypeCode.Map) {
        typeCode = TypeCode.Object;
      }

      switch (typeCode) {
        case TypeCode.Integer:
          return {'type': 'integer', 'format': 'int32'};
        case TypeCode.Long:
          return {'type': 'number', 'format': 'int64'};
        case TypeCode.Float:
          return {'type': 'number', 'format': 'float'};
        case TypeCode.Double:
          return {'type': 'number', 'format': 'double'};
        case TypeCode.DateTime:
          return {'type': 'string', 'format': 'date-time'};
        default:
          return {
            'type': toSupportedSwaggerType(TypeConverter.asString(typeCode))
          };
      }
    }
  }

  Map<String, dynamic> _createResponsesData() {
    return <String, dynamic>{
      '200': <String, dynamic>{
        'description': 'Successful response',
        'content': <String, dynamic>{
          'application/json': <String, dynamic>{
            'schema': <String, dynamic>{'type': 'object'}
          }
        }
      }
    };
  }

  void writeData(int indent, Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is String) {
        writeAsString(indent, key, value);
      } else if (value is List) {
        if ((value).isNotEmpty) {
          writeName(indent, key);
          for (var index = 0; index < value.length; index++) {
            var item = (value)[index];
            writeArrayItem(indent + 1, item);
          }
        }
      } else if (value is Map) {
        var values = List.from(value.values);
        if (values.indexWhere((dynamic item) {
              return item != null;
            }) >=
            0) {
          writeName(indent, key);
          writeData(indent + 1, (value as Map<String, dynamic>));
        }
      } else {
        writeAsObject(indent, key, value);
      }
    });
  }

  void writeName(int indent, String name) {
    var spaces = getSpaces(indent);
    _content += spaces + name + ':\n';
  }

  void writeArrayItem(int indent, String name, {bool isObjectItem = false}) {
    var spaces = getSpaces(indent);
    _content += spaces + '- ';

    if (isObjectItem) {
      _content += name + ':\n';
    } else {
      _content += name + '\n';
    }
  }

  void writeAsObject(int indent, String name, dynamic value) {
    if (value == null) return;

    var spaces = getSpaces(indent);
    _content += spaces + name + ': ' + value + '\n';
  }

  void writeAsString(int indent, String name, String? value) {
    if (value == null) return;
    var spaces = getSpaces(indent);
    _content += spaces + name + ': \'' + value + '\'\n';
  }

  String getSpaces(int length) {
    return ' ' * length * 2;
  }
}
