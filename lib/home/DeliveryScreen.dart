import 'package:flutter/material.dart';
import 'package:sakesage/DatabaseHelper.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final DatabaseHelper db = DatabaseHelper();
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;
  String _selectedSort = 'Price';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    List<Map<String, dynamic>> fetchedData = await db.getData();
    setState(() {
      data = fetchedData;
      isLoading = false;
    });
    sortData();
  }

  void sortData() {
    setState(() {
      if (_selectedSort == 'Price') {
        data.sort((a, b) => double.parse(a['price']).compareTo(double.parse(b['price'])));
      } else if (_selectedSort == 'Name') {
        data.sort((a, b) => a['title'].compareTo(b['title']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _selectedSort,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedSort = newValue;
                        sortData();
                      });
                    }
                  },
                  items: <String>['Price', 'Name']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150.0,
                          width: double.infinity,
                          child: data[index]['image_url'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: Image.network(
                              data[index]['image_url'],
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index]['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text('${data[index]['price']}'),
                              Text('${data[index]['site_name']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
