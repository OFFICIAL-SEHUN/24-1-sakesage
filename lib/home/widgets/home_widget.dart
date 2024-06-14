import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:sakesage/DatabaseHelper.dart';

class HomeWidget extends StatefulWidget {
  final Function(int) navigateToPage;

  const HomeWidget({super.key, required this.navigateToPage});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  PageController pageController = PageController();
  PageController youtubePageController = PageController();
  int bannerIndex = 0;
  int youtubeIndex = 0;

  final List<String> cardTexts = [
    "픽업하기", "배달받기", "사케 큐레이션"
  ];
  final List<IconData> cardIcons = [
    Icons.store, Icons.delivery_dining, Icons.wine_bar
  ];
  final List<String> discountImages = [
    "assets/banner_sake1.png", "assets/banner_sake2.png", "assets/banner_sake3.png", "assets/banner_sake4.png"
  ];
  List<Map<String, dynamic>> popularItems = [];
  bool isLoading = true;

  final DatabaseHelper db = DatabaseHelper();

  final List<String> youtubeVideoIds = [
    'oboGO0705CM',
    'FtemVq2qyco',
  ];

  @override
  void initState() {
    super.initState();
    fetchPopularItems();
  }

  @override
  void dispose() {
    pageController.dispose();
    youtubePageController.dispose();
    super.dispose();
  }

  Future<void> fetchPopularItems() async {
    List<Map<String, dynamic>> fetchedData = await db.getData();
    setState(() {
      popularItems = fetchedData.length > 3 ? fetchedData.sublist(2, 4) : [];
      isLoading = false;
    });
  }

  void navigateToPage(BuildContext context, String text) {
    if (text == "픽업하기") {
      widget.navigateToPage(1);
    } else if (text == "배달받기") {
      widget.navigateToPage(2);
    } else if (text == "사케 큐레이션") {
      widget.navigateToPage(3);
    }
  }

  Widget buildCard(String text, IconData icon, double iconSize, double fontSize) {
    return GestureDetector(
      onTap: () => navigateToPage(context, text),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Colors.blue,
            ),
            SizedBox(height: 8.0),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  YoutubePlayerController createYoutubeController(String videoId) {
    return YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  Widget buildYoutubePlayer(String videoId, double width, double height) {
    return Center(
      child: Container(
        width: width,
        height: height,
        child: YoutubePlayer(
          controller: createYoutubeController(videoId),
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          onReady: () {
            // Add any logic you want when the video is ready
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final bannerHeight = screenHeight * 0.14;
        final iconSize = screenWidth * 0.1;
        final fontSize = screenWidth * 0.03;
        final gridItemHeight = screenHeight * 0.25;
        final gridItemWidth = screenWidth * 0.9;
        final youtubePlayerWidth = screenWidth * 0.7;
        final youtubePlayerHeight = screenHeight * 0.3;

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: bannerHeight,
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
                          "어떤 것을 찾으시나요?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize * 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Container(
                      height: gridItemHeight * 0.6,
                      width: gridItemWidth,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 150,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: cardTexts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildCard(cardTexts[index], cardIcons[index], iconSize, fontSize);
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
                        fontSize: fontSize * 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: screenHeight * 0.12,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: discountImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: screenWidth * 0.23,
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
                      "사케에 대해서!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: youtubePlayerHeight * 1.34,
                          child: PageView.builder(
                            controller: youtubePageController,
                            itemCount: youtubeVideoIds.length,
                            itemBuilder: (context, index) {
                              return buildYoutubePlayer(youtubeVideoIds[index], youtubePlayerWidth, youtubePlayerHeight);
                            },
                            onPageChanged: (idx) {
                              setState(() {
                                youtubeIndex = idx;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              if (youtubeIndex > 0) {
                                youtubePageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ),
                        Positioned(
                          right: 16,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              if (youtubeIndex < youtubeVideoIds.length - 1) {
                                youtubePageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: DotsIndicator(
                            dotsCount: youtubeVideoIds.length,
                            position: youtubeIndex,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 추가된 이미지 컨테이너
              Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.white,
                child: Image.asset(
                  "assets/caution.gif", // 여기에 원하는 이미지 경로를 설정하세요
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
