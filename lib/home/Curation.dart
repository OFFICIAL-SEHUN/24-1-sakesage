import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:sakesage/home/ProductDetail.dart';

class CurationScreen extends StatefulWidget {
  @override
  _CurationScreenState createState() => _CurationScreenState();
}

class _CurationScreenState extends State<CurationScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final DatabaseHelper db = DatabaseHelper();
  List<Map<String, dynamic>> _curatedSake = [];
  bool isLoading = false;

  final List<String> _modern = ["모던", "클래식"];
  final List<String> _flavors = ["깔끔한", "달콤한", "감칠맛", "신맛"];
  final List<String> _bodies = ["풀", "미디엄", "라이트"];

  String? _selectedModern;
  String? _selectedFlavor;
  String? _selectedBody;

  int _currentQuestionIndex = -1; // Initially set to -1

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _resetCuration();
    }
  }

  void _fetchCuratedSake() async {
    if (_selectedModern == null || _selectedFlavor == null || _selectedBody == null) return;
    setState(() {
      isLoading = true;
    });
    await db.connect();
    List<Map<String, dynamic>> curatedSake = await db.getCuratedSake(_selectedModern!, _selectedFlavor!, _selectedBody!);
    setState(() {
      _curatedSake = curatedSake;
      isLoading = false;
    });
    _showSearchResults();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < 2) {
      setState(() {
        _currentQuestionIndex++;
      });
      _controller.reset();
      _controller.forward();
    } else {
      _fetchCuratedSake();
      setState(() {
        _currentQuestionIndex = 3; // This prevents further questions from being displayed
      });
    }
  }

  void _resetCuration() {
    setState(() {
      _selectedModern = null;
      _selectedFlavor = null;
      _selectedBody = null;
      _currentQuestionIndex = -1; // Reset to -1
      _curatedSake = [];
    });
    _controller.reset();
    _controller.forward();
  }

  void _startCuration() {
    setState(() {
      _currentQuestionIndex = 0; // Start with the first question
    });
    _controller.reset();
    _controller.forward();
  }

  List<Widget> _buildOptions(List<String> options, int questionIndex, double fontSize) {
    return options.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              switch (questionIndex) {
                case 0:
                  _selectedModern = option;
                  break;
                case 1:
                  _selectedFlavor = option;
                  break;
                case 2:
                  _selectedBody = option;
                  break;
              }
            });
            _nextQuestion();
          },
          child: Text(option, style: TextStyle(fontSize: fontSize)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
          ),
        ),
      );
    }).toList();
  }

  void _showSearchResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double fontSize = MediaQuery.of(context).size.width * 0.024;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '큐레이션 결과',
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  height: 300, // Adjust the height as needed
                  child: _buildCuratedSakeList(fontSize),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetCuration(); // Reset the curation process when "닫기" is pressed
                  },
                  child: Text('닫기', style: TextStyle(fontSize: fontSize)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double fontSize = MediaQuery.of(context).size.width * 0.024;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('사케사게', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('미리 배우는 사케의 분류 기준!', style: TextStyle(fontSize: fontSize)),
                SizedBox(height: 16),
                Image.asset(
                  'assets/sake_classification.png', // Replace with your image path
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16),
                Text('SSI(일본주 서비스 연구회)의 4-Type 분류법과 \n"카네세 상점" 모던/클래식 및 농담도(풀/미디엄/라이트)를 합쳐서 큐레이션합니다.\n\n'
                    '"모던"은 프레시감이 있는 타입\n"클래식"은 차분한 타입을 말합니다.\n\n'
                    '쿤슈 ☞ 화려함 또는 프루티한 향\n'
                    '소슈 ☞ 가장 경쾌하고 심플한 향미, 깔끔함, 마시기 쉬움\n'
                    '쥰슈 ☞ 농후한 풍미, 감칠맛\n'
                    '쥬쿠슈 ☞ 황색,갈색의 외관, 나무류, 견과류 등 복잡하고 응축된 향\n\n\n\n                                     '
                    '사케 큐레이션을 시작할까요?', style: TextStyle(fontSize: fontSize)),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startCuration();
                      },
                      child: Text('예', style: TextStyle(fontSize: fontSize)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('아니오', style: TextStyle(fontSize: fontSize)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.025;
    List<String> options = [];
    String question = '';
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex <= 2) {
      switch (_currentQuestionIndex) {
        case 0:
          options = _modern;
          question = '모던한 사케를 원하시나요? 클래식한 사케를 원하시나요?';
          break;
        case 1:
          options = _flavors;
          question = '어떤 맛을 원하시나요?';
          break;
        case 2:
          options = _bodies;
          question = '어떤 바디감을 원하시나요?';
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('다시하기', style: TextStyle(color: Colors.white, fontSize: fontSize * 0.8)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _resetCuration,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentQuestionIndex == -1) // Show start button if no question is active
            Center(
              child: ElevatedButton(
                onPressed: _showStartDialog,
                child: Text('사케 큐레이션 시작', style: TextStyle(fontSize: fontSize)),
              ),
            ),
          if (_currentQuestionIndex >= 0) // Show questions if active
            Expanded(
              child: ListView(
                children: [
                  ..._buildPreviousSelections(fontSize),
                  if (_currentQuestionIndex <= 2)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/profile_image.webp'), // Replace with your profile image path
                            radius: 20,
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Text(
                                    question,
                                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (_currentQuestionIndex <= 2)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildOptions(options, _currentQuestionIndex, fontSize),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPreviousSelections(double fontSize) {
    List<Widget> selections = [];
    if (_selectedModern != null) {
      selections.add(_buildChatBubble('모던한 사케를 원하시나요? 클래식한 사케를 원하시나요?', '$_selectedModern 한 사케를 원하시군요!', fontSize));
    }
    if (_selectedFlavor != null) {
      selections.add(_buildChatBubble('어떤 맛을 원하시나요?', '$_selectedFlavor 사케를 찾으시는군요!', fontSize));
    }
    if (_selectedBody != null) {
      selections.add(_buildChatBubble('어떤 바디감을 원하시나요?', '$_selectedBody 한 바디감을 원하시군요!', fontSize));
    }
    return selections;
  }

  Widget _buildChatBubble(String question, String answer, double fontSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures full width
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/profile_image.webp'), // Replace with your profile image path
                radius: 20,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7, // Adjust the width as needed
                    minWidth: MediaQuery.of(context).size.width * 0.5, // Set a minimum width if necessary
                  ),
                  child: Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        question,
                        style: TextStyle(fontSize: fontSize * 0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          Align(
            alignment: Alignment.centerRight,
            child: Card(
              color: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  answer,
                  style: TextStyle(fontSize: fontSize * 0.9, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedSakeList(double fontSize) {
    Set<String> displayedNames = {};
    return _curatedSake.isEmpty
        ? Center(child: Text('사케를 찾지 못했어요...', style: TextStyle(fontSize: fontSize * 0.8)))
        : ListView.builder(
      itemCount: _curatedSake.length,
      itemBuilder: (context, index) {
        var sake = _curatedSake[index];
        if (displayedNames.contains(sake['name'])) {
          return SizedBox.shrink();
        }
        displayedNames.add(sake['name']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  '이런 사케는 어떠세요?',
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(sake['name'],
                  style: TextStyle(fontSize: fontSize * 0.9, fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${sake['flavor']}\n${sake['body']}한 바디감\n${sake['modern']}\n\n사케를 찾았습니다!',
                style: TextStyle(fontSize: fontSize * 0.9),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetail(sake),
                  ),
                );
              },
            ),
            Divider(thickness: 2),
          ],
        );
      },
    );
  }
}
