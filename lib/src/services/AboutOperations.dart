import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:shelf/shelf.dart';
import './HttpRequestDetector.dart';

import './RestOperations.dart';

class AboutOperations extends RestOperations {
  ContextInfo? _contextInfo;

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);

    _contextInfo = references.getOneOptional<ContextInfo>(
        Descriptor('pip-services', 'context-info', '*', '*', '*'));
  }

  Function(Request req) getAboutOperation() {
    return (Request req) async {
      return await about(req);
    };
  }

  Future<List<String>> _getNetworkAddresses() async {
    var interfaces = await NetworkInterface.list();
    var addresses = <String>[];
    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 && !address.isLinkLocal) {
          addresses.add(address.address);
        }
      }
    }
    return addresses;
  }

  FutureOr<Response> about(Request req) {
    var about = {
      'server': {
        'name': _contextInfo != null ? _contextInfo!.name : 'unknown',
        'description': _contextInfo != null ? _contextInfo!.description : null,
        'properties': _contextInfo != null ? _contextInfo!.properties : null,
        'uptime': _contextInfo != null ? _contextInfo!.uptime : null,
        'start_time': _contextInfo != null ? _contextInfo!.startTime : null,
        'current_time': DateTime.now().toUtc().toIso8601String(),
        'protocol': req.protocolVersion,
        'host': HttpRequestDetector.detectServerHost(req),
        'addresses': _getNetworkAddresses(),
        'port': HttpRequestDetector.detectServerPort(req),
        'url': req.url.toString(),
      },
      'client': {
        'address': HttpRequestDetector.detectAddress(req),
        'client': HttpRequestDetector.detectBrowser(req),
        'platform': HttpRequestDetector.detectPlatform(req),
        'user': req.headers['user']
      }
    };

    return HttpResponseSender.sendResult(req, json.encode(about));
  }
}
