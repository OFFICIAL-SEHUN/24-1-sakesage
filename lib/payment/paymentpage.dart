import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController _controller;
  String paymentUrl = '';
  String? accessToken;

  @override
  void initState() {
    super.initState();
    getAccessToken().then((token) {
      setState(() {
        accessToken = token;
      });
      initiatePayment();
    }).catchError((error) {
      print('Failed to get access token: $error');
    });
  }

  Future<String> getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://api.bootpay.co.kr/v2/request/token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'application_id': '66700a6b9d67b097451b01d4',
        'private_key': 'd5GW4TKZs1I/lp0BusNxj7V/xa2++oNxjD14mlar8rM=',
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('Response data: $jsonResponse');
      if (jsonResponse['access_token'] != null) {
        return jsonResponse['access_token'];
      } else {
        throw Exception('Failed to obtain access token: Invalid response structure');
      }
    } else {
      throw Exception('Failed to obtain access token: ${response.body}');
    }
  }

  Future<void> initiatePayment() async {
    if (accessToken == null) {
      print('Access token is not available');
      return;
    }

    final response = await http.post(
      Uri.parse('https://api.bootpay.co.kr/v2/request/payment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'price': 1000,
        'order_id': 'ORDER_ID',
        'name': 'Test Payment',
        'pg': 'danal',
        'method': 'card',
        'user_info': {
          'username': 'user',
          'email': 'user@example.com',
          'phone': '010-0000-0000'
        },
        'sandbox': true // 샌드박스 모드 활성화
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data']['payment_url'] != null) {
        setState(() {
          paymentUrl = jsonResponse['data']['payment_url'];
        });
      } else {
        print('Failed to initiate payment: Invalid response structure');
      }
    } else {
      print('Failed to initiate payment: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: paymentUrl.isEmpty
          ? Center(child: CircularProgressIndicator())
          : WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(paymentUrl)),
      ),
    );
  }
}
