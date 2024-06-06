import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliveryScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchUsers();
  }
  fetchUsers() async {
    try{
      var db = DatabaseHelper();
      List<Map<String, dynamic>> fetchedUsers = await db.getUsers();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
    print('Error fetching users: $e');
    setState(() {
    isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Screen'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]['no']),
            subtitle: Text(users[index]['name']),
          );
        },
      ),
    );
  }
}