
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextContoller = TextEditingController();
  TextEditingController pwdTextContoller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/sakesage.png"),
              const SizedBox(
                height: 30,
              ),
              Form(
                child: Column(
                  children: [
                    Container(
                      height: 80, // 이메일 입력칸의 높이 조정
                      child: TextFormField(
                        controller: emailTextContoller,
                        style: TextStyle(fontSize: 18), // 폰트 크기 조정
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey), // underline color
                          ),
                          labelText: "이메일",
                          hintText: "ex) abc@sakesage.co.kr",
                        ),
                        validator: (value){
                          if (value == null || value.isEmpty){
                            return "이메일 주소를 입력하세요.";
                          }
                          return null;
                        },
                      ),
                    ),
                    //const SizedBox(height: 24,),
                    Container(
                      height : 80,
                      child: TextFormField(
                        controller: pwdTextContoller,
                        style: TextStyle(fontSize: 18), // 폰트 크기 조정
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey), // underline color
                          ),
                          labelText: "비밀번호",
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value){
                          if (value == null || value.isEmpty){
                            return "비밀번호를 입력하세요.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: MaterialButton(
                  onPressed: (){},
                  height: 48,
                  minWidth: double.infinity,
                  color: Colors.blueAccent,
                  child: const Text("로그인",style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  ),
                ),
              ),
              TextButton(
                onPressed: (){},
                child: const Text("계정이 없나요? 회원가입"),
              ),
              const Divider(),
              Image.asset("assets/naver_login_icon.png",
                width: 60,
                height: 60),

              Image.asset("assets/google_login_icon.png",
                width: 60,
                height: 60,)
            ],
          ),
        ),
      ),
    );
  }

}
