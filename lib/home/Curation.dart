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

  final List<String> _recipients = ["친구", "가족", "연인", "동료"];
  final List<String> _flavors = ["짠맛", "감칠맛", "달콤함", "쓴맛", "신맛"];
  final List<String> _bodies = ["풀", "미디엄", "라이트"];
  final List<String> _aromas = ["과일 향", "스파이시 향", "나무 향", "꽃 향", "허브 향"];

  String? _selectedRecipient;
  String? _selectedFlavor;
  String? _selectedBody;
  String? _selectedAroma;

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
    if (_selectedRecipient == null || _selectedFlavor == null || _selectedBody == null || _selectedAroma == null) return;
    setState(() {
      isLoading = true;
    });
    await db.connect();
    List<Map<String, dynamic>> curatedSake = await db.getCuratedSake(_selectedRecipient!, _selectedFlavor!, _selectedBody!, _selectedAroma!);
    setState(() {
      _curatedSake = curatedSake;
      isLoading = false;
    });
    _showSearchResults();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < 3) {
      setState(() {
        _currentQuestionIndex++;
      });
      _controller.reset();
      _controller.forward();
    } else {
      _fetchCuratedSake();
      setState(() {
        _currentQuestionIndex = 4; // This prevents further questions from being displayed
      });
    }
  }

  void _resetCuration() {
    setState(() {
      _selectedRecipient = null;
      _selectedFlavor = null;
      _selectedBody = null;
      _selectedAroma = null;
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

  List<Widget> _buildOptions(List<String> options, int questionIndex) {
    return options.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              switch (questionIndex) {
                case 0:
                  _selectedRecipient = option;
                  break;
                case 1:
                  _selectedFlavor = option;
                  break;
                case 2:
                  _selectedBody = option;
                  break;
                case 3:
                  _selectedAroma = option;
                  break;
              }
            });
            _nextQuestion();
          },
          child: Text(option),
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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '큐레이션 결과',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  height: 300, // Adjust the height as needed
                  child: _buildCuratedSakeList(),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('닫기'),
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
        return AlertDialog(
          title: Text('사케 큐레이션 시작'),
          content: Text('사케 큐레이션을 시작하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startCuration();
              },
              child: Text('예'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('아니오'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = [];
    String question = '';
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex <= 3) {
      switch (_currentQuestionIndex) {
        case 0:
          options = _recipients;
          question = '누구에게 선물할 사케인가요?';
          break;
        case 1:
          options = _flavors;
          question = '어떤 맛을 원하시나요?';
          break;
        case 2:
          options = _bodies;
          question = '어떤 바디감을 원하시나요?';
          break;
        case 3:
          options = _aromas;
          question = '어떤 향을 원하시나요?';
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('다시하기', style: TextStyle(color: Colors.white)),
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
                child: Text('사케 큐레이션 시작'),
              ),
            ),
          if (_currentQuestionIndex >= 0) // Show questions if active
            Expanded(
              child: ListView(
                children: [
                  ..._buildPreviousSelections(),
                  if (_currentQuestionIndex <= 3)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          question,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex <= 3)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildOptions(options, _currentQuestionIndex),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPreviousSelections() {
    List<Widget> selections = [];
    if (_selectedRecipient != null) {
      selections.add(_buildChatBubble('누구에게 선물할 사케인가요?', '$_selectedRecipient에게 선물하고싶으시군요!'));
    }
    if (_selectedFlavor != null) {
      selections.add(_buildChatBubble('어떤 맛을 원하시나요?', '$_selectedFlavor 을 원하시군요!'));
    }
    if (_selectedBody != null) {
      selections.add(_buildChatBubble('어떤 바디감을 원하시나요?', '$_selectedBody 바디감을 원하시군요!'));
    }
    if (_selectedAroma != null) {
      selections.add(_buildChatBubble('어떤 향을 원하시나요?', '$_selectedAroma 향을 원하시군요!'));
    }
    return selections;
  }

  Widget _buildChatBubble(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures full width
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  question,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
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
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedSakeList() {
    Set<String> displayedNames = {};
    return _curatedSake.isEmpty
        ? Center(child: Text('사케를 찾지 못했어요...', style: TextStyle(fontSize: 15)))
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(sake['name'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${sake['flavor']}\n${sake['body']}한 바디감\n${sake['aroma']}\n\n사케를 찾았습니다!',
                style: TextStyle(fontSize: 18),
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
