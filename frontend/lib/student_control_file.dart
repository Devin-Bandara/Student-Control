//student_control_file.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myproject/updateform.dart';

class StudentForm extends StatefulWidget {
  const StudentForm({super.key});

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  TextEditingController _searchController = TextEditingController();
  List<String> _allStudentNames = [];
  String? _selectedStudentName;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchStudentNames(); // Fetch student names when the screen is initialized
  // }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentNames() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/students'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allStudentNames =
              data.map((item) => item['stunam'] as String).toList();
        });
      } else {
        print('Failed to load student names');
      }
    } catch (error) {
      print('Error fetching student names: $error');
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool _isMarried = false;
  String? _gender;
  String? _idType;
  String? _studentName;
  String? _telephone;
  String? _mobileNo;
  String? _faxNo;
  String? _email;
  String? _idNumber;
  String? _address1;
  String? _address2;
  String? _address3;
  String? _title;
  DateTime? _dob;

  // Add these variables to handle the titles dropdown
  List<String> _titles = [];
  String? _selectedTitle;
  int? __titleTypeSyssno; // Store the syssno for the selected title
  bool _isLoading = true;

  List<String> _idTypes = [];
  int? _idTypeSyssno; // Store the syssno for the selected ID type
  String? _selectedIDType;
  bool _isLoadingIDTypes = true;

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchStudentNames();
    _fetchTitles();
    _fetchIDTypes();
  }

  Future<void> _fetchTitles() async {
    final response = await http.get(Uri.parse('http://localhost:3000/titles'));
    if (response.statusCode == 200) {
      setState(() {
        _titles = List<String>.from(json.decode(response.body));
        _isLoading = false; // Set loading to false after fetching data
      });
    } else {
      throw Exception('Failed to load titles');
    }
  }

  // Fetch syssno based on selected title
  Future<void> _fetchSyssno(String title) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/get-syssno'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode == 200) {
      setState(() {
        __titleTypeSyssno = jsonDecode(response.body)['syssno'];
      });
    } else {
      // Handle error
      print('Failed to load syssno');
    }
  }

  Future<void> _fetchIDTypes() async {
    final url = 'http://localhost:3000/ids';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _idTypes = List<String>.from(json.decode(response.body));
          _isLoadingIDTypes = false;
        });
      } else {
        throw Exception('Failed to load ID types');
      }
    } catch (error) {
      print('Error fetching ID types: $error');
    }
  }

  // Method to fetch syssno for selected ID type
  Future<void> _fetchIDTypeSyssno(String idtype) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getIDsyssno'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idtype': idtype}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _idTypeSyssno = jsonDecode(response.body)['syssno'];
      });
    } else {
      // Handle error
      print('Failed to load ID syssno');
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime(1969, 1, 1),
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _dob = newDateTime;
              });
            },
          ),
        );
      },
    );
  }

  int? _studentID; // Store the fetched student ID
  Future<void> _fetchStudentID(String studentName) async {
    final response = await http.get(Uri.parse('http://localhost:3000/studentID?name=$studentName'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _studentID = data['studentID'];
      });
    } else {
      // Handle error
      setState(() {
        _studentID = null;
      });
    }
  }

void _navigateToUpdateForm() {

  print("Student ID: $_studentID"); // Print the student ID to the console for debugging
  if (_studentID != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStudentForm(studentID: _studentID!), // Pass studentID as a named parameter
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No student ID found.')),
    );
  }
}

