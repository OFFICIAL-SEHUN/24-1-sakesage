import 'package:flutter/material.dart';
import 'package:sakesage/home/Cart.dart';
import 'OrderHistoryPage.dart'; // OrderHistoryPage를 임포트합니다.
import 'package:sakesage/login/auth_service.dart'; // AuthService를 임포트합니다.

class MyPageWidget extends StatelessWidget {
  const MyPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final size = MediaQuery.of(context).size;
    final double fontSize = size.width * 0.035; // 화면 너비의 4%를 텍스트 크기로 설정
    final double iconSize = size.width * 0.04; // 화면 너비의 4%를 아이콘 크기로 설정
    final double paddingSize = size.width * 0.04; // 화면 너비의 4%를 패딩 크기로 설정
    final double tileHeight = size.height * 0.055; // 화면 높이의 6%를 타일 높이로 설정

    Future<void> _navigateToCart(BuildContext context) async {
      String? userEmail = await _authService.getUserEmail(); // 사용자 이메일 가져오기
      if (userEmail != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartScreen(userEmail: userEmail), // 사용자 이메일 전달
          ),
        );
      } else {
        // 이메일이 없을 경우 로그인 화면으로 이동 또는 에러 처리
        // 예: Navigator.pushNamed(context, '/login');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지', style: TextStyle(fontSize: fontSize)),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Column(
          children: [
            _buildListTile(
              context,
              icon: Icons.history,
              title: '주문 내역',
              fontSize: fontSize,
              iconSize: iconSize,
              tileHeight: tileHeight,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                );
              },
            ),
            _buildListTile(
              context,
              icon: Icons.shopping_cart,
              title: '장바구니',
              fontSize: fontSize,
              iconSize: iconSize,
              tileHeight: tileHeight,
              onTap: () => _navigateToCart(context),
            ),
            _buildListTile(
              context,
              icon: Icons.person,
              title: '개인정보 관리',
              fontSize: fontSize,
              iconSize: iconSize,
              tileHeight: tileHeight,
              onTap: () {
                // 개인정보 관리 페이지로 이동하는 코드 작성
              },
            ),
            _buildListTile(
              context,
              icon: Icons.rate_review,
              title: '리뷰 및 평점',
              fontSize: fontSize,
              iconSize: iconSize,
              tileHeight: tileHeight,
              onTap: () {
                // 리뷰 및 평점 페이지로 이동하는 코드 작성
              },
            ),
            _buildEmptyTile(tileHeight), // 빈 타일 추가
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
        required String title,
        required double fontSize,
        required double iconSize,
        required double tileHeight,
        required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: tileHeight,
        child: ListTile(
          leading: Icon(icon, size: iconSize),
          title: Text(title, style: TextStyle(fontSize: fontSize)),
          trailing: Icon(Icons.arrow_forward_ios, size: iconSize), // 오른쪽에 '>' 아이콘 추가
          onTap: onTap,
          tileColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTile(double tileHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: tileHeight*5,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
