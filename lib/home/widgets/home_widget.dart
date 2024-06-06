import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'dart:convert'; // 이미지 데이터 변환에 필요

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  PageController pageController = PageController();
  int bannerIndex = 0;

  final List<String> categoryTexts = [
    "같이 마시기 좋은", "최고 인기 사케", "선물하기 좋은", "할인 상품"
  ];
  final List<String> categoryImages = [
    "assets/category_image_1.jpg", "assets/category_image_2.jpg",
    "assets/category_image_3.jpg", "assets/category_image_4.jpg"
  ];
  final List<String> discountImages = [
    "assets/banner_sake1.png", "assets/banner_sake2.png", "assets/banner_sake3.png"
  ];
  List<Map<String, dynamic>> popularItems = [];
  bool isLoading = true;

  final DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchPopularItems();
  }

  Future<void> fetchPopularItems() async {
    List<Map<String, dynamic>> fetchedData = await db.getData();
    setState(() {
      popularItems = fetchedData.length > 3 ? fetchedData.sublist(2,4):[];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

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
                  padding: EdgeInsets.all(8),
                  child: Image.asset("assets/sakesage.png"),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Image.asset("assets/banner_sake1.png"),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Image.asset("assets/banner_sake2.png"),
                ),
              ],
              onPageChanged: (idx) {
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
                    Text(
                      "카테고리",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("더보기"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 90,
                  color: Colors.white10,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: categoryTexts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              categoryImages[index],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            categoryTexts[index],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "오늘의 특가",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: discountImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        color: Colors.white,
                        child: Center(
                          child: Image.asset(
                            discountImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "최고 인기 상품",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: popularItems[index]['image_url'] != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                                child: Image.network(
                                  popularItems[index]['image_url'],
                                  width: double.infinity,
                                  height: 150.0,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                height: 150.0,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              popularItems[index]['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('₩${popularItems[index]['price']}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
