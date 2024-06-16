import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FlutterWebviewPlugin _webviewPlugin = FlutterWebviewPlugin();
  final String userId = 'aaa@gmail.com'; // 실제 사용자 ID로 교체하세요

  @override
  void initState() {
    super.initState();
    _webviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains('/payments/complete')) {
        // 결제 완료 처리
        _handlePaymentComplete();
      }
    });
  }

  void _handlePaymentComplete() {
    // 결제 완료 후 처리 로직
    // 예: 서버에 결제 완료 알림 전송, 결제 결과 확인 등
    Navigator.pop(context); // 결제 완료 후 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: 'http://43.201.174.131:8080/payments/checkout?user_id=$userId',
      appBar: AppBar(
        title: Text('결제하기'),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _webviewPlugin.dispose();
    super.dispose();
  }
}
