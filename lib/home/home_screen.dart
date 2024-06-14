import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'package:sakesage/home/GoogleMap.dart';
import 'package:sakesage/home/widgets/home_widget.dart';
import 'package:sakesage/home/ProductDetail.dart';
import 'package:sakesage/home/DeliveryScreen.dart';
import 'package:sakesage/home/Curation.dart'; // CurationScreen import 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
    } else {
      _search(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) async {
    await db.connect();
    List<Map<String, dynamic>> results = await db.searchData(query);
    setState(() {
      _searchResults = results;
    });
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(child: Text('No results found'))
        : ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        var item = _searchResults[index];
        return ListTile(
          title: Text(item['title']),
          subtitle: Text('Price: ${item['price']}'),
          trailing: item['image_url'] != null
              ? Image.network(
            item['image_url'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
              : Icon(Icons.image, size: 50, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetail(item),
              ),
            );
          },
        );
      },
    );
  }

  void navigateToPage(int index) {
    setState(() {
      _menuIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        )
            : const Text("사케사게"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchResults.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: IndexedStack(
        index: _menuIndex,
        children: _isSearching
            ? [_buildSearchResults(), Container(), Container(), Container()]
            : [
          HomeWidget(navigateToPage: navigateToPage),
          GoogleMapScreen(),
          DeliveryScreen(),
          CurationScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _menuIndex,
        onDestinationSelected: (idx) {
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
            icon: Icon(Icons.delivery_dining_outlined),
            label: "배달받기",
          ),
          NavigationDestination(
            icon: Icon(Icons.corporate_fare),
            label: "큐레이션",
          ),
        ],
      ),
    );
  }
}
