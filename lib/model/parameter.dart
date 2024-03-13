class Parameter {
  final String observationType;
  List<String>? options;
  final String prompt;
  String value;
  final String comment;

  Parameter({
    required this.observationType,
    required this.options,
    required this.prompt,
    required this.value,
    required this.comment,
  }) {
    // If observationType is "dropdown" and options are not empty, initialize value with the first option
    if (observationType == "Dropdown" &&
        options != null &&
        options!.isNotEmpty) {
      value = options![0];
    }
  }

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      observationType: json['observation_type'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : [],
      prompt: json['prompt'],
      value: json['value'] != null ? (json['value'] is List? json['value'].join(', ') : json['value']) : "defaultValue",
      comment: json['comment'] ?? 'DefaultComment',
    );
  }

  Map<String, dynamic> toJson() {
    if (observationType == 'Checklist') {
      // Parse the value string into an array of options
     List<String> optionsList = (value.isNotEmpty) ? value.split(',').map((e) => e.trim()).toList() : [];
      return {
        'observation_type': observationType,
        'prompt': prompt,
        'value': optionsList, // Assign the array of options to the value
      };
    } else {
      // For other observation types, directly return the object properties
      return {
        'observation_type': observationType,
        //'options': options,
        'prompt': prompt,
        'value': value,
        //'comment': comment,
      };
    }
  }
}
