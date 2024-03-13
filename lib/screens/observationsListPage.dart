import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/Observation.dart';
import 'package:flutter_application_1/screens/edit_observation.dart';
import 'add_observations_page.dart';

class ObservationsPage extends StatefulWidget {
  final dynamic project;
  const ObservationsPage({Key? key, required this.project}) : super(key: key);
  @override
  _ObservationsPageState createState() => _ObservationsPageState();
}

class _ObservationsPageState extends State<ObservationsPage> {
  @override
  Widget build(BuildContext context) {
    List<Observation> observations = widget.project.observations ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations List'),
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/image4.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18),
                    children: <TextSpan>[
                      // TextSpan(text: 'Hi Mark,', style: TextStyle(color: Color.fromARGB(255, 15, 15, 14))),
                      // TextSpan(text: '\n'),
                      TextSpan(
                          text:
                              "Hey there!\nLet's have fun exploring and adding cool observations together! 😊",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 243, 110, 9),
                          )),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: observations.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.grey[300], // Divider color
                      thickness: 1, // Divider thickness
                      height: 1, // Divider height
                    );
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 87, 95, 103)),
                                  children: <TextSpan>[
                                    const TextSpan(text: 'Observation: '),
                                    TextSpan(
                                        text: '${observations[index].id}',
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 35, 124, 5))),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  //style: DefaultTextStyle.of(context).style,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 87, 95, 103)),
                                  children: <TextSpan>[
                                    const TextSpan(text: 'Time added: '),
                                    TextSpan(
                                        text: '${observations[index].timeDate}',
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 35, 124, 5))),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  // Navigate to EditObservationPage and wait for result
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditObservationPage(
                                                project: widget.project,
                                                observationIndex: index)),
                                  );

                                  // If result is not null (i.e., user saved an edited observation), update the list
                                  if (result != null) {
                                    setState(() {
                                      // Update the observation at index 'index' with the edited observation 'result'
                                      observations[index] = result;
                                    });
                                  }
                                },
                              ),
                              // IconButton(
                              //   icon: const Icon(Icons.delete),
                              //   onPressed: () {
                              //     // Handle delete button click
                              //     //_showDeleteConfirmationDialog(index);
                              //   },
                              // ),
                            ],
                          ),
                        ],
                      ),
                      // You can customize the ListTile further as needed
                    );
                  },
                ),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to AddObservationPage and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddObservationPage(project: widget.project)),
          );

          // If result is not null (i.e., user saved a new observation), update the list
          if (result != null) {
            setState(() {
              observations.add(result);
            });
          }
        },
        label: const Text('Add more',
            style: TextStyle(
                color: Colors.white, fontSize: 16)), // Set text color to white
        icon: const Icon(Icons.add,
            color: Colors.white), // Set icon color to white
        backgroundColor: const Color.fromARGB(255, 98, 175, 114),
      ),
    );
  }
}
//   void _showDeleteConfirmationDialog(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Observation'),
//           content: const Text('Are you sure you want to delete this observation?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   observations.removeAt(index);
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