Future<void> _checkStudentExists(String studentName) async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/student/check/$studentName'));

    if (response.statusCode == 200) {
      setState(() {
        _isButtonEnabled = true; // Student exists
      });
    } else {
      setState(() {
        _isButtonEnabled = false; // Student does not exist
      });
    }
  } catch (e) {
    print('Error checking student existence: $e');
    setState(() {
      _isButtonEnabled = false; // Assume false in case of error
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Student',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 25, 43),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(
                context); // This will pop the current page from the navigation stack
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                  children: <Widget>[
                    Expanded(
                    // Student Name Dropdown
                    child:Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _allStudentNames.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selectedName) {
                        _searchController.text = selectedName;
                        _selectedStudentName = selectedName;
                        _fetchStudentID(selectedName); // Fetch student ID
                        _checkStudentExists(selectedName); // Check if the student exists
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Student Name',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: (value) {
                              _studentName = value;
                              _checkStudentExists(value); // Check if the student exists
                            }
                            );
                      },
                    ),
                    ),
                    SizedBox(width: 10), // Add a SizedBox to create a gap
                    ElevatedButton(
              onPressed: _isButtonEnabled ? _navigateToUpdateForm : null,
              child: Text('Search'),
            ),
                      ],
                      
                    ),
                    const SizedBox(height: 16.0),

                    // Titles Dropdown
                    _isLoading
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Title *',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 72, 105, 133)),
                              border: OutlineInputBorder(),
                            ),
                            items: _titles.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedTitle = newValue;
                              });

                              // Fetch the syssno for the selected title
                              if (newValue != null) {
                                await _fetchSyssno(newValue);
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a title';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _title = value;
                            },
                          ),
                    const SizedBox(height: 16.0),

                    Row(
                      children: <Widget>[
                        const Text('Gender: '),
                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'M',
                                groupValue: _gender,
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),
                              const Text('Male'),
                              Radio<String>(
                                value: 'F',
                                groupValue: _gender,
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),
                              const Text('Female'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    CheckboxListTile(
                      value: _isMarried,
                      onChanged: (bool? value) {
                        setState(() {
                          _isMarried = value ?? false;
                        });
                      },
                      title: const Text(
                        'Active',
                        style:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                      ),
                      controlAffinity: ListTileControlAffinity
                          .leading, // Position the checkbox at the start of the row
                      activeColor: Color.fromARGB(255, 72, 105,
                          133), // Set the active color of the checkbox
                    ),
                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date of Birth *',
                          style: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
                        ),
                        TextButton(
                          onPressed: () => _showDatePicker(context),
                          child: Text(
                            _dob == null
                                ? 'Select the date'
                                : '${_dob!.day}-${_dob!.month}-${_dob!.year}',
                            style: TextStyle(
                                color: Color.fromARGB(255, 72, 105, 133)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // ID Types Dropdown
                    _isLoadingIDTypes
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'ID Type *',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 72, 105, 133)),
                              border: OutlineInputBorder(),
                            ),
                            items: _idTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedIDType = newValue;
                              });

                              // Fetch the syssno for the selected ID type
                              if (newValue != null) {
                                await _fetchIDTypeSyssno(newValue);
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an ID type';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _selectedIDType = value;
                            },
                          ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'ID No',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the ID number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _idNumber = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _address1 = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _address2 = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _address3 = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Telephone',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType:
                          TextInputType.phone, // Use the phone input type
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly, // Restrict input to digits only
                      ],
                      validator: (value) {
                        // Regular expression for a basic telephone number (e.g., 10 digits)
                        String pattern = r'^\d{10}$';
                        RegExp regex = RegExp(pattern);
                      },
                      onSaved: (value) {
                        _telephone = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mobile No',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType:
                          TextInputType.phone, // Use the phone input type
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly, // Restrict input to digits only
                      ],
                      validator: (value) {
                        // Regular expression for a basic mobile number (e.g., 10 digits)
                        String pattern = r'^\d{10}$';
                        RegExp regex = RegExp(pattern);
                      },
                      onSaved: (value) {
                        _mobileNo = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Fax No',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType:
                          TextInputType.phone, // Use the phone input type
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly, // Restrict input to digits only
                      ],
                      validator: (value) {
                        // Regular expression for a basic fax number (e.g., 10 digits)
                        String pattern = r'^\d{10}$';
                        RegExp regex = RegExp(pattern);
                      },
                      onSaved: (value) {
                        _faxNo = value;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'E-Mail',
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 72, 105, 133)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType
                          .emailAddress, // Use the email input type
                      validator: (value) {
                        // Regular expression for validating an email address
                        String pattern =
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                        RegExp regex = RegExp(pattern);
                      },
                      onSaved: (value) {
                        _email = value;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _submitForm();
                              // Debugging: Print form data to terminal
                              print('Student Name: $_studentName');
                              print('Telephone: $_telephone');
                              print('Mobile No: $_mobileNo');
                              print('Fax No: $_faxNo');
                              print('E-Mail: $_email');
                              print('ID No: $_idNumber');
                              print('Address 1: $_address1');
                              print('Address 2: $_address2');
                              print('Address 3: $_address3');
                              print(
                                  'Date of Birth: ${_dob?.toLocal().toString()}');
                              print('Gender: $_gender');
                              // print('ID Type syssno: $_selectedIDType');
                              print('Married: $_isMarried');
                              print('Title: $_selectedTitle');
                              print('Title syssno: $__titleTypeSyssno');
                              print('ID type: $_selectedIDType');
                              print('ID type syssno: $_idTypeSyssno');
                            }
                          },
                          child: const Text('INSERT'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _formKey.currentState!.reset();
                          },
                          child: const Text('RESET'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_dob == null) {
      _showErrorSnackBar("Please enter the date of birth");
    }
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'stucomsno': 1, // Assuming a static company number for demonstration
          'stunam': _studentName,
          'stuttlsno':
              __titleTypeSyssno, // Map to appropriate title ID from backend
          'stumof': _gender, // Map gender to single character ('M' or 'F')
          'studob': _dob?.toIso8601String(),
          'stuidtsno':
              _idTypeSyssno, // Map ID type to appropriate ID from backend
          'stuidno': _idNumber,
          'stuact': _isMarried ? 'Y' : 'N', // Convert boolean to 'Y' or 'N'
          'stuad1': _address1, // Assuming you only need one address field
          'stuad2': _address2, // Assuming no additional address fields
          'stuad3': _address3, // Assuming no additional address fields
          'stutel': _telephone,
          'stumob': _mobileNo,
          'stufax': _faxNo,
          'stuemail': _email,
          'stuucdnew': 'admin', // Assuming a static user code for demonstration
          'stuentddt': DateTime.now().toIso8601String().split('T').first,
          'stuenttime':
              DateTime.now().toIso8601String().split('T').last.split('.').first,
          'stuucdame': 'admin', // Assuming a static user code for demonstration
          'stuameddt': DateTime.now().toIso8601String().split('T').first,
          'stuametime':
              DateTime.now().toIso8601String().split('T').last.split('.').first,
          'sturegddt': DateTime.now().toIso8601String().split('T').first,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog(context);
        print('Data inserted successfully');
        _formKey.currentState!.reset();
      } else {
        print('Failed to insert data: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Student data inserted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StudentForm()),
                ); // Reload the current page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
