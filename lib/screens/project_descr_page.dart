import 'package:flutter/material.dart';
import 'observationsListPage.dart';

class ProjectExplanationPage extends StatelessWidget {
  final dynamic project;
  const ProjectExplanationPage({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Description'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/image4.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              // Display the API response received from the previous page
              // Extract title and description from the parsed JSON
              Text(
                '${project.title}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromARGB(
                      255, 98, 175, 114), // Use plant green color
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                '${project.description}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87, // Description color
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Observations Page when the button is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ObservationsPage(project: project)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 98, 175, 114), // Button color
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Button border radius
                  ),
                ),
                child: const Text(
                  'Go to Observations',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white, // Button text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
