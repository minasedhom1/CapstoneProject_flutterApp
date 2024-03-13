import 'parameter.dart';

class Observation {
  final String? id;
  final List<Parameter>? observationParams;
  final String studentId;
  final String timeDate;

  Observation(
      {this.id,
      required this.observationParams,
      required this.studentId,
      required this.timeDate});

  factory Observation.fromJson(Map<String, dynamic> json) {
    List<Parameter> parameters = [];
    if (json['observation_parameters'] is List) {
      for (var parameter in json['observation_parameters']) {
        parameters.add(Parameter.fromJson(parameter));
      }
    }

    return Observation(
      id: json["id"].toString(),
      observationParams: parameters,
      studentId: json['student_id'].toString(),
      timeDate: json['time_date'],
    );
  }
}
