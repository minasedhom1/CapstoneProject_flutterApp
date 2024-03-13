import 'dart:convert';
import 'package:flutter_application_1/model/global_vars.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/project.dart';
import 'project_descr_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TextEditingController projectCodeController =
      TextEditingController(text: "AVD43");
  TextEditingController studentIdController =
      TextEditingController(text: "11111111");
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    List<String> testProjects = ['AVD43', 'B4F41', '7NIQ5', 'MR4YF', 'X7ZUE'];
    List<String> testStudents = ['11111111', '22222222', '33333333'];

    String dropdownValue =
        testProjects.first; // Set initial value to the first item
    String dropdownValue2 = testStudents.first;
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent the content from resizing when the keyboard appears
      backgroundColor:
          Colors.transparent, // Make the scaffold background transparent
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/image1.jpg'), // Replace 'assets/background_image.jpg' with your image path
                fit: BoxFit
                    .cover, // Ensure that the background image covers the entire container
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 100),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Citizen Science App',
                      style: TextStyle(
                        fontSize: 36,
                        color: Color.fromARGB(255, 98, 175, 114),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Row(children: [
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Test Projects', // Add label to the dropdown
                      ),
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          projectCodeController.text =
                              newValue; // Update the projectCodeController with the selected value
                        });
                      },
                      items: testProjects.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Test Students', // Add label to the dropdown
                      ),
                      value: dropdownValue2,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue2 = newValue!;
                          studentIdController.text =
                              newValue; // Update the projectCodeController with the selected value
                        });
                      },
                      items: testStudents.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                  ]),
                  const SizedBox(height: 20),
                  TextField(
                    controller: projectCodeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your project code here',
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: studentIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your student ID',
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : fetchData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 16), // Adjust vertical padding
                      minimumSize: Size(double.infinity,
                          30), // Set minimum button width and height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Set border radius for a square shape
                      ),
                      backgroundColor: Color.fromARGB(255, 98, 175, 114),
                    ),
                    child: const Text('Submit',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  if (isLoading)
                    const Center(
                      child:
                          CircularProgressIndicator(), // Display CircularProgressIndicator when isLoading is true
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetchData() async {
    setState(() {
      isLoading = true; // Set loading state to true when button is pressed
    });

    // Get the code and student ID from the respective TextFields
    Globals.projectCode = projectCodeController.text;
    Globals.studentId = studentIdController.text;

    if (Globals.projectCode.isEmpty || Globals.studentId.isEmpty) {
      // Show error message if project code or student ID is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter both project code and student ID before submitting..')),
      );
      setState(() {
        isLoading = false; // Set loading state to false
      });
      return;
    }

    // Construct the URL by appending the code and student ID
    String url =
        'https://capstone-citizen-science.wl.r.appspot.com/projects/${Globals.projectCode}/observations/${Globals.studentId}';

    try {
      // Perform the GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON data
        final responseData = json.decode(response.body);

        if (responseData is List) {
          // Handle the response as needed
          List<Project> projects = (responseData as List)
              .map((item) => Project.fromJson(item))
              .toList();

          // Navigate to the new page (ProjectExplanationPage) when the button is clicked
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProjectExplanationPage(project: projects[0])),
          );
        } else {
          // Handle unexpected response type
          print('Unexpected response type: ${responseData.runtimeType}');
        }
      } else {
        // If the server did not return a 200 OK response, display an error
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching data. Please try again later.')),
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }
}
