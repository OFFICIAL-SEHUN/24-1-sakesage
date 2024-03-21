import 'package:flutter/material.dart';
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
          IconButton(
              onPressed: (){},
              icon: const Icon(
                  Icons.search,
              ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _menuIndex,
        children: [
          HomeWidget(),
          Container(color: Colors.white,),
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
          NavigationDestination(icon: Icon(Icons.person),
              label: "마이페이지",
          ),
        ],
      ),
    );
  }
}
