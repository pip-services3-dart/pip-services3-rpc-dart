//  @module services 
// const os = require('os');

// import { IReferences } from 'pip-services3-commons-node';
// import { Descriptor } from 'pip-services3-commons-node';
// import { ContextInfo } from 'pip-services3-components-node';
// import { HttpRequestDetector } from './HttpRequestDetector';

// import { RestOperations } from './RestOperations';

// export class AboutOperations extends RestOperations {
//     private _contextInfo: ContextInfo;

//     public setReferences(references: IReferences): void {
//         super.setReferences(references);

//         this._contextInfo = references.getOneOptional<ContextInfo>(
//             new Descriptor('pip-services', 'context-info', '*', '*', '*')
//         );
//     }

//     public getAboutOperation() {
//         return (req, res) => {
//             this.about(req, res);
//         };
//     }

//     private getNetworkAddresses(): string[] {
//         var interfaces = os.networkInterfaces();
//         var addresses: string[] = [];
//         for (var k in interfaces) {
//             for (var k2 in interfaces[k]) {
//                 var address = interfaces[k][k2];
//                 if (address.family === 'IPv4' && !address.internal) {
//                     addresses.push(address.address);
//                 }
//             }
//         }
//         return addresses;
//     }

//     public about(req, res) {
//         var about = {
//             server: {
//                 name: this._contextInfo != null ? this._contextInfo.name : 'unknown',
//                 description: this._contextInfo != null ? this._contextInfo.description : null,
//                 properties: this._contextInfo != null ? this._contextInfo.properties : null,
//                 uptime: this._contextInfo != null ? this._contextInfo.uptime : null,
//                 start_time: this._contextInfo != null ? this._contextInfo.startTime : null,

//                 current_time: new Date().toISOString(),
//                 protocol: req.protocol,
//                 host: HttpRequestDetector.detectServerHost(req),
//                 addresses: this.getNetworkAddresses(),
//                 port: HttpRequestDetector.detectServerPort(req),
//                 url: req.originalUrl,
//             },
//             client: {
//                 address: HttpRequestDetector.detectAddress(req),
//                 client: HttpRequestDetector.detectBrowser(req),
//                 platform: HttpRequestDetector.detectPlatform(req),
//                 user: req.user
//             }
//         };

//         res.json(about);
//     }

// }
