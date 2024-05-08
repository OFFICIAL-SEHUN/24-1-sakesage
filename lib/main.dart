import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakesage/home/Product_list.dart';
import 'package:sakesage/home/home_screen.dart';
import 'package:sakesage/login/login_screen.dart';
import 'package:sakesage/login/sign_up_screen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen()
      //Product_list_Screen(),
      //HomeScreen(),
      //SignUpScreen(),
      //LoginScreen(),
    );
  }
}

