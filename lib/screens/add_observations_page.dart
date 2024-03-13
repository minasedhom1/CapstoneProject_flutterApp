import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/Observation.dart';
import 'package:flutter_application_1/model/global_vars.dart';
import '../model/parameter.dart';
import 'package:http/http.dart' as http;

class AddObservationPage extends StatefulWidget {
  final dynamic project;
  const AddObservationPage({Key? key, required this.project}) : super(key: key);

  @override
  _AddObservationPageState createState() => _AddObservationPageState();
}

class _AddObservationPageState extends State<AddObservationPage> {
  // value set to false
  late List<bool> _isCheckedList;
  List<String> _selectedOptions = [];
  List<Parameter> updatedParametersList = [];
  bool hasChecklist = false;

  @override
  void initState() {
    _isCheckedList = List.filled(10, false);
    updatedParametersList = widget.project.parameters;
    for (final parameter in updatedParametersList) {
      if (parameter.observationType == 'Checklist') {
        hasChecklist = true;
        break;
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Observation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.project.parameters.length,
              itemBuilder: (context, index) {
                final parameter = widget.project.parameters[index];
                return _buildFormField(parameter);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 98, 175, 114), // Background color
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                minimumSize:
                    Size(300, 48), // Set minimum button width and height
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Button border radius
                ),
              ),
              onPressed: () async {
                if (hasChecklist && _selectedOptions.isEmpty) {
                  // Display snackbar with error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select from checklist first.'),
                    ),
                  );
                } else {
                  try {
                    // Create a new list to store JSON objects
                    List<Map<String, dynamic>> parameterJsonList = [];
                    // Iterate over the list of parameters and convert them to JSON format
                    for (final parameter in updatedParametersList) {
                      parameterJsonList.add(parameter.toJson());
                    }

                    String url =
                        'https://capstone-citizen-science.wl.r.appspot.com/projects/${Globals.projectCode}/observations/${Globals.studentId}';
                    // Create a new map with the desired structure, including the list of JSON objects
                    Map<String, dynamic> requestBody = {
                      "observation_parameters": parameterJsonList,
                    };

                    // Encode the new map to JSON format
                    String requestBodyJson = jsonEncode(requestBody);
                    print('Body: $requestBodyJson');
                    // Make the POST request
                    final response = await http.post(
                      Uri.parse(url),
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                      },
                      body: requestBodyJson,
                    );

                    // Check if request was successful
                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      // Display snackbar with success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Observation added successfully'),
                        ),
                      );

                      Observation observation =
                          Observation.fromJson(json.decode(response.body));
                      //get options for new observation
                      for (int i = 0; i < updatedParametersList.length; i++) {
                        observation.observationParams?[i].options =
                            updatedParametersList[i].options;
                      }
                      // Navigate back after a delay
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.pop(context, observation);
                        //Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    } else {
                      // Display snackbar with error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to add observation: ${response.body}'),
                        ),
                      );
                    }
                  } catch (e) {
                    // Handle any errors that occur during the request
                    print('Error: $e');
                    // Display snackbar with error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('An error occurred: $e'),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Add Observation',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(Parameter parameter) {
    final String observationType = parameter.observationType;
    switch (observationType) {
      case 'Numerical':
        return _buildNumericalFormField(parameter);
      case 'Checklist':
        return _buildCheckboxFormField(parameter);
      case 'Dropdown':
        return _buildDropdownFormField(parameter);
      case 'Text':
        return _buildTextFormField(parameter);
      // Add more cases for other observation types if needed
      default:
        return Container(); // Return an empty container if observation type is not recognized
    }
  }

  Widget _buildNumericalFormField(Parameter parameter) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.prompt,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 9),
          TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                parameter.value = value; // Update parameter value
              },
              onEditingComplete: () {
                // Add parameter to the global list when editing is complete
                if (!updatedParametersList.contains(parameter)) {
                  updatedParametersList.add(parameter);
                }
              }),
        ],
      ),
    );
  }

  Widget _buildDropdownFormField(Parameter parameter) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.prompt,
            style: TextStyle(fontSize: 16),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: parameter.options!.first, // Set the initial value
            items: parameter.options!.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              // Handle dropdown value changes here
              setState(() {
                parameter.value = value ?? parameter.options!.first;
                if (!updatedParametersList.contains(parameter)) {
                  updatedParametersList.add(parameter);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(Parameter parameter) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.prompt,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 9),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              parameter.value = value; // Update parameter value
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxFormField(Parameter parameter) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.prompt,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(parameter.options!.length, (index) {
              final option = parameter.options![index];
              return CheckboxListTile(
                title: Text(option),
                selected: _isCheckedList[index],
                value: _isCheckedList[index],
                onChanged: (value) {
                  setState(() {
                    _isCheckedList[index] = value ?? false;
                    if (_isCheckedList[index]) {
                      _selectedOptions
                          .add(option); // Add the selected option to the list
                    } else {
                      _selectedOptions
                          .remove(option); // Remove the option if unchecked
                    }
                    parameter.value = _selectedOptions.join(', ');
                    if (!updatedParametersList.contains(parameter)) {
                      updatedParametersList.add(parameter);
                    }
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
