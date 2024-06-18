import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home/DeliveryScreen.dart';
import 'home/Product_list.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';
import 'login/sign_up_screen.dart';
import 'DatabaseHelper.dart';
import 'login/auth_service.dart';
import 'home/Cart.dart';
import 'home/ProductDetail.dart';
import 'package:sakesage/payment/paymentpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = DatabaseHelper();
  await db.connect();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService _authService = AuthService();

  // Define the router
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
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
        path: '/cart',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CartScreen(userEmail: extra['userEmail']);
        },
      ),
      GoRoute(
        path: '/product_detail',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return ProductDetail(product);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => PaymentPage(),
      ),
    ],
    redirect: (context, state) async {
      final loggedIn = await _authService.isLoggedIn();
      final loggingIn = state.uri.toString() == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';

      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}
