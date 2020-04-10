
import 'dart:io';
import 'dart:convert';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import './HttpRequestDetector.dart';

import './RestOperations.dart';

class AboutOperations extends RestOperations {
    ContextInfo _contextInfo;

    @override
    void setReferences(IReferences references) {
        super.setReferences(references);

        _contextInfo = references.getOneOptional<ContextInfo>(
             Descriptor('pip-services', 'context-info', '*', '*', '*')
        );
    }

    Function (angel.RequestContext req, angel.ResponseContext res) getAboutOperation() {
        return (angel.RequestContext req, angel.ResponseContext res) {
            about(req, res);
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

    void about(req, res) {
        var about = {
            'server': {
                'name': _contextInfo != null ? _contextInfo.name : 'unknown',
                'description': _contextInfo != null ? _contextInfo.description : null,
                'properties': _contextInfo != null ? _contextInfo.properties : null,
                'uptime': _contextInfo != null ? _contextInfo.uptime : null,
                'start_time': _contextInfo != null ? _contextInfo.startTime : null,

                'current_time': DateTime.now().toIso8601String(),
                'protocol': req.protocol,
                'host': HttpRequestDetector.detectServerHost(req),
                'addresses': _getNetworkAddresses(),
                'port': HttpRequestDetector.detectServerPort(req),
                'url': req.originalUrl,
            },
            'client': {
                'address': HttpRequestDetector.detectAddress(req),
                'client': HttpRequestDetector.detectBrowser(req),
                'platform': HttpRequestDetector.detectPlatform(req),
                'user': req.user
            }
        };

        res.write(json.encode(about));
    }

}
