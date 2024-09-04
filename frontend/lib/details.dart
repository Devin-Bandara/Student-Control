//details.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myproject/home.dart';
import 'package:myproject/updateform.dart';

class StudentDetailsScreen extends StatelessWidget {
  final String studentName;

  StudentDetailsScreen({required this.studentName});

  Future<Map<String, dynamic>> fetchStudentDetails() async {
    final response = await http.get(
        Uri.parse('http://localhost:3000/studentdetails?name=$studentName'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate directly to the HomePage and clear the navigation stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 3, 25, 43),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStudentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var details = snapshot.data!;
            return SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildTextField('Student Serial No', details['stusno']),
                  // _buildTextField(
                  //     'Student Company Serial No', details['stucomsno']),
                  _buildTextField('Name', details['stunam']),
                  // _buildTextField('Title Serial No', details['stuttlsno']),
                  _buildTextField('Title', details['title']),
                  _buildTextField('Gender', details['stumof']),
                  _buildTextField('Date of Birth', details['studob']),
                  // _buildTextField('ID Type Serial No', details['stuidtsno']),
                  _buildTextField('ID Type', details['idType']),
                  _buildTextField('ID Number', details['stuidno']),
                  _buildTextField('Is Active', details['stuact']),
                  _buildTextField('Address Line 1', details['stuad1']),
                  _buildTextField('Address Line 2', details['stuad2']),
                  _buildTextField('Address Line 3', details['stuad3']),
                  _buildTextField('Telephone', details['stutel']),
                  _buildTextField('Mobile', details['stumob']),
                  _buildTextField('Fax', details['stufax']),
                  _buildTextField('Email', details['stuemail']),
                  _buildTextField('Created by', details['stuucdnew']),
                  _buildTextField('Entry Date', details['stuentddt']),
                  _buildTextField('Entry Time', details['stuenttime']),
                  _buildTextField('Modified by', details['stuucdame']),
                  _buildTextField('Amend Date', details['stuameddt']),
                  _buildTextField('Amend Time', details['stuametime']),
                  _buildTextField('Registration Date', details['sturegddt']),

                  SizedBox(height: 20), // Space before the button
                  Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to the Update Details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateStudentForm(
                                studentID: details['stusno'],
                              ),
                            ),
                          );
                        },
                        child: Text('Update'),
                      ),
                    ),
                ],
              ),
            ));
          } else {
            return Center(child: Text('No details found.'));
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, dynamic value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: value.toString(),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          readOnly: true,
        ),
      ),
    );
  }
}
