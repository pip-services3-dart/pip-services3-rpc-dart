import 'package:pip_services3_commons/pip_services3_commons.dart';

class CommandableSwaggerDocument {
  String _content = '';

  List<ICommand> commands;

  String version = '3.0.2';
  String baseRoute;

  String infoTitle;
  String infoDescription;
  String infoVersion = '1';
  String infoTermsOfService;

  String infoContactName;
  String infoContactUrl;
  String infoContactEmail;

  String infoLicenseName;
  String infoLicenseUrl;

  CommandableSwaggerDocument(
      String baseRoute, ConfigParams config, List<ICommand> commands) {
    this.baseRoute = baseRoute;
    this.commands = commands ?? [];

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

  Map<String, dynamic> _createRequestBodyData(ICommand command) {
    var schemaData = _createSchemaData(command);
    return schemaData == null
        ? null
        : <String, dynamic>{
            'content': <String, dynamic>{
              'application/json': <String, dynamic>{'schema': schemaData}
            }
          };
  }

  Map<String, dynamic> _createSchemaData(ICommand command) {
    var schema = ((command as Command).getSchema()
        as ObjectSchema); //command.getSchema();// as ObjectSchema;

    if (schema == null || schema.getProperties() == null) {
      return null;
    }

    var properties = <String, dynamic>{};
    var required = [];

    for (var property in schema.getProperties()) {
      properties[property.getName()] = <String, dynamic>{
        'type': typeToString(property.getType())
      };

      if (property.isRequired()) required.add(property.getName());
    }

    var data = <String, dynamic>{'properties': properties};

    if (required.isNotEmpty) {
      data['required'] = required;
    }
    return data;
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
        if ((value as List).isNotEmpty) {
          writeName(indent, key);
          for (var index = 0; index < value.length; index++) {
            var item = (value as List)[index];
            writeArrayItem(indent + 1, item);
          }
        }
      } else if (value is Map) {
        var values = List.from((value as Map).values);
        if (values.indexWhere((dynamic item) {
              return item != null;
            }) >=
            0) {
          writeName(indent, key);
          writeData(indent + 1, (value as Map));
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

  void writeAsString(int indent, String name, String value) {
    if (value == null) return;
    var spaces = getSpaces(indent);
    _content += spaces + name + ': \'' + value + '\'\n';
  }

  String getSpaces(int length) {
    return ' ' * (length * 2);
  }

  String typeToString(dynamic type) {
    // allowed types: array, boolean, integer, number, object, String
    if (type == TypeCode.Integer || type == TypeCode.Long) return 'integer';
    if (type == TypeCode.Double || type == TypeCode.Float) return 'number';
    if (type == TypeCode.String) return 'String';
    if (type == TypeCode.Boolean) return 'boolean';
    if (type == TypeCode.Array) return 'array';

    return 'object';
  }
}
