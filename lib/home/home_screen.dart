import 'package:flutter/material.dart';
import 'package:sakesage/home/DeliveryScreen.dart';
import 'package:sakesage/home/GoogleMap.dart';
import 'package:sakesage/home/Product_list.dart';
import 'package:sakesage/home/widgets/home_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("사케사게"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (){},
              icon: const Icon(
                  Icons.logout
              ),
          ),
          if (_menuIndex == 0)
            IconButton(
                onPressed: (){},
                icon: const Icon(
                    Icons.search,
                ),
            )
        ],
      ),
      body: IndexedStack(
        index: _menuIndex,
        children: [
          HomeWidget(),
          GoogleMapScreen(),
          DeliveryScreen(),
          Product_list_Screen(), //임시
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _menuIndex,
        onDestinationSelected: (idx){
          setState(() {
            _menuIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.store_outlined),
              label: "홈",
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            label: "픽업하기",
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bike_outlined),
            label: "배달받기",
          ),
          NavigationDestination(icon: Icon(Icons.person),
            label: "마이페이지(임시로 제품 리스트)",
          ),
        ],
      ),
    );
  }
}
