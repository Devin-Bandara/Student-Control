import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myproject/student_control_file.dart';

class UpdateStudentForm extends StatefulWidget {
  final int studentID; // Assuming you pass the student's ID for updating

  UpdateStudentForm({Key? key, required this.studentID}) : super(key: key);

  @override
  _UpdateStudentFormState createState() => _UpdateStudentFormState();
}

class _UpdateStudentFormState extends State<UpdateStudentForm> {
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

  List<String> _titles = [];
  String? _selectedTitle;
  int? _titleTypeSyssno;
  bool _isLoading = true;

  List<String> _idTypes = [];
  int? _idTypeSyssno;
  String? _selectedIDType;
  bool _isLoadingIDTypes = true;

  late TextEditingController _studentNameController;
  late TextEditingController _telephoneController;
  late TextEditingController _mobileNoController;
  late TextEditingController _faxNoController;
  late TextEditingController _emailController;
  late TextEditingController _idNumberController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _address3Controller;

  @override
  void initState() {
    super.initState();
    print("Student ID in update form: ${widget.studentID}");
    _initializeControllers();
    _fetchStudentData();
    _fetchTitles();
    _fetchIDTypes();
  }

  void _initializeControllers() {
    _studentNameController = TextEditingController();
    _telephoneController = TextEditingController();
    _mobileNoController = TextEditingController();
    _faxNoController = TextEditingController();
    _emailController = TextEditingController();
    _idNumberController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _address3Controller = TextEditingController();
  }

  Future<void> _fetchStudentData() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/studentdetailsbyID?id=${widget.studentID}'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final details = json.decode(response.body);
        print('Student details: $details');
        setState(() {
          _studentName = details['stunam'];
          _telephone = details['stutel'];
          _mobileNo = details['stumob'];
          _faxNo = details['stufax'];
          _email = details['stuemail'];
          _idNumber = details['stuidno'];
          _address1 = details['stuad1'];
          _address2 = details['stuad2'];
          _address3 = details['stuad3'];
          _gender = details['stumof'];
          _isMarried = details['stuact'] == 'Y';
          _title = details['title'];
          _selectedTitle = details['title'];
          _dob = DateTime.parse(details['studob']);
          _idType = details['idType'];
          _selectedIDType = details['idType'];

          // Set the values in the controllers
          _studentNameController.text = _studentName ?? '';
          _telephoneController.text = _telephone ?? '';
          _mobileNoController.text = _mobileNo ?? '';
          _faxNoController.text = _faxNo ?? '';
          _emailController.text = _email ?? '';
          _idNumberController.text = _idNumber ?? '';
          _address1Controller.text = _address1 ?? '';
          _address2Controller.text = _address2 ?? '';
          _address3Controller.text = _address3 ?? '';
        });
      } else {
        print('Failed to load student data');
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  @override
  void dispose() {
    // Properly dispose controllers to free up resources
    _studentNameController.dispose();
    _telephoneController.dispose();
    _mobileNoController.dispose();
    _faxNoController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();
    super.dispose();
  }

  Future<void> _fetchTitles() async {
    final response = await http.get(Uri.parse('http://localhost:3000/titles'));
    if (response.statusCode == 200) {
      setState(() {
        _titles = List<String>.from(json.decode(response.body));
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load titles');
    }
  }

  Future<void> _fetchSyssno(String title) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/get-syssno'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _titleTypeSyssno = jsonDecode(response.body)['syssno'];
      });
    } else {
      print('Failed to load syssno');
    }
  }

  Future<void> _fetchIDTypes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/ids'));
    if (response.statusCode == 200) {
      setState(() {
        _idTypes = List<String>.from(json.decode(response.body));
        _isLoadingIDTypes = false;
      });
    } else {
      throw Exception('Failed to load ID types');
    }
  }

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
      print('Failed to load ID syssno');
    }
  }

  Future<void> _updateStudent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final studentId = widget.studentID; // Assuming you have this value

      final response = await http.patch(
        Uri.parse('http://localhost:3000/student/update/$studentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'stunam': _studentName,
          'stutel': _telephone,
          'stumob': _mobileNo,
          'stufax': _faxNo,
          'stuemail': _email,
          'stuidno': _idNumber,
          'stuad1': _address1,
          'stuad2': _address2,
          'stuad3': _address3,
          'stumof': _gender,
          'stuact': _isMarried ? 'Y' : 'N',
          'title': _selectedTitle,
          'studob': _dob?.toIso8601String(),
          'idType': _idType,
          'titleSyssno': _titleTypeSyssno, // Include fetched syssno
          'idTypeSyssno': _idTypeSyssno, // Include fetched syssno
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessDialogtoUpdate( context);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Student data updated successfully')));
      } else {
        print('Failed to update student');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Student',
          style: TextStyle(color: Colors.white),),
          backgroundColor: const Color.fromARGB(255, 3, 25, 43),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(
                context); 
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
                      TextFormField(
                        controller:
                            _studentNameController, // Use the controller
                        decoration: const InputDecoration(
                          labelText: 'Student Name *',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the student name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _studentName = value;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Titles Dropdown
                      _isLoading
                          ? CircularProgressIndicator()
                          : DropdownButtonFormField<String>(
                              value: _selectedTitle, // Set initial value
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
                          'Married ',
                          style: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                              value: _selectedIDType, // Set initial value
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
                        controller: _idNumberController,
                        decoration: const InputDecoration(
                          labelText: 'ID No',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _address1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _address2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _address3Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _telephoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telephone',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _mobileNoController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile No',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _faxNoController,
                        decoration: const InputDecoration(
                          labelText: 'Fax No',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-Mail',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 72, 105, 133)),
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
                                _updateStudent();
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
                                print('Title syssno: $_titleTypeSyssno');
                                print('ID type: $_selectedIDType');
                                print('ID type syssno: $_idTypeSyssno');
                              }
                            },
                            child: const Text('Update Student'),
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
                              _deleteStudent();
                            },
                            child: const Text('Delete Student'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .grey, // Optional: to make the delete button stand out
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
        ));
  }

  void _deleteStudent() async {
    final studentId = widget.studentID; // Assuming you have this value

    // Replace with your actual backend API URL
    final url = Uri.parse('http://localhost:3000/student/delete/$studentId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Handle successful deletion
        print('Student deleted successfully');
        _showSuccessDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student deleted successfully')),
        );
      } else if (response.statusCode == 404) {
        print('Student not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student not found')),
        );
      } else {
        print('Failed to delete student');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete student')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
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
              _titleTypeSyssno, // Map to appropriate title ID from backend
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Student deleted successfully!'),
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

  void _showSuccessDialogtoUpdate(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Student updated successfully!'),
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
