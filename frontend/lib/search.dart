//search.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myproject/details.dart';
import 'package:myproject/home.dart';

class StudentSearchScreen extends StatefulWidget {
  @override
  _StudentSearchScreenState createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _allStudentNames = [];
  String? _selectedStudentName;

  @override
  void initState() {
    super.initState();
    fetchStudentNames(); // Fetch student names when the screen is initialized
  }

  Future<void> fetchStudentNames() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/students'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allStudentNames = data.map((item) => item['stunam'] as String).toList();
        });
      } else {
        print('Failed to load student names');
      }
    } catch (error) {
      print('Error fetching student names: $error');
    }
  }

  void _navigateToDetailsScreen() {
    if (_selectedStudentName != null &&_selectedStudentName!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDetailsScreen(studentName: _selectedStudentName!),
        ),
      );
    } else {
      // Optionally show a message if no student is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a student name before searching.')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Student Names',
          style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false, 
            );
          },
        ),
          backgroundColor: const Color.fromARGB(255, 3, 25, 43),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _allStudentNames.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selectedName) {
                _searchController.text = selectedName;
                _selectedStudentName = selectedName;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Search by Name',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToDetailsScreen,
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
