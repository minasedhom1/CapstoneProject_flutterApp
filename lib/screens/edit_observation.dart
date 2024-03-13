import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/Observation.dart';
import 'package:flutter_application_1/model/global_vars.dart';
import '../model/parameter.dart';
import 'package:http/http.dart' as http;

class EditObservationPage extends StatefulWidget {
  final dynamic project;
  final int observationIndex;
  const EditObservationPage({
    Key? key,
    required this.project,
    required this.observationIndex,
  }) : super(key: key);

  @override
  _EditObservationPageState createState() => _EditObservationPageState();
}

class _EditObservationPageState extends State<EditObservationPage> {
  // value set to false
  late List<bool> _isCheckedList;
  List<String> _selectedOptions = [];
  List<Parameter> updatedParametersList = [];
  bool hasChecklist = false;

  @override
  void initState() {
    super.initState();
    _isCheckedList = List.filled(10, false);
    updatedParametersList =
        widget.project.observations[widget.observationIndex].observationParams;
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
        title: const Text('Edit Observation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.project.parameters.length,
              itemBuilder: (context, index) {
                final parameter = widget
                    .project
                    .observations[widget.observationIndex]
                    .observationParams[index];
                return _buildFormField(parameter);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 98, 175, 114),
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
                    String obs_id = widget
                        .project.observations[widget.observationIndex].id!;
                    Map<String, dynamic> requestBody = {
                      "id": obs_id,
                      "observation_parameters": parameterJsonList,
                    };

                    // Encode the new map to JSON format
                    String requestBodyJson = jsonEncode(requestBody);
                    print('Body: $requestBodyJson');
                    // Make the PUT request
                    final response = await http.put(
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
                          content: Text('Observation edited successfully'),
                        ),
                      );

                      Observation observation =
                          Observation.fromJson(json.decode(response.body));

                      //get options for new observation
                      for (int i = 0;
                          i <
                              widget.project.observations[0].observationParams
                                  .length;
                          i++) {
                        observation.observationParams?[i].options = widget
                            .project
                            .observations[0]
                            .observationParams[i]
                            .options;
                      }
                      // Navigate back after a delay
                      Future.delayed(const Duration(seconds: 1), () {
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
              child: const Text('Save Observation',
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
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
      // Add more cases for other observation types if needed
      case 'Text':
        return _buildTextFormField(parameter);
      default:
        return Container(); // Return an empty container if observation type is not recognized
    }
  }

  Widget _buildNumericalFormField(Parameter parameter) {
    TextEditingController controller =
        TextEditingController(text: parameter.value);
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
              controller:
                  controller, // Set the initial value using the controller
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: parameter.options!.contains(parameter.value)
                ? parameter.value
                : parameter.options!
                    .first, // Choose the passed value if found in options, otherwise choose the first option
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
    TextEditingController controller =
        TextEditingController(text: parameter.value);
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
            controller: controller,
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
    final valueList = parameter.value.split(',').map((e) => e.trim()).toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
              _isCheckedList[index] = valueList.contains(option);
              if (_isCheckedList[index] && !_selectedOptions.contains(option)) {
                _selectedOptions
                    .add(option); // Add the selected option to the list
              }
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
                    //new updated values
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


// Widget _buildFormField(Parameter parameter) {
//     final String observationType = parameter.observationType;
//     final List<String>? options = parameter.options;
//     final String prompt = parameter.prompt;
//     final String value = parameter.value;

//     switch (observationType) {
//       case 'Numerical':
//         return _buildNumericalFormField(prompt, value);
//       case 'Checkbox':
//         return _buildCheckboxFormField(prompt, options!);
//       case 'Dropdown':
//       return _buildDropdownFormField(prompt,options!, value);
//       // Add more cases for other observation types if needed
//       default:
//         return Container(); // Return an empty container if observation type is not recognized
//     }
//   }

// Widget _buildNumericalFormField(String prompt, String value) {
// TextEditingController controller = TextEditingController(text: value);
//   return Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: TextField(
//       controller: controller, // Set the initial value using the controller
//       decoration: InputDecoration(
//         labelText: prompt,
//         labelStyle: TextStyle(fontWeight: FontWeight.bold), // Apply bold font style
//       ),
//       keyboardType: TextInputType.number,
//     ),
//   );
//   }

//   Widget _buildDropdownFormField(String prompt, List<String> options, String value) {
//   return Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: prompt,
//         labelStyle: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       value: options.contains(value) ? value : options.first, // Choose the passed value if found in options, otherwise choose the first option
//       items: options.map((option) {
//         return DropdownMenuItem(
//           value: option,
//           child: Text(option),
//         );
//       }).toList(),
//       onChanged: (value) {
//         // Handle dropdown value changes here
//       },
//     ),
//   );
// }

// Widget _buildTextFormField(String prompt) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         decoration: InputDecoration(
//           labelText: prompt,
//           labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Apply bold font style
//         ),
//       ),
//     );
//   }

// Widget _buildCheckboxFormField(String prompt, List<String> options) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             prompt,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(options.length, (index) {
//               final option = options[index];
//               return CheckboxListTile(
//                 title: Text(option),
//                 selected: _isCheckedList[index],
//                 value: _isCheckedList[index],
//                 onChanged: (value) {
//                   setState(() {
//                     _isCheckedList[index] = value ?? false;
//                   });
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
