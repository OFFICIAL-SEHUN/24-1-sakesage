import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  PageController pageController = PageController();
  int bannerIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 140,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: PageView(
              controller: pageController,
              children: [
                Container(
                  padding : EdgeInsets.all(8),
                  child: Image.asset("assets/sakesage.png"),
                ),
                Container(
                  padding : EdgeInsets.all(8),
                  child: Image.asset("assets/banner_sake1.png"),
                ),
                Container(
                  padding : EdgeInsets.all(8),
                  child: Image.asset("assets/banner_sake2.png"),
                ),
              ],
              onPageChanged: (idx){
                setState(() {
                  bannerIndex = idx;
                });
              },
            ),
          ),
          DotsIndicator(
            dotsCount: 3,
            position: bannerIndex,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("카테고리",style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),),
                    TextButton(
                      onPressed: (){},
                      child: Text("더보기"))
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                //TODO: 카테고리 목록을 받아오는 위젯구현
                Container(
                  height: 400,
                  color:Colors.black,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
