import 'dart:io';
import 'package:application_dr/view/result_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRViewExample extends StatefulWidget {
  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Image(image: AssetImage('assets/images/background.png')),
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40,bottom: 40),
                  child: Container(
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:Colors.pink[300],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Text('Scan a code',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanned) {
        setState(() {
          isScanned = true; // لمنع القراءة المتكررة
        });

        _navigateToResultPage(scanData.code.toString());
      }
    });
  }

  void _navigateToResultPage(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(id: code),
      ),
    ).then((_) {
      // عند الرجوع من صفحة الريزالت
      setState(() {
        isScanned = false; // إعادة تمكين القراءة
      });
      controller?.resumeCamera(); // إعادة تشغيل الكاميرا
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
