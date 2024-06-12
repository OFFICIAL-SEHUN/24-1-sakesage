import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakesage/home/DeliveryScreen.dart';
import 'package:sakesage/home/Product_list.dart';
import 'package:sakesage/home/home_screen.dart';
import 'package:sakesage/login/login_screen.dart';
import 'package:sakesage/login/sign_up_screen.dart';
import 'package:sakesage/DatabaseHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = DatabaseHelper();
  await db.connect();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Define the router
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ProductListScreen(
            storeName: extra['storeName'],
            storeAddress: extra['storeAddress'],
          );
        },
      ),
      GoRoute(
        path: '/delivery',
        builder: (context, state) => DeliveryScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue, // 기본 버튼 색상 설정
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}
