

import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("회원가입"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              const Text("사케사게\n가입을 환영합니다",
                style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 42,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "이메일",
                        ),
                        validator: (value){
                          if (value == null || value.isEmpty){
                            return "이메일 주소를 입력하세요.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        controller: pwdTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "비밀번호",
                        ),
                      ),
                    ],
                  ),
              ),
              SizedBox(
                height: 24,
              ),
              MaterialButton(
                onPressed: (){},
                height: 48,
                minWidth: double.infinity,
                color: Colors.lightBlue,
                child: Text("회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
