import 'Observation.dart';
import 'parameter.dart';

class Project {
  final String code;
  final String description;
  final int id;
  final List<Observation> observations;
  final List<Parameter> parameters;
  final String title;
  final String user;

  Project({
    required this.code,
    required this.description,
    required this.id,
    required this.observations,
    required this.parameters,
    required this.title,
    required this.user,
  });

factory Project.fromJson(Map<String, dynamic> json) {
  List<Observation> observationsList = [];
  List<Parameter> parameters = [];

  if (json['observations_list'] is List) {
    for (var observation in json['observations_list']) {
      observationsList.add(Observation.fromJson(observation));
    }
  }

if (json['parameters'] is List) {
    for (var parameter in json['parameters']) {
      parameters.add(Parameter.fromJson(parameter));
    }
  }
    return Project(
      code: json['code'],
      description: json['description'],
      id: json['id'] ?? 0,
      observations: observationsList,
      parameters: parameters,
      title: json['title'],
      user: json['user'],
    );
  }
}